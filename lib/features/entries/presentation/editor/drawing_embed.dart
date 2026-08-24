import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

import 'package:sreerajp_journal_vault/features/entries/presentation/editor/inline_image_store.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

/// Data stored inside a `drawing` embed in the entry document.
///
/// **Only the attachment id and vector stroke data — never raw image bytes.**
/// The document JSON lives in `Entries.contentJson`, so the rendered PNG file
/// itself stays AES-256-GCM encrypted in the attachment store.
class DrawingEmbedData {
  const DrawingEmbedData({
    required this.attachmentId,
    required this.fileName,
    this.widthFactor = fullWidth,
    this.strokeJson,
  });

  /// The row in `Attachments` holding the encrypted rendered sketch.
  final int attachmentId;

  /// The file name of the drawing.
  final String fileName;

  /// How much of the editor's width the drawing takes: [smallWidth],
  /// [mediumWidth], or [fullWidth].
  final double widthFactor;

  /// Serialized vector strokes for re-opening and editing the drawing.
  final String? strokeJson;

  static const double smallWidth = 0.4;
  static const double mediumWidth = 0.66;
  static const double fullWidth = 1.0;

  /// Reads embed data. Never throws on corrupted or unexpected input.
  static DrawingEmbedData parse(Object? raw) {
    if (raw is! String) {
      return const DrawingEmbedData(attachmentId: 0, fileName: '');
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) {
        return const DrawingEmbedData(attachmentId: 0, fileName: '');
      }
      final id = decoded['attachmentId'];
      final width = decoded['widthFactor'];
      final strokes = decoded['strokeJson']?.toString();

      return DrawingEmbedData(
        attachmentId: id is int ? id : int.tryParse('$id') ?? 0,
        fileName: decoded['fileName']?.toString() ?? '',
        widthFactor: _nearestWidth(width is num ? width.toDouble() : fullWidth),
        strokeJson: strokes,
      );
    } on FormatException {
      return const DrawingEmbedData(attachmentId: 0, fileName: '');
    }
  }

  static double _nearestWidth(double value) {
    if (value <= (smallWidth + mediumWidth) / 2) return smallWidth;
    if (value <= (mediumWidth + fullWidth) / 2) return mediumWidth;
    return fullWidth;
  }

  String encode() => jsonEncode({
    'attachmentId': attachmentId,
    'fileName': fileName,
    'widthFactor': widthFactor,
    if (strokeJson != null) 'strokeJson': strokeJson,
  });

  DrawingEmbedData copyWith({
    int? attachmentId,
    String? fileName,
    double? widthFactor,
    String? strokeJson,
  }) => DrawingEmbedData(
    attachmentId: attachmentId ?? this.attachmentId,
    fileName: fileName ?? this.fileName,
    widthFactor: widthFactor ?? this.widthFactor,
    strokeJson: strokeJson ?? this.strokeJson,
  );
}

/// A sketch / handwriting drawing embedded in the document flow.
class DrawingEmbed extends CustomBlockEmbed {
  const DrawingEmbed(String data) : super(drawingType, data);

  static const String drawingType = 'drawing';

  factory DrawingEmbed.create({
    required int attachmentId,
    required String fileName,
    double widthFactor = DrawingEmbedData.fullWidth,
    String? strokeJson,
  }) {
    return DrawingEmbed(
      DrawingEmbedData(
        attachmentId: attachmentId,
        fileName: fileName,
        widthFactor: widthFactor,
        strokeJson: strokeJson,
      ).encode(),
    );
  }

  DrawingEmbedData get drawingData => DrawingEmbedData.parse(data);
}

/// Draws a [DrawingEmbed] inline in the Quill editor.
class DrawingEmbedBuilder extends EmbedBuilder {
  DrawingEmbedBuilder({required this.store, this.onEditDrawing});

  final InlineImageStore store;
  final Future<void> Function(DrawingEmbedData data, int documentOffset)?
  onEditDrawing;

  @override
  String get key => DrawingEmbed.drawingType;

  @override
  Widget build(BuildContext context, EmbedContext embedContext) {
    final data = DrawingEmbedData.parse(embedContext.node.value.data);
    final offset = embedContext.node.documentOffset;

    void replaceWith(Object replacement, {bool collapseAfter = false}) {
      embedContext.controller.replaceText(
        offset,
        1,
        replacement,
        collapseAfter ? TextSelection.collapsed(offset: offset) : null,
        ignoreFocus: !collapseAfter,
      );
    }

    return _InlineDrawingBlock(
      key: ValueKey('drawing-embed-${data.attachmentId}'),
      data: data,
      store: store,
      readOnly: embedContext.readOnly,
      onEdit: embedContext.readOnly || onEditDrawing == null
          ? null
          : () => onEditDrawing!(data, offset),
      onWidthChanged: embedContext.readOnly
          ? null
          : (width) => replaceWith(
              DrawingEmbed(data.copyWith(widthFactor: width).encode()),
            ),
      onDelete: embedContext.readOnly
          ? null
          : () => replaceWith('', collapseAfter: true),
    );
  }
}

class _InlineDrawingBlock extends StatefulWidget {
  const _InlineDrawingBlock({
    super.key,
    required this.data,
    required this.store,
    required this.readOnly,
    this.onEdit,
    this.onWidthChanged,
    this.onDelete,
  });

  final DrawingEmbedData data;
  final InlineImageStore store;
  final bool readOnly;
  final VoidCallback? onEdit;
  final ValueChanged<double>? onWidthChanged;
  final VoidCallback? onDelete;

  @override
  State<_InlineDrawingBlock> createState() => _InlineDrawingBlockState();
}

class _InlineDrawingBlockState extends State<_InlineDrawingBlock> {
  static const double _maxHeight = 360;
  late Future<InlineImageState> _state;

  @override
  void initState() {
    super.initState();
    _state = widget.store.resolve(widget.data.attachmentId);
  }

  @override
  void didUpdateWidget(covariant _InlineDrawingBlock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data.attachmentId != widget.data.attachmentId) {
      _state = widget.store.resolve(widget.data.attachmentId);
    }
  }

  Future<void> _unlock() async {
    final next = widget.store.unlock(widget.data.attachmentId);
    setState(() => _state = next);
    await next;
  }

  void _openFullScreen(File file) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) =>
            _FullScreenDrawing(file: file, fileName: widget.data.fileName),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TextFieldTapRegion(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: widget.data.widthFactor,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: _maxHeight),
                child: FutureBuilder<InlineImageState>(
                  future: _state,
                  builder: (context, snapshot) => _buildBody(snapshot.data),
                ),
              ),
            ),
            if (!widget.readOnly) _buildControls(context),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(InlineImageState? state) {
    final l10n = AppLocalizations.of(context);
    return switch (state) {
      null => _DrawingPlaceholder(
        key: const Key('drawing-loading'),
        icon: Icons.draw_outlined,
        message: l10n.drawingLoading,
      ),
      InlineImageReady(:final file) => GestureDetector(
        key: const Key('drawing-open-fullscreen'),
        onTap: () => _openFullScreen(file),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(7),
            child: Image.file(
              file,
              fit: BoxFit.contain,
              alignment: Alignment.centerLeft,
              errorBuilder: (_, _, _) => _DrawingPlaceholder(
                icon: Icons.broken_image_outlined,
                message: l10n.drawingUnavailable,
              ),
            ),
          ),
        ),
      ),
      InlineImageLocked() => _DrawingPlaceholder(
        key: const Key('drawing-locked'),
        icon: Icons.lock_outline,
        message: 'Locked drawing — tap to unlock',
        onTap: _unlock,
      ),
      InlineImageUnavailable() => _DrawingPlaceholder(
        key: const Key('drawing-unavailable'),
        icon: Icons.broken_image_outlined,
        message: widget.data.fileName.isEmpty
            ? l10n.drawingUnavailable
            : '${l10n.drawingUnavailable} — ${widget.data.fileName}',
      ),
    };
  }

  Widget _buildControls(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Row(
      children: [
        if (widget.onEdit != null)
          IconButton(
            key: const Key('drawing-edit-button'),
            icon: const Icon(Icons.edit_outlined, size: 18),
            color: theme.colorScheme.onSurfaceVariant,
            tooltip: l10n.drawingEditTooltip,
            onPressed: widget.onEdit,
          ),
        if (widget.onWidthChanged != null)
          PopupMenuButton<double>(
            key: const Key('drawing-size-menu'),
            tooltip: l10n.drawingSizeTooltip,
            icon: Icon(
              Icons.photo_size_select_large,
              size: 18,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            onSelected: widget.onWidthChanged,
            itemBuilder: (_) => [
              PopupMenuItem(
                value: DrawingEmbedData.smallWidth,
                child: Text(l10n.editorImageSizeSmall),
              ),
              PopupMenuItem(
                value: DrawingEmbedData.mediumWidth,
                child: Text(l10n.editorImageSizeMedium),
              ),
              PopupMenuItem(
                value: DrawingEmbedData.fullWidth,
                child: Text(l10n.editorImageSizeFull),
              ),
            ],
          ),
        if (widget.onDelete != null)
          IconButton(
            key: const Key('drawing-delete-button'),
            icon: const Icon(Icons.close, size: 18),
            color: theme.colorScheme.onSurfaceVariant,
            tooltip: l10n.drawingDeleteTooltip,
            onPressed: widget.onDelete,
          ),
      ],
    );
  }
}

class _DrawingPlaceholder extends StatelessWidget {
  const _DrawingPlaceholder({
    super.key,
    required this.icon,
    required this.message,
    this.onTap,
  });

  final IconData icon;
  final String message;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 120,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FullScreenDrawing extends StatelessWidget {
  const _FullScreenDrawing({required this.file, required this.fileName});

  final File file;
  final String fileName;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(fileName.isEmpty ? l10n.drawingDefaultTitle : fileName),
      ),
      body: Center(
        child: InteractiveViewer(
          maxScale: 5,
          child: Image.file(
            file,
            errorBuilder: (context, _, _) =>
                Text(AppLocalizations.of(context).drawingUnavailable),
          ),
        ),
      ),
    );
  }
}
