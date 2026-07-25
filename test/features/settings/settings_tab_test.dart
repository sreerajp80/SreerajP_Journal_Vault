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
    await tester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      JournalVaultAppHost(
        database: database,
        overrides: <Override>[
          biometricAuthenticatorProvider.overrideWithValue(fakeBiometric),
          appPinKeystoreProvider.overrideWithValue(fakeKeystore),
          appPermissionsServiceProvider.overrideWithValue(fakePermissions),
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

  testWidgets('renders all five sections in the plan-defined order', (
    tester,
  ) async {
    await pumpApp(tester);

    final headers = const ['Security', 'Appearance', 'Storage', 'Permissions', 'About'];
    for (final h in headers) {
      expect(find.text(h), findsOneWidget,
          reason: '$h section header missing');
    }

    // Verify ordering by Y position so we catch out-of-order rebuilds.
    final positions = <String, double>{};
    for (final h in headers) {
      positions[h] = tester.getTopLeft(find.text(h)).dy;
    }
    expect(positions['Security']! < positions['Appearance']!, isTrue);
    expect(positions['Appearance']! < positions['Storage']!, isTrue);
    expect(positions['Storage']! < positions['Permissions']!, isTrue);
    expect(positions['Permissions']! < positions['About']!, isTrue);

    // Slice B coming-soon stubs that Slice D wires up — Auto-Lock Timeout
    // and Attachment-Level Lock now have real screens; only Tamper Alerts
    // is still a stub (V3 hardware integration).
    expect(find.text('Auto-Lock Timeout'), findsOneWidget);
    expect(find.text('Attachment-Level Lock'), findsOneWidget);
    expect(find.text('Tamper Alerts'), findsOneWidget);
    expect(find.text('Coming soon'), findsOneWidget);

    // Storage rows (C2 Backup Health, Import Data + D1 Sync Health).
    expect(find.byKey(const Key('settings-attachment-storage-location')),
        findsOneWidget);
    expect(find.byKey(const Key('settings-migrate-storage')), findsOneWidget);
    expect(find.byKey(const Key('settings-storage-usage')), findsOneWidget);
    expect(find.byKey(const Key('settings-backup-health')), findsOneWidget);
    expect(find.byKey(const Key('settings-import-data')), findsOneWidget);
    expect(find.byKey(const Key('settings-sync-health')), findsOneWidget);

    // Slice D Security rows.
    expect(find.byKey(const Key('settings-auto-lock-timeout')), findsOneWidget);
    expect(find.byKey(const Key('settings-attachment-level-lock')),
        findsOneWidget);
    expect(find.byKey(const Key('settings-sync-conflicts')), findsOneWidget);
    expect(find.byKey(const Key('settings-security-events')), findsOneWidget);

    // Permissions rows.
    expect(find.byKey(const Key('settings-permissions-status')),
        findsOneWidget);
    expect(find.byKey(const Key('settings-manage-permissions')),
        findsOneWidget);
    expect(find.byKey(const Key('settings-open-system-settings')),
        findsOneWidget);

    // System theme chip must NOT exist; only Light + Dark.
    expect(find.text('System'), findsNothing);
    expect(find.text('Light'), findsOneWidget);
    expect(find.text('Dark'), findsOneWidget);
  });

  testWidgets('Manage Permissions tile pushes the PermissionsScreen', (
    tester,
  ) async {
    await pumpApp(tester);

    await tester.tap(find.byKey(const Key('settings-manage-permissions')));
    await tester.pumpAndSettle();

    expect(find.text('Permissions'), findsWidgets);
    expect(find.text('Attachment import'), findsOneWidget);
  });

  testWidgets('Backup Health tile pushes the BackupHealthScreen', (
    tester,
  ) async {
    await pumpApp(tester);

    await tester.tap(find.byKey(const Key('settings-backup-health')));
    // BackupHealthScreen has an animated entry, so pump a few frames rather
    // than pumpAndSettle (its providers re-poll periodically and never idle).
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(AppBar), findsOneWidget);
    expect(find.text('Settings').evaluate().isEmpty, isTrue,
        reason: 'BackupHealthScreen replaced the Settings AppBar');
  });

  testWidgets(
      'Import Data tile asks user to pick a journal then pushes ImportScreen',
      (tester) async {
    await database.journalsDao.createJournal(
      JournalsCompanion.insert(title: 'Inbox'),
    );
    await pumpApp(tester);

    await tester.tap(find.byKey(const Key('settings-import-data')));
    await tester.pumpAndSettle();

    expect(find.text('Import into journal'), findsOneWidget);
    await tester.tap(find.text('Inbox'));
    await tester.pumpAndSettle();

    expect(find.text('Import into "Inbox"'), findsOneWidget);
  });

  testWidgets('Import Data with no journals prompts the user to create one',
      (tester) async {
    await pumpApp(tester);

    await tester.tap(find.byKey(const Key('settings-import-data')));
    await tester.pumpAndSettle();

    expect(find.text('Create a journal first to import into.'), findsOneWidget);
  });

  testWidgets(
    'Migrate Storage flow renders progress and supports cancel',
    (tester) async {
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

      // Open the storage location dialog and choose SD Card. The picker
      // override returns null (user cancel) by default — wire a fake picker
      // first.
      // Instead of going through the location dialog, retry-style we trigger
      // by switching to App Private (no picker). Use SD Card via tree picker
      // would need a platform channel; here we just invoke "Migrate Storage"
      // directly by faking a failed migration target.
      //
      // Force a failed migration target so the Retry button appears.
      await database.appSettingsDao.updateSettings(const AppSettingsCompanion(
        attachmentMigrationStatus: Value('failed'),
        attachmentMigrationTarget: Value('app_private'),
        attachmentMigrationFailure: Value('Earlier run interrupted.'),
      ));
      // Force the Storage section to reload by reopening Settings.
      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

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
      expect(settings.attachmentMigrationFailure,
          contains('cancelled'));
    },
  );
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
