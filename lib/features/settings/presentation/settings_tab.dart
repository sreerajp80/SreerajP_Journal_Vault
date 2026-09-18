import 'package:flutter/material.dart';
import 'package:sreerajp_journal_vault/features/about/presentation/about_screen.dart';
import 'package:sreerajp_journal_vault/features/appearance/presentation/appearance_screen.dart';
import 'package:sreerajp_journal_vault/features/entries/presentation/time_capsules_list_screen.dart';
import 'package:sreerajp_journal_vault/features/features_catalog/presentation/features_screen.dart';
import 'package:sreerajp_journal_vault/features/help/presentation/help_home_screen.dart';
import 'package:sreerajp_journal_vault/features/ritual/presentation/ritual_screen.dart';
import 'package:sreerajp_journal_vault/features/settings/presentation/permissions_settings_screen.dart';
import 'package:sreerajp_journal_vault/features/settings/presentation/security_settings_screen.dart';
import 'package:sreerajp_journal_vault/features/settings/presentation/storage_settings_screen.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

/// Settings home — a menu of cards, one per section.
///
/// Each card opens a page that holds only that section's rows, so the screen
/// stays short and related controls stay together.
class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navSettings)),
      body: ListView(
        key: const Key('settings-list'),
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          SettingsSectionCard(
            cardKey: const Key('settings-card-security'),
            icon: Icons.lock_outline,
            title: l10n.titleSettingsSectionSecurity,
            subtitle: l10n.descSettingsSectionSecurity,
            builder: (_) => const SecuritySettingsScreen(),
          ),
          SettingsSectionCard(
            cardKey: const Key('settings-card-appearance'),
            icon: Icons.palette_outlined,
            title: l10n.titleSettingsSectionAppearance,
            subtitle: l10n.descSettingsSectionAppearance,
            builder: (_) => const AppearanceScreen(),
          ),
          SettingsSectionCard(
            cardKey: const Key('settings-card-time-capsules'),
            icon: Icons.hourglass_bottom_rounded,
            title: l10n.titleTimeCapsule,
            subtitle: l10n.descTimeCapsule,
            builder: (_) => const TimeCapsulesListScreen(),
          ),
          SettingsSectionCard(
            cardKey: const Key('settings-card-ritual'),
            icon: Icons.self_improvement_rounded,
            title: l10n.titleRitualSettingsTile,
            subtitle: l10n.descRitualSettingsTile,
            builder: (_) => const RitualScreen(),
          ),
          SettingsSectionCard(
            cardKey: const Key('settings-card-storage'),
            icon: Icons.folder_outlined,
            title: l10n.titleSettingsSectionStorage,
            subtitle: l10n.descSettingsSectionStorage,
            builder: (_) => const StorageSettingsScreen(),
          ),
          SettingsSectionCard(
            cardKey: const Key('settings-card-features'),
            icon: Icons.stars_outlined,
            title: l10n.titleSettingsSectionFeatures,
            subtitle: l10n.descSettingsSectionFeatures,
            builder: (_) => const FeaturesScreen(),
          ),
          SettingsSectionCard(
            cardKey: const Key('settings-card-permissions'),
            icon: Icons.verified_user_outlined,
            title: l10n.titleSettingsSectionPermissions,
            subtitle: l10n.descSettingsSectionPermissions,
            builder: (_) => const PermissionsSettingsScreen(),
          ),
          SettingsSectionCard(
            cardKey: const Key('settings-card-help'),
            icon: Icons.help_outline,
            title: l10n.titleSettingsSectionHelp,
            subtitle: l10n.descSettingsSectionHelp,
            builder: (_) => const HelpHomeScreen(),
          ),
          SettingsSectionCard(
            cardKey: const Key('settings-card-about'),
            icon: Icons.info_outline,
            title: l10n.titleSettingsSectionAbout,
            subtitle: l10n.descSettingsSectionAbout,
            builder: (_) => const AboutScreen(),
          ),
        ],
      ),
    );
  }
}

/// One tappable card on the Settings home screen.
class SettingsSectionCard extends StatelessWidget {
  const SettingsSectionCard({
    super.key,
    required this.cardKey,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.builder,
  });

  final Key cardKey;
  final IconData icon;
  final String title;
  final String subtitle;
  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;

    return Semantics(
      button: true,
      label: title,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          key: cardKey,
          borderRadius: BorderRadius.circular(20),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute<void>(builder: builder),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(icon, color: accent),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
