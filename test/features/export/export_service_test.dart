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

  group('single file vs zip', () {
    test('one entry with no attachments is a single file', () async {
      final result = await service.build(
        labels: englishExportLabels,
        bundleOf([doc()]),
        format: ExportFormat.markdown,
      );

      expect(result.isZip, isFalse);
      expect(result.fileName, '2026-08-15_My_Entry.md');
      expect(utf8.decode(result.bytes), contains('the body'));
    });

    test('two entries become a zip with one file each', () async {
      final result = await service.build(
        labels: englishExportLabels,
        bundleOf([doc(title: 'First'), doc(id: 2, title: 'Second')]),
        format: ExportFormat.markdown,
      );

      expect(result.isZip, isTrue);
      final names = namesIn(readZip(result.bytes));
      expect(names, contains('entries/2026-08-15_First.md'));
      expect(names, contains('entries/2026-08-15_Second.md'));
      expect(names, contains('README.txt'));
    });

    test(
      'HTML keeps every entry in one document even for many entries',
      () async {
        final result = await service.build(
          labels: englishExportLabels,
          bundleOf([doc(title: 'First'), doc(id: 2, title: 'Second')]),
          format: ExportFormat.html,
        );

        // One document, so no zip is needed.
        expect(result.isZip, isFalse);
        expect(result.fileName, 'My_Journal.html');
        final html = utf8.decode(result.bytes);
        expect(html, contains('First'));
        expect(html, contains('Second'));
      },
    );

    test('one attachment forces a zip even for a single entry', () async {
      crypto.contents['ok'] = utf8.encode('image bytes');
      final result = await service.build(
        labels: englishExportLabels,
        bundleOf([
          doc(attachments: [attachment()]),
        ]),
        format: ExportFormat.markdown,
        includeAttachments: true,
      );

      expect(result.isZip, isTrue);
      expect(
        namesIn(readZip(result.bytes)),
        contains('attachments/10_photo.jpg'),
      );
    });

    test('the zip is named after the journal and the day', () async {
      final result = await service.build(
        labels: englishExportLabels,
        bundleOf([doc(), doc(id: 2)]),
        format: ExportFormat.markdown,
      );

      expect(result.fileName, 'My_Journal_export_2026-08-16.zip');
    });
  });

  group('file naming', () {
    test('keeps a Malayalam title in the file name', () async {
      final result = await service.build(
        labels: englishExportLabels,
        bundleOf([doc(title: 'എന്റെ ഡയറി')]),
        format: ExportFormat.markdown,
      );

      expect(result.fileName, '2026-08-15_എന്റെ_ഡയറി.md');
    });

    test('falls back for an entry with no title', () async {
      final result = await service.build(
        labels: englishExportLabels,
        bundleOf([doc(title: null)]),
        format: ExportFormat.plainText,
      );

      expect(result.fileName, contains('Untitled_entry'));
    });

    test('makes two same-day, same-title entries unique', () async {
      // A zip cannot hold two files with the same path; one would be lost.
      final result = await service.build(
        labels: englishExportLabels,
        bundleOf([doc(title: 'Same'), doc(id: 2, title: 'Same')]),
        format: ExportFormat.markdown,
      );

      final names = namesIn(readZip(result.bytes));
      expect(names, contains('entries/2026-08-15_Same.md'));
      expect(names, contains('entries/2026-08-15_Same(2).md'));
    });
  });

  group('attachments', () {
    test('writes an unlocked attachment into the bundle', () async {
      crypto.contents['ok'] = utf8.encode('image bytes');

      final result = await service.build(
        labels: englishExportLabels,
        bundleOf([
          doc(attachments: [attachment()]),
        ]),
        format: ExportFormat.markdown,
        includeAttachments: true,
      );

      final archive = readZip(result.bytes);
      final file = archive.files.firstWhere(
        (f) => f.name == 'attachments/10_photo.jpg',
      );
      expect(utf8.decode(file.content as List<int>), 'image bytes');
      expect(result.skipped, isEmpty);
    });

    test('never writes out a locked attachment, and says so', () async {
      crypto.contents['ok'] = utf8.encode('secret bytes');

      final result = await service.build(
        labels: englishExportLabels,
        bundleOf([
          doc(
            attachments: [attachment(fileName: 'secret.pdf', isLocked: true)],
          ),
        ]),
        format: ExportFormat.markdown,
        includeAttachments: true,
      );

      // Nothing was decrypted at all — the lock is checked before the file is
      // ever touched.
      expect(crypto.decryptCalls, isEmpty);
      expect(result.skipped, hasLength(1));
      expect(result.skipped.single.fileName, 'secret.pdf');
      expect(
        result.skipped.single.reason,
        ExportOmissionReason.lockedAttachment,
      );
    });

    test('skips an attachment that cannot be read, keeping the rest', () async {
      crypto.contents['ok'] = utf8.encode('good bytes');
      // 'missing' is not in contents, so the fake throws for it.

      final result = await service.build(
        labels: englishExportLabels,
        bundleOf([
          doc(
            attachments: [
              attachment(fileName: 'good.jpg'),
              attachment(id: 11, fileName: 'broken.jpg', path: 'missing'),
            ],
          ),
        ]),
        format: ExportFormat.markdown,
        includeAttachments: true,
      );

      final names = namesIn(readZip(result.bytes));
      expect(names, contains('attachments/10_good.jpg'));
      expect(names, isNot(contains('attachments/11_broken.jpg')));
      expect(result.skipped.single.fileName, 'broken.jpg');
      expect(
        result.skipped.single.reason,
        ExportOmissionReason.unreadableAttachment,
      );
    });

    test('deletes every decrypted temporary copy afterwards', () async {
      // A plaintext copy left in the cache would undo the encryption the
      // vault exists to provide.
      crypto.contents['ok'] = utf8.encode('image bytes');

      await service.build(
        labels: englishExportLabels,
        bundleOf([
          doc(attachments: [attachment()]),
        ]),
        format: ExportFormat.markdown,
        includeAttachments: true,
      );

      expect(crypto.handedOutHandles, isNotEmpty);
      expect(
        crypto.handedOutHandles.every((h) => h.isReleased),
        isTrue,
        reason: 'every decrypted temp file must be released',
      );
    });

    test(
      'leaves attachments out entirely when they were not asked for',
      () async {
        crypto.contents['ok'] = utf8.encode('image bytes');

        final result = await service.build(
          labels: englishExportLabels,
          bundleOf([
            doc(attachments: [attachment()]),
          ]),
          format: ExportFormat.markdown,
        );

        expect(result.isZip, isFalse);
        expect(crypto.decryptCalls, isEmpty);
      },
    );

    test('writes voice-note audio into the bundle', () async {
      crypto.contents['voice'] = utf8.encode('audio bytes');

      final result = await service.build(
        labels: englishExportLabels,
        bundleOf([
          doc(
            voiceNotes: [
              const ExportVoiceNoteRef(
                voiceNoteId: 7,
                fileName: 'note.m4a',
                durationMs: 5000,
                encryptedPath: 'voice',
                nonceBase64: 'n',
                keyReference: 'k',
              ),
            ],
          ),
        ]),
        format: ExportFormat.markdown,
        includeAttachments: true,
      );

      expect(
        namesIn(readZip(result.bytes)),
        contains('attachments/voice_7_note.m4a'),
      );
    });
  });

  group('content of the written files', () {
    test('a Markdown entry carries its title, metadata and body', () async {
      final result = await service.build(
        labels: englishExportLabels,
        bundleOf([
          doc(tags: ['work', 'ideas'], mood: 4),
        ]),
        format: ExportFormat.markdown,
      );

      final text = utf8.decode(result.bytes);
      expect(text, contains('# My Entry'));
      expect(text, contains('Date: 2026-08-15 09:00'));
      expect(text, contains('Tags: work, ideas'));
      expect(text, contains('Mood: 4 of 5'));
      expect(text, contains('the body'));
    });

    test('metadata is left out when it was not asked for', () async {
      final result = await service.build(
        labels: englishExportLabels,
        bundleOf([
          doc(tags: ['work'], mood: 4),
        ]),
        format: ExportFormat.markdown,
        includeMetadata: false,
      );

      final text = utf8.decode(result.bytes);
      expect(text, isNot(contains('Tags:')));
      expect(text, isNot(contains('Mood:')));
      expect(text, contains('the body'));
    });

    test('a voice-note transcript is written out as text', () async {
      // The transcript is content, so it appears even when the audio does not.
      final result = await service.build(
        labels: englishExportLabels,
        bundleOf([
          doc(
            voiceNotes: [
              const ExportVoiceNoteRef(
                voiceNoteId: 7,
                fileName: 'note.m4a',
                durationMs: 95000,
                encryptedPath: 'voice',
                nonceBase64: 'n',
                keyReference: 'k',
                transcript: 'what I said out loud',
              ),
            ],
          ),
        ]),
        format: ExportFormat.markdown,
      );

      final text = utf8.decode(result.bytes);
      expect(text, contains('what I said out loud'));
      expect(text, contains('1:35'));
    });

    test('a locked attachment is named in the text as not included', () async {
      final result = await service.build(
        labels: englishExportLabels,
        bundleOf([
          doc(
            attachments: [attachment(fileName: 'secret.pdf', isLocked: true)],
          ),
        ]),
        format: ExportFormat.markdown,
        includeAttachments: true,
      );

      // The only attachment was locked, so nothing was written to the
      // attachments folder — which means there is no second file, and the
      // export stays a single plain file rather than becoming a zip.
      expect(result.isZip, isFalse);
      final text = utf8.decode(result.bytes);
      expect(text, contains('secret.pdf'));
      expect(text, contains('locked'));
    });

    test('the README says the export is not encrypted', () async {
      final result = await service.build(
        labels: englishExportLabels,
        bundleOf([doc(), doc(id: 2)]),
        format: ExportFormat.markdown,
      );

      final archive = readZip(result.bytes);
      final readme = archive.files.firstWhere((f) => f.name == 'README.txt');
      final text = utf8.decode(readme.content as List<int>);
      expect(text, contains('NOT encrypted'));
      expect(text, contains('My Journal'));
      expect(text, contains('2026-08-16'));
    });
  });
}
