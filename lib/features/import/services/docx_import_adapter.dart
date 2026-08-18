import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:sreerajp_journal_vault/features/import/services/import_adapter.dart';

/// Imports DOCX files into journal entries.
///
/// DOCX files are ZIP archives containing XML. This adapter extracts
/// text content from `word/document.xml`, preserving paragraph structure
/// and basic formatting (bold, italic).
class DocxImportAdapter extends ImportAdapter {
  @override
  String get formatName => 'Word Document';

  @override
  List<String> get supportedExtensions => ['.docx'];

  @override
  List<String> get supportedMimeTypes => [
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
  ];

  @override
  Future<ImportResult> import(List<int> bytes, String fileName) async {
    final archive = ZipDecoder().decodeBytes(bytes);
    final docXml = _findDocumentXml(archive);

    if (docXml == null) {
      // Fallback: treat as empty document
      return ImportResult(
        title: ImportAdapter.titleFromFileName(fileName),
        contentJson: ImportAdapter.plainTextToQuillJson(''),
        plainText: '',
      );
    }

    final xmlContent = utf8.decode(docXml.content as List<int>);
    final paragraphs = _parseParagraphs(xmlContent);
    final ops = _paragraphsToOps(paragraphs);
    final plainText = paragraphs
        .map((p) => p.runs.map((r) => r.text).join())
        .join('\n');

    return ImportResult(
      title:
          _extractTitle(paragraphs) ??
          ImportAdapter.titleFromFileName(fileName),
      contentJson: jsonEncode(ops),
      plainText: plainText,
    );
  }

  ArchiveFile? _findDocumentXml(Archive archive) {
    for (final file in archive) {
      if (file.name == 'word/document.xml') return file;
    }
    return null;
  }

  /// Extracts the first heading paragraph as the title.
  String? _extractTitle(List<_DocxParagraph> paragraphs) {
    for (final p in paragraphs) {
      if (p.isHeading && p.runs.isNotEmpty) {
        return p.runs.map((r) => r.text).join();
      }
    }
    return null;
  }

  /// Parses paragraphs from the document.xml content.
  ///
  /// Uses simple regex-based XML parsing to avoid heavy XML dependencies.
  /// Handles: `<w:p>` paragraphs, `<w:r>` runs, `<w:t>` text,
  /// `<w:b/>` bold, `<w:i/>` italic, `<w:pStyle>` heading styles.
  List<_DocxParagraph> _parseParagraphs(String xml) {
    final paragraphs = <_DocxParagraph>[];
    final pPattern = RegExp(r'<w:p\b[^>]*>(.*?)</w:p>', dotAll: true);

    for (final pMatch in pPattern.allMatches(xml)) {
      final pContent = pMatch.group(1) ?? '';

      // Check for heading style
      final styleMatch = RegExp(
        r'<w:pStyle\s+w:val="([^"]*)"',
      ).firstMatch(pContent);
      final styleName = styleMatch?.group(1) ?? '';
      final isHeading = styleName.startsWith('Heading');
      int? headingLevel;
      if (isHeading) {
        headingLevel = int.tryParse(styleName.replaceFirst('Heading', '')) ?? 1;
      }

      // Check for list style
      final numIdMatch = RegExp(
        r'<w:numId\s+w:val="(\d+)"',
      ).firstMatch(pContent);
      final isListItem = numIdMatch != null;

      // Extract runs
      final runs = <_DocxRun>[];
      final rPattern = RegExp(r'<w:r\b[^>]*>(.*?)</w:r>', dotAll: true);
      for (final rMatch in rPattern.allMatches(pContent)) {
        final rContent = rMatch.group(1) ?? '';

        // Extract text
        final tPattern = RegExp(r'<w:t[^>]*>(.*?)</w:t>', dotAll: true);
        final textBuffer = StringBuffer();
        for (final tMatch in tPattern.allMatches(rContent)) {
          textBuffer.write(tMatch.group(1) ?? '');
        }
        final text = textBuffer.toString();
        if (text.isEmpty) continue;

        // Check formatting
        final isBold =
            rContent.contains('<w:b/>') || rContent.contains('<w:b ');
        final isItalic =
            rContent.contains('<w:i/>') || rContent.contains('<w:i ');

        runs.add(_DocxRun(text: text, isBold: isBold, isItalic: isItalic));
      }

      paragraphs.add(
        _DocxParagraph(
          runs: runs,
          isHeading: isHeading,
          headingLevel: headingLevel,
          isListItem: isListItem,
        ),
      );
    }

    return paragraphs;
  }

  List<Map<String, dynamic>> _paragraphsToOps(List<_DocxParagraph> paragraphs) {
    final ops = <Map<String, dynamic>>[];

    for (final p in paragraphs) {
      if (p.runs.isEmpty) {
        ops.add({'insert': '\n'});
        continue;
      }

      for (final run in p.runs) {
        final attrs = <String, dynamic>{};
        if (run.isBold) attrs['bold'] = true;
        if (run.isItalic) attrs['italic'] = true;

        if (attrs.isNotEmpty) {
          ops.add({'insert': run.text, 'attributes': attrs});
        } else {
          ops.add({'insert': run.text});
        }
      }

      // Line ending with block-level attributes
      if (p.isHeading && p.headingLevel != null) {
        ops.add({
          'insert': '\n',
          'attributes': {'header': p.headingLevel},
        });
      } else if (p.isListItem) {
        ops.add({
          'insert': '\n',
          'attributes': {'list': 'bullet'},
        });
      } else {
        ops.add({'insert': '\n'});
      }
    }

    if (ops.isEmpty) {
      ops.add({'insert': '\n'});
    }

    return ops;
  }
}

class _DocxParagraph {
  final List<_DocxRun> runs;
  final bool isHeading;
  final int? headingLevel;
  final bool isListItem;

  const _DocxParagraph({
    required this.runs,
    this.isHeading = false,
    this.headingLevel,
    this.isListItem = false,
  });
}

class _DocxRun {
  final String text;
  final bool isBold;
  final bool isItalic;

  const _DocxRun({
    required this.text,
    this.isBold = false,
    this.isItalic = false,
  });
}
