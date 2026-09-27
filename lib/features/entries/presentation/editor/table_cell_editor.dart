import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:sreerajp_journal_vault/core/security/keyboard_privacy_scope.dart';
import 'package:sreerajp_journal_vault/features/entries/domain/table_data.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sreerajp_journal_vault/core/security/external_handoff_guard.dart';

/// Shows one table cell's formatted text, read-only.
///
/// Every cell not being edited is drawn this way, so a large pasted table
/// costs one [Text] per cell rather than one editor per cell.
///
/// When [openLinks] is true (read-only screens), tapping a link opens it.
/// Only `http`, `https`, `mailto` and `tel` links are opened.
class TableCellText extends StatefulWidget {
  const TableCellText({
    super.key,
    required this.ops,
    required this.style,
    this.openLinks = false,
  });

  /// The cell's Quill text ops, as stored in [TableData.cells].
  final List<Map<String, dynamic>> ops;
  final TextStyle? style;
  final bool openLinks;

  @override
  State<TableCellText> createState() => _TableCellTextState();
}

class _TableCellTextState extends State<TableCellText> {
  final List<TapGestureRecognizer> _recognizers = [];

  void _disposeRecognizers() {
    for (final recognizer in _recognizers) {
      recognizer.dispose();
    }
    _recognizers.clear();
  }

  @override
  void dispose() {
    _disposeRecognizers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _disposeRecognizers();
    final theme = Theme.of(context);
    final base = widget.style ?? DefaultTextStyle.of(context).style;
    final spans = <InlineSpan>[
      for (final op in widget.ops)
        _spanFor(
          op['insert'] as String,
          op['attributes'] as Map<String, dynamic>?,
          base,
          theme,
        ),
    ];
    return Text.rich(TextSpan(style: base, children: spans));
  }

  TextSpan _spanFor(
    String text,
    Map<String, dynamic>? attributes,
    TextStyle base,
    ThemeData theme,
  ) {
    if (attributes == null) return TextSpan(text: text);

    final decorations = <TextDecoration>[
      if (attributes['underline'] == true) TextDecoration.underline,
      if (attributes['strike'] == true) TextDecoration.lineThrough,
    ];
    final link = attributes['link'] as String?;
    final color = cellColor(attributes['color']);
    final background = cellColor(attributes['background']);
    final script = attributes['script'];
    final isCode = attributes['code'] == true;

    if (link != null) decorations.add(TextDecoration.underline);

    var style = TextStyle(
      fontWeight: attributes['bold'] == true ? FontWeight.bold : null,
      fontStyle: attributes['italic'] == true ? FontStyle.italic : null,
      decoration: decorations.isEmpty
          ? null
          : TextDecoration.combine(decorations),
      color: link != null ? theme.colorScheme.primary : color,
      backgroundColor: isCode
          ? theme.colorScheme.surfaceContainerHighest
          : background,
      fontFamily: isCode ? 'monospace' : null,
    );
    if (script == 'sub' || script == 'super') {
      final size = base.fontSize ?? 14;
      style = style.copyWith(
        fontSize: size * 0.75,
        fontFeatures: [
          script == 'sub'
              ? const FontFeature.subscripts()
              : const FontFeature.superscripts(),
        ],
      );
    }

    TapGestureRecognizer? recognizer;
    if (link != null && widget.openLinks && isOpenableLink(link)) {
      recognizer = TapGestureRecognizer()
        ..onTap = () => ExternalHandoffGuard.instance.run(
          () => launchUrl(Uri.parse(link.trim())),
        );
      _recognizers.add(recognizer);
    }
    return TextSpan(text: text, style: style, recognizer: recognizer);
  }
}

/// True for links a cell may open: `http`, `https`, `mailto` and `tel`.
bool isOpenableLink(String link) {
  final uri = Uri.tryParse(link.trim());
  if (uri == null) return false;
  return const {'http', 'https', 'mailto', 'tel'}.contains(uri.scheme);
}

/// Reads a Quill colour value (`#RRGGBB` or `#AARRGGBB`), or null.
Color? cellColor(Object? value) {
  if (value is! String) return null;
  var hex = value.trim();
  if (!hex.startsWith('#')) return null;
  hex = hex.substring(1);
  if (hex.length == 6) hex = 'FF$hex';
  if (hex.length != 8) return null;
  final parsed = int.tryParse(hex, radix: 16);
  return parsed == null ? null : Color(parsed);
}

/// A live Quill editor for the one table cell being edited.
///
/// It grows with its text (no scrolling of its own), follows the Keyboard
/// privacy switch, and moves between cells with Tab / Shift-Tab.
class TableCellEditor extends StatelessWidget {
  const TableCellEditor({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.scrollController,
    required this.style,
    required this.onTab,
  });

  final QuillController controller;
  final FocusNode focusNode;
  final ScrollController scrollController;
  final TextStyle? style;

  /// Called for Tab (`backwards` false) and Shift-Tab (`backwards` true).
  final void Function({required bool backwards}) onTab;

  @override
  Widget build(BuildContext context) {
    final textStyle = style ?? DefaultTextStyle.of(context).style;
    final styles = DefaultStyles.getInstance(context).merge(
      DefaultStyles(
        paragraph: DefaultTextBlockStyle(
          textStyle,
          HorizontalSpacing.zero,
          VerticalSpacing.zero,
          VerticalSpacing.zero,
          null,
        ),
      ),
    );

    return QuillEditor(
      controller: controller,
      focusNode: focusNode,
      scrollController: scrollController,
      config: QuillEditorConfig(
        scrollable: false,
        enableIMEPersonalizedLearning: KeyboardPrivacyScope.allowLearning(
          context,
        ),
        customStyles: styles,
        // Leaving the cell (tapping the Save button, the title, anything
        // outside the table and the toolbar) ends the edit, which saves the
        // cell into the entry.
        onTapOutside: (event, node) {
          if (node.hasFocus) node.unfocus();
        },
        // Experimental in flutter_quill, but it is the only hook that sees Tab
        // before the editor turns it into a tab character. The copy is
        // vendored in third_party/, so it cannot change under us.
        // ignore: experimental_member_use
        onKeyPressed: (event, node) {
          if (event is! KeyDownEvent && event is! KeyRepeatEvent) return null;
          if (event.logicalKey != LogicalKeyboardKey.tab) return null;
          onTab(backwards: HardwareKeyboard.instance.isShiftPressed);
          return KeyEventResult.handled;
        },
      ),
    );
  }
}
