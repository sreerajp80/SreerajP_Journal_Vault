import 'dart:async';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_journal_vault/app/app.dart';
import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/features/attachments/providers/attachment_providers.dart';
import 'package:sreerajp_journal_vault/features/attachments/services/attachment_crypto_storage.dart';
import 'package:sreerajp_journal_vault/features/lock_gate/providers/lock_gate_providers.dart';
import 'package:sreerajp_journal_vault/features/lock_gate/services/app_pin_keystore.dart';
import 'package:sreerajp_journal_vault/features/lock_gate/services/biometric_authenticator.dart';
import 'package:sreerajp_journal_vault/features/permissions/domain/app_permission_models.dart';
import 'package:sreerajp_journal_vault/features/permissions/providers/permissions_providers.dart';
import 'package:sreerajp_journal_vault/features/permissions/services/app_permissions_service.dart';
import 'package:sreerajp_journal_vault/features/security/providers/security_providers.dart';

void main() {
  late AppDatabase database;
  late _FakeBiometric fakeBiometric;
  late _InMemoryPinKeystore fakeKeystore;
  late _FakePermissionsService fakePermissions;

  setUp(() async {
    database = AppDatabase.forExecutor(NativeDatabase.memory());
    fakeBiometric = _FakeBiometric();
    fakeKeystore = _InMemoryPinKeystore();
    fakePermissions = _FakePermissionsService();
    await database.appSecurityDao.updateLockState(
      const AppSecurityCompanion(
        lockMode: Value('phone_lock'),
        isLocked: Value(true),
      ),
    );
  });

  tearDown(() async {
    await database.close();
  });

  Future<void> pumpApp(
    WidgetTester tester, {
    AttachmentCryptoStorage? cryptoStorage,
    List<Override> extraOverrides = const [],
  }) async {
    // Tall enough that every section header, including About at the bottom,
    // is laid out — the Security section grew a screenshot-blocking switch.
    await tester.binding.setSurfaceSize(const Size(800, 1800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      JournalVaultAppHost(
        database: database,
        overrides: <Override>[
          biometricAuthenticatorProvider.overrideWithValue(fakeBiometric),
          appPinKeystoreProvider.overrideWithValue(fakeKeystore),
          appPermissionsServiceProvider.overrideWithValue(fakePermissions),
          tamperEventsProvider.overrideWith(
            (ref) => Stream.value(<SecurityEvent>[]),
          ),
          recentSecurityEventsProvider.overrideWith(
            (ref) => Stream.value(<SecurityEvent>[]),
          ),
          if (cryptoStorage != null)
            attachmentCryptoStorageProvider.overrideWithValue(cryptoStorage),
          ...extraOverrides,
        ],
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('phone-lock-unlock-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
  }

  /// Opens one Settings section page by tapping its card.
  Future<void> openSection(WidgetTester tester, String section) async {
    await tester.tap(find.byKey(Key('settings-card-$section')));
    await tester.pumpAndSettle();
  }

  testWidgets('renders all seven section cards in the plan-defined order', (
    tester,
  ) async {
    await pumpApp(tester);

    const cards = [
      ('settings-card-security', 'Security'),
      ('settings-card-appearance', 'Appearance'),
      ('settings-card-storage', 'Storage'),
      ('settings-card-features', 'Features'),
      ('settings-card-permissions', 'Permissions'),
      ('settings-card-help', 'Help'),
      ('settings-card-about', 'About'),
    ];

    // Verify ordering by Y position so we catch out-of-order rebuilds.
    final positions = <double>[];
    for (final (key, title) in cards) {
      final finder = find.byKey(Key(key));
      expect(finder, findsOneWidget, reason: '$title card missing');
      expect(find.text(title), findsOneWidget, reason: '$title title missing');
      positions.add(tester.getTopLeft(finder).dy);
    }
    for (var i = 1; i < positions.length; i++) {
      expect(
        positions[i - 1] < positions[i],
        isTrue,
        reason: '${cards[i].$2} card is out of order',
      );
    }

    // Section content now lives behind its card, not on the home screen.
    expect(find.byKey(const Key('settings-screen-security')), findsNothing);
  });

  testWidgets('Security card opens a page holding every security row', (
    tester,
  ) async {
    await pumpApp(tester);
    await openSection(tester, 'security');

    expect(find.text('Auto-Lock Timeout'), findsOneWidget);
    expect(find.text('Attachment-Level Lock'), findsOneWidget);
    expect(find.text('Tamper Alerts'), findsOneWidget);
    // Tamper Alerts has its own screen; sync rows have no dead stubs when disabled.
    expect(find.text('Coming soon'), findsNothing);

    // Security rows.
    expect(find.byKey(const Key('settings-auto-lock-timeout')), findsOneWidget);
    expect(
      find.byKey(const Key('settings-attachment-level-lock')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('settings-tamper-alerts')), findsOneWidget);
    expect(find.byKey(const Key('settings-security-events')), findsOneWidget);
    expect(find.byKey(const Key('settings-screen-security')), findsOneWidget);
  });

  testWidgets('Tamper Alerts tile pushes the TamperAlertsScreen', (
    tester,
  ) async {
    await pumpApp(tester);
    await openSection(tester, 'security');

    await tester.tap(find.byKey(const Key('settings-tamper-alerts')));
    await tester.pumpAndSettle();

    expect(find.text('Tamper Alerts'), findsWidgets);
    expect(find.text('Vault Integrity Verified'), findsOneWidget);
    expect(
      find.byKey(const Key('tamper-alerts-verify-button')),
      findsOneWidget,
    );
  });

  testWidgets('Appearance card opens the appearance hub', (tester) async {
    await pumpApp(tester);
    await openSection(tester, 'appearance');

    expect(find.byKey(const Key('appearance-card-theme-mode')), findsOneWidget);
    expect(
      find.byKey(const Key('appearance-card-accent-color')),
      findsOneWidget,
    );

    // Tap theme mode card
    await tester.tap(find.byKey(const Key('appearance-card-theme-mode')));
    await tester.pumpAndSettle();

    expect(find.text('Light'), findsOneWidget);
    expect(find.text('Dark'), findsOneWidget);
    expect(find.text('System'), findsOneWidget);
  });

  testWidgets('Features card opens the features catalog', (tester) async {
    await pumpApp(tester);
    await openSection(tester, 'features');

    expect(find.text('SreerajP Journal Vault Features'), findsOneWidget);
    expect(find.text('JOURNALING & RICH TEXT EDITOR'), findsOneWidget);
    expect(find.text('PRIVACY, ENCRYPTION & VAULT SECURITY'), findsOneWidget);
    expect(find.text('Quill Rich Text Editor'), findsOneWidget);
    expect(find.text('SQLCipher AES-256 Database Encryption'), findsOneWidget);
  });

  testWidgets('Help card opens the help center', (tester) async {
    await pumpApp(tester);
    await openSection(tester, 'help');

    expect(find.text('Help Center & Knowledge Base'), findsOneWidget);
    expect(find.text('WRITING & JOURNAL MANAGEMENT'), findsOneWidget);
    expect(find.text('SECURITY, LOCK & ENCRYPTION'), findsOneWidget);
    expect(find.text('Journal Organization & Templates'), findsOneWidget);

    await tester.tap(find.text('Journal Organization & Templates'));
    await tester.pumpAndSettle();

    expect(find.text('Multiple Separate Journals'), findsOneWidget);
  });

  testWidgets('Storage card opens a page holding every storage row', (
    tester,
  ) async {
    await pumpApp(tester);
    await openSection(tester, 'storage');

    // Storage rows (C2 Backup Health, Import Data + D1 Sync Health).
    expect(
      find.byKey(const Key('settings-attachment-storage-location')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('settings-migrate-storage')), findsOneWidget);
    expect(find.byKey(const Key('settings-storage-usage')), findsOneWidget);
    expect(find.byKey(const Key('settings-backup-health')), findsOneWidget);
    expect(find.byKey(const Key('settings-import-data')), findsOneWidget);
    // Gated off: the sync row is not rendered when sync UI is disabled.
    expect(find.byKey(const Key('settings-sync-health')), findsNothing);
    expect(find.text('Sync Health'), findsNothing);
    expect(find.text('Coming soon'), findsNothing);
  });

  testWidgets('Permissions card opens a page holding every permissions row', (
    tester,
  ) async {
    await pumpApp(tester);
    await openSection(tester, 'permissions');

    expect(
      find.byKey(const Key('settings-permissions-status')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('settings-manage-permissions')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('settings-open-system-settings')),
      findsOneWidget,
    );
  });

  testWidgets('Manage Permissions tile pushes the PermissionsScreen', (
    tester,
  ) async {
    await pumpApp(tester);
    await openSection(tester, 'permissions');

    await tester.tap(find.byKey(const Key('settings-manage-permissions')));
    await tester.pumpAndSettle();

    expect(find.text('Permissions'), findsWidgets);
    expect(find.text('Attachment import'), findsOneWidget);
  });

  testWidgets('Backup Health tile pushes the BackupHealthScreen', (
    tester,
  ) async {
    await pumpApp(tester);
    await openSection(tester, 'storage');

    await tester.tap(find.byKey(const Key('settings-backup-health')));
    // BackupHealthScreen has an animated entry, so pump a few frames rather
    // than pumpAndSettle (its providers re-poll periodically and never idle).
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(AppBar), findsOneWidget);
    expect(
      find.text('Settings').evaluate().isEmpty,
      isTrue,
      reason: 'BackupHealthScreen replaced the Settings AppBar',
    );
  });

  testWidgets(
    'Import Data tile asks user to pick a journal then pushes ImportScreen',
    (tester) async {
      await database.journalsDao.createJournal(
        JournalsCompanion.insert(title: 'Inbox'),
      );
      await pumpApp(tester);
      await openSection(tester, 'storage');

      await tester.tap(find.byKey(const Key('settings-import-data')));
      await tester.pumpAndSettle();

      expect(find.text('Import into journal'), findsOneWidget);
      await tester.tap(find.text('Inbox'));
      await tester.pumpAndSettle();

      expect(find.text('Import into "Inbox"'), findsOneWidget);
    },
  );

  testWidgets('Import Data with no journals prompts the user to create one', (
    tester,
  ) async {
    await pumpApp(tester);
    await openSection(tester, 'storage');

    await tester.tap(find.byKey(const Key('settings-import-data')));
    await tester.pumpAndSettle();

    expect(find.text('Create a journal first to import into.'), findsOneWidget);
  });

  testWidgets('Migrate Storage flow renders progress and supports cancel', (
    tester,
  ) async {
    // Seed 3 attachments so the migration loop has work to do.
    final journalId = await database.journalsDao.createJournal(
      JournalsCompanion.insert(title: 'Journal'),
    );
    final entryId = await database.entriesDao.createEntry(
      EntriesCompanion.insert(
        journalId: journalId,
        title: const Value('Entry'),
        contentJson: const Value('[{"insert":"hi\\n"}]'),
      ),
    );
    for (var i = 0; i < 3; i++) {
      await database.attachmentsDao.createAttachment(
        AttachmentsCompanion.insert(
          entryId: entryId,
          fileName: 'file-$i.bin',
          mimeType: const Value('application/octet-stream'),
          encryptedPath: 'app_private/file-$i.enc',
          nonceBase64: 'nonce',
          keyReference: 'key',
          sizeBytes: 1024 * (i + 1),
        ),
      );
    }

    final cryptoStorage = _SlowCryptoStorage();
    await pumpApp(tester, cryptoStorage: cryptoStorage);
    await openSection(tester, 'storage');

    // Open the storage location dialog and choose SD Card. The picker
    // override returns null (user cancel) by default — wire a fake picker
    // first.
    // Instead of going through the location dialog, retry-style we trigger
    // by switching to App Private (no picker). Use SD Card via tree picker
    // would need a platform channel; here we just invoke "Migrate Storage"
    // directly by faking a failed migration target.
    //
    // Force a failed migration target so the Retry button appears.
    await database.appSettingsDao.updateSettings(
      const AppSettingsCompanion(
        attachmentMigrationStatus: Value('failed'),
        attachmentMigrationTarget: Value('app_private'),
        attachmentMigrationFailure: Value('Earlier run interrupted.'),
      ),
    );
    // Force the Storage section to reload by leaving and reopening its page.
    await tester.pageBack();
    await tester.pumpAndSettle();
    await openSection(tester, 'storage');

    // Tap Retry → progress dialog opens, blocked on cryptoStorage.
    cryptoStorage.holdMigration = true;
    await tester.tap(find.byKey(const Key('settings-migrate-storage-retry')));
    await tester.pump();

    expect(find.text('Migrating attachments'), findsOneWidget);
    expect(find.byKey(const Key('migration-cancel-button')), findsOneWidget);

    // Cancel mid-flight.
    await tester.tap(find.byKey(const Key('migration-cancel-button')));
    await tester.pump();
    expect(find.text('Cancelling…'), findsOneWidget);

    // Release the held migration so the loop resumes and observes cancel.
    cryptoStorage.holdMigration = false;
    cryptoStorage.releaseAll();
    await tester.pumpAndSettle();

    // Snackbar acknowledges the cancellation; dialog has closed.
    expect(find.text('Migration cancelled.'), findsOneWidget);
    expect(find.text('Migrating attachments'), findsNothing);

    final settings = await database.appSettingsDao.getSettings();
    expect(settings.attachmentMigrationStatus, 'failed');
    expect(settings.attachmentMigrationFailure, contains('cancelled'));
  });
}

class _FakeBiometric implements BiometricAuthenticator {
  @override
  Future<bool> canAuthenticate() async => true;

  @override
  Future<BiometricAuthResult> authenticate({required String reason}) async =>
      BiometricAuthResult.success;
}

class _InMemoryPinKeystore implements AppPinKeystore {
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

class _FakePermissionsService implements AppPermissionsService {
  bool openSettingsCalled = false;

  @override
  Future<AppPermissionItem> getPermission(AppPermissionId id) async =>
      _itemFor(id);

  @override
  Future<PermissionsSnapshot> getSnapshot() async {
    return PermissionsSnapshot(
      explicitPermissions: [_itemFor(AppPermissionId.attachmentImport)],
      implicitPermissions: [_itemFor(AppPermissionId.documentPicker)],
    );
  }

  @override
  Future<AppPermissionState> requestPermission(AppPermissionId id) async =>
      AppPermissionState.granted;

  @override
  Future<bool> shouldShowRequestRationale(AppPermissionId id) async => false;

  @override
  Future<bool> openSystemSettings() async {
    openSettingsCalled = true;
    return true;
  }

  AppPermissionItem _itemFor(AppPermissionId id) {
    return AppPermissionItem(
      id: id,
      category: id == AppPermissionId.attachmentImport
          ? AppPermissionCategory.explicit
          : AppPermissionCategory.implicit,
      title: id == AppPermissionId.attachmentImport
          ? 'Attachment import'
          : 'Document picker',
      description: 'Test permission',
      status: AppPermissionState.granted,
    );
  }
}

/// Records calls to `migrateStoredFile` and lets the test gate the loop so
/// the migration dialog stays visible while we assert against it. Cancel
/// causes the next call to throw via the `isCancelled` flag.
class _SlowCryptoStorage implements AttachmentCryptoStorage {
  bool holdMigration = false;
  final List<Completer<void>> _pendingHolds = [];

  void releaseAll() {
    for (final c in _pendingHolds) {
      if (!c.isCompleted) c.complete();
    }
    _pendingHolds.clear();
  }

  @override
  Future<String> migrateStoredFile({
    required String encryptedPath,
    required String fileName,
    required AttachmentStorageLocation targetLocation,
    String? targetTreeUri,
  }) async {
    if (holdMigration) {
      final c = Completer<void>();
      _pendingHolds.add(c);
      await c.future;
    }
    return 'app_private/$fileName.enc';
  }

  @override
  bool isStoredInLocation({
    required String encryptedPath,
    required AttachmentStorageLocation location,
  }) {
    return false;
  }

  @override
  Future<void> deleteStoredFile(String encryptedPath) async {}

  @override
  Future<void> cleanupMigrationArtifacts({
    required AttachmentStorageLocation targetLocation,
    String? targetTreeUri,
  }) async {}

  @override
  Future<AttachmentTempFileHandle> decryptToTempFile({
    required String encryptedPath,
    required String nonceBase64,
    required String keyReference,
    required String fileName,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<StoredAttachmentPayload> encryptAndStore({
    required List<int> sourceBytes,
    required String sourceFileName,
  }) {
    throw UnimplementedError();
  }
}
