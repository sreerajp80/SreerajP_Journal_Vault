import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

import 'package:sreerajp_journal_vault/features/entries/presentation/editor/inline_image_store.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

/// What a `vault_image` embed stores in the document.
///
/// **Only the attachment id — never the bytes.** The document JSON lives
/// unencrypted in `Entries.contentJson`, so the picture itself has to stay
/// where every other file is: in the encrypted attachment store. This is also
/// why the embed does not reuse Quill's built-in `image` type, which expects a
/// URL or base64 data in the delta.
class VaultImageData {
  const VaultImageData({
    required this.attachmentId,
    required this.fileName,
    this.widthFactor = fullWidth,
  });

  /// The row in `Attachments` holding the encrypted picture.
  final int attachmentId;

  /// The original file name, shown when the picture cannot be drawn.
  final String fileName;

  /// How much of the editor's width the picture takes: [smallWidth],
  /// [mediumWidth] or [fullWidth].
  final double widthFactor;

  static const double smallWidth = 0.4;
  static const double mediumWidth = 0.66;
  static const double fullWidth = 1.0;

  /// Reads embed data. Never throws — a document that survived a bad write
  /// still has to open, so anything unreadable becomes an id of 0, which the
  /// builder draws as an unavailable image.
  static VaultImageData parse(Object? raw) {
    if (raw is! String) {
      return const VaultImageData(attachmentId: 0, fileName: '');
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) {
        return const VaultImageData(attachmentId: 0, fileName: '');
      }
      final id = decoded['attachmentId'];
      final width = decoded['widthFactor'];
      return VaultImageData(
        attachmentId: id is int ? id : int.tryParse('$id') ?? 0,
        fileName: decoded['fileName']?.toString() ?? '',
        // Clamped to the three offered sizes, so a surprising number cannot
        // make the picture wider than the page or too small to see.
        widthFactor: _nearestWidth(width is num ? width.toDouble() : fullWidth),
      );
    } on FormatException {
      return const VaultImageData(attachmentId: 0, fileName: '');
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
  });

  VaultImageData copyWith({double? widthFactor}) => VaultImageData(
    attachmentId: attachmentId,
    fileName: fileName,
    widthFactor: widthFactor ?? this.widthFactor,
  );
}

/// An image embedded in the flow of the entry, backed by an encrypted
/// attachment.
class VaultImageEmbed extends CustomBlockEmbed {
  const VaultImageEmbed(String data) : super(vaultImageType, data);

  static const String vaultImageType = 'vault_image';

  factory VaultImageEmbed.create({
    required int attachmentId,
    required String fileName,
    double widthFactor = VaultImageData.fullWidth,
  }) {
    return VaultImageEmbed(
      VaultImageData(
        attachmentId: attachmentId,
        fileName: fileName,
        widthFactor: widthFactor,
      ).encode(),
    );
  }

  VaultImageData get imageData => VaultImageData.parse(data);
}

/// Draws a [VaultImageEmbed], decrypting it through [store].
class VaultImageEmbedBuilder extends EmbedBuilder {
  VaultImageEmbedBuilder({required this.store});

  final InlineImageStore store;

  @override
  String get key => VaultImageEmbed.vaultImageType;

  @override
  Widget build(BuildContext context, EmbedContext embedContext) {
    final data = VaultImageData.parse(embedContext.node.value.data);

    // node.documentOffset is the embed's authoritative position — the same
    // reason callout_embed.dart and table_embed.dart use it.
    void replaceWith(Object replacement, {bool collapseAfter = false}) {
      final offset = embedContext.node.documentOffset;
      embedContext.controller.replaceText(
        offset,
        1,
        replacement,
        collapseAfter ? TextSelection.collapsed(offset: offset) : null,
        ignoreFocus: !collapseAfter,
      );
    }

    return _InlineImageBlock(
      // Keyed by id so Flutter rebuilds the state — and re-resolves the file —
      // when a different picture takes this embed's place.
      key: ValueKey('vault-image-${data.attachmentId}'),
      data: data,
      store: store,
      readOnly: embedContext.readOnly,
      onWidthChanged: embedContext.readOnly
          ? null
          : (width) => replaceWith(
              VaultImageEmbed(data.copyWith(widthFactor: width).encode()),
            ),
      onDelete: embedContext.readOnly
          ? null
          // Only the embed leaves the document. The attachment row stays, so
          // the picture is still in the tray and can be put back — deleting a
          // file for good is the tray's job, not a keystroke's.
          : () => replaceWith('', collapseAfter: true),
    );
  }
}

class _InlineImageBlock extends StatefulWidget {
  const _InlineImageBlock({
    super.key,
    required this.data,
    required this.store,
    required this.readOnly,
    this.onWidthChanged,
    this.onDelete,
  });

  final VaultImageData data;
  final InlineImageStore store;
  final bool readOnly;
  final ValueChanged<double>? onWidthChanged;
  final VoidCallback? onDelete;

  @override
  State<_InlineImageBlock> createState() => _InlineImageBlockState();
}

class _InlineImageBlockState extends State<_InlineImageBlock> {
  /// Tallest an image is drawn inline. A portrait photo would otherwise fill
  /// the screen and push the writing out of sight.
  static const double _maxHeight = 320;

  late Future<InlineImageState> _state;

  @override
  void initState() {
    super.initState();
    _state = widget.store.resolve(widget.data.attachmentId);
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
            _FullScreenImage(file: file, fileName: widget.data.fileName),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // TextFieldTapRegion keeps a tap on the picture from reading as a "tap
    // outside" to the title field and the callout/table fields on the page.
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
    return switch (state) {
      null => const _ImagePlaceholder(
        key: Key('vault-image-loading'),
        icon: Icons.image_outlined,
        message: 'Loading image…',
      ),
      InlineImageReady(:final file) => GestureDetector(
        key: const Key('vault-image-open'),
        onTap: () => _openFullScreen(file),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(
            file,
            fit: BoxFit.contain,
            alignment: Alignment.centerLeft,
            // A file that disappears under us (cache swept while the screen is
            // open) must not throw a red box into the middle of the entry.
            errorBuilder: (_, _, _) => const _ImagePlaceholder(
              icon: Icons.broken_image_outlined,
              message: 'Image unavailable',
            ),
          ),
        ),
      ),
      InlineImageLocked() => _ImagePlaceholder(
        key: const Key('vault-image-locked'),
        icon: Icons.lock_outline,
        message: 'Locked image — tap to unlock',
        onTap: _unlock,
      ),
      InlineImageUnavailable() => _ImagePlaceholder(
        key: const Key('vault-image-unavailable'),
        icon: Icons.broken_image_outlined,
        message: widget.data.fileName.isEmpty
            ? 'Image unavailable'
            : 'Image unavailable — ${widget.data.fileName}',
      ),
    };
  }

  Widget _buildControls(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Row(
      children: [
        if (widget.onWidthChanged != null)
          PopupMenuButton<double>(
            key: const Key('vault-image-size-menu'),
            tooltip: l10n.editorImageSize,
            icon: Icon(
              Icons.photo_size_select_large,
              size: 18,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            onSelected: widget.onWidthChanged,
            itemBuilder: (_) => [
              PopupMenuItem(
                value: VaultImageData.smallWidth,
                child: Text(l10n.editorImageSizeSmall),
              ),
              PopupMenuItem(
                value: VaultImageData.mediumWidth,
                child: Text(l10n.editorImageSizeMedium),
              ),
              PopupMenuItem(
                value: VaultImageData.fullWidth,
                child: Text(l10n.editorImageSizeFull),
              ),
            ],
          ),
        if (widget.onDelete != null)
          IconButton(
            key: const Key('vault-image-delete-button'),
            icon: const Icon(Icons.close, size: 18),
            color: theme.colorScheme.onSurfaceVariant,
            tooltip: l10n.editorRemoveImage,
            onPressed: widget.onDelete,
          ),
      ],
    );
  }
}

/// The grey box drawn while loading, and in place of a picture that is locked
/// or cannot be read.
class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder({
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

/// Full-screen, zoomable view of one inline image.
class _FullScreenImage extends StatelessWidget {
  const _FullScreenImage({required this.file, required this.fileName});

  final File file;
  final String fileName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(fileName.isEmpty ? 'Image' : fileName)),
      body: Center(
        child: InteractiveViewer(
          maxScale: 5,
          child: Image.file(
            file,
            errorBuilder: (context, _, _) =>
                Text(AppLocalizations.of(context).editorImageUnavailable),
          ),
        ),
      ),
    );
  }
}
