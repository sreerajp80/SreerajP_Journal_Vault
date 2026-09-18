import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:sreerajp_journal_vault/features/entries/presentation/editor/drawing/drawing_canvas.dart';
import 'package:sreerajp_journal_vault/features/entries/presentation/editor/drawing/drawing_models.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

part 'drawing_canvas_controls.dart';

/// Result returned when user saves a drawing.
class DrawingCanvasResult {
  const DrawingCanvasResult({required this.pngBytes, required this.strokeJson});

  final Uint8List pngBytes;
  final String strokeJson;
}

/// Fullscreen drawing and handwriting canvas screen.
class DrawingCanvasScreen extends StatefulWidget {
  const DrawingCanvasScreen({super.key, this.initialStrokeJson});

  final String? initialStrokeJson;

  @override
  State<DrawingCanvasScreen> createState() => _DrawingCanvasScreenState();
}

class _DrawingCanvasScreenState extends State<DrawingCanvasScreen> {
  /// Lets the extensions in this library's part files rebuild the
  /// widget: `setState` is protected, so they cannot call it directly.
  void _rebuild(VoidCallback fn) => setState(fn);

  final GlobalKey _canvasKey = GlobalKey();

  late List<DrawingStroke> _strokes;
  final List<List<DrawingStroke>> _undoStack = [];
  final List<List<DrawingStroke>> _redoStack = [];

  DrawingStroke? _currentStroke;
  DrawingTool _selectedTool = DrawingTool.pen;
  Color _selectedColor = const Color(0xFF0F172A); // Dark slate
  double _strokeWidth = 3.5;
  DrawingBackgroundStyle _backgroundStyle = DrawingBackgroundStyle.blank;

  bool _isDirty = false;
  bool _isSaving = false;

  static const List<Color> _presetColors = [
    Color(0xFF0F172A), // Dark Slate / Black
    Color(0xFF64748B), // Slate Grey
    Color(0xFFE11D48), // Crimson Red
    Color(0xFFEA580C), // Deep Orange
    Color(0xFFD97706), // Amber
    Color(0xFF059669), // Emerald Green
    Color(0xFF0284C7), // Ocean Blue
    Color(0xFF6366F1), // Indigo
    Color(0xFF9333EA), // Purple
    Color(0xFFDB2777), // Pink
  ];

  @override
  void initState() {
    super.initState();
    final initialState = DrawingCanvasState.parse(widget.initialStrokeJson);
    _strokes = List.from(initialState.strokes);
    _backgroundStyle = initialState.backgroundStyle;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final canvasBgColor = isDark
        ? const Color(0xFF1E1E2E)
        : const Color(0xFFFFFFFF);

    final isEdit =
        widget.initialStrokeJson != null &&
        widget.initialStrokeJson!.isNotEmpty;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final allow = await _handleWillPop();
        if (allow && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        appBar: AppBar(
          title: Text(
            isEdit ? l10n.titleDrawingCanvasEdit : l10n.titleDrawingCanvas,
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.undo),
              tooltip: l10n.actionDrawingCanvasUndo,
              onPressed: _undoStack.isNotEmpty ? _undo : null,
            ),
            IconButton(
              icon: const Icon(Icons.redo),
              tooltip: l10n.actionDrawingCanvasRedo,
              onPressed: _redoStack.isNotEmpty ? _redo : null,
            ),
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              tooltip: l10n.actionDrawingCanvasClear,
              onPressed: _strokes.isNotEmpty ? _clearCanvas : null,
            ),
            const SizedBox(width: 4),
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: FilledButton.icon(
                key: const Key('drawing-save-button'),
                onPressed: _isSaving ? null : _handleSave,
                icon: _isSaving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check, size: 18),
                label: Text(l10n.actionDrawingCanvasSave),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            // Canvas area
            Expanded(
              child: Container(
                key: _canvasKey,
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: canvasBgColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: DrawingCanvas(
                  strokes: _strokes,
                  currentStroke: _currentStroke,
                  backgroundStyle: _backgroundStyle,
                  backgroundColor: canvasBgColor,
                  onPointerDown: _handlePointerDown,
                  onPointerMove: _handlePointerMove,
                  onPointerUp: _handlePointerUp,
                ),
              ),
            ),
            // Bottom control bar
            _buildBottomControls(context),
          ],
        ),
      ),
    );
  }
}
