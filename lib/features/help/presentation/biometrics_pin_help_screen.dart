import 'package:flutter/material.dart';

import 'package:sreerajp_journal_vault/features/help/presentation/help_components.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

class BiometricsPinHelpScreen extends StatelessWidget {
  const BiometricsPinHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.helpTopicBiometrics)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        children: [
          HelpIntro(l10n.helpBiometricsIntro),
          const SizedBox(height: 24),
          HelpSection(
            icon: Icons.fingerprint,
            title: l10n.helpBiometricsSectionPhoneLock,
            children: [
              HelpBullet(l10n.helpBiometricsPhoneLockBullet1),
              HelpBullet(l10n.helpBiometricsPhoneLockBullet2),
            ],
          ),
          HelpSection(
            icon: Icons.pin_outlined,
            title: l10n.helpBiometricsSectionAppPin,
            children: [
              HelpBullet(l10n.helpBiometricsAppPinBullet1),
              HelpBullet(l10n.helpBiometricsAppPinBullet2),
            ],
          ),
          HelpSection(
            icon: Icons.timer_outlined,
            title: l10n.helpBiometricsSectionAutoLock,
            children: [
              HelpBullet(l10n.helpBiometricsAutoLockBullet1),
              HelpBullet(l10n.helpBiometricsAutoLockBullet2),
            ],
          ),
        ],
      ),
    );
  }
}
