import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:sreerajp_journal_vault/features/entries/presentation/editor/table_cell_editing.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

/// Rich formatting toolbar for the Quill editor.
///
/// Undo and redo are pinned at the start and always visible. The rest scrolls
/// sideways, most-used first: character style, colours, heading and font,
/// lists and indents, alignment, link/code/quote, then the insert buttons.
///
/// While a table cell is being edited (see [cellEditing]), the character
/// buttons — bold, italic, underline, strike, sub/superscript, colours, inline
/// code, link, clear formatting, undo/redo — act on the cell. Buttons that
/// have no meaning inside a cell are greyed out until the edit ends.
class EditorToolbar extends StatelessWidget {
  const EditorToolbar({
    super.key,
    required this.controller,
    this.cellEditing,
    this.onInsertTab,
    this.onInsertTable,
    this.onInsertCallout,
    this.onInsertImage,
    this.onInsertDrawing,
    this.onScanText,
  });

  final QuillController controller;

  /// Reports the table cell being edited, if any.
  final TableCellEditingController? cellEditing;

  /// Inserts a tab character at the caret. Android soft keyboards have no Tab
  /// key, so this button is the only way to type one on a phone.
  final VoidCallback? onInsertTab;
  final VoidCallback? onInsertTable;
  final VoidCallback? onInsertCallout;
  final VoidCallback? onInsertImage;
  final VoidCallback? onInsertDrawing;
  final VoidCallback? onScanText;

  @override
  Widget build(BuildContext context) {
    final cellEditing = this.cellEditing;
    final Widget bar = cellEditing == null
        ? _buildBar(context, controller, inCell: false)
        : ListenableBuilder(
            listenable: cellEditing,
            builder: (context, _) {
              final cellController = cellEditing.activeController;
              return _buildBar(
                context,
                cellController ?? controller,
                inCell: cellController != null,
              );
            },
          );
    // A tap on the toolbar is part of editing, not a tap "outside" the text:
    // without this, pressing Bold would end the table cell's edit first.
    return TextFieldTapRegion(child: bar);
  }

  Widget _buildBar(
    BuildContext context,
    QuillController controller, {
    required bool inCell,
  }) {
    /// A button that only makes sense in the entry body, not in a cell.
    Widget entryOnly(Widget child) {
      if (!inCell) return child;
      return IgnorePointer(child: Opacity(opacity: 0.38, child: child));
    }

    final l10n = AppLocalizations.of(context);

    /// A plain icon button for one of the insert actions.
    Widget insertButton(
      String key,
      IconData icon,
      String tooltip,
      VoidCallback onPressed,
    ) {
      return entryOnly(
        IconButton(
          key: Key(key),
          icon: Icon(icon, size: 20),
          onPressed: onPressed,
          tooltip: tooltip,
          visualDensity: VisualDensity.compact,
        ),
      );
    }

    Widget toggle(Attribute<dynamic> attribute) =>
        QuillToolbarToggleStyleButton(
          controller: controller,
          attribute: attribute,
        );

    final onInsertTab = this.onInsertTab;
    final onInsertTable = this.onInsertTable;
    final onInsertCallout = this.onInsertCallout;
    final onInsertImage = this.onInsertImage;
    final onInsertDrawing = this.onInsertDrawing;
    final onScanText = this.onScanText;
    final hasInsertButtons =
        onInsertTable != null ||
        onInsertCallout != null ||
        onInsertImage != null ||
        onInsertDrawing != null ||
        onScanText != null;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        border: Border(
          top: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        ),
      ),
      child: Row(
        children: [
          // Undo / Redo stay pinned at the start, outside the scrolling part,
          // so they are always one tap away.
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: QuillToolbarHistoryButton(
              controller: controller,
              isUndo: true,
            ),
          ),
          QuillToolbarHistoryButton(controller: controller, isUndo: false),
          _divider(),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(right: 4, top: 2, bottom: 2),
              child: Row(
                children: [
                  // Character style
                  toggle(Attribute.bold),
                  toggle(Attribute.italic),
                  toggle(Attribute.underline),
                  toggle(Attribute.strikeThrough),
                  _divider(),
                  // Text colour / highlight / clear formatting
                  QuillToolbarColorButton(
                    controller: controller,
                    isBackground: false,
                  ),
                  QuillToolbarColorButton(
                    controller: controller,
                    isBackground: true,
                  ),
                  QuillToolbarClearFormatButton(controller: controller),
                  _divider(),
                  // Heading / font family / font size
                  entryOnly(
                    QuillToolbarSelectHeaderStyleDropdownButton(
                      controller: controller,
                    ),
                  ),
                  entryOnly(
                    QuillToolbarFontFamilyButton(controller: controller),
                  ),
                  entryOnly(QuillToolbarFontSizeButton(controller: controller)),
                  _divider(),
                  // Lists, indent and tab
                  entryOnly(toggle(Attribute.ul)),
                  entryOnly(toggle(Attribute.ol)),
                  entryOnly(
                    QuillToolbarToggleCheckListButton(controller: controller),
                  ),
                  entryOnly(
                    QuillToolbarIndentButton(
                      controller: controller,
                      isIncrease: false,
                    ),
                  ),
                  entryOnly(
                    QuillToolbarIndentButton(
                      controller: controller,
                      isIncrease: true,
                    ),
                  ),
                  // Tab character — the soft keyboard has no Tab key.
                  if (onInsertTab != null)
                    insertButton(
                      'editor-insert-tab',
                      Icons.keyboard_tab,
                      l10n.tabEditorInsert,
                      onInsertTab,
                    ),
                  _divider(),
                  // Alignment (left / center / right / justify)
                  entryOnly(toggle(Attribute.leftAlignment)),
                  entryOnly(toggle(Attribute.centerAlignment)),
                  entryOnly(toggle(Attribute.rightAlignment)),
                  entryOnly(toggle(Attribute.justifyAlignment)),
                  _divider(),
                  // Link, code, quote, sub/superscript
                  QuillToolbarLinkStyleButton(controller: controller),
                  toggle(Attribute.inlineCode),
                  entryOnly(toggle(Attribute.codeBlock)),
                  entryOnly(toggle(Attribute.blockQuote)),
                  toggle(Attribute.subscript),
                  toggle(Attribute.superscript),
                  // Insert: table, callout, image, drawing, scanned text
                  if (hasInsertButtons) _divider(),
                  if (onInsertTable != null)
                    insertButton(
                      'editor-insert-table',
                      Icons.table_chart_outlined,
                      l10n.tooltipEditorInsertTable,
                      onInsertTable,
                    ),
                  if (onInsertCallout != null)
                    insertButton(
                      'editor-insert-callout',
                      Icons.info_outline,
                      l10n.tooltipEditorInsertCallout,
                      onInsertCallout,
                    ),
                  if (onInsertImage != null)
                    insertButton(
                      'editor-insert-image',
                      Icons.image_outlined,
                      l10n.tooltipEditorInsertImage,
                      onInsertImage,
                    ),
                  if (onInsertDrawing != null)
                    insertButton(
                      'editor-insert-drawing',
                      Icons.draw_outlined,
                      l10n.tooltipEditorInsertDrawing,
                      onInsertDrawing,
                    ),
                  if (onScanText != null)
                    insertButton(
                      'editor-scan-text',
                      Icons.document_scanner_outlined,
                      l10n.tooltipEntryEditorScanText,
                      onScanText,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => const SizedBox(
    height: 24,
    child: VerticalDivider(width: 8, thickness: 1),
  );
}
