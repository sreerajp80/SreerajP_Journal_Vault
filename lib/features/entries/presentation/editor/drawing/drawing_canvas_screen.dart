import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:sreerajp_journal_vault/features/entries/presentation/editor/drawing/drawing_canvas.dart';
import 'package:sreerajp_journal_vault/features/entries/presentation/editor/drawing/drawing_models.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

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

  void _pushUndoState() {
    _undoStack.add(List.from(_strokes));
    _redoStack.clear();
    _isDirty = true;
  }

  void _undo() {
    if (_undoStack.isEmpty) return;
    setState(() {
      _redoStack.add(List.from(_strokes));
      _strokes = _undoStack.removeLast();
    });
  }

  void _redo() {
    if (_redoStack.isEmpty) return;
    setState(() {
      _undoStack.add(List.from(_strokes));
      _strokes = _redoStack.removeLast();
    });
  }

  Future<void> _clearCanvas() async {
    if (_strokes.isEmpty) return;

    final l10n = AppLocalizations.of(context);
    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.drawingCanvasClearConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.drawingCanvasClear),
          ),
        ],
      ),
    );

    if (shouldClear == true && mounted) {
      _pushUndoState();
      setState(() {
        _strokes = [];
      });
    }
  }

  void _handlePointerDown(PointerDownEvent event) {
    if (_selectedTool == DrawingTool.eraser) {
      _pushUndoState();
      _eraseAtPoint(event.localPosition);
      return;
    }

    final point = DrawingPoint(
      x: event.localPosition.dx,
      y: event.localPosition.dy,
      pressure: event.pressure,
    );

    setState(() {
      _currentStroke = DrawingStroke(
        points: [point],
        color: _selectedColor,
        strokeWidth: _strokeWidth,
        tool: _selectedTool,
        isHighlighter: _selectedTool == DrawingTool.highlighter,
      );
    });
  }

  void _handlePointerMove(PointerMoveEvent event) {
    if (_selectedTool == DrawingTool.eraser) {
      _eraseAtPoint(event.localPosition);
      return;
    }

    if (_currentStroke == null) return;

    final point = DrawingPoint(
      x: event.localPosition.dx,
      y: event.localPosition.dy,
      pressure: event.pressure,
    );

    setState(() {
      _currentStroke = DrawingStroke(
        points: [..._currentStroke!.points, point],
        color: _currentStroke!.color,
        strokeWidth: _currentStroke!.strokeWidth,
        tool: _currentStroke!.tool,
        isHighlighter: _currentStroke!.isHighlighter,
      );
    });
  }

  void _handlePointerUp(PointerUpEvent event) {
    if (_selectedTool == DrawingTool.eraser) {
      return;
    }

    if (_currentStroke != null) {
      _pushUndoState();
      setState(() {
        _strokes.add(_currentStroke!);
        _currentStroke = null;
      });
    }
  }

  void _eraseAtPoint(Offset point) {
    const eraserRadius = 24.0;
    bool modified = false;
    final remainingStrokes = <DrawingStroke>[];

    for (final stroke in _strokes) {
      bool hit = false;
      for (final p in stroke.points) {
        final distance = (p.offset - point).distance;
        if (distance <= eraserRadius + (stroke.strokeWidth / 2)) {
          hit = true;
          break;
        }
      }
      if (!hit) {
        remainingStrokes.add(stroke);
      } else {
        modified = true;
      }
    }

    if (modified) {
      setState(() {
        _strokes = remainingStrokes;
      });
    }
  }

  Future<void> _handleSave() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    try {
      final renderBox =
          _canvasKey.currentContext?.findRenderObject() as RenderBox?;
      final size = renderBox?.size ?? const Size(800, 1000);

      final state = DrawingCanvasState(
        strokes: _strokes,
        backgroundStyle: _backgroundStyle,
      );

      final isDark = Theme.of(context).brightness == Brightness.dark;
      final canvasBgColor = isDark
          ? const Color(0xFF1E1E2E)
          : const Color(0xFFFFFFFF);

      final pngBytes = await DrawingImageExporter.renderToPngBytes(
        strokes: _strokes,
        backgroundStyle: _backgroundStyle,
        size: size,
        backgroundColor: canvasBgColor,
      );

      if (!mounted) return;

      Navigator.of(context).pop(
        DrawingCanvasResult(pngBytes: pngBytes, strokeJson: state.encode()),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).drawingSaveError),
          ),
        );
        setState(() => _isSaving = false);
      }
    }
  }

  Future<bool> _handleWillPop() async {
    if (!_isDirty || _strokes.isEmpty) return true;

    final l10n = AppLocalizations.of(context);
    final shouldDiscard = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.drawingCanvasDiscardTitle),
        content: Text(l10n.drawingCanvasDiscardMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.editorDiscard),
          ),
        ],
      ),
    );

    return shouldDiscard == true;
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
            isEdit ? l10n.drawingCanvasEditTitle : l10n.drawingCanvasTitle,
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.undo),
              tooltip: l10n.drawingCanvasUndo,
              onPressed: _undoStack.isNotEmpty ? _undo : null,
            ),
            IconButton(
              icon: const Icon(Icons.redo),
              tooltip: l10n.drawingCanvasRedo,
              onPressed: _redoStack.isNotEmpty ? _redo : null,
            ),
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              tooltip: l10n.drawingCanvasClear,
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
                label: Text(l10n.drawingCanvasSave),
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

  Widget _buildBottomControls(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        border: Border(
          top: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Row 1: Tools & Options
            Row(
              children: [
                // Tool Selector Segmented Buttons
                SegmentedButton<DrawingTool>(
                  segments: [
                    ButtonSegment(
                      value: DrawingTool.pen,
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: Text(l10n.drawingCanvasPen),
                    ),
                    ButtonSegment(
                      value: DrawingTool.highlighter,
                      icon: const Icon(Icons.brush_outlined, size: 18),
                      label: Text(l10n.drawingCanvasHighlighter),
                    ),
                    ButtonSegment(
                      value: DrawingTool.eraser,
                      icon: const Icon(
                        Icons.auto_fix_normal_outlined,
                        size: 18,
                      ),
                      label: Text(l10n.drawingCanvasEraser),
                    ),
                  ],
                  selected: {_selectedTool},
                  onSelectionChanged: (set) {
                    setState(() => _selectedTool = set.first);
                  },
                  showSelectedIcon: false,
                ),
                const Spacer(),
                // Stroke Width Popup
                PopupMenuButton<double>(
                  tooltip: l10n.drawingCanvasStrokeWidth,
                  icon: Icon(
                    Icons.line_weight,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  initialValue: _strokeWidth,
                  onSelected: (width) => setState(() => _strokeWidth = width),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 2.0,
                      child: Text(l10n.drawingStrokeFine),
                    ),
                    PopupMenuItem(
                      value: 3.5,
                      child: Text(l10n.drawingStrokeNormal),
                    ),
                    PopupMenuItem(
                      value: 7.0,
                      child: Text(l10n.drawingStrokeThick),
                    ),
                    PopupMenuItem(
                      value: 14.0,
                      child: Text(l10n.drawingStrokeBold),
                    ),
                  ],
                ),
                // Background Style Popup
                PopupMenuButton<DrawingBackgroundStyle>(
                  tooltip: l10n.drawingCanvasBackground,
                  icon: Icon(
                    Icons.grid_4x4_outlined,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  initialValue: _backgroundStyle,
                  onSelected: (style) {
                    _pushUndoState();
                    setState(() => _backgroundStyle = style);
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: DrawingBackgroundStyle.blank,
                      child: Text(l10n.drawingCanvasBgBlank),
                    ),
                    PopupMenuItem(
                      value: DrawingBackgroundStyle.ruled,
                      child: Text(l10n.drawingCanvasBgRuled),
                    ),
                    PopupMenuItem(
                      value: DrawingBackgroundStyle.grid,
                      child: Text(l10n.drawingCanvasBgGrid),
                    ),
                    PopupMenuItem(
                      value: DrawingBackgroundStyle.dots,
                      child: Text(l10n.drawingCanvasBgDots),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Row 2: Color Palette
            if (_selectedTool != DrawingTool.eraser)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final color in _presetColors)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedColor = color),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _selectedColor == color
                                    ? theme.colorScheme.primary
                                    : Colors.grey.withValues(alpha: 0.3),
                                width: _selectedColor == color ? 2.5 : 1.0,
                              ),
                              boxShadow: _selectedColor == color
                                  ? [
                                      BoxShadow(
                                        color: color.withValues(alpha: 0.4),
                                        blurRadius: 4,
                                        spreadRadius: 1,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: _selectedColor == color
                                ? Icon(
                                    Icons.check,
                                    size: 16,
                                    color: color.computeLuminance() > 0.5
                                        ? Colors.black
                                        : Colors.white,
                                  )
                                : null,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
