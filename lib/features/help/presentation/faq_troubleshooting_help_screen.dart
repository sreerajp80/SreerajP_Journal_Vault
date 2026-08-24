import 'package:flutter/material.dart';

import 'package:sreerajp_journal_vault/features/help/presentation/help_components.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

class FaqTroubleshootingHelpScreen extends StatelessWidget {
  const FaqTroubleshootingHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.helpTopicFaq)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        children: [
          HelpIntro(l10n.helpFaqIntro),
          const SizedBox(height: 24),
          HelpSection(
            icon: Icons.wifi_off_outlined,
            title: l10n.helpFaqQ1,
            children: [HelpBullet(l10n.helpFaqA1)],
          ),
          HelpSection(
            icon: Icons.lock_reset_outlined,
            title: l10n.helpFaqQ2,
            children: [HelpBullet(l10n.helpFaqA2)],
          ),
          HelpSection(
            icon: Icons.privacy_tip_outlined,
            title: l10n.helpFaqQ3,
            children: [HelpBullet(l10n.helpFaqA3)],
          ),
          HelpSection(
            icon: Icons.phonelink_setup_outlined,
            title: l10n.helpFaqQ4,
            children: [HelpBullet(l10n.helpFaqA4)],
          ),
        ],
      ),
    );
  }
}
