import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sreerajp_journal_vault/core/l10n/locale_controller.dart';
import 'package:sreerajp_journal_vault/features/appearance/presentation/accent_color_settings_screen.dart';
import 'package:sreerajp_journal_vault/features/appearance/presentation/language_settings_screen.dart';
import 'package:sreerajp_journal_vault/features/appearance/presentation/theme_mode_settings_screen.dart';
import 'package:sreerajp_journal_vault/features/appearance/presentation/typography_settings_screen.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

/// Appearance preferences hub reached from Settings → Appearance.
class AppearanceScreen extends ConsumerWidget {
  const AppearanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final languageName = appLanguageLabel(
      l10n,
      ref.watch(localeControllerProvider),
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.titleSettingsSectionAppearance)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          _AppearanceCard(
            key: const Key('appearance-card-language'),
            icon: Icons.translate,
            title: l10n.titleLanguage,
            subtitle: languageName,
            // Screen readers hear the current value, not just "Language".
            semanticsLabel: l10n.labelLanguageCurrent(languageName),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const LanguageSettingsScreen(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _AppearanceCard(
            key: const Key('appearance-card-theme-mode'),
            icon: Icons.brightness_6_outlined,
            title: l10n.titleAppearanceThemeMode,
            subtitle: l10n.descAppearanceThemeMode,
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
            title: l10n.titleAppearanceAccentColor,
            subtitle: l10n.descAppearanceAccentColor,
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
            title: l10n.titleAppearanceTypography,
            subtitle: l10n.descAppearanceTypography,
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
    this.semanticsLabel,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;

    final card = Card(
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

    if (semanticsLabel == null) return card;
    return Semantics(
      button: true,
      label: semanticsLabel,
      excludeSemantics: true,
      onTap: onTap,
      child: card,
    );
  }
}
