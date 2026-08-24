import 'package:flutter/material.dart';

import 'package:sreerajp_journal_vault/features/help/presentation/help_components.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

class BackupRestoreHelpScreen extends StatelessWidget {
  const BackupRestoreHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.helpTopicBackupRestore)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        children: [
          HelpIntro(l10n.helpBackupIntro),
          const SizedBox(height: 24),
          HelpSection(
            icon: Icons.backup_outlined,
            title: l10n.helpBackupSectionCreate,
            children: [
              HelpBullet(l10n.helpBackupCreateBullet1),
              HelpBullet(l10n.helpBackupCreateBullet2),
              HelpBullet(l10n.helpBackupCreateBullet3),
            ],
          ),
          HelpSection(
            icon: Icons.restore_page_outlined,
            title: l10n.helpBackupSectionRestore,
            children: [
              HelpBullet(l10n.helpBackupRestoreBullet1),
              HelpBullet(l10n.helpBackupRestoreBullet2),
              HelpBullet(l10n.helpBackupRestoreBullet3),
            ],
          ),
          const SizedBox(height: 8),
          HelpFooter(l10n.helpBackupFooter),
        ],
      ),
    );
  }
}
