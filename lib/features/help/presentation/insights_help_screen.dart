import 'package:flutter/material.dart';

import 'package:sreerajp_journal_vault/features/help/presentation/help_components.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

class InsightsHelpScreen extends StatelessWidget {
  const InsightsHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.helpTopicInsights)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        children: [
          HelpIntro(l10n.helpInsightsIntro),
          const SizedBox(height: 24),
          HelpSection(
            icon: Icons.local_fire_department_outlined,
            title: l10n.helpInsightsSectionHabits,
            children: [
              HelpBullet(l10n.helpInsightsHabitsBullet1),
              HelpBullet(l10n.helpInsightsHabitsBullet2),
            ],
          ),
          HelpSection(
            icon: Icons.bar_chart_outlined,
            title: l10n.helpInsightsSectionStats,
            children: [HelpBullet(l10n.helpInsightsStatsBullet1)],
          ),
          HelpSection(
            icon: Icons.pie_chart_outline,
            title: l10n.helpInsightsSectionTags,
            children: [HelpBullet(l10n.helpInsightsTagsBullet1)],
          ),
        ],
      ),
    );
  }
}
