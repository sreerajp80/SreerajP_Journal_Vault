import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_quill/flutter_quill.dart';

/// Tells the formatting toolbar which table cell, if any, is being edited.
///
/// A table cell is edited by its own small Quill editor. While one has focus,
/// the toolbar's inline buttons (bold, colour, link, …) must act on that
/// cell's controller rather than on the entry's. The entry screen owns one of
/// these and hands it to both the [EditorToolbar] and the table embed builder.
///
/// Only one table owns it at a time. When the entry's own editor takes focus
/// back, the screen calls [clear], and the table that owned it closes its cell
/// editor and saves the cell into the entry.
class TableCellEditingController extends ChangeNotifier {
  QuillController? _controller;
  Object? _owner;
  bool _disposed = false;

  /// The controller of the cell being edited, or null when the toolbar should
  /// act on the entry itself.
  QuillController? get activeController => _controller;

  /// True while a table cell is being edited.
  bool get isEditingCell => _controller != null;

  /// True when [owner] is the table whose cell is being edited.
  bool isOwnedBy(Object owner) => identical(_owner, owner);

  /// Points the toolbar at [controller], the live cell editor of [owner].
  void activate(Object owner, QuillController controller) {
    if (_disposed) return;
    if (identical(_owner, owner) && identical(_controller, controller)) return;
    _owner = owner;
    _controller = controller;
    notifyListeners();
  }

  /// Gives the toolbar back to the entry, if [owner] still holds it.
  void release(Object owner) {
    if (_disposed || !identical(_owner, owner)) return;
    _owner = null;
    _controller = null;
    notifyListeners();
  }

  /// Gives the toolbar back to the entry, whoever holds it.
  void clear() {
    if (_disposed || _controller == null) return;
    _owner = null;
    _controller = null;
    notifyListeners();
  }

  /// Where the last finger touched down inside a table, in global
  /// coordinates, or null.
  Offset? _tablePointerDown;

  /// Called by a table when a finger touches down inside it.
  void noteTablePointerDown(Offset globalPosition) {
    _tablePointerDown = globalPosition;
  }

  /// Whether a tap at [globalPosition] began inside a table, so the entry's
  /// own editor must leave it alone.
  ///
  /// flutter_quill's editor sees every tap, even one a child widget handles
  /// (its tap recognizer is deliberately "transparent"). A tap on a table
  /// cell would otherwise also move the entry's caret and take focus from
  /// the cell editor — and while a cell editor is being swapped for another,
  /// the two editors then take focus from each other without end. The entry
  /// screen passes this to the editor's `onTapDown` / `onTapUp` hooks, which
  /// skip the default handling when it returns true.
  ///
  /// Pass [tapEnded] from `onTapUp`: the record is then used up.
  bool isTableTap(Offset globalPosition, {bool tapEnded = false}) {
    final down = _tablePointerDown;
    // A tap's finger may drift a little between down and up.
    final matches =
        down != null && (down - globalPosition).distance <= kTouchSlop;
    if (!matches || tapEnded) _tablePointerDown = null;
    return matches;
  }

  /// Editor config hooks that make the entry's editor ignore taps on tables.
  ({
    bool Function(TapDownDetails, TextPosition Function(Offset)) onTapDown,
    bool Function(TapUpDetails, TextPosition Function(Offset)) onTapUp,
  })
  get entryTapHooks => (
    onTapDown: (details, _) => isTableTap(details.globalPosition),
    onTapUp: (details, _) => isTableTap(details.globalPosition, tapEnded: true),
  );

  @override
  void dispose() {
    _disposed = true;
    _owner = null;
    _controller = null;
    super.dispose();
  }
}
