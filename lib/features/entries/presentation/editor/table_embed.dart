import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

/// Custom embeddable block for simple tables in the editor.
///
/// Tables are stored as a JSON-encoded 2D list of strings.
class TableEmbed extends CustomBlockEmbed {
  const TableEmbed(String data) : super(tableType, data);

  static const String tableType = 'table';

  List<List<String>> get rows {
    final list = jsonDecode(data) as List;
    return list
        .map((row) => (row as List).map((c) => c as String).toList())
        .toList();
  }

  factory TableEmbed.create({int rowCount = 3, int colCount = 3}) {
    final rows = List.generate(
      rowCount,
      (_) => List.generate(colCount, (_) => ''),
    );
    return TableEmbed(jsonEncode(rows));
  }

  factory TableEmbed.fromRows(List<List<String>> rows) {
    return TableEmbed(jsonEncode(rows));
  }
}

/// Builds the visual representation of a [TableEmbed] in the editor.
class TableEmbedBuilder extends EmbedBuilder {
  @override
  String get key => TableEmbed.tableType;

  @override
  Widget build(BuildContext context, EmbedContext embedContext) {
    final rows = (jsonDecode(embedContext.node.value.data as String) as List)
        .map((row) => (row as List).map((c) => c as String).toList())
        .toList();

    return _TableBlock(
      rows: rows,
      readOnly: embedContext.readOnly,
      // node.documentOffset is the embed's authoritative position; the
      // built-in getEmbedNode helper reads from controller.selection.start
      // which can drift away from the embed once an inner cell has focus.
      onCommit: embedContext.readOnly
          ? null
          : (updatedRows) {
              final offset = embedContext.node.documentOffset;
              embedContext.controller.replaceText(
                offset,
                1,
                TableEmbed.fromRows(updatedRows),
                null,
                ignoreFocus: true,
              );
            },
    );
  }
}

class _TableBlock extends StatefulWidget {
  const _TableBlock({
    required this.rows,
    required this.readOnly,
    this.onCommit,
  });

  final List<List<String>> rows;
  final bool readOnly;

  /// Called when a cell loses focus to write the table's text back into the
  /// embed. Replacing the embed on every keystroke causes the surrounding
  /// editor to rebuild mid-input, which destroys focus and resets the cell's
  /// controller after a single character — so commit happens at blur, not
  /// per character.
  final ValueChanged<List<List<String>>>? onCommit;

  @override
  State<_TableBlock> createState() => _TableBlockState();
}

class _TableBlockState extends State<_TableBlock> {
  late List<List<TextEditingController>> _controllers;
  late List<List<FocusNode>> _focusNodes;

  @override
  void initState() {
    super.initState();
    _buildCellState(widget.rows);
  }

  void _buildCellState(List<List<String>> rows) {
    _controllers = [
      for (final row in rows)
        [for (final cell in row) TextEditingController(text: cell)],
    ];
    _focusNodes = [
      for (int r = 0; r < rows.length; r++)
        [
          for (int c = 0; c < rows[r].length; c++)
            FocusNode(debugLabel: 'TableCell[$r][$c]')
              ..addListener(_handleFocusChange),
        ],
    ];
  }

  void _disposeCellState() {
    for (final row in _controllers) {
      for (final c in row) {
        c.dispose();
      }
    }
    for (final row in _focusNodes) {
      for (final fn in row) {
        fn.dispose();
      }
    }
  }

  bool _shapeMatches(List<List<String>> rows) {
    if (rows.length != _controllers.length) return false;
    for (int r = 0; r < rows.length; r++) {
      if (rows[r].length != _controllers[r].length) return false;
    }
    return true;
  }

  @override
  void didUpdateWidget(covariant _TableBlock oldWidget) {
    super.didUpdateWidget(oldWidget);
    // External shape change (e.g. revision restore) — rebuild from scratch.
    if (!_shapeMatches(widget.rows)) {
      _disposeCellState();
      _buildCellState(widget.rows);
      return;
    }
    // Echo of our own commit, plus possible external edits to other cells.
    // Sync only non-focused cells whose text differs, so we never disturb
    // the cell the user is currently typing in.
    for (int r = 0; r < widget.rows.length; r++) {
      for (int c = 0; c < widget.rows[r].length; c++) {
        final cell = widget.rows[r][c];
        if (cell != _controllers[r][c].text && !_focusNodes[r][c].hasFocus) {
          _controllers[r][c].value = TextEditingValue(
            text: cell,
            selection: TextSelection.collapsed(offset: cell.length),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    if (_anyHasFocus()) {
      // Final commit if the screen is being torn down while focus is inside.
      _commitIfChanged();
    }
    _disposeCellState();
    super.dispose();
  }

  bool _anyHasFocus() {
    for (final row in _focusNodes) {
      for (final fn in row) {
        if (fn.hasFocus) return true;
      }
    }
    return false;
  }

  void _handleFocusChange() {
    // Commit when a cell loses focus. The diff check keeps cell-to-cell
    // tabs from triggering redundant embed replacements.
    _commitIfChanged();
  }

  void _commitIfChanged() {
    final onCommit = widget.onCommit;
    if (onCommit == null) return;
    final updated = [
      for (final row in _controllers) [for (final c in row) c.text],
    ];
    bool changed = false;
    outer:
    for (int r = 0; r < updated.length; r++) {
      for (int c = 0; c < updated[r].length; c++) {
        if (updated[r][c] != widget.rows[r][c]) {
          changed = true;
          break outer;
        }
      }
    }
    if (!changed) return;
    onCommit(updated);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderColor = theme.colorScheme.outlineVariant;

    final body = Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Table(
        border: TableBorder.all(color: borderColor, width: 0.5),
        children: [
          for (int r = 0; r < widget.rows.length; r++)
            TableRow(
              decoration: r == 0
                  ? BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                    )
                  : null,
              children: [
                for (int c = 0; c < widget.rows[r].length; c++)
                  _buildCell(context, r, c),
              ],
            ),
        ],
      ),
    );

    // TextFieldTapRegion: keep taps inside the table from being treated
    // as "tap outside" by other text fields on the page.
    //
    // Focus(parentNode: rootScope): re-parent this subtree in the focus
    // tree so the cell text fields are NOT descendants of the QuillEditor's
    // FocusNode. Without this, FocusNode.hasFocus on the editor stays true
    // while a cell is focused, the editor keeps its caret blinking, and
    // some keystrokes are intercepted before reaching the cell.
    return TextFieldTapRegion(
      child: Focus(
        parentNode: FocusManager.instance.rootScope,
        child: body,
      ),
    );
  }

  Widget _buildCell(BuildContext context, int row, int col) {
    final isHeader = row == 0;
    final style = isHeader
        ? Theme.of(context)
            .textTheme
            .bodyMedium
            ?.copyWith(fontWeight: FontWeight.bold)
        : Theme.of(context).textTheme.bodyMedium;

    if (widget.readOnly) {
      return Padding(
        padding: const EdgeInsets.all(8),
        child: Text(widget.rows[row][col], style: style),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(4),
      child: TextField(
        controller: _controllers[row][col],
        focusNode: _focusNodes[row][col],
        decoration: const InputDecoration(
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.all(4),
        ),
        style: style,
        maxLines: null,
        // Calling unfocus() drops focus to the root scope, which lets the
        // surrounding editor reclaim focus cleanly and triggers our commit
        // listener for this cell.
        onTapOutside: (_) {
          if (_focusNodes[row][col].hasFocus) {
            _focusNodes[row][col].unfocus();
          }
        },
      ),
    );
  }
}
