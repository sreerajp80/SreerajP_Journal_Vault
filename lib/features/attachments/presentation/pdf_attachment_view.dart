import 'dart:io';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
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
          child: Text(l10n.attachmentPdfMissing),
        ),
      );
    }

    return SfPdfViewer.file(
      file,
      key: const Key('pdf-attachment-viewer'),
      onDocumentLoadFailed: (details) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.attachmentPdfOpenFailed(details.description)),
          ),
        );
      },
    );
  }
}
