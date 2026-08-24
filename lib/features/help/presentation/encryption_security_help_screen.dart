import 'package:flutter/material.dart';

import 'package:sreerajp_journal_vault/features/help/presentation/help_components.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

class EncryptionSecurityHelpScreen extends StatelessWidget {
  const EncryptionSecurityHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.helpTopicEncryption)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        children: [
          HelpIntro(l10n.helpEncryptionIntro),
          const SizedBox(height: 24),
          HelpSection(
            icon: Icons.lock_outline,
            title: l10n.helpEncryptionSectionSqlcipher,
            children: [
              HelpBullet(l10n.helpEncryptionSqlcipherBullet1),
              HelpBullet(l10n.helpEncryptionSqlcipherBullet2),
            ],
          ),
          HelpSection(
            icon: Icons.security,
            title: l10n.helpEncryptionSectionKeystore,
            children: [
              HelpBullet(l10n.helpEncryptionKeystoreBullet1),
              HelpBullet(l10n.helpEncryptionKeystoreBullet2),
            ],
          ),
          HelpSection(
            icon: Icons.wifi_off_outlined,
            title: l10n.helpEncryptionSectionOffline,
            children: [
              HelpBullet(l10n.helpEncryptionOfflineBullet1),
              HelpBullet(l10n.helpEncryptionOfflineBullet2),
            ],
          ),
        ],
      ),
    );
  }
}
