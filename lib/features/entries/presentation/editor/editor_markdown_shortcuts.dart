import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

/// Detects and expands Markdown shorthand syntax in the Quill editor in real-time.
///
/// Supported prefixes at line start:
/// - `# ` to `###### ` -> Headers 1 to 6
/// - `- `, `* `, `+ ` -> Bulleted list
/// - `1. `, `1) ` -> Numbered list
/// - `[] `, `[ ] ` -> Checklist item
/// - `> ` -> Blockquote
/// - ```` ``` ```` -> Code block
class EditorMarkdownShortcuts {
  EditorMarkdownShortcuts();

  static const Map<String, Attribute> shortcuts = {
    '###### ': Attribute.h6,
    '##### ': Attribute.h5,
    '#### ': Attribute.h4,
    '### ': Attribute.h3,
    '## ': Attribute.h2,
    '# ': Attribute.h1,
    '- ': Attribute.ul,
    '* ': Attribute.ul,
    '+ ': Attribute.ul,
    '1. ': Attribute.ol,
    '1) ': Attribute.ol,
    '[] ': Attribute.unchecked,
    '[ ] ': Attribute.unchecked,
    '> ': Attribute.blockQuote,
    '``` ': Attribute.codeBlock,
  };

  bool _isProcessing = false;

  /// Handles incoming document changes. Returns true if a shortcut was expanded.
  bool handleDocChange(QuillController controller, DocChange change) {
    if (_isProcessing) return false;
    if (change.source != ChangeSource.local) return false;

    final selection = controller.selection;
    if (!selection.isCollapsed || selection.baseOffset <= 0) return false;

    final cursorOffset = selection.baseOffset;
    final plainText = controller.document.toPlainText();
    if (cursorOffset > plainText.length) return false;

    // Find the start index of the current line.
    final lineStart = plainText.lastIndexOf('\n', cursorOffset - 1);
    final start = lineStart == -1 ? 0 : lineStart + 1;
    final linePrefix = plainText.substring(start, cursorOffset);

    for (final entry in shortcuts.entries) {
      if (linePrefix == entry.key) {
        _isProcessing = true;
        try {
          // Remove the trigger characters from the line start.
          controller.replaceText(
            start,
            entry.key.length,
            '',
            TextSelection.collapsed(offset: start),
          );
          // Apply the corresponding block style.
          controller.formatSelection(entry.value);
          return true;
        } finally {
          _isProcessing = false;
        }
      }
    }
    return false;
  }
}
