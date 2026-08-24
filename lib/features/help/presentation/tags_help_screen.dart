import 'package:flutter/material.dart';

import 'package:sreerajp_journal_vault/features/help/presentation/help_components.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

class TagsHelpScreen extends StatelessWidget {
  const TagsHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.helpTopicTags)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        children: [
          HelpIntro(l10n.helpTagsIntro),
          const SizedBox(height: 24),
          HelpSection(
            icon: Icons.label_outline,
            title: l10n.helpTagsSectionTagging,
            children: [HelpBullet(l10n.helpTagsTaggingBullet1)],
          ),
          HelpSection(
            icon: Icons.palette_outlined,
            title: l10n.helpTagsSectionColors,
            children: [HelpBullet(l10n.helpTagsColorsBullet1)],
          ),
          HelpSection(
            icon: Icons.auto_delete_outlined,
            title: l10n.helpTagsSectionCleanup,
            children: [HelpBullet(l10n.helpTagsCleanupBullet1)],
          ),
        ],
      ),
    );
  }
}
