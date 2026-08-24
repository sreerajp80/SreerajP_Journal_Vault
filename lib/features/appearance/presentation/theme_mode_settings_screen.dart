import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sreerajp_journal_vault/core/theme/theme_mode_controller.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

/// Screen for choosing between Light, Sepia/Paper, Dark, OLED, and System theme modes.
class ThemeModeSettingsScreen extends ConsumerWidget {
  const ThemeModeSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final currentAppMode = ref.watch(appThemeModeProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.appearanceThemeModeTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          Text(
            l10n.appearanceThemeModeTitle.toUpperCase(),
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 12),

          // ─── Theme Cards ────────────────────────────────────────────────
          _ThemeModeCard(
            key: const Key('theme-mode-option-light'),
            mode: AppThemeMode.light,
            title: l10n.settingsThemeLight,
            subtitle: l10n.settingsThemeLightDesc,
            icon: Icons.light_mode_outlined,
            previewBgColor: const Color(0xFFFAF9F6),
            previewTextColor: const Color(0xFF1C1B1F),
            previewBorderColor: const Color(0xFFCAC4D0),
            isSelected: currentAppMode == AppThemeMode.light,
            onTap: () => _applyTheme(context, ref, AppThemeMode.light),
          ),
          const SizedBox(height: 10),
          _ThemeModeCard(
            key: const Key('theme-mode-option-sepia'),
            mode: AppThemeMode.sepia,
            title: l10n.settingsThemeSepia,
            subtitle: l10n.settingsThemeSepiaDesc,
            icon: Icons.auto_stories_outlined,
            previewBgColor: const Color(0xFFF8F3E6),
            previewTextColor: const Color(0xFF2C221E),
            previewBorderColor: const Color(0xFFD6CABA),
            isSelected: currentAppMode == AppThemeMode.sepia,
            onTap: () => _applyTheme(context, ref, AppThemeMode.sepia),
          ),
          const SizedBox(height: 10),
          _ThemeModeCard(
            key: const Key('theme-mode-option-dark'),
            mode: AppThemeMode.dark,
            title: l10n.settingsThemeDark,
            subtitle: l10n.settingsThemeDarkDesc,
            icon: Icons.dark_mode_outlined,
            previewBgColor: const Color(0xFF1E1E1E),
            previewTextColor: const Color(0xFFE6E1E5),
            previewBorderColor: const Color(0xFF49454F),
            isSelected: currentAppMode == AppThemeMode.dark,
            onTap: () => _applyTheme(context, ref, AppThemeMode.dark),
          ),
          const SizedBox(height: 10),
          _ThemeModeCard(
            key: const Key('theme-mode-option-oled'),
            mode: AppThemeMode.oled,
            title: l10n.settingsThemeOled,
            subtitle: l10n.settingsThemeOledDesc,
            icon: Icons.brightness_2_outlined,
            previewBgColor: const Color(0xFF000000),
            previewTextColor: const Color(0xFFFFFFFF),
            previewBorderColor: const Color(0xFF333333),
            isSelected: currentAppMode == AppThemeMode.oled,
            onTap: () => _applyTheme(context, ref, AppThemeMode.oled),
          ),
          const SizedBox(height: 10),
          _ThemeModeCard(
            key: const Key('theme-mode-option-system'),
            mode: AppThemeMode.system,
            title: l10n.settingsThemeSystem,
            subtitle: l10n.settingsThemeSystemDesc,
            icon: Icons.brightness_auto_outlined,
            previewBgColor: const Color(0xFFE0E0E0),
            previewTextColor: const Color(0xFF202020),
            previewBorderColor: const Color(0xFF888888),
            isSelected: currentAppMode == AppThemeMode.system,
            onTap: () => _applyTheme(context, ref, AppThemeMode.system),
          ),
          const SizedBox(height: 24),

          // ─── Explainer note ─────────────────────────────────────────────
          Card(
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      l10n.appearanceSystemModeExplainer,
                      style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 13,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _applyTheme(
    BuildContext context,
    WidgetRef ref,
    AppThemeMode mode,
  ) async {
    final l10n = AppLocalizations.of(context);
    try {
      await ref.read(appThemeModeProvider.notifier).setAppThemeMode(mode);
      if (context.mounted) {
        final label = switch (mode) {
          AppThemeMode.dark => l10n.settingsThemeDark,
          AppThemeMode.light => l10n.settingsThemeLight,
          AppThemeMode.sepia => l10n.settingsThemeSepia,
          AppThemeMode.oled => l10n.settingsThemeOled,
          AppThemeMode.system => l10n.settingsThemeSystem,
        };
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.settingsThemeUpdated(label)),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.settingsThemeSaveFailed)));
      }
    }
  }
}

class _ThemeModeCard extends StatelessWidget {
  const _ThemeModeCard({
    super.key,
    required this.mode,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.previewBgColor,
    required this.previewTextColor,
    required this.previewBorderColor,
    required this.isSelected,
    required this.onTap,
  });

  final AppThemeMode mode;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color previewBgColor;
  final Color previewTextColor;
  final Color previewBorderColor;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isSelected ? colors.primary : colors.outlineVariant,
          width: isSelected ? 2 : 1,
        ),
      ),
      color: isSelected
          ? colors.primaryContainer.withValues(alpha: 0.25)
          : colors.surface,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Visual mini theme surface preview
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: previewBgColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: previewBorderColor, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(icon, color: previewTextColor, size: 24),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: isSelected
                                ? colors.primary
                                : colors.onSurface,
                          ),
                        ),
                        if (mode == AppThemeMode.oled) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: colors.inverseSurface,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'OLED',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: colors.onInverseSurface,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.onSurfaceVariant,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (isSelected)
                Icon(
                  Icons.check_circle_rounded,
                  color: colors.primary,
                  size: 22,
                )
              else
                Icon(
                  Icons.radio_button_unchecked_rounded,
                  color: colors.onSurfaceVariant.withValues(alpha: 0.5),
                  size: 22,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
