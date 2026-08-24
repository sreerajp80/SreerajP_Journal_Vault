import 'package:flutter/material.dart';

import 'package:sreerajp_journal_vault/features/help/presentation/help_components.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

class StorageMigrationHelpScreen extends StatelessWidget {
  const StorageMigrationHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.helpTopicStorageMigration)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        children: [
          HelpIntro(l10n.helpStorageMigrationIntro),
          const SizedBox(height: 24),
          HelpSection(
            icon: Icons.phone_android_outlined,
            title: l10n.helpStorageMigrationSectionInternal,
            children: [HelpBullet(l10n.helpStorageMigrationInternalBullet1)],
          ),
          HelpSection(
            icon: Icons.sd_card_outlined,
            title: l10n.helpStorageMigrationSectionSd,
            children: [
              HelpBullet(l10n.helpStorageMigrationSdBullet1),
              HelpBullet(l10n.helpStorageMigrationSdBullet2),
            ],
          ),
        ],
      ),
    );
  }
}
