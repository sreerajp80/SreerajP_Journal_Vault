import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

/// Rich formatting toolbar for the Quill editor.
///
/// Provides buttons for headings, fonts, character formatting,
/// colors, alignment, lists, indents, code, links, quotes,
/// tables, callouts, and undo/redo.
class EditorToolbar extends StatelessWidget {
  const EditorToolbar({
    super.key,
    required this.controller,
    this.onInsertTable,
    this.onInsertCallout,
    this.onInsertImage,
  });

  final QuillController controller;
  final VoidCallback? onInsertTable;
  final VoidCallback? onInsertCallout;
  final VoidCallback? onInsertImage;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        border: Border(
          top: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Row(
          children: [
            // Heading dropdown
            QuillToolbarSelectHeaderStyleDropdownButton(controller: controller),
            _divider(),
            // Font family / size
            QuillToolbarFontFamilyButton(controller: controller),
            QuillToolbarFontSizeButton(controller: controller),
            _divider(),
            // Bold / Italic / Underline / Strikethrough
            QuillToolbarToggleStyleButton(
              controller: controller,
              attribute: Attribute.bold,
            ),
            QuillToolbarToggleStyleButton(
              controller: controller,
              attribute: Attribute.italic,
            ),
            QuillToolbarToggleStyleButton(
              controller: controller,
              attribute: Attribute.underline,
            ),
            QuillToolbarToggleStyleButton(
              controller: controller,
              attribute: Attribute.strikeThrough,
            ),
            // Subscript / Superscript
            QuillToolbarToggleStyleButton(
              controller: controller,
              attribute: Attribute.subscript,
            ),
            QuillToolbarToggleStyleButton(
              controller: controller,
              attribute: Attribute.superscript,
            ),
            _divider(),
            // Text color / Background highlight
            QuillToolbarColorButton(
              controller: controller,
              isBackground: false,
            ),
            QuillToolbarColorButton(controller: controller, isBackground: true),
            // Clear formatting
            QuillToolbarClearFormatButton(controller: controller),
            _divider(),
            // Lists
            QuillToolbarToggleStyleButton(
              controller: controller,
              attribute: Attribute.ul,
            ),
            QuillToolbarToggleStyleButton(
              controller: controller,
              attribute: Attribute.ol,
            ),
            // Checklist
            QuillToolbarToggleCheckListButton(controller: controller),
            // Indent / Outdent
            QuillToolbarIndentButton(controller: controller, isIncrease: false),
            QuillToolbarIndentButton(controller: controller, isIncrease: true),
            _divider(),
            // Alignment (left / center / right / justify)
            QuillToolbarToggleStyleButton(
              controller: controller,
              attribute: Attribute.leftAlignment,
            ),
            QuillToolbarToggleStyleButton(
              controller: controller,
              attribute: Attribute.centerAlignment,
            ),
            QuillToolbarToggleStyleButton(
              controller: controller,
              attribute: Attribute.rightAlignment,
            ),
            QuillToolbarToggleStyleButton(
              controller: controller,
              attribute: Attribute.justifyAlignment,
            ),
            _divider(),
            // Code block
            QuillToolbarToggleStyleButton(
              controller: controller,
              attribute: Attribute.codeBlock,
            ),
            // Inline code
            QuillToolbarToggleStyleButton(
              controller: controller,
              attribute: Attribute.inlineCode,
            ),
            // Block quote
            QuillToolbarToggleStyleButton(
              controller: controller,
              attribute: Attribute.blockQuote,
            ),
            // Link
            QuillToolbarLinkStyleButton(controller: controller),
            _divider(),
            // Table insert
            if (onInsertTable != null)
              IconButton(
                key: const Key('editor-insert-table'),
                icon: const Icon(Icons.table_chart_outlined, size: 20),
                onPressed: onInsertTable,
                tooltip: AppLocalizations.of(context).editorInsertTable,
                visualDensity: VisualDensity.compact,
              ),
            // Callout insert
            if (onInsertCallout != null)
              IconButton(
                key: const Key('editor-insert-callout'),
                icon: const Icon(Icons.info_outline, size: 20),
                onPressed: onInsertCallout,
                tooltip: AppLocalizations.of(context).editorInsertCallout,
                visualDensity: VisualDensity.compact,
              ),
            // Inline image insert
            if (onInsertImage != null)
              IconButton(
                key: const Key('editor-insert-image'),
                icon: const Icon(Icons.image_outlined, size: 20),
                onPressed: onInsertImage,
                tooltip: AppLocalizations.of(context).editorInsertImage,
                visualDensity: VisualDensity.compact,
              ),
            _divider(),
            // Undo / Redo
            QuillToolbarHistoryButton(controller: controller, isUndo: true),
            QuillToolbarHistoryButton(controller: controller, isUndo: false),
          ],
        ),
      ),
    );
  }

  Widget _divider() => const SizedBox(
    height: 24,
    child: VerticalDivider(width: 8, thickness: 1),
  );
}
