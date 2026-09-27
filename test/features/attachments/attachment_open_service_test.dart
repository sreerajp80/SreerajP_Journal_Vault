import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:open_filex/open_filex.dart';
import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/features/attachments/domain/attachment_open_router.dart';
import 'package:sreerajp_journal_vault/features/attachments/services/attachment_crypto_storage.dart';
import 'package:sreerajp_journal_vault/features/attachments/services/attachment_open_service.dart';

/// Decrypts to a real temp file, so the tests can see whether it survives.
class _TempFileStorage implements AttachmentCryptoStorage {
  _TempFileStorage(this.dir);

  final Directory dir;

  @override
  Future<AttachmentTempFileHandle> decryptToTempFile({
    required String encryptedPath,
    required String nonceBase64,
    required String keyReference,
    required String fileName,
  }) async {
    final file = File('${dir.path}/$fileName')..writeAsStringSync('plain');
    return AttachmentTempFileHandle(file: file);
  }

  @override
  Future<StoredAttachmentPayload> encryptAndStore({
    required List<int> sourceBytes,
    required String sourceFileName,
  }) => throw UnimplementedError();

  @override
  Future<void> deleteStoredFile(String encryptedPath) async {}

  @override
  bool isStoredInLocation({
    required String encryptedPath,
    required AttachmentStorageLocation location,
  }) => true;

  @override
  Future<String> migrateStoredFile({
    required String encryptedPath,
    required String fileName,
    required AttachmentStorageLocation targetLocation,
    String? targetTreeUri,
  }) => throw UnimplementedError();

  @override
  Future<void> cleanupMigrationArtifacts({
    required AttachmentStorageLocation targetLocation,
    String? targetTreeUri,
  }) async {}
}

void main() {
  late Directory dir;

  setUp(() => dir = Directory.systemTemp.createTempSync('open_service_test'));
  tearDown(() {
    if (dir.existsSync()) dir.deleteSync(recursive: true);
  });

  final attachment = Attachment(
    id: 1,
    entryId: 1,
    fileName: 'report.odt',
    mimeType: 'application/vnd.oasis.opendocument.text',
    encryptedPath: 'enc.bin',
    nonceBase64: 'n',
    keyReference: 'k',
    sizeBytes: 5,
    createdAt: DateTime(2026, 9, 19),
  );

  AttachmentOpenService service(ResultType result) => AttachmentOpenService(
    storage: _TempFileStorage(dir),
    router: AttachmentOpenRouter(
      opener: (path, {type}) async => OpenResult(type: result),
    ),
  );

  test('a failed hand-off deletes the decrypted copy at once', () async {
    final open = service(ResultType.noAppToOpen);
    final session = await open.prepare(attachment);

    await expectLater(
      open.openExternally(session),
      throwsA(isA<AttachmentOpenException>()),
    );

    expect(session.handle.file.existsSync(), isFalse);
  });

  test(
    'keepOnFailure leaves the copy for the viewer still showing it',
    () async {
      final open = service(ResultType.noAppToOpen);
      final session = await open.prepare(attachment);

      await expectLater(
        open.openExternally(session, keepOnFailure: true),
        throwsA(isA<AttachmentOpenException>()),
      );

      expect(session.handle.file.existsSync(), isTrue);
    },
  );

  test(
    'a successful hand-off keeps the copy and marks it for the sweep',
    () async {
      final open = service(ResultType.done);
      final session = await open.prepare(attachment);

      await open.openExternally(session);

      expect(session.handle.file.existsSync(), isTrue);
      expect(session.handle.isHandedOff, isTrue);
    },
  );
}
