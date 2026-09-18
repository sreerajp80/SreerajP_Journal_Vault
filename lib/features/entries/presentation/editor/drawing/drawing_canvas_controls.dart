part of 'drawing_canvas_screen.dart';

extension _DrawingCanvasScreenStatePart1 on _DrawingCanvasScreenState {
  void _pushUndoState() {
    _undoStack.add(List.from(_strokes));
    _redoStack.clear();
    _isDirty = true;
  }

  void _undo() {
    if (_undoStack.isEmpty) return;
    _rebuild(() {
      _redoStack.add(List.from(_strokes));
      _strokes = _undoStack.removeLast();
    });
  }

  void _redo() {
    if (_redoStack.isEmpty) return;
    _rebuild(() {
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
        title: Text(l10n.bodyDrawingCanvasClear),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.actionCommonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.actionDrawingCanvasClear),
          ),
        ],
      ),
    );

    if (shouldClear == true && mounted) {
      _pushUndoState();
      _rebuild(() {
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

    _rebuild(() {
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

    _rebuild(() {
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
      _rebuild(() {
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
      _rebuild(() {
        _strokes = remainingStrokes;
      });
    }
  }

  Future<void> _handleSave() async {
    if (_isSaving) return;
    _rebuild(() => _isSaving = true);

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
            content: Text(AppLocalizations.of(context).errorDrawingSave),
          ),
        );
        _rebuild(() => _isSaving = false);
      }
    }
  }

  Future<bool> _handleWillPop() async {
    if (!_isDirty || _strokes.isEmpty) return true;

    final l10n = AppLocalizations.of(context);
    final shouldDiscard = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.bodyDrawingCanvasDiscard),
        content: Text(l10n.bodyDrawingCanvasDiscardMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.actionCommonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.actionEditorDiscard),
          ),
        ],
      ),
    );

    return shouldDiscard == true;
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
                      label: Text(l10n.labelDrawingCanvasPen),
                    ),
                    ButtonSegment(
                      value: DrawingTool.highlighter,
                      icon: const Icon(Icons.brush_outlined, size: 18),
                      label: Text(l10n.labelDrawingCanvasHighlighter),
                    ),
                    ButtonSegment(
                      value: DrawingTool.eraser,
                      icon: const Icon(
                        Icons.auto_fix_normal_outlined,
                        size: 18,
                      ),
                      label: Text(l10n.labelDrawingCanvasEraser),
                    ),
                  ],
                  selected: {_selectedTool},
                  onSelectionChanged: (set) {
                    _rebuild(() => _selectedTool = set.first);
                  },
                  showSelectedIcon: false,
                ),
                const Spacer(),
                // Stroke Width Popup
                PopupMenuButton<double>(
                  tooltip: l10n.labelDrawingCanvasStrokeWidth,
                  icon: Icon(
                    Icons.line_weight,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  initialValue: _strokeWidth,
                  onSelected: (width) => _rebuild(() => _strokeWidth = width),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 2.0,
                      child: Text(l10n.labelDrawingStrokeFine),
                    ),
                    PopupMenuItem(
                      value: 3.5,
                      child: Text(l10n.labelDrawingStrokeNormal),
                    ),
                    PopupMenuItem(
                      value: 7.0,
                      child: Text(l10n.labelDrawingStrokeThick),
                    ),
                    PopupMenuItem(
                      value: 14.0,
                      child: Text(l10n.labelDrawingStrokeBold),
                    ),
                  ],
                ),
                // Background Style Popup
                PopupMenuButton<DrawingBackgroundStyle>(
                  tooltip: l10n.labelDrawingCanvasBackground,
                  icon: Icon(
                    Icons.grid_4x4_outlined,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  initialValue: _backgroundStyle,
                  onSelected: (style) {
                    _pushUndoState();
                    _rebuild(() => _backgroundStyle = style);
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: DrawingBackgroundStyle.blank,
                      child: Text(l10n.labelDrawingCanvasBgBlank),
                    ),
                    PopupMenuItem(
                      value: DrawingBackgroundStyle.ruled,
                      child: Text(l10n.labelDrawingCanvasBgRuled),
                    ),
                    PopupMenuItem(
                      value: DrawingBackgroundStyle.grid,
                      child: Text(l10n.labelDrawingCanvasBgGrid),
                    ),
                    PopupMenuItem(
                      value: DrawingBackgroundStyle.dots,
                      child: Text(l10n.labelDrawingCanvasBgDots),
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
                    for (final color in _DrawingCanvasScreenState._presetColors)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: GestureDetector(
                          onTap: () => _rebuild(() => _selectedColor = color),
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
