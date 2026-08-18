import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_journal_vault/app/app.dart';
import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/core/database/database_providers.dart';
import 'package:sreerajp_journal_vault/features/attachments/domain/attachment_open_models.dart';
import 'package:sreerajp_journal_vault/features/attachments/domain/attachment_open_router.dart';
import 'package:sreerajp_journal_vault/features/attachments/providers/attachment_providers.dart';
import 'package:sreerajp_journal_vault/features/attachments/services/attachment_crypto_storage.dart';
import 'package:sreerajp_journal_vault/features/attachments/services/attachment_open_service.dart';
import 'package:sreerajp_journal_vault/features/lock_gate/providers/lock_gate_providers.dart';
import 'package:sreerajp_journal_vault/features/lock_gate/services/app_pin_keystore.dart';
import 'package:sreerajp_journal_vault/features/lock_gate/services/biometric_authenticator.dart';

void main() {
  late AppDatabase database;

  setUp(() async {
    database = AppDatabase.forExecutor(NativeDatabase.memory());
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

  testWidgets('Attachment failure dialog offers recovery actions', (
    tester,
  ) async {
    final journalId = await database.journalsDao.createJournal(
      JournalsCompanion.insert(title: 'Recovery'),
    );
    final entryId = await database.entriesDao.createEntry(
      EntriesCompanion.insert(
        journalId: journalId,
        title: const Value('Entry'),
        contentJson: const Value('[{"insert":"Hello\\n"}]'),
      ),
    );
    await database.attachmentsDao.createAttachment(
      AttachmentsCompanion.insert(
        entryId: entryId,
        fileName: 'broken.pdf',
        mimeType: const Value('application/pdf'),
        encryptedPath: 'tmp/path',
        nonceBase64: 'abc',
        keyReference: 'test-key-ref',
        sizeBytes: 1024,
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          attachmentOpenServiceProvider.overrideWithValue(
            _FailingOpenService(),
          ),
          appPinKeystoreProvider.overrideWithValue(_InMemoryAppPinKeystore()),
          biometricAuthenticatorProvider.overrideWithValue(
            _AlwaysSuccessBiometric(),
          ),
        ],
        child: const JournalVaultApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('phone-lock-unlock-button')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Recovery'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Entry'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('open-attachment-1')));
    await tester.pumpAndSettle();

    expect(find.text('No compatible app found'), findsOneWidget);
    expect(find.text('Open with...'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
    expect(find.text('Close'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    await tester.pumpAndSettle();
  });
}

class _FailingOpenService extends AttachmentOpenService {
  _FailingOpenService()
    : super(storage: _NoopStorage(), router: AttachmentOpenRouter());

  @override
  Future<AttachmentOpenSession> prepare(Attachment attachment) async {
    throw AttachmentOpenException(AttachmentOpenFailure.noCompatibleApp);
  }

  @override
  Future<AttachmentOpenPrepared> prepareOpen(Attachment attachment) async {
    throw AttachmentOpenException(AttachmentOpenFailure.noCompatibleApp);
  }
}

class _NoopStorage implements AttachmentCryptoStorage {
  @override
  Future<void> cleanupMigrationArtifacts({
    required AttachmentStorageLocation targetLocation,
    String? targetTreeUri,
  }) async {}

  @override
  Future<void> deleteStoredFile(String encryptedPath) async {}

  @override
  Future<AttachmentTempFileHandle> decryptToTempFile({
    required String encryptedPath,
    required String nonceBase64,
    required String keyReference,
    required String fileName,
  }) {
    throw AttachmentOpenException(AttachmentOpenFailure.decryptFailed);
  }

  @override
  Future<StoredAttachmentPayload> encryptAndStore({
    required List<int> sourceBytes,
    required String sourceFileName,
  }) {
    throw UnimplementedError();
  }

  @override
  bool isStoredInLocation({
    required String encryptedPath,
    required AttachmentStorageLocation location,
  }) {
    return false;
  }

  @override
  Future<String> migrateStoredFile({
    required String encryptedPath,
    required String fileName,
    required AttachmentStorageLocation targetLocation,
    String? targetTreeUri,
  }) {
    throw UnimplementedError();
  }
}

class _AlwaysSuccessBiometric implements BiometricAuthenticator {
  @override
  Future<bool> canAuthenticate() async => true;

  @override
  Future<BiometricAuthResult> authenticate({required String reason}) async =>
      BiometricAuthResult.success;
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
