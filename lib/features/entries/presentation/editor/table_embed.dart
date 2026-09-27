import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:sreerajp_journal_vault/features/entries/domain/table_data.dart';
import 'package:sreerajp_journal_vault/features/entries/presentation/editor/table_cell_editing.dart';
import 'package:sreerajp_journal_vault/features/entries/presentation/editor/table_cell_editor.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

/// Custom embeddable block for tables in the editor.
///
/// The embed's data is a JSON string read and written by [TableData], which
/// supports the legacy list format, the envelope format with column widths,
/// and the rich (v2) format whose cells carry inline formatting.
class TableEmbed extends CustomBlockEmbed {
  const TableEmbed(String data) : super(tableType, data);

  /// Wraps [table] as an embed, in the oldest format that can hold it.
  factory TableEmbed.fromData(TableData table) =>
      TableEmbed(table.toJsonString());

  static const String tableType = TableData.tableEmbedType;

  /// The table's contents. A damaged embed reads as one empty cell, so the
  /// entry still opens and the table can be deleted.
  TableData get table =>
      TableData.tryParse(data) ??
      TableData.fromPlainRows(const [
        [''],
      ]);

  /// The cells as plain text.
  List<List<String>> get rows => table.plainRows;

  /// Per-column widths, or `null` when every column uses equal flex width.
  List<double>? get colWidths => table.colWidths;

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

  /// Creates an embed that includes explicit column widths.
  factory TableEmbed.fromRowsAndWidths(
    List<List<String>> rows,
    List<double>? colWidths,
  ) {
    return TableEmbed.fromData(
      TableData.fromPlainRows(rows, colWidths: colWidths),
    );
  }
}

/// Builds the visual representation of a [TableEmbed] in the editor.
class TableEmbedBuilder extends EmbedBuilder {
  TableEmbedBuilder({this.cellEditing, this.cellControllerConfig});

  /// Shared with the formatting toolbar, so the toolbar can work on the cell
  /// being edited. Null in screens without a toolbar.
  final TableCellEditingController? cellEditing;

  /// Builds the controller config for a live cell editor (its paste
  /// handling). Null uses the Quill defaults.
  final QuillControllerConfig Function(QuillController Function() cell)?
  cellControllerConfig;

  @override
  String get key => TableEmbed.tableType;

  /// The table's words rather than one placeholder character, for a caller
  /// that asks for plain text with the embed builders.
  @override
  String toPlainText(Embed node) {
    final table = TableData.tryParse(node.value.data);
    return table == null ? super.toPlainText(node) : table.searchText;
  }

  @override
  Widget build(BuildContext context, EmbedContext embedContext) {
    final embed = TableEmbed(embedContext.node.value.data as String);
    // The embed's node in the document. node.documentOffset is the embed's
    // authoritative position; the built-in getEmbedNode helper reads from
    // controller.selection.start, which drifts away from the embed once a
    // cell has focus.
    //
    // A write-back replaces the node, and with ignoreFocus the editor does
    // not rebuild this widget afterwards, so the old node would be left
    // detached (its offset reads as 0). After each write-back the new node is
    // looked up at the same position and kept here, so a second write-back
    // before the next rebuild still lands on the table.
    var node = embedContext.node;
    final controller = embedContext.controller;
    return _TableBlock(
      table: embed.table,
      readOnly: embedContext.readOnly,
      cellEditing: cellEditing,
      cellControllerConfig: cellControllerConfig,
      onCommit: embedContext.readOnly
          ? null
          : (updated) {
              final offset = node.documentOffset;
              controller.replaceText(
                offset,
                1,
                TableEmbed.fromData(updated),
                null,
                ignoreFocus: true,
              );
              node = _embedAt(controller.document, offset) ?? node;
            },
      onDelete: embedContext.readOnly
          ? null
          : () {
              final offset = node.documentOffset;
              embedContext.controller.replaceText(
                offset,
                1,
                '',
                TextSelection.collapsed(offset: offset),
              );
            },
    );
  }

  /// The table embed at [offset] in [document], or null.
  static Embed? _embedAt(Document document, int offset) {
    final lineQuery = document.queryChild(offset);
    final line = lineQuery.node;
    if (line is! Line) return null;
    final leaf = line.queryChild(lineQuery.offset, false).node;
    if (leaf is Embed && leaf.value.type == TableEmbed.tableType) return leaf;
    return null;
  }
}

typedef _Cells = List<List<List<Map<String, dynamic>>>>;

class _TableBlock extends StatefulWidget {
  const _TableBlock({
    required this.table,
    required this.readOnly,
    this.cellEditing,
    this.cellControllerConfig,
    this.onCommit,
    this.onDelete,
  });

  final TableData table;
  final bool readOnly;
  final TableCellEditingController? cellEditing;
  final QuillControllerConfig Function(QuillController Function() cell)?
  cellControllerConfig;

  /// Writes the table back into the entry.
  ///
  /// A cell is written back when it loses focus, not on every keystroke:
  /// replacing the embed makes the surrounding editor rebuild, which would
  /// interrupt typing.
  final void Function(TableData table)? onCommit;

  /// Called to delete the entire table embed from the document.
  final VoidCallback? onDelete;

  @override
  State<_TableBlock> createState() => _TableBlockState();
}

class _TableBlockState extends State<_TableBlock> {
  /// The cells as last written to (or read from) the entry. The cell being
  /// edited lives in [_activeController] until it is written back.
  late _Cells _cells;

  /// Per-column widths. `null` means equal-flex (default for existing tables).
  List<double>? _colWidths;

  /// True while the user is actively dragging a column resize handle.
  bool _isDragging = false;

  /// The cell being edited, and its live editor's parts. All null when no
  /// cell is being edited. Only one cell has a live editor at a time.
  (int, int)? _active;
  QuillController? _activeController;
  FocusNode? _activeFocus;
  ScrollController? _activeScroll;

  /// True once the toolbar has been pointed at this table's cell editor.
  bool _holdsToolbar = false;

  /// The JSON of the last table written back. The entry editor does not
  /// rebuild this widget after a write-back, so until it next does,
  /// [_TableBlock.table] is older than what the entry holds.
  String? _lastSentJson;

  bool get _editable => !widget.readOnly && widget.onCommit != null;

  @override
  void initState() {
    super.initState();
    _cells = _copyCells(widget.table.cells);
    _colWidths = _copyWidths(widget.table.colWidths);
    widget.cellEditing?.addListener(_handleCellEditingChange);
  }

  @override
  void didUpdateWidget(covariant _TableBlock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.cellEditing, widget.cellEditing)) {
      oldWidget.cellEditing?.removeListener(_handleCellEditingChange);
      widget.cellEditing?.addListener(_handleCellEditingChange);
    }

    // The entry rebuilt the table: from our own write-backs, or from an
    // outside change (a revision restore). Either way the entry is now the
    // source of truth. The cell being edited keeps what is in its editor.
    _lastSentJson = null;
    _cells = _copyCells(widget.table.cells);
    final active = _active;
    if (active != null && !_inBounds(active.$1, active.$2)) {
      _closeActiveCell(commit: false);
    }
    if (!_isDragging) _colWidths = _copyWidths(widget.table.colWidths);
  }

  @override
  void dispose() {
    widget.cellEditing?.removeListener(_handleCellEditingChange);
    // Save what is in the cell editor if the screen closes mid-edit.
    _closeActiveCell(rebuild: false);
    super.dispose();
  }

  static _Cells _copyCells(_Cells cells) => [
    for (final row in cells)
      [
        for (final cell in row)
          [for (final op in cell) Map<String, dynamic>.of(op)],
      ],
  ];

  static List<double>? _copyWidths(List<double>? widths) =>
      widths == null ? null : List<double>.of(widths);

  bool _inBounds(int row, int col) =>
      row < _cells.length && col < _cells[row].length;

  int get _columnCount => _cells.isEmpty ? 0 : _cells[0].length;

  // ---------------------------------------------------------------------------
  // The live cell editor
  // ---------------------------------------------------------------------------

  /// The cells, with the cell being edited taken from its editor.
  _Cells _currentCells() {
    final cells = _copyCells(_cells);
    final active = _active;
    final controller = _activeController;
    if (active != null &&
        controller != null &&
        active.$1 < cells.length &&
        active.$2 < cells[active.$1].length) {
      cells[active.$1][active.$2] = TableData.normalizeCell(
        controller.document.toDelta().toJson(),
      );
    }
    return cells;
  }

  void _commitIfChanged() {
    _send(TableData(cells: _currentCells(), colWidths: _colWidths));
  }

  /// Writes [table] into the entry, unless the entry already holds it.
  void _send(TableData table) {
    final onCommit = widget.onCommit;
    if (onCommit == null) return;
    final json = table.toJsonString();
    if (json == (_lastSentJson ?? widget.table.toJsonString())) return;
    _lastSentJson = json;
    onCommit(table);
  }

  void _openCell(int row, int col) {
    if (!_editable || !_inBounds(row, col)) return;
    if (_active == (row, col)) {
      _activeFocus?.requestFocus();
      return;
    }
    _closeActiveCell();

    final document = Document.fromJson([
      ..._cells[row][col],
      {'insert': '\n'},
    ]);
    late final QuillController controller;
    controller = QuillController(
      document: document,
      selection: TextSelection.collapsed(offset: document.length - 1),
      config:
          widget.cellControllerConfig?.call(() => controller) ??
          const QuillControllerConfig(),
    )..addListener(_handleActiveControllerChange);
    final focus = FocusNode(debugLabel: 'TableCell[$row][$col]')
      ..addListener(_handleActiveFocusChange);

    setState(() {
      _active = (row, col);
      _activeController = controller;
      _activeFocus = focus;
      _activeScroll = ScrollController();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && identical(_activeFocus, focus)) focus.requestFocus();
    });
  }

  /// Ends the edit: writes the cell back (unless [commit] is false), shows
  /// it as formatted text again, and gives the toolbar back to the entry.
  void _closeActiveCell({bool commit = true, bool rebuild = true}) {
    final active = _active;
    final controller = _activeController;
    final focus = _activeFocus;
    final scroll = _activeScroll;
    if (active == null || controller == null || focus == null) return;

    if (commit) _commitIfChanged();
    if (_inBounds(active.$1, active.$2)) {
      _cells[active.$1][active.$2] = TableData.normalizeCell(
        controller.document.toDelta().toJson(),
      );
    }

    controller.removeListener(_handleActiveControllerChange);
    focus.removeListener(_handleActiveFocusChange);
    if (_holdsToolbar) {
      _holdsToolbar = false;
      widget.cellEditing?.release(this);
    }
    _active = null;
    _activeController = null;
    _activeFocus = null;
    _activeScroll = null;
    if (rebuild && mounted) setState(() {});

    // The editor widget still holds these until the next frame rebuilds it.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.dispose();
      focus.dispose();
      scroll?.dispose();
    });
  }

  void _handleActiveFocusChange() {
    final focus = _activeFocus;
    final controller = _activeController;
    if (focus == null || controller == null) return;
    if (focus.hasFocus) {
      _holdsToolbar = true;
      widget.cellEditing?.activate(this, controller);
    } else {
      _commitIfChanged();
    }
  }

  /// A toolbar dialog (colour, link) changes the cell while the dialog, not
  /// the cell, has focus. Nobody is typing then, so the change is written
  /// back straight away.
  void _handleActiveControllerChange() {
    if (_activeFocus?.hasFocus ?? true) return;
    _commitIfChanged();
  }

  /// The entry's own editor took the toolbar back: the edit is over.
  void _handleCellEditingChange() {
    final cellEditing = widget.cellEditing;
    if (cellEditing == null || !_holdsToolbar) return;
    if (!cellEditing.isOwnedBy(this)) {
      _holdsToolbar = false;
      _closeActiveCell();
    }
  }

  // ---------------------------------------------------------------------------
  // Tab navigation and extending
  // ---------------------------------------------------------------------------

  /// Moves to the next cell. From the last cell, adds a row first.
  void _moveToNextCell(int row, int col) {
    var nextRow = row;
    var nextCol = col + 1;
    if (nextCol >= _columnCount) {
      nextCol = 0;
      nextRow = row + 1;
    }
    if (nextRow >= _cells.length) _addRow();
    _openCell(nextRow, nextCol);
  }

  void _moveToPreviousCell(int row, int col) {
    var prevRow = row;
    var prevCol = col - 1;
    if (prevCol < 0) {
      prevRow = row - 1;
      prevCol = _columnCount - 1;
    }
    if (prevRow < 0) return; // Already at the very first cell.
    _openCell(prevRow, prevCol);
  }

  // ---------------------------------------------------------------------------
  // Add / delete row and column
  // ---------------------------------------------------------------------------

  /// Applies a change to the table's shape and writes it to the entry.
  ///
  /// The cell being edited is written back first, so its text is kept.
  void _changeShape(void Function(_Cells cells) change) {
    final cells = _currentCells();
    change(cells);
    setState(() => _cells = cells);
    _send(TableData(cells: cells, colWidths: _colWidths));
  }

  void _addRow() {
    _changeShape((cells) {
      final colCount = cells.isNotEmpty ? cells[0].length : 1;
      cells.add([for (var c = 0; c < colCount; c++) []]);
    });
  }

  void _addColumn() {
    // Give the new column a default width if widths are tracked.
    if (_colWidths != null && _colWidths!.isNotEmpty) {
      final avg = _colWidths!.reduce((a, b) => a + b) / _colWidths!.length;
      _colWidths!.add(avg);
    }
    _changeShape((cells) {
      for (final row in cells) {
        row.add([]);
      }
    });
  }

  void _deleteRow(int rowIndex) {
    if (_cells.length <= 1) return; // Keep at least one row.
    final active = _active;
    if (active != null && active.$1 == rowIndex) {
      _closeActiveCell(commit: false);
    }
    _changeShape((cells) => cells.removeAt(rowIndex));
    final stillActive = _active;
    if (stillActive != null && stillActive.$1 > rowIndex) {
      _active = (stillActive.$1 - 1, stillActive.$2);
    }
  }

  void _deleteColumn(int colIndex) {
    if (_columnCount <= 1) return; // Keep at least one column.
    final active = _active;
    if (active != null && active.$2 == colIndex) {
      _closeActiveCell(commit: false);
    }
    // Remove the corresponding column width if tracked.
    if (_colWidths != null && colIndex < _colWidths!.length) {
      _colWidths!.removeAt(colIndex);
    }
    _changeShape((cells) {
      for (final row in cells) {
        if (colIndex < row.length) row.removeAt(colIndex);
      }
    });
    final stillActive = _active;
    if (stillActive != null && stillActive.$2 > colIndex) {
      _active = (stillActive.$1, stillActive.$2 - 1);
    }
  }

  // ---------------------------------------------------------------------------
  // Column resize
  // ---------------------------------------------------------------------------

  /// Minimum column width during resize.
  static const double _minColWidth = 48.0;

  /// Called on each horizontal drag update for a column resize handle.
  /// Uses a split-pane model: dragging the border between `col` and `col + 1`
  /// redistributes width between them, keeping the total constant.
  void _onColumnResize(int col, double delta, double maxWidth) {
    if (_colWidths == null) {
      // First resize — initialise all columns to equal widths.
      final colCount = _columnCount;
      _colWidths = List.generate(colCount, (_) => maxWidth / colCount);
    }

    setState(() {
      final nextCol = col + 1;
      if (nextCol >= _colWidths!.length) return;

      final newWidth = (_colWidths![col] + delta).clamp(
        _minColWidth,
        double.infinity,
      );
      final consumed = newWidth - _colWidths![col];
      final newNextWidth = (_colWidths![nextCol] - consumed).clamp(
        _minColWidth,
        double.infinity,
      );
      final actualConsumed = _colWidths![nextCol] - newNextWidth;

      _colWidths![col] += actualConsumed;
      _colWidths![nextCol] = newNextWidth;
    });
  }

  /// Commit column widths to the embed after a drag ends.
  void _commitWidths() {
    _commitIfChanged();
  }

  // ---------------------------------------------------------------------------
  // Long-press context menu
  // ---------------------------------------------------------------------------

  void _showTableContextMenu(BuildContext ctx, Offset tapPosition) {
    final l10n = AppLocalizations.of(ctx);
    final focused = _active;

    final items = <PopupMenuEntry<String>>[
      PopupMenuItem(value: 'add_row', child: Text(l10n.actionTableAddRow)),
      PopupMenuItem(
        value: 'add_column',
        child: Text(l10n.actionTableAddColumn),
      ),
      const PopupMenuDivider(),
    ];

    // Only show row/column delete when we know which row/column.
    if (focused != null) {
      items.add(
        PopupMenuItem(
          value: 'delete_row',
          enabled: _cells.length > 1,
          child: Text(l10n.actionTableDeleteRow),
        ),
      );
      items.add(
        PopupMenuItem(
          value: 'delete_column',
          enabled: _columnCount > 1,
          child: Text(l10n.actionTableDeleteColumn),
        ),
      );
      items.add(const PopupMenuDivider());
    }

    if (widget.onDelete != null) {
      items.add(
        PopupMenuItem(
          value: 'delete_table',
          child: Text(l10n.actionTableDelete),
        ),
      );
    }

    unawaited(
      showMenu<String>(
        context: ctx,
        position: RelativeRect.fromLTRB(
          tapPosition.dx,
          tapPosition.dy,
          tapPosition.dx,
          tapPosition.dy,
        ),
        items: items,
      ).then((value) {
        if (value == null || !mounted) return;
        switch (value) {
          case 'add_row':
            _addRow();
          case 'add_column':
            _addColumn();
          case 'delete_row':
            if (focused != null) _deleteRow(focused.$1);
          case 'delete_column':
            if (focused != null) _deleteColumn(focused.$2);
          case 'delete_table':
            _closeActiveCell(commit: false);
            widget.onDelete?.call();
        }
      }),
    );
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderColor = theme.colorScheme.outlineVariant;

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;

        final tableWidget = Table(
          border: TableBorder.all(color: borderColor, width: 0.5),
          columnWidths: _colWidths != null
              ? {
                  for (int i = 0; i < _colWidths!.length; i++)
                    i: FixedColumnWidth(_colWidths![i]),
                }
              : null,
          children: [
            for (int r = 0; r < _cells.length; r++)
              TableRow(
                decoration: r == 0
                    ? BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                      )
                    : null,
                children: [
                  for (int c = 0; c < _columnCount; c++)
                    if (r == 0 && _editable)
                      _buildResizableHeaderCell(context, c, maxWidth)
                    else
                      _buildCell(context, r, c),
                ],
              ),
          ],
        );

        final framed = Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: borderColor),
            borderRadius: BorderRadius.circular(4),
          ),
          child: tableWidget,
        );

        if (!_editable) return framed;

        // Editable mode: table + long-press context menu. The Listener tells
        // the entry's editor that this tap belongs to the table (see
        // TableCellEditingController.isTableTap).
        final body = Listener(
          onPointerDown: (event) =>
              widget.cellEditing?.noteTablePointerDown(event.position),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onLongPressStart: (details) {
              _showTableContextMenu(context, details.globalPosition);
            },
            child: framed,
          ),
        );

        // TextFieldTapRegion: keep taps inside the table from being treated
        // as "tap outside" by the cell editor.
        //
        // Focus(parentNode: the route's scope): re-parent this subtree in the
        // focus tree so the cell editor is NOT a descendant of the entry
        // editor's FocusNode. Without this, the entry editor would still count
        // as focused while a cell is edited, keep its caret blinking, and take
        // some keystrokes. The route's scope (not the root scope) is used so
        // that closing a toolbar dialog (colour, link) gives focus back to the
        // cell rather than to the entry.
        return TextFieldTapRegion(
          child: Focus(
            parentNode: FocusScope.of(context),
            canRequestFocus: false,
            skipTraversal: true,
            child: body,
          ),
        );
      },
    );
  }

  Widget _buildCell(BuildContext context, int row, int col) {
    final isHeader = row == 0;
    final baseStyle = Theme.of(context).textTheme.bodyMedium;
    final style = isHeader
        ? baseStyle?.copyWith(fontWeight: FontWeight.bold)
        : baseStyle;
    final ops = col < _cells[row].length
        ? _cells[row][col]
        : const <Map<String, dynamic>>[];

    if (!_editable) {
      return Padding(
        padding: const EdgeInsets.all(8),
        child: TableCellText(ops: ops, style: style, openLinks: true),
      );
    }

    final isActive = _active == (row, col);
    final controller = _activeController;
    final focus = _activeFocus;
    final scroll = _activeScroll;

    final Widget content;
    if (isActive && controller != null && focus != null && scroll != null) {
      content = TableCellEditor(
        controller: controller,
        focusNode: focus,
        scrollController: scroll,
        style: style,
        onTab: ({required backwards}) => backwards
            ? _moveToPreviousCell(row, col)
            : _moveToNextCell(row, col),
      );
    } else {
      content = TableCellText(ops: ops, style: style);
    }

    // The first tap opens the cell's editor. Without this the entry editor
    // would take the tap as a whole-block embed selection (the "big cursor"
    // problem), and the cell would need a second tap.
    return Semantics(
      label: AppLocalizations.of(context).labelTableCell,
      textField: true,
      value: TableData.cellPlainText(ops),
      onTap: () => _openCell(row, col),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: isActive ? null : () => _openCell(row, col),
        child: Padding(padding: const EdgeInsets.all(8), child: content),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Resizable header cell and drag handle
  // ---------------------------------------------------------------------------

  /// Wraps a header cell (row 0) in a [Stack] with a drag handle on its right
  /// edge, allowing the user to resize the column by dragging.
  Widget _buildResizableHeaderCell(
    BuildContext context,
    int col,
    double maxWidth,
  ) {
    final colCount = _columnCount;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        _buildCell(context, 0, col),
        // Place a drag handle on the right edge of every column except the
        // last — there is nothing to the right of the last column to resize.
        if (col < colCount - 1)
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: _buildDragHandle(context, col, maxWidth),
          ),
      ],
    );
  }

  /// A thin, draggable handle rendered on the column border. Dragging it
  /// redistributes width between the column and its right neighbour.
  Widget _buildDragHandle(BuildContext context, int col, double maxWidth) {
    final l10n = AppLocalizations.of(context);
    return Semantics(
      label: l10n.tooltipTableResizeColumn,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragStart: (_) {
          _isDragging = true;
        },
        onHorizontalDragUpdate: (details) {
          _onColumnResize(col, details.delta.dx, maxWidth);
        },
        onHorizontalDragEnd: (_) {
          _isDragging = false;
          _commitWidths();
        },
        child: SizedBox(
          width: 8,
          child: Center(
            child: Container(
              width: 2,
              color: Theme.of(
                context,
              ).colorScheme.outline.withValues(alpha: 0.4),
            ),
          ),
        ),
      ),
    );
  }
}
