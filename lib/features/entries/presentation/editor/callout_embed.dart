import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

/// Custom embeddable block type for callout/admonition blocks.
///
/// Callouts appear as highlighted boxes with an icon and text content,
/// used for tips, warnings, notes, and important information.
class CalloutEmbed extends CustomBlockEmbed {
  const CalloutEmbed(String data) : super(calloutType, data);

  static const String calloutType = 'callout';

  /// The callout style: 'info', 'warning', 'tip', or 'important'.
  String get style {
    final map = jsonDecode(data) as Map<String, dynamic>;
    return map['style'] as String? ?? 'info';
  }

  /// The text content of the callout.
  String get text {
    final map = jsonDecode(data) as Map<String, dynamic>;
    return map['text'] as String? ?? '';
  }

  factory CalloutEmbed.create({String style = 'info', String text = ''}) {
    return CalloutEmbed(jsonEncode({'style': style, 'text': text}));
  }
}

/// Builds the visual representation of a [CalloutEmbed] in the editor.
class CalloutEmbedBuilder extends EmbedBuilder {
  @override
  String get key => CalloutEmbed.calloutType;

  @override
  Widget build(BuildContext context, EmbedContext embedContext) {
    final data =
        jsonDecode(embedContext.node.value.data as String)
            as Map<String, dynamic>;
    final style = data['style'] as String? ?? 'info';
    final text = data['text'] as String? ?? '';

    return _CalloutBlock(
      style: style,
      text: text,
      readOnly: embedContext.readOnly,
      // node.documentOffset is the embed's authoritative position; the
      // built-in getEmbedNode helper reads from controller.selection.start
      // which can drift away from the embed once the inner field has focus.
      onCommit: embedContext.readOnly
          ? null
          : (newText) {
              if (newText == text) return;
              final offset = embedContext.node.documentOffset;
              embedContext.controller.replaceText(
                offset,
                1,
                CalloutEmbed.create(style: style, text: newText),
                null,
                ignoreFocus: true,
              );
            },
      onDelete: embedContext.readOnly
          ? null
          : () {
              final offset = embedContext.node.documentOffset;
              embedContext.controller.replaceText(
                offset,
                1,
                '',
                TextSelection.collapsed(offset: offset),
              );
            },
    );
  }
}

class _CalloutBlock extends StatefulWidget {
  const _CalloutBlock({
    required this.style,
    required this.text,
    required this.readOnly,
    this.onCommit,
    this.onDelete,
  });

  final String style;
  final String text;
  final bool readOnly;

  /// Called once on focus loss to write the field's text back into the embed.
  /// Replacing the embed on every keystroke causes the surrounding editor to
  /// rebuild mid-input, which destroys focus and creates duplicate-looking
  /// renders — so commit happens at blur, not per character.
  final ValueChanged<String>? onCommit;

  final VoidCallback? onDelete;

  @override
  State<_CalloutBlock> createState() => _CalloutBlockState();
}

class _CalloutBlockState extends State<_CalloutBlock> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.text);
    _focusNode = FocusNode(debugLabel: 'CalloutTextField');
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void didUpdateWidget(covariant _CalloutBlock oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Echo of our own commit: text already matches, leave the cursor alone.
    // Only resync when an external source (e.g. revision restore) changes it.
    if (widget.text != _controller.text && !_focusNode.hasFocus) {
      _controller.value = TextEditingValue(
        text: widget.text,
        selection: TextSelection.collapsed(offset: widget.text.length),
      );
    }
  }

  @override
  void dispose() {
    if (_focusNode.hasFocus) {
      // Final commit if the screen is being torn down while we still hold focus.
      widget.onCommit?.call(_controller.text);
    }
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (!_focusNode.hasFocus) {
      widget.onCommit?.call(_controller.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (icon, color) = _styleAttributes(theme);

    final body = Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: widget.readOnly
                ? Text(widget.text, style: theme.textTheme.bodyMedium)
                : TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      hintText: AppLocalizations.of(context).editorCalloutHint,
                    ),
                    maxLines: null,
                    style: theme.textTheme.bodyMedium,
                    // Default tap-outside would only unfocus among text fields;
                    // calling unfocus() ourselves drops focus to the root scope,
                    // which lets the surrounding editor reclaim focus cleanly
                    // and triggers our commit listener.
                    onTapOutside: (_) {
                      if (_focusNode.hasFocus) _focusNode.unfocus();
                    },
                  ),
          ),
          if (!widget.readOnly && widget.onDelete != null) ...[
            const SizedBox(width: 4),
            InkWell(
              key: const Key('callout-delete-button'),
              onTap: widget.onDelete,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(
                  Icons.close,
                  size: 18,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ],
      ),
    );

    // TextFieldTapRegion: keep taps inside the callout from being treated as
    // "tap outside" by other text fields on the page (the title, the inner
    // field itself).
    //
    // Focus(parentNode: rootScope): re-parent this subtree in the focus tree
    // so the inner field is NOT a descendant of the QuillEditor's FocusNode.
    // Without this, FocusNode.hasFocus on the editor stays true while the
    // inner field is focused, and the editor keeps its caret blinking — the
    // double cursor users were seeing.
    return TextFieldTapRegion(
      child: Focus(parentNode: FocusManager.instance.rootScope, child: body),
    );
  }

  (IconData, Color) _styleAttributes(ThemeData theme) {
    return switch (widget.style) {
      'warning' => (Icons.warning_amber_rounded, Colors.orange),
      'tip' => (Icons.lightbulb_outline, Colors.green),
      'important' => (Icons.priority_high, Colors.red),
      _ => (Icons.info_outline, theme.colorScheme.primary),
    };
  }
}
