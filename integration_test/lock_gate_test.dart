import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_journal_vault/app/app.dart';
import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/features/journal_lock/services/journal_password_service.dart';
import 'package:sreerajp_journal_vault/features/journal_lock/services/journal_secret_store.dart';
import 'package:sreerajp_journal_vault/features/lock_gate/providers/lock_gate_providers.dart';
import 'package:sreerajp_journal_vault/features/lock_gate/services/app_pin_keystore.dart';
import 'package:sreerajp_journal_vault/features/lock_gate/services/app_pin_service.dart';
import 'package:sreerajp_journal_vault/features/lock_gate/services/biometric_authenticator.dart';

/// End-to-end coverage of the V1 app-lock gate.
///
/// Walks through: cold launch → wrong PIN denied → right PIN unlocks →
/// background pause → relock → simulated restart → still locked.
///
/// Uses [TestWidgetsFlutterBinding] (not the on-device integration_test
/// binding) so the suite runs as part of `flutter test integration_test/`
/// alongside the host widget tests, without requiring a device.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('App-lock gate denies wrong PIN, accepts right, relocks on '
      'background, and stays locked across restart', (tester) async {
    // Shared persistent fixtures across the simulated restart.
    final database = AppDatabase.forExecutor(NativeDatabase.memory());
    final keystore = _InMemoryAppPinKeystore();
    final biometric = _FakeBiometricAuthenticator();

    // Seed a known PIN credential so we don't have to walk the first-launch
    // setup screen on every cold start.
    final pinService = AppPinService(keystore: keystore);
    await pinService.setPin('1234');

    // Seed app_lock mode so the lock gate is the first screen on cold start.
    await database.appSecurityDao.updateLockState(
      const AppSecurityCompanion(
        lockMode: Value('app_lock'),
        isLocked: Value(true),
      ),
    );

    Future<void> pumpAppLockApp() async {
      await tester.pumpWidget(
        JournalVaultAppHost(
          database: database,
          overrides: <Override>[
            biometricAuthenticatorProvider.overrideWithValue(biometric),
            appPinKeystoreProvider.overrideWithValue(keystore),
          ],
        ),
      );
      await tester.pumpAndSettle();
    }

    // ── Cold launch is locked ─────────────────────────────────────────
    await pumpAppLockApp();
    expect(find.text('App Lock Gate'), findsOneWidget);
    expect(find.text('Separate App Lock'), findsOneWidget);
    expect(find.byKey(const Key('app-lock-pin-field')), findsOneWidget);

    // ── Wrong PIN is denied ───────────────────────────────────────────
    await tester.enterText(find.byKey(const Key('app-lock-pin-field')), '0000');
    await tester.tap(find.byKey(const Key('app-lock-unlock-button')));
    await tester.pumpAndSettle();
    expect(find.text('Incorrect PIN.'), findsOneWidget);
    expect(find.text('App Lock Gate'), findsOneWidget);

    // ── Right PIN unlocks ─────────────────────────────────────────────
    await tester.enterText(find.byKey(const Key('app-lock-pin-field')), '1234');
    await tester.tap(find.byKey(const Key('app-lock-unlock-button')));
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsWidgets);
    expect(find.text('App Lock Gate'), findsNothing);

    // ── Background pause → relock ────────────────────────────────────
    for (final state in const [
      AppLifecycleState.paused,
      AppLifecycleState.hidden,
      AppLifecycleState.inactive,
      AppLifecycleState.resumed,
    ]) {
      tester.binding.handleAppLifecycleStateChanged(state);
      await tester.pumpAndSettle();
    }
    expect(find.text('App Lock Gate'), findsOneWidget);

    // Confirm DB persisted isLocked=true on pause.
    final settingsAfterPause = await database.appSecurityDao
        .getSecuritySettings();
    expect(settingsAfterPause.isLocked, isTrue);

    // ── Simulated restart — still locked ─────────────────────────────
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    await pumpAppLockApp();

    expect(find.text('App Lock Gate'), findsOneWidget);
    expect(find.byKey(const Key('app-lock-pin-field')), findsOneWidget);

    // Right PIN still unlocks after restart.
    await tester.enterText(find.byKey(const Key('app-lock-pin-field')), '1234');
    await tester.tap(find.byKey(const Key('app-lock-unlock-button')));
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsWidgets);

    await database.close();
  });

  testWidgets('Phone-lock mode requires biometric success to unlock', (
    tester,
  ) async {
    final database = AppDatabase.forExecutor(NativeDatabase.memory());
    final keystore = _InMemoryAppPinKeystore();
    final biometric = _FakeBiometricAuthenticator();

    await database.appSecurityDao.updateLockState(
      const AppSecurityCompanion(
        lockMode: Value('phone_lock'),
        isLocked: Value(true),
      ),
    );

    await tester.pumpWidget(
      JournalVaultAppHost(
        database: database,
        overrides: <Override>[
          biometricAuthenticatorProvider.overrideWithValue(biometric),
          appPinKeystoreProvider.overrideWithValue(keystore),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Phone Lock'), findsOneWidget);

    // Failure path: biometric returns failed → still locked.
    biometric.nextResult = BiometricAuthResult.failed;
    await tester.tap(find.byKey(const Key('phone-lock-unlock-button')));
    await tester.pumpAndSettle();
    expect(find.text('App Lock Gate'), findsOneWidget);
    expect(
      find.text('Authentication failed. Please try again.'),
      findsOneWidget,
    );

    // Success path: biometric returns success → unlocks.
    biometric.nextResult = BiometricAuthResult.success;
    await tester.tap(find.byKey(const Key('phone-lock-unlock-button')));
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsWidgets);

    await database.close();
  });

  testWidgets(
    'Locked journal secrets persist across app restart via the secret store',
    (tester) async {
      // The persistent fixtures (DB + secret store + pin keystore) survive the
      // pumpWidget(SizedBox.shrink) "restart", standing in for the platform
      // Keystore that would persist across a real process kill.
      final database = AppDatabase.forExecutor(NativeDatabase.memory());
      final keystore = _InMemoryAppPinKeystore();
      final biometric = _FakeBiometricAuthenticator();
      final secretStore = _PersistentJournalSecretStore();

      await database.appSecurityDao.updateLockState(
        const AppSecurityCompanion(
          lockMode: Value('phone_lock'),
          isLocked: Value(true),
        ),
      );

      Future<void> pumpAppWithSecretStore() async {
        await tester.pumpWidget(
          JournalVaultAppHost(
            database: database,
            overrides: <Override>[
              biometricAuthenticatorProvider.overrideWithValue(biometric),
              appPinKeystoreProvider.overrideWithValue(keystore),
              journalSecretStoreProvider.overrideWithValue(secretStore),
            ],
          ),
        );
        await tester.pumpAndSettle();
      }

      // ── First session: create a locked journal ───────────────────────
      await pumpAppWithSecretStore();
      await tester.tap(find.byKey(const Key('phone-lock-unlock-button')));
      await tester.pumpAndSettle();

      // Create the locked journal directly through the password service so we
      // do not depend on the journal-form dialog UI.
      final passwordService = JournalPasswordService(secretStore: secretStore);
      final journalId = await database.journalsDao.createJournal(
        JournalsCompanion.insert(title: 'Vault'),
      );
      final credential = await passwordService.createCredential(
        journalId: journalId,
        password: 'corner-stone',
      );
      await database.journalsDao.updateJournalById(
        journalId,
        JournalsCompanion(
          isLocked: const Value(true),
          credentialReference: Value(credential.credentialReference),
          passwordSaltBase64: Value(credential.passwordSaltBase64),
          passwordVerifierBase64: Value(credential.passwordVerifierBase64),
          passwordIterations: Value(credential.passwordIterations),
        ),
      );

      // Sanity check that the secret was actually written through the store.
      expect(
        secretStore.contains(credential.credentialReference),
        isTrue,
        reason: 'createCredential must persist the DEK via the secret store',
      );

      // ── Simulated restart ───────────────────────────────────────────
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      await pumpAppWithSecretStore();

      expect(find.text('App Lock Gate'), findsOneWidget);
      await tester.tap(find.byKey(const Key('phone-lock-unlock-button')));
      await tester.pumpAndSettle();

      // ── Wrong password denied, right password unlocks the journal ───
      await tester.tap(find.text('Vault'));
      await tester.pumpAndSettle();
      expect(find.text('Journal is locked'), findsOneWidget);

      await tester.enterText(
        find.byKey(const Key('journal-unlock-password-field')),
        'wrong-pass',
      );
      await tester.tap(find.byKey(const Key('journal-unlock-button')));
      await tester.pumpAndSettle();
      expect(find.text('Incorrect password.'), findsOneWidget);

      await tester.enterText(
        find.byKey(const Key('journal-unlock-password-field')),
        'corner-stone',
      );
      await tester.tap(find.byKey(const Key('journal-unlock-button')));
      await tester.pumpAndSettle();
      expect(find.text('Add entry'), findsOneWidget);

      // The DEK must be loadable from the store — proving persistence beyond
      // the in-memory default.
      final reloaded = await secretStore.loadSecret(
        credential.credentialReference,
      );
      expect(reloaded, hasLength(32));

      await database.close();
    },
  );
}

/// A [JournalSecretStore] backed by a plain map. Stands in for the platform
/// Keystore: the underlying state lives in [_secrets], so it survives the
/// `pumpWidget(SizedBox)` "restart" while still being a pure-Dart fake.
class _PersistentJournalSecretStore implements JournalSecretStore {
  final Map<String, List<int>> _secrets = {};

  bool contains(String credentialReference) =>
      _secrets.containsKey(credentialReference);

  @override
  Future<List<int>> createSecret(String credentialReference) async {
    final bytes = List<int>.generate(32, (i) => (i * 7 + 11) % 256);
    _secrets[credentialReference] = bytes;
    return bytes;
  }

  @override
  Future<List<int>> loadSecret(String credentialReference) async {
    final bytes = _secrets[credentialReference];
    if (bytes == null) {
      throw JournalSecretUnavailableException(credentialReference);
    }
    return bytes;
  }

  @override
  Future<void> deleteSecret(String credentialReference) async {
    _secrets.remove(credentialReference);
  }
}

class _FakeBiometricAuthenticator implements BiometricAuthenticator {
  BiometricAuthResult nextResult = BiometricAuthResult.success;

  @override
  Future<bool> canAuthenticate() async => true;

  @override
  Future<BiometricAuthResult> authenticate({required String reason}) async =>
      nextResult;
}

class _InMemoryAppPinKeystore implements AppPinKeystore {
  AppPinCredentialPayload? _stored;

  @override
  Future<AppPinCredentialPayload?> getCredential() async => _stored;

  @override
  Future<void> setCredential({
    required String saltBase64,
    required String verifierBase64,
    required int iterations,
  }) async {
    _stored = AppPinCredentialPayload(
      saltBase64: saltBase64,
      verifierBase64: verifierBase64,
      iterations: iterations,
    );
  }

  @override
  Future<void> clearCredential() async {
    _stored = null;
  }
}
