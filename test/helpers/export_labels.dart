import 'package:flutter/widgets.dart';
import 'package:sreerajp_journal_vault/features/export/presentation/export_text.dart';
import 'package:sreerajp_journal_vault/features/export/services/export_labels.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

/// The English words an export writes, straight from `app_en.arb`, so export
/// tests can check real output without hard-coding the translation.
final ExportLabels englishExportLabels = exportLabelsFor(
  lookupAppLocalizations(const Locale('en')),
);
