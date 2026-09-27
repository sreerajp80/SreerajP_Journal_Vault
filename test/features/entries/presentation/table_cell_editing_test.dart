import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_journal_vault/core/security/keyboard_privacy_scope.dart';
import 'package:sreerajp_journal_vault/features/entries/domain/table_data.dart';
import 'package:sreerajp_journal_vault/features/entries/presentation/editor/editor_toolbar.dart';
import 'package:sreerajp_journal_vault/features/entries/presentation/editor/table_cell_editing.dart';
import 'package:sreerajp_journal_vault/features/entries/presentation/editor/table_embed.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

/// Covers editing a table cell with its own small Quill editor, and the
/// toolbar formatting that cell.
///
/// The harness mirrors the entry editor: the entry's QuillEditor with the
/// table embed builder, the formatting toolbar, and one shared
/// [TableCellEditingController] that is cleared when the entry's own editor
/// takes focus.
class _Harness extends StatefulWidget {
  const _Harness({
    required this.controller,
    required this.cellEditing,
    this.keyboardPrivacy = false,
  });

  final QuillController controller;
  final TableCellEditingController cellEditing;
  final bool keyboardPrivacy;

  @override
  State<_Harness> createState() => _HarnessState();
}

class _HarnessState extends State<_Harness> {
  final FocusNode focusNode = FocusNode(debugLabel: 'entry');
  final ScrollController scrollController = ScrollController();
  late final List<EmbedBuilder> builders = [
    TableEmbedBuilder(cellEditing: widget.cellEditing),
  ];

  @override
  void initState() {
    super.initState();
    focusNode.addListener(() {
      if (focusNode.hasFocus) widget.cellEditing.clear();
    });
  }

  @override
  void dispose() {
    focusNode.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        FlutterQuillLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],
      home: KeyboardPrivacyScope(
        enabled: widget.keyboardPrivacy,
        child: Scaffold(
          body: Column(
            children: [
              Expanded(
                child: QuillEditor(
                  controller: widget.controller,
                  focusNode: focusNode,
                  scrollController: scrollController,
                  config: QuillEditorConfig(
                    embedBuilders: builders,
                    onTapDown: widget.cellEditing.entryTapHooks.onTapDown,
                    onTapUp: widget.cellEditing.entryTapHooks.onTapUp,
                  ),
                ),
              ),
              EditorToolbar(
                controller: widget.controller,
                cellEditing: widget.cellEditing,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

QuillController _controllerWithTable(TableData table) {
  return QuillController(
    document: Document.fromJson([
      {'insert': 'Before\n'},
      {
        'insert': {'table': table.toJsonString()},
      },
      {'insert': 'After\n'},
    ]),
    selection: const TextSelection.collapsed(offset: 0),
  );
}

/// The table currently stored in [controller]'s document.
TableData _storedTable(QuillController controller) {
  for (final op in controller.document.toDelta().toJson()) {
    final insert = op['insert'];
    if (insert is Map && insert['table'] is String) {
      return TableData.tryParse(insert['table'])!;
    }
  }
  fail('no table in the document');
}

Future<void> _pumpHarness(
  WidgetTester tester, {
  required QuillController controller,
  required TableCellEditingController cellEditing,
  bool keyboardPrivacy = false,
}) async {
  await tester.binding.setSurfaceSize(const Size(1000, 1200));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    _Harness(
      controller: controller,
      cellEditing: cellEditing,
      keyboardPrivacy: keyboardPrivacy,
    ),
  );
  await tester.pumpAndSettle();
}

/// Finds the live editor of the cell being edited (the entry's editor is the
/// first QuillEditor).
QuillEditor _cellEditor(WidgetTester tester) =>
    tester.widgetList<QuillEditor>(find.byType(QuillEditor)).last;

void main() {
  late TableCellEditingController cellEditing;

  setUp(() => cellEditing = TableCellEditingController());
  tearDown(() => cellEditing.dispose());

  testWidgets('shows a cell with its formatting', (tester) async {
    final controller = _controllerWithTable(
      TableData(
        cells: [
          [
            [
              {'insert': 'Head'},
            ],
          ],
          [
            [
              {
                'insert': 'Bold',
                'attributes': {'bold': true},
              },
              {'insert': ' plain'},
            ],
          ],
        ],
      ),
    );
    await _pumpHarness(
      tester,
      controller: controller,
      cellEditing: cellEditing,
    );

    final text = tester.widget<RichText>(
      find.text('Bold plain', findRichText: true),
    );
    final span = text.text as TextSpan;
    final bold = (span.children!.first as TextSpan).children!.first as TextSpan;
    expect(bold.text, 'Bold');
    expect(bold.style?.fontWeight, FontWeight.bold);
  });

  testWidgets(
    'tapping a cell opens an editor; the toolbar formats the cell; leaving '
    'the cell writes it back as a rich table',
    (tester) async {
      final controller = _controllerWithTable(
        TableData.fromPlainRows([
          ['H1', 'H2'],
          ['A', 'B'],
        ]),
      );
      await _pumpHarness(
        tester,
        controller: controller,
        cellEditing: cellEditing,
      );
      expect(find.byType(QuillEditor), findsOneWidget);

      await tester.tap(find.text('A', findRichText: true));
      await tester.pumpAndSettle();

      // One live cell editor, and the toolbar now works on it.
      expect(find.byType(QuillEditor), findsNWidgets(2));
      final cell = _cellEditor(tester);
      expect(cell.focusNode.hasFocus, isTrue);
      expect(cellEditing.activeController, same(cell.controller));

      // Type into the cell and make it bold from the toolbar.
      cell.controller.replaceText(
        1,
        0,
        'nu',
        const TextSelection.collapsed(offset: 3),
      );
      cell.controller.updateSelection(
        const TextSelection(baseOffset: 0, extentOffset: 3),
        ChangeSource.local,
      );
      await tester.pump();
      await tester.tap(find.byIcon(Icons.format_bold));
      await tester.pumpAndSettle();

      // Pressing a toolbar button must not end the edit.
      expect(_cellEditor(tester).focusNode.hasFocus, isTrue);
      // Nothing is written back while the cell is being typed in.
      expect(_storedTable(controller).plainRows[1][0], 'A');

      // Back to the entry body: the edit ends and the cell is written back.
      final entry = tester
          .widgetList<QuillEditor>(find.byType(QuillEditor))
          .first;
      entry.focusNode.requestFocus();
      await tester.pumpAndSettle();

      expect(find.byType(QuillEditor), findsOneWidget);
      expect(cellEditing.isEditingCell, isFalse);
      final stored = _storedTable(controller);
      expect(stored.plainRows, [
        ['H1', 'H2'],
        ['Anu', 'B'],
      ]);
      expect(stored.cells[1][0], [
        {
          'insert': 'Anu',
          'attributes': {'bold': true},
        },
      ]);
      // Older app versions read `rows`; it must hold the words.
      final raw = controller.document
          .toDelta()
          .toJson()
          .map((op) => op['insert'])
          .whereType<Map>()
          .single['table'];
      expect(jsonDecode(raw as String)['rows'], stored.plainRows);
    },
  );

  testWidgets('Tab moves to the next cell and adds a row at the end', (
    tester,
  ) async {
    final controller = _controllerWithTable(
      TableData.fromPlainRows([
        ['H1', 'H2'],
        ['A', 'B'],
      ]),
    );
    await _pumpHarness(
      tester,
      controller: controller,
      cellEditing: cellEditing,
    );

    await tester.tap(find.text('B', findRichText: true));
    await tester.pumpAndSettle();
    _cellEditor(tester).controller.replaceText(
      1,
      0,
      'x',
      const TextSelection.collapsed(offset: 2),
    );
    await tester.pump();

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();

    // The last cell was left, so it was written back, and a row was added.
    final stored = _storedTable(controller);
    expect(stored.plainRows, [
      ['H1', 'H2'],
      ['A', 'Bx'],
      ['', ''],
    ]);
    // The new row's first cell is now being edited.
    final cell = _cellEditor(tester);
    expect(cell.focusNode.hasFocus, isTrue);
    expect(cell.controller.document.toPlainText(), '\n');

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
    expect(_cellEditor(tester).focusNode.hasFocus, isTrue);
    expect(_storedTable(controller).rowCount, 3);
  });

  testWidgets(
    'moving between cells writes each one back, including an undo to the '
    'original text',
    (tester) async {
      final controller = _controllerWithTable(
        TableData.fromPlainRows([
          ['H1', 'H2'],
          ['A', 'B'],
        ]),
      );
      await _pumpHarness(
        tester,
        controller: controller,
        cellEditing: cellEditing,
      );

      await tester.tap(find.text('A', findRichText: true));
      await tester.pumpAndSettle();
      _cellEditor(tester).controller.replaceText(
        1,
        0,
        'x',
        const TextSelection.collapsed(offset: 2),
      );
      await tester.tap(find.text('B', findRichText: true));
      await tester.pumpAndSettle();
      expect(_storedTable(controller).plainRows[1], ['Ax', 'B']);

      // Back to the first cell, and remove the typed letter again.
      await tester.tap(find.text('Ax', findRichText: true));
      await tester.pumpAndSettle();
      _cellEditor(tester).controller.replaceText(
        1,
        1,
        '',
        const TextSelection.collapsed(offset: 1),
      );
      await tester.tap(find.text('B', findRichText: true));
      await tester.pumpAndSettle();

      expect(_storedTable(controller).plainRows[1], ['A', 'B']);
      // The document still holds exactly one table, with the text around it.
      final plain = controller.document.toPlainText();
      expect(plain, startsWith('Before\n'));
      expect(plain, endsWith('After\n'));
      expect(
        controller.document.toDelta().toJson().where(
          (op) => op['insert'] is Map,
        ),
        hasLength(1),
      );
      // Let the editor's double-tap timer run out.
      await tester.pump(const Duration(milliseconds: 500));
    },
  );

  testWidgets('the cell editor follows the Keyboard privacy switch', (
    tester,
  ) async {
    final controller = _controllerWithTable(
      TableData.fromPlainRows([
        ['H'],
        ['A'],
      ]),
    );
    await _pumpHarness(
      tester,
      controller: controller,
      cellEditing: cellEditing,
      keyboardPrivacy: true,
    );
    await tester.tap(find.text('A', findRichText: true));
    await tester.pumpAndSettle();
    expect(_cellEditor(tester).config.enableIMEPersonalizedLearning, isFalse);
  });

  testWidgets('block-only toolbar buttons are disabled inside a cell', (
    tester,
  ) async {
    final controller = _controllerWithTable(
      TableData.fromPlainRows([
        ['H'],
        ['A'],
      ]),
    );
    await _pumpHarness(
      tester,
      controller: controller,
      cellEditing: cellEditing,
    );

    IgnorePointer listButtonBlocker() => tester.widget<IgnorePointer>(
      find
          .ancestor(
            of: find.byIcon(Icons.format_list_bulleted),
            matching: find.byType(IgnorePointer),
          )
          .first,
    );

    expect(
      find.ancestor(
        of: find.byIcon(Icons.format_list_bulleted),
        matching: find.byWidgetPredicate((w) => w is Opacity && w.opacity < 1),
      ),
      findsNothing,
    );

    await tester.tap(find.text('A', findRichText: true));
    await tester.pumpAndSettle();

    expect(listButtonBlocker().ignoring, isTrue);
    expect(
      find.ancestor(
        of: find.byIcon(Icons.format_list_bulleted),
        matching: find.byWidgetPredicate((w) => w is Opacity && w.opacity < 1),
      ),
      findsOneWidget,
    );
  });

  test('toPlainText gives the table words for search', () {
    final builder = TableEmbedBuilder();
    final table = TableEmbed.fromRows([
      ['Name', 'City'],
      ['Anu', 'Kochi'],
    ]);
    final text = builder.toPlainText(Embed(table));
    expect(text, 'Name City\nAnu Kochi\n');
  });
}
