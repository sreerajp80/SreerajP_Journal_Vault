import 'package:flutter/material.dart';

import 'package:sreerajp_journal_vault/features/help/presentation/help_components.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

class ScreenshotAuditHelpScreen extends StatelessWidget {
  const ScreenshotAuditHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.helpTopicScreenshotAudit)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        children: [
          HelpIntro(l10n.helpScreenshotAuditIntro),
          const SizedBox(height: 24),
          HelpSection(
            icon: Icons.screenshot_outlined,
            title: l10n.helpScreenshotAuditSectionGuard,
            children: [
              HelpBullet(l10n.helpScreenshotAuditGuardBullet1),
              HelpBullet(l10n.helpScreenshotAuditGuardBullet2),
            ],
          ),
          HelpSection(
            icon: Icons.history_edu_outlined,
            title: l10n.helpScreenshotAuditSectionLog,
            children: [HelpBullet(l10n.helpScreenshotAuditLogBullet1)],
          ),
        ],
      ),
    );
  }
}
