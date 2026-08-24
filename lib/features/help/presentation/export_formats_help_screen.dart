import 'package:flutter/material.dart';

import 'package:sreerajp_journal_vault/features/help/presentation/help_components.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

class ExportFormatsHelpScreen extends StatelessWidget {
  const ExportFormatsHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.helpTopicExportFormats)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        children: [
          HelpIntro(l10n.helpExportIntro),
          const SizedBox(height: 24),
          HelpSection(
            icon: Icons.picture_as_pdf_outlined,
            title: l10n.helpExportSectionPdf,
            children: [HelpBullet(l10n.helpExportPdfBullet1)],
          ),
          HelpSection(
            icon: Icons.folder_zip_outlined,
            title: l10n.helpExportSectionMarkdown,
            children: [
              HelpBullet(l10n.helpExportMarkdownBullet1),
              HelpBullet(l10n.helpExportMarkdownBullet2),
            ],
          ),
          HelpSection(
            icon: Icons.lock_open_outlined,
            title: l10n.helpExportSectionReader,
            children: [HelpBullet(l10n.helpExportReaderBullet1)],
          ),
        ],
      ),
    );
  }
}
