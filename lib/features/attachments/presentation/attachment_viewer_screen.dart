import 'package:flutter/material.dart';

import 'package:sreerajp_journal_vault/features/attachments/domain/attachment_open_models.dart';
import 'package:sreerajp_journal_vault/features/attachments/presentation/archive_attachment_view.dart';
import 'package:sreerajp_journal_vault/features/attachments/presentation/audio_attachment_view.dart';
import 'package:sreerajp_journal_vault/features/attachments/presentation/pdf_attachment_view.dart';
import 'package:sreerajp_journal_vault/features/attachments/services/attachment_open_service.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

/// Host screen for in-app attachment viewing.
///
/// Owns the decrypted [AttachmentOpenSession]: the plaintext temp file is
/// deleted when this screen is disposed, so closing the viewer leaves nothing
/// behind. Type-specific bodies are injected based on the routing decision the
/// session already carries.
class AttachmentViewerScreen extends StatefulWidget {
  const AttachmentViewerScreen({
    required this.session,
    this.onOpenExternally,
    this.playbackHandleFactory,
    this.archiveEntryReader = readZipEntries,
    super.key,
  });

  final AttachmentOpenSession session;

  /// Invoked by the `Open with...` action. Null hides the action.
  final Future<void> Function()? onOpenExternally;

  /// Forwarded to [AudioAttachmentView] so tests can fake playback.
  final AudioPlaybackHandle Function()? playbackHandleFactory;

  /// Forwarded to [ArchiveAttachmentView] so tests can fake archive reads.
  final List<ArchiveEntryInfo> Function(String filePath) archiveEntryReader;

  @override
  State<AttachmentViewerScreen> createState() => _AttachmentViewerScreenState();
}

class _AttachmentViewerScreenState extends State<AttachmentViewerScreen> {
  @override
  void dispose() {
    // Fire-and-forget: the widget is going away and the delete must not block
    // the frame. Any file left behind is still caught by the startup sweep.
    widget.session.close();
    super.dispose();
  }

  Widget _body() {
    final path = widget.session.filePath;
    switch (widget.session.decision.kind) {
      case AttachmentOpenKind.inAppPdf:
        return PdfAttachmentView(filePath: path);
      case AttachmentOpenKind.inAppAudio:
        return AudioAttachmentView(
          filePath: path,
          playbackHandleFactory: widget.playbackHandleFactory,
        );
      case AttachmentOpenKind.inAppArchive:
        return ArchiveAttachmentView(
          filePath: path,
          entryReader: widget.archiveEntryReader,
        );
      case AttachmentOpenKind.externalOnly:
      case AttachmentOpenKind.unsupported:
        // The caller is expected to hand these off without opening the viewer.
        // Reaching here means routing changed, so state it plainly rather than
        // showing an empty screen.
        return _UnsupportedBody(
          fileName: widget.session.fileName,
          onOpenExternally: widget.onOpenExternally,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      key: const Key('attachment-viewer-screen'),
      appBar: AppBar(
        title: Text(widget.session.fileName, overflow: TextOverflow.ellipsis),
        actions: [
          if (widget.onOpenExternally != null)
            IconButton(
              key: const Key('attachment-viewer-open-with'),
              icon: const Icon(Icons.open_in_new),
              tooltip: l10n.attachmentOpenWith,
              onPressed: widget.onOpenExternally,
            ),
        ],
      ),
      body: _body(),
    );
  }
}

class _UnsupportedBody extends StatelessWidget {
  const _UnsupportedBody({required this.fileName, this.onOpenExternally});

  final String fileName;
  final Future<void> Function()? onOpenExternally;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      key: const Key('attachment-viewer-unsupported'),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.help_outline, size: 48),
            const SizedBox(height: 16),
            Text(
              l10n.attachmentUnsupportedTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.attachmentUnsupportedBody(fileName),
              textAlign: TextAlign.center,
            ),
            if (onOpenExternally != null) ...[
              const SizedBox(height: 16),
              FilledButton(
                onPressed: onOpenExternally,
                child: Text(l10n.attachmentOpenWith),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
