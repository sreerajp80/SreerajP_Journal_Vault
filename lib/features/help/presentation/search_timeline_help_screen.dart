import 'package:flutter/material.dart';

import 'package:sreerajp_journal_vault/features/help/presentation/help_components.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

class SearchTimelineHelpScreen extends StatelessWidget {
  const SearchTimelineHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.helpTopicSearchTimeline)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        children: [
          HelpIntro(l10n.helpSearchTimelineIntro),
          const SizedBox(height: 24),
          HelpSection(
            icon: Icons.manage_search_outlined,
            title: l10n.helpSearchTimelineSectionFts,
            children: [HelpBullet(l10n.helpSearchTimelineFtsBullet1)],
          ),
          HelpSection(
            icon: Icons.bookmark_border_outlined,
            title: l10n.helpSearchTimelineSectionPresets,
            children: [HelpBullet(l10n.helpSearchTimelinePresetsBullet1)],
          ),
          HelpSection(
            icon: Icons.calendar_month_outlined,
            title: l10n.helpSearchTimelineSectionTimeline,
            children: [HelpBullet(l10n.helpSearchTimelineTimelineBullet1)],
          ),
        ],
      ),
    );
  }
}
