import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../helpers/export_labels.dart';

import 'package:sreerajp_journal_vault/core/security/vault_envelope.dart';
import 'package:sreerajp_journal_vault/core/security/vault_payload.dart';
import 'package:sreerajp_journal_vault/features/attachments/services/attachment_crypto_storage.dart';
import 'package:sreerajp_journal_vault/features/export/services/delta_document.dart';
import 'package:sreerajp_journal_vault/features/export/services/export_document.dart';
import 'package:sreerajp_journal_vault/features/export/services/export_format.dart';
import 'package:sreerajp_journal_vault/features/export/services/export_html_builder.dart';
import 'package:sreerajp_journal_vault/features/export/services/export_service.dart';

/// Covers A4.2: an export sealed under a password, and opened again.
///
/// The point of these tests is that the *file name* is protected too. A file
/// called `Leaving my job.md.jvenc` would give away the thing the password is
/// meant to hide, so the name lives inside the sealed bytes and the file on
/// disk is offered under a plain dated name.
void main() {
  const password = 'correct-horse-battery';

  /// Argon2id at production settings takes seconds per call in pure Dart.
  VaultEnvelope cheapEnvelope() => VaultEnvelope(
    kdf: const VaultKdfParameters(memoryKib: 64, iterations: 1),
    legacyKdf: const VaultKdfParameters(memoryKib: 64, iterations: 1),
  );

  late ExportService service;

  DateTime fixedNow() => DateTime(2026, 8, 18, 14, 30);

  setUp(() {
    service = ExportService(
      cryptoStorage: _UnusedCryptoStorage(),
      htmlBuilder: ExportHtmlBuilder(
        assetLoader: (_) async => utf8.encode('fake-font-bytes'),
      ),
      envelope: cheapEnvelope(),
      now: fixedNow,
    );
  });

  ExportDocument doc({int id = 1, String title = 'Leaving my job'}) =>
      ExportDocument(
        entryId: id,
        title: title,
        blocks: const [
          TextBlock(spans: [InlineSpan(text: 'the private body')]),
        ],
        entryDate: DateTime(2026, 8, 15, 9),
      );

  ExportBundle bundleOf(List<ExportDocument> documents) => ExportBundle(
    journalId: 1,
    journalTitle: 'My Journal',
    documents: documents,
  );

  test('no password still writes a plain, readable file', () async {
    final result = await service.build(
      labels: englishExportLabels,
      bundleOf([doc()]),
      format: ExportFormat.markdown,
    );

    expect(result.isEncrypted, isFalse);
    expect(result.fileName, endsWith('.md'));
    expect(utf8.decode(result.bytes), contains('the private body'));
  });

  test('a password seals the file and hides its name', () async {
    final result = await service.build(
      labels: englishExportLabels,
      bundleOf([doc()]),
      format: ExportFormat.markdown,
      password: password,
    );

    expect(result.isEncrypted, isTrue);
    expect(result.fileName, 'journal_export_2026-08-18.jvenc');
    expect(result.mimeType, 'application/octet-stream');
    expect(VaultEnvelope.isSealed(result.bytes), isTrue);

    // Neither the writing nor the entry title is readable in the file.
    final asText = latin1.decode(result.bytes, allowInvalid: true);
    expect(asText, isNot(contains('the private body')));
    expect(asText, isNot(contains('Leaving my job')));
  });

  test('the sealed file opens again into the original file', () async {
    final plainResult = await service.build(
      labels: englishExportLabels,
      bundleOf([doc()]),
      format: ExportFormat.markdown,
    );
    final sealedResult = await service.build(
      labels: englishExportLabels,
      bundleOf([doc()]),
      format: ExportFormat.markdown,
      password: password,
    );

    final opened = await cheapEnvelope().open(
      sealedBytes: sealedResult.bytes,
      password: password,
    );
    final payload = unwrapVaultPayload(opened);

    expect(payload.header, isNotNull);
    expect(payload.header!.kind, vaultPayloadKindExport);
    expect(payload.header!.fileName, plainResult.fileName);
    expect(payload.header!.mimeType, plainResult.mimeType);
    expect(payload.bytes, plainResult.bytes);
    expect(utf8.decode(payload.bytes), contains('the private body'));
  });

  test('a zip bundle seals and opens the same way', () async {
    final sealedResult = await service.build(
      labels: englishExportLabels,
      bundleOf([doc(), doc(id: 2, title: 'Second')]),
      format: ExportFormat.markdown,
      password: password,
    );

    expect(sealedResult.isEncrypted, isTrue);
    // What is inside is not visible from the outside — that is the point.
    expect(sealedResult.isZip, isFalse);

    final opened = await cheapEnvelope().open(
      sealedBytes: sealedResult.bytes,
      password: password,
    );
    final payload = unwrapVaultPayload(opened);

    expect(payload.header!.fileName, endsWith('.zip'));
    final names = ZipDecoder()
        .decodeBytes(payload.bytes)
        .files
        .map((f) => f.name)
        .toList();
    expect(names, contains('entries/2026-08-15_Leaving_my_job.md'));
    expect(names, contains('entries/2026-08-15_Second.md'));
  });

  test('the wrong password does not open a sealed export', () async {
    final sealedResult = await service.build(
      labels: englishExportLabels,
      bundleOf([doc()]),
      format: ExportFormat.markdown,
      password: password,
    );

    expect(
      () => cheapEnvelope().open(
        sealedBytes: sealedResult.bytes,
        password: 'not-the-password',
      ),
      throwsA(
        isA<VaultCorruptedException>().having(
          (e) => e.isWrongPassword,
          'isWrongPassword',
          isTrue,
        ),
      ),
    );
  });

  test('a short password is refused before anything is sealed', () async {
    expect(
      () => service.build(
        labels: englishExportLabels,
        bundleOf([doc()]),
        format: ExportFormat.markdown,
        password: 'short',
      ),
      throwsA(isA<VaultPasswordException>()),
    );
  });
}

/// These tests never include attachments, so nothing here is ever called.
class _UnusedCryptoStorage implements AttachmentCryptoStorage {
  @override
  Future<AttachmentTempFileHandle> decryptToTempFile({
    required String encryptedPath,
    required String nonceBase64,
    required String keyReference,
    required String fileName,
  }) => throw UnimplementedError();

  @override
  Future<void> cleanupMigrationArtifacts({
    required AttachmentStorageLocation targetLocation,
    String? targetTreeUri,
  }) async {}

  @override
  Future<void> deleteStoredFile(String encryptedPath) async {}

  @override
  Future<StoredAttachmentPayload> encryptAndStore({
    required List<int> sourceBytes,
    required String sourceFileName,
  }) => throw UnimplementedError();

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
}
