import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../helpers/export_labels.dart';
import 'package:sreerajp_journal_vault/features/export/services/delta_document.dart';
import 'package:sreerajp_journal_vault/features/export/services/export_document.dart';
import 'package:sreerajp_journal_vault/features/export/services/export_format.dart';
import 'package:sreerajp_journal_vault/features/export/services/export_html_builder.dart';
import 'package:sreerajp_journal_vault/features/export/services/export_service.dart';
import 'export_test_fakes.dart';

/// Covers the orchestrator: single file vs zip, naming, attachment rules, and
/// what happens when a file cannot be read.
///
/// The locked-attachment test is the one that matters most. Locking a file was
/// a deliberate act by the user, and an export must not be a way around it.
void main() {
  late Directory tempDir;
  late FakeCryptoStorage crypto;
  late ExportService service;

  /// A fixed clock so file names and the README are predictable.
  DateTime fixedNow() => DateTime(2026, 8, 16, 14, 30);

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('export_service_test');
    crypto = FakeCryptoStorage(tempDir);
    service = ExportService(
      cryptoStorage: crypto,
      // A stub asset loader keeps the builder off the Flutter asset bundle,
      // so these tests need no binding and no real font files.
      htmlBuilder: ExportHtmlBuilder(
        assetLoader: (_) async => utf8.encode('fake-font-bytes'),
      ),
      now: fixedNow,
    );
  });

  tearDown(() async {
    if (tempDir.existsSync()) await tempDir.delete(recursive: true);
  });

  ExportDocument doc({
    int id = 1,
    String? title = 'My Entry',
    String body = 'the body',
    DateTime? date,
    List<ExportAttachmentRef> attachments = const [],
    List<ExportAttachmentRef> inlineImages = const [],
    List<ExportBlock>? blocks,
    List<ExportVoiceNoteRef> voiceNotes = const [],
    List<String> tags = const [],
    int? mood,
  }) => ExportDocument(
    entryId: id,
    title: title,
    blocks:
        blocks ??
        [
          TextBlock(spans: [InlineSpan(text: body)]),
        ],
    entryDate: date ?? DateTime(2026, 8, 15, 9),
    tags: tags,
    mood: mood,
    attachments: attachments,
    inlineImages: inlineImages,
    voiceNotes: voiceNotes,
  );

  ExportBundle bundleOf(List<ExportDocument> documents) => ExportBundle(
    journalId: 1,
    journalTitle: 'My Journal',
    documents: documents,
  );

  ExportAttachmentRef attachment({
    int id = 10,
    String fileName = 'photo.jpg',
    bool isLocked = false,
    String path = 'ok',
  }) => ExportAttachmentRef(
    attachmentId: id,
    fileName: fileName,
    sizeBytes: 3,
    encryptedPath: path,
    nonceBase64: 'n',
    keyReference: 'k',
    isLocked: isLocked,
  );

  Archive readZip(Uint8List bytes) => ZipDecoder().decodeBytes(bytes);

  List<String> namesIn(Archive archive) =>
      archive.files.map((f) => f.name).toList();

  group('inline images', () {
    ExportDocument docWithImage({
      int id = 1,
      int attachmentId = 10,
      String fileName = 'photo.jpg',
      bool isLocked = false,
      String path = 'img',
      String? mimeType = 'image/jpeg',
    }) => doc(
      id: id,
      blocks: [
        const TextBlock(spans: [InlineSpan(text: 'before')]),
        ImageBlock(attachmentId: attachmentId, fileName: fileName),
      ],
      inlineImages: [
        ExportAttachmentRef(
          attachmentId: attachmentId,
          fileName: fileName,
          sizeBytes: 3,
          encryptedPath: path,
          nonceBase64: 'n',
          keyReference: 'k',
          mimeType: mimeType,
          isLocked: isLocked,
        ),
      ],
    );

    test('HTML draws the picture inline as a data URI', () async {
      crypto.contents['img'] = [1, 2, 3];

      final result = await service.build(
        labels: englishExportLabels,
        bundleOf([docWithImage()]),
        format: ExportFormat.html,
      );

      final html = utf8.decode(result.bytes);
      expect(html, contains('<figure class="inline-image">'));
      expect(html, contains('src="data:image/jpeg;base64,'));
      expect(result.skipped, isEmpty);
    });

    test(
      'the picture is drawn even when attachments are not included',
      () async {
        crypto.contents['img'] = [1, 2, 3];

        // includeAttachments defaults to false — no attachment files at all.
        final result = await service.build(
          labels: englishExportLabels,
          bundleOf([docWithImage()]),
          format: ExportFormat.html,
        );

        // The image is part of the page, not a file travelling beside it.
        expect(utf8.decode(result.bytes), contains('data:image/jpeg;base64,'));
        expect(result.isZip, isFalse);
      },
    );

    test('a locked inline image is never decrypted, and is reported', () async {
      crypto.contents['img'] = [1, 2, 3];

      final result = await service.build(
        labels: englishExportLabels,
        bundleOf([docWithImage(fileName: 'private.jpg', isLocked: true)]),
        format: ExportFormat.html,
      );

      expect(crypto.decryptCalls, isEmpty);
      final html = utf8.decode(result.bytes);
      expect(html, isNot(contains('data:image/')));
      expect(html, contains('private.jpg'));
      expect(
        result.skipped.map((o) => o.reason),
        contains(ExportOmissionReason.lockedInlineImage),
      );
    });

    test('an unreadable inline image is named, not dropped', () async {
      // Nothing registered for 'img', so the fake storage throws.
      final result = await service.build(
        labels: englishExportLabels,
        bundleOf([docWithImage(fileName: 'gone.jpg')]),
        format: ExportFormat.html,
      );

      final html = utf8.decode(result.bytes);
      expect(html, contains('gone.jpg'));
      expect(html, contains('image not included'));
      expect(
        result.skipped.map((o) => o.reason),
        contains(ExportOmissionReason.unreadableInlineImage),
      );
    });

    test('a non-image MIME type falls back to image/png', () async {
      crypto.contents['img'] = [1, 2, 3];

      final result = await service.build(
        labels: englishExportLabels,
        bundleOf([docWithImage(mimeType: 'application/octet-stream')]),
        format: ExportFormat.html,
      );

      expect(utf8.decode(result.bytes), contains('data:image/png;base64,'));
    });

    test('the same picture used twice is decrypted once', () async {
      crypto.contents['img'] = [1, 2, 3];

      await service.build(
        labels: englishExportLabels,
        bundleOf([docWithImage(), docWithImage(id: 2)]),
        format: ExportFormat.html,
      );

      expect(crypto.decryptCalls, ['img']);
    });

    test('Markdown links to the file when the attachment came along', () async {
      crypto.contents['img'] = [1, 2, 3];

      final result = await service.build(
        labels: englishExportLabels,
        bundleOf([
          doc(
            blocks: [const ImageBlock(attachmentId: 10, fileName: 'photo.jpg')],
            attachments: [attachment(path: 'img')],
          ),
        ]),
        format: ExportFormat.markdown,
        includeAttachments: true,
      );

      final archive = readZip(result.bytes);
      final entry = archive.files.firstWhere(
        (f) => f.name.startsWith('entries/'),
      );
      expect(
        utf8.decode(entry.content as List<int>),
        contains('![photo.jpg](attachments/10_photo.jpg)'),
      );
      expect(namesIn(archive), contains('attachments/10_photo.jpg'));
    });

    test('Markdown names the image when its file is not included', () async {
      final result = await service.build(
        labels: englishExportLabels,
        bundleOf([
          doc(
            blocks: [const ImageBlock(attachmentId: 10, fileName: 'photo.jpg')],
          ),
        ]),
        format: ExportFormat.markdown,
      );

      final text = utf8.decode(result.bytes);
      // No link, because there is no attachments folder to link into.
      expect(text, isNot(contains('](attachments/')));
      expect(text, contains('[Image: photo.jpg]'));
    });
  });

  test('refuses to build an export with no entries', () async {
    expect(
      () => service.build(
        labels: englishExportLabels,
        bundleOf([]),
        format: ExportFormat.markdown,
      ),
      throwsA(isA<ExportException>()),
    );
  });
}
