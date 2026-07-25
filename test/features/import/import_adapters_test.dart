import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_journal_vault/features/import/services/docx_import_adapter.dart';
import 'package:sreerajp_journal_vault/features/import/services/import_adapter.dart';
import 'package:sreerajp_journal_vault/features/import/services/markdown_import_adapter.dart';
import 'package:sreerajp_journal_vault/features/import/services/plain_text_import_adapter.dart';

/// Slice E coverage for the import adapters that map external file formats
/// onto Quill delta JSON + plain text.
void main() {
  group('PlainTextImportAdapter', () {
    final adapter = PlainTextImportAdapter();

    test('declares the .txt format', () {
      expect(adapter.formatName, 'Plain Text');
      expect(adapter.supportedExtensions, contains('.txt'));
      expect(adapter.supportedMimeTypes, contains('text/plain'));
    });

    test('imports each line as its own paragraph op', () async {
      final result = await adapter.import(
        utf8.encode('hello\nworld'),
        'note.txt',
      );

      expect(result.title, 'note');
      expect(result.plainText, 'hello\nworld');
      final ops = jsonDecode(result.contentJson) as List;
      expect(ops, hasLength(2));
      expect(ops.first['insert'], 'hello\n');
      expect(ops.last['insert'], 'world\n');
    });

    test('falls back to a single newline op for empty input', () async {
      final result = await adapter.import(<int>[], 'empty.txt');
      final ops = jsonDecode(result.contentJson) as List;
      expect(ops, isNotEmpty);
      // Either one '\n' op OR an op containing just '\n' is acceptable.
      final inserts = ops.map((o) => o['insert']).join();
      expect(inserts, '\n');
    });

    test('strips the extension from the filename for the title', () async {
      final result = await adapter.import(utf8.encode('x'), 'My Notes.txt');
      expect(result.title, 'My Notes');
    });
  });

  group('MarkdownImportAdapter', () {
    final adapter = MarkdownImportAdapter();

    test('declares the .md format', () {
      expect(adapter.formatName, 'Markdown');
      expect(adapter.supportedExtensions, containsAll(['.md', '.markdown']));
    });

    test('uses the first H1 heading as the title', () async {
      final result = await adapter.import(
        utf8.encode('# My Title\n\nbody text'),
        'fallback.md',
      );
      expect(result.title, 'My Title');
    });

    test('falls back to filename when there is no H1', () async {
      final result = await adapter.import(
        utf8.encode('## subheading only\n\nbody'),
        'no-title.md',
      );
      expect(result.title, 'no-title');
    });

    test('headings are emitted as header attribute ops', () async {
      final result = await adapter.import(
        utf8.encode('# H1\n## H2\n### H3\n'),
        'h.md',
      );
      final ops = jsonDecode(result.contentJson) as List;
      // Find header lines.
      final headerLevels = ops
          .where((o) => o['attributes']?['header'] != null)
          .map<int>((o) => o['attributes']['header'] as int)
          .toList();
      expect(headerLevels, [1, 2, 3]);
    });

    test('bold and italic spans become inline attributes', () async {
      final result = await adapter.import(
        utf8.encode('**bold** and *italic* text'),
        'fmt.md',
      );
      final ops = jsonDecode(result.contentJson) as List;
      final boldOps =
          ops.where((o) => o['attributes']?['bold'] == true).toList();
      final italicOps =
          ops.where((o) => o['attributes']?['italic'] == true).toList();
      expect(boldOps.first['insert'], 'bold');
      expect(italicOps.first['insert'], 'italic');
    });

    test('blockquotes and lists get their respective attributes', () async {
      final result = await adapter.import(
        utf8.encode('> quote line\n- item 1\n- item 2\n1. ordered\n'),
        'b.md',
      );
      final ops = jsonDecode(result.contentJson) as List;
      final blockquotes = ops.where(
        (o) => o['attributes']?['blockquote'] == true,
      );
      final bullets = ops.where(
        (o) => o['attributes']?['list'] == 'bullet',
      );
      final ordered = ops.where(
        (o) => o['attributes']?['list'] == 'ordered',
      );
      expect(blockquotes, hasLength(1));
      expect(bullets, hasLength(2));
      expect(ordered, hasLength(1));
    });

    test('plainText output strips markdown syntax', () async {
      final result = await adapter.import(
        utf8.encode('# Title\n\nA **bold** *italic* line.\n'),
        'p.md',
      );
      expect(result.plainText, contains('Title'));
      expect(result.plainText, contains('A bold italic line.'));
      expect(result.plainText.contains('**'), isFalse);
      expect(result.plainText.contains('*'), isFalse);
    });

    test('inline code is preserved as a code attribute span', () async {
      final result = await adapter.import(
        utf8.encode('Run `flutter test` now.'),
        'c.md',
      );
      final ops = jsonDecode(result.contentJson) as List;
      final code = ops.firstWhere(
        (o) => o['attributes']?['code'] == true,
        orElse: () => {},
      );
      expect(code['insert'], 'flutter test');
    });
  });

  group('DocxImportAdapter', () {
    final adapter = DocxImportAdapter();

    test('declares the .docx format', () {
      expect(adapter.formatName, 'Word Document');
      expect(adapter.supportedExtensions, contains('.docx'));
      expect(adapter.supportedMimeTypes, contains(
        'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      ));
    });

    test('parses paragraphs from a minimal docx archive', () async {
      // Build a minimal valid docx in memory: a ZIP with word/document.xml.
      final docXml = '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
  <w:body>
    <w:p><w:r><w:t>Hello</w:t></w:r></w:p>
    <w:p><w:r><w:t>World</w:t></w:r></w:p>
  </w:body>
</w:document>''';
      final archive = Archive()
        ..addFile(ArchiveFile(
          'word/document.xml',
          utf8.encode(docXml).length,
          utf8.encode(docXml),
        ));
      final bytes = ZipEncoder().encode(archive);

      final result = await adapter.import(bytes, 'doc.docx');
      expect(result.title, 'doc');
      expect(result.plainText, contains('Hello'));
      expect(result.plainText, contains('World'));
    });

    test('emits an empty Quill delta when document.xml is missing',
        () async {
      // Build a docx without word/document.xml.
      final archive = Archive()
        ..addFile(ArchiveFile('garbage.txt', 4, utf8.encode('text')));
      final bytes = ZipEncoder().encode(archive);

      final result = await adapter.import(bytes, 'broken.docx');
      expect(result.title, 'broken');
      expect(result.plainText, '');
      // contentJson should still be parseable as a list of ops.
      expect(jsonDecode(result.contentJson), isA<List>());
    });
  });

  group('ImportAdapter helpers', () {
    test('plainTextToQuillJson always produces a non-empty op list', () {
      final empty = ImportAdapter.plainTextToQuillJson('');
      final ops = jsonDecode(empty) as List;
      expect(ops, isNotEmpty);
    });

    test('titleFromFileName drops the last extension only', () {
      expect(ImportAdapter.titleFromFileName('a.b.c.txt'), 'a.b.c');
      expect(ImportAdapter.titleFromFileName('noext'), 'noext');
      expect(ImportAdapter.titleFromFileName('.dot'), '.dot');
    });
  });
}
