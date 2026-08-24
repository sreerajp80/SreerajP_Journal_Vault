import 'package:flutter/material.dart';

import 'package:sreerajp_journal_vault/features/help/presentation/help_components.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

class JournalLocksHelpScreen extends StatelessWidget {
  const JournalLocksHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.helpTopicJournalLocks)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        children: [
          HelpIntro(l10n.helpJournalLocksIntro),
          const SizedBox(height: 24),
          HelpSection(
            icon: Icons.password_rounded,
            title: l10n.helpJournalLocksSectionJournal,
            children: [
              HelpBullet(l10n.helpJournalLocksJournalBullet1),
              HelpBullet(l10n.helpJournalLocksJournalBullet2),
            ],
          ),
          HelpSection(
            icon: Icons.attach_file_outlined,
            title: l10n.helpJournalLocksSectionAttachment,
            children: [HelpBullet(l10n.helpJournalLocksAttachmentBullet1)],
          ),
        ],
      ),
    );
  }
}
