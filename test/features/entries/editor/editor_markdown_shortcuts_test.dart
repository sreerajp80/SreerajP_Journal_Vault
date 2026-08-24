import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_journal_vault/features/entries/presentation/editor/editor_markdown_shortcuts.dart';

void main() {
  group('EditorMarkdownShortcuts', () {
    late QuillController controller;
    late EditorMarkdownShortcuts shortcuts;

    setUp(() {
      controller = QuillController.basic();
      shortcuts = EditorMarkdownShortcuts();
    });

    tearDown(() {
      controller.dispose();
    });

    test('ignores non-local changes', () {
      final change = DocChange(
        Delta()..insert('# '),
        Delta(),
        ChangeSource.remote,
      );
      final handled = shortcuts.handleDocChange(controller, change);
      expect(handled, isFalse);
    });

    test('expands H1 shortcut "# "', () async {
      final sub = controller.document.changes.listen((change) {
        shortcuts.handleDocChange(controller, change);
      });

      controller.replaceText(
        0,
        0,
        '#',
        const TextSelection.collapsed(offset: 1),
      );
      controller.replaceText(
        1,
        0,
        ' ',
        const TextSelection.collapsed(offset: 2),
      );

      await Future<void>.delayed(Duration.zero);

      expect(controller.document.toPlainText(), '\n');
      final deltaJson = controller.document.toDelta().toJson().toString();
      expect(deltaJson.contains('header: 1'), isTrue);

      await sub.cancel();
    });

    test('expands H2 shortcut "## "', () async {
      final sub = controller.document.changes.listen((change) {
        shortcuts.handleDocChange(controller, change);
      });

      controller.replaceText(
        0,
        0,
        '##',
        const TextSelection.collapsed(offset: 2),
      );
      controller.replaceText(
        2,
        0,
        ' ',
        const TextSelection.collapsed(offset: 3),
      );

      await Future<void>.delayed(Duration.zero);

      expect(controller.document.toPlainText(), '\n');
      final deltaJson = controller.document.toDelta().toJson().toString();
      expect(deltaJson.contains('header: 2'), isTrue);

      await sub.cancel();
    });

    test('expands H3 shortcut "### "', () async {
      final sub = controller.document.changes.listen((change) {
        shortcuts.handleDocChange(controller, change);
      });

      controller.replaceText(
        0,
        0,
        '###',
        const TextSelection.collapsed(offset: 3),
      );
      controller.replaceText(
        3,
        0,
        ' ',
        const TextSelection.collapsed(offset: 4),
      );

      await Future<void>.delayed(Duration.zero);

      expect(controller.document.toPlainText(), '\n');
      final deltaJson = controller.document.toDelta().toJson().toString();
      expect(deltaJson.contains('header: 3'), isTrue);

      await sub.cancel();
    });

    test('expands bullet list shortcuts "- ", "* ", "+ "', () async {
      for (final bullet in ['- ', '* ', '+ ']) {
        final ctrl = QuillController.basic();
        final sub = ctrl.document.changes.listen((change) {
          shortcuts.handleDocChange(ctrl, change);
        });

        ctrl.replaceText(
          0,
          0,
          bullet[0],
          const TextSelection.collapsed(offset: 1),
        );
        ctrl.replaceText(1, 0, ' ', const TextSelection.collapsed(offset: 2));

        await Future<void>.delayed(Duration.zero);

        expect(ctrl.document.toPlainText(), '\n');
        final deltaJson = ctrl.document.toDelta().toJson().toString();
        expect(
          deltaJson.contains('list: bullet'),
          isTrue,
          reason: 'failed for $bullet',
        );

        await sub.cancel();
        ctrl.dispose();
      }
    });

    test('expands numbered list shortcut "1. "', () async {
      final sub = controller.document.changes.listen((change) {
        shortcuts.handleDocChange(controller, change);
      });

      controller.replaceText(
        0,
        0,
        '1.',
        const TextSelection.collapsed(offset: 2),
      );
      controller.replaceText(
        2,
        0,
        ' ',
        const TextSelection.collapsed(offset: 3),
      );

      await Future<void>.delayed(Duration.zero);

      expect(controller.document.toPlainText(), '\n');
      final deltaJson = controller.document.toDelta().toJson().toString();
      expect(deltaJson.contains('list: ordered'), isTrue);

      await sub.cancel();
    });

    test('expands checklist shortcuts "[] " and "[ ] "', () async {
      for (final check in ['[] ', '[ ] ']) {
        final ctrl = QuillController.basic();
        final sub = ctrl.document.changes.listen((change) {
          shortcuts.handleDocChange(ctrl, change);
        });

        final prefix = check.substring(0, check.length - 1);
        ctrl.replaceText(
          0,
          0,
          prefix,
          TextSelection.collapsed(offset: prefix.length),
        );
        ctrl.replaceText(
          prefix.length,
          0,
          ' ',
          TextSelection.collapsed(offset: check.length),
        );

        await Future<void>.delayed(Duration.zero);

        expect(ctrl.document.toPlainText(), '\n');
        final deltaJson = ctrl.document.toDelta().toJson().toString();
        expect(
          deltaJson.contains('list: unchecked'),
          isTrue,
          reason: 'failed for $check',
        );

        await sub.cancel();
        ctrl.dispose();
      }
    });

    test('expands blockquote shortcut "> "', () async {
      final sub = controller.document.changes.listen((change) {
        shortcuts.handleDocChange(controller, change);
      });

      controller.replaceText(
        0,
        0,
        '>',
        const TextSelection.collapsed(offset: 1),
      );
      controller.replaceText(
        1,
        0,
        ' ',
        const TextSelection.collapsed(offset: 2),
      );

      await Future<void>.delayed(Duration.zero);

      expect(controller.document.toPlainText(), '\n');
      final deltaJson = controller.document.toDelta().toJson().toString();
      expect(deltaJson.contains('blockquote: true'), isTrue);

      await sub.cancel();
    });

    test('expands code block shortcut "``` "', () async {
      final sub = controller.document.changes.listen((change) {
        shortcuts.handleDocChange(controller, change);
      });

      controller.replaceText(
        0,
        0,
        '```',
        const TextSelection.collapsed(offset: 3),
      );
      controller.replaceText(
        3,
        0,
        ' ',
        const TextSelection.collapsed(offset: 4),
      );

      await Future<void>.delayed(Duration.zero);

      expect(controller.document.toPlainText(), '\n');
      final deltaJson = controller.document.toDelta().toJson().toString();
      expect(deltaJson.contains('code-block: true'), isTrue);

      await sub.cancel();
    });

    test('does not expand if trigger is in the middle of a line', () async {
      final sub = controller.document.changes.listen((change) {
        shortcuts.handleDocChange(controller, change);
      });

      controller.replaceText(
        0,
        0,
        'Word #',
        const TextSelection.collapsed(offset: 6),
      );
      controller.replaceText(
        6,
        0,
        ' ',
        const TextSelection.collapsed(offset: 7),
      );

      await Future<void>.delayed(Duration.zero);

      expect(controller.document.toPlainText(), 'Word # \n');
      final deltaJson = controller.document.toDelta().toJson().toString();
      expect(deltaJson.contains('header: 1'), isFalse);

      await sub.cancel();
    });
  });
}
