import 'package:flutter/material.dart';

import 'package:sreerajp_journal_vault/features/appearance/presentation/accent_color_settings_screen.dart';
import 'package:sreerajp_journal_vault/features/appearance/presentation/theme_mode_settings_screen.dart';
import 'package:sreerajp_journal_vault/features/appearance/presentation/typography_settings_screen.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

/// Appearance preferences hub reached from Settings → Appearance.
class AppearanceScreen extends StatelessWidget {
  const AppearanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsSectionAppearance)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          _AppearanceCard(
            key: const Key('appearance-card-theme-mode'),
            icon: Icons.brightness_6_outlined,
            title: l10n.appearanceThemeModeTitle,
            subtitle: l10n.appearanceThemeModeSubtitle,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const ThemeModeSettingsScreen(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _AppearanceCard(
            key: const Key('appearance-card-accent-color'),
            icon: Icons.color_lens_outlined,
            title: l10n.appearanceAccentColorTitle,
            subtitle: l10n.appearanceAccentColorSubtitle,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const AccentColorSettingsScreen(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _AppearanceCard(
            key: const Key('appearance-card-typography'),
            icon: Icons.text_fields_rounded,
            title: l10n.appearanceTypographyTitle,
            subtitle: l10n.appearanceTypographySubtitle,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const TypographySettingsScreen(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AppearanceCard extends StatelessWidget {
  const _AppearanceCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;

    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
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
    );
  }
}
