import 'package:flutter/material.dart';

import 'package:sreerajp_journal_vault/features/help/presentation/help_components.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

class JournalOrganizationHelpScreen extends StatelessWidget {
  const JournalOrganizationHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.helpTopicJournalOrg)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        children: [
          HelpIntro(l10n.helpJournalOrgIntro),
          const SizedBox(height: 24),
          HelpSection(
            icon: Icons.menu_book_outlined,
            title: l10n.helpJournalOrgSectionMultiple,
            children: [
              HelpBullet(l10n.helpJournalOrgMultipleBullet1),
              HelpBullet(l10n.helpJournalOrgMultipleBullet2),
            ],
          ),
          HelpSection(
            icon: Icons.dashboard_customize_outlined,
            title: l10n.helpJournalOrgSectionTemplates,
            children: [
              HelpBullet(l10n.helpJournalOrgTemplatesBullet1),
              HelpBullet(l10n.helpJournalOrgTemplatesBullet2),
            ],
          ),
          HelpSection(
            icon: Icons.format_paint_outlined,
            title: l10n.helpJournalOrgSectionRichText,
            children: [HelpBullet(l10n.helpJournalOrgRichTextBullet1)],
          ),
        ],
      ),
    );
  }
}
