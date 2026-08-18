import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sreerajp_journal_vault/core/database/database_providers.dart';
import 'package:sreerajp_journal_vault/features/attachments/providers/attachment_providers.dart';
import 'package:sreerajp_journal_vault/features/export/services/export_collector.dart';
import 'package:sreerajp_journal_vault/features/export/services/export_service.dart';
import 'package:sreerajp_journal_vault/features/export/services/html_pdf_service.dart';

/// Reads the database and gathers what an export covers.
final exportCollectorProvider = Provider<ExportCollector>((ref) {
  return ExportCollector(ref.watch(appDatabaseProvider));
});

/// Talks to the native PDF renderer.
final htmlPdfServiceProvider = Provider<HtmlPdfService>((ref) {
  return const HtmlPdfService();
});

/// Turns a gathered bundle into the bytes of a file to save.
final exportServiceProvider = Provider<ExportService>((ref) {
  return ExportService(
    cryptoStorage: ref.watch(attachmentCryptoStorageProvider),
    pdfService: ref.watch(htmlPdfServiceProvider),
  );
});

/// Whether this device can produce a PDF.
///
/// Asked once, up front, so the export screen can show PDF as unavailable
/// rather than letting the user pick it and fail — `SreerajP_PDFApp` rule 6,
/// "never a dead button".
final pdfExportAvailableProvider = FutureProvider<bool>((ref) async {
  return ref.watch(htmlPdfServiceProvider).isAvailable();
});
