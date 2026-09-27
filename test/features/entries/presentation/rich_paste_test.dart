// The clipboard service seam is marked experimental in flutter_quill; the
// vendored copy cannot change under this test.
// ignore_for_file: experimental_member_use

import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/internal.dart'
    show ClipboardService, ClipboardServiceProvider;
import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_journal_vault/features/entries/domain/table_data.dart';
import 'package:sreerajp_journal_vault/features/entries/presentation/editor/rich_paste_config.dart';

/// A clipboard that holds [html] (or no HTML at all).
class _FakeClipboard extends ClipboardService {
  _FakeClipboard(this.html);

  final String? html;

  @override
  Future<String?> getHtmlText() async => html;

  @override
  Future<String?> getHtmlFile() async => null;

  @override
  Future<String?> getMarkdownFile() async => null;

  @override
  Future<Uint8List?> getImageFile() async => null;

  @override
  Future<Uint8List?> getGifFile() async => null;

  @override
  Future<void> copyImage(Uint8List imageBytes) async {}
}

QuillController _controller(String text) {
  late final QuillController controller;
  controller = QuillController(
    // Loaded, not typed, so the starting text is not an Undo step.
    document: Document.fromJson([
      {'insert': '$text\n'},
    ]),
    selection: TextSelection.collapsed(offset: text.length),
    config: RichPaste.controllerConfig(() => controller),
  );
  return controller;
}

List<Map<String, dynamic>> _ops(QuillController c) =>
    c.document.toDelta().toJson().cast<Map<String, dynamic>>();

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  tearDown(ClipboardServiceProvider.setInstanceToDefault);

  test('Paste keeps formatting and tables from clipboard HTML', () async {
    ClipboardServiceProvider.setInstance(
      _FakeClipboard(
        '<p><b>Bold</b> words</p>'
        '<table><tr><th>A</th></tr><tr><td>1</td></tr></table>',
      ),
    );
    final controller = _controller('Start ');

    // The editor's Paste button and long-press Paste both call this.
    expect(await controller.clipboardPaste(), isTrue);

    final ops = _ops(controller);
    expect(controller.document.toPlainText(), startsWith('Start Bold words\n'));
    expect(ops.firstWhere((op) => op['insert'] == 'Bold')['attributes'], {
      'bold': true,
    });
    final table = ops.firstWhere((op) => op['insert'] is Map)['insert'] as Map;
    expect(TableData.tryParse(table[TableData.tableEmbedType])!.plainRows, [
      ['A'],
      ['1'],
    ]);
  });

  test('without HTML on the clipboard, the normal paste runs', () async {
    ClipboardServiceProvider.setInstance(_FakeClipboard(null));
    final controller = _controller('x');
    expect(await RichPaste.pasteHtml(controller), isFalse);
    expect(controller.document.toPlainText(), 'x\n');
  });

  test('HTML with nothing usable falls back to the normal paste', () async {
    ClipboardServiceProvider.setInstance(
      _FakeClipboard('<img src="https://example.com/a.png">'),
    );
    final controller = _controller('x');
    expect(await RichPaste.pasteHtml(controller), isFalse);
  });

  test('a read-only editor is never pasted into', () async {
    ClipboardServiceProvider.setInstance(_FakeClipboard('<p>hi</p>'));
    final controller = _controller('x')..readOnly = true;
    expect(await RichPaste.pasteHtml(controller), isFalse);
    expect(controller.document.toPlainText(), 'x\n');
  });

  test('a single pasted paragraph adds no line break', () async {
    ClipboardServiceProvider.setInstance(_FakeClipboard('<p>word</p>'));
    final controller = _controller('a ');
    expect(await RichPaste.pasteHtml(controller), isTrue);
    expect(controller.document.toPlainText(), 'a word\n');
    expect(controller.selection.baseOffset, 6);
  });

  test('pasting replaces the selection and is one Undo step', () async {
    ClipboardServiceProvider.setInstance(_FakeClipboard('<p><i>new</i></p>'));
    final controller = _controller('old text')
      ..updateSelection(
        const TextSelection(baseOffset: 0, extentOffset: 3),
        ChangeSource.local,
      );
    expect(await RichPaste.pasteHtml(controller), isTrue);
    expect(controller.document.toPlainText(), 'new text\n');
    controller.undo();
    expect(controller.document.toPlainText(), 'old text\n');
  });

  test('pasting into a table cell keeps only inline formatting', () async {
    ClipboardServiceProvider.setInstance(
      _FakeClipboard(
        '<h1>Title</h1><table><tr><td><b>a</b></td><td>b</td></tr></table>',
      ),
    );
    late final QuillController cell;
    cell = QuillController(
      document: Document(),
      selection: const TextSelection.collapsed(offset: 0),
      config: RichPaste.controllerConfig(() => cell, inlineOnly: true),
    );
    expect(await cell.clipboardPaste(), isTrue);
    final ops = _ops(cell);
    expect(ops.where((op) => op['insert'] is Map), isEmpty);
    for (final op in ops) {
      final attributes = op['attributes'] as Map<String, dynamic>?;
      expect(attributes?.containsKey('header') ?? false, isFalse);
    }
    expect(cell.document.toPlainText(), contains('Title'));
    expect(ops.firstWhere((op) => op['insert'] == 'a')['attributes'], {
      'bold': true,
    });
  });
}
