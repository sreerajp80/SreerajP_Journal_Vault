import 'package:flutter/material.dart';

import 'package:sreerajp_journal_vault/features/help/presentation/help_components.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

class AttachmentsOcrHelpScreen extends StatelessWidget {
  const AttachmentsOcrHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.helpTopicAttachmentsOcr)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        children: [
          HelpIntro(l10n.helpAttachmentsIntro),
          const SizedBox(height: 24),
          HelpSection(
            icon: Icons.document_scanner_outlined,
            title: l10n.helpAttachmentsSectionOcr,
            children: [
              HelpBullet(l10n.helpAttachmentsOcrBullet1),
              HelpBullet(l10n.helpAttachmentsOcrBullet2),
              HelpBullet(l10n.helpAttachmentsOcrBullet3),
            ],
          ),
          HelpSection(
            icon: Icons.lock_outline,
            title: l10n.helpAttachmentsSectionEncryption,
            children: [HelpBullet(l10n.helpAttachmentsEncryptionBullet1)],
          ),
          const SizedBox(height: 8),
          HelpFooter(l10n.helpAttachmentsFooter),
        ],
      ),
    );
  }
}
