import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

/// In-app PDF viewer for an attachment (V1 attachment plan, slice 3).
///
/// Renders the decrypted temp file directly. The file is never handed to
/// another app, so the plaintext stays inside the app cache.
class PdfAttachmentView extends StatelessWidget {
  const PdfAttachmentView({required this.filePath, super.key});

  final String filePath;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final file = File(filePath);
    if (!file.existsSync()) {
      return Center(
        key: const Key('pdf-attachment-missing'),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(l10n.bodyAttachmentPdfMissing),
        ),
      );
    }

    return PdfViewer.file(
      filePath,
      key: const Key('pdf-attachment-viewer'),
      params: PdfViewerParams(
        errorBannerBuilder: (context, error, stackTrace, documentRef) {
          return Center(
            key: const Key('pdf-attachment-error'),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(l10n.errorAttachmentPdfOpen(error.toString())),
            ),
          );
        },
      ),
    );
  }
}
