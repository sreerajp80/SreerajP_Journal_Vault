import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sreerajp_journal_vault/core/theme/typography_controller.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

/// Screen allowing customization of journal body typography (font family and font size).
class TypographySettingsScreen extends ConsumerWidget {
  const TypographySettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final typography = ref.watch(typographyProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appearanceTypographyTitle),
        actions: [
          IconButton(
            key: const Key('typography-reset-button'),
            icon: const Icon(Icons.restart_alt_outlined),
            tooltip: l10n.appearanceResetDefault,
            onPressed: () async {
              await ref.read(typographyProvider.notifier).resetToDefault();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.appearanceTypographyReset),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          // ─── Live Preview Card ──────────────────────────────────────────
          _LivePreviewCard(typography: typography),
          const SizedBox(height: 24),

          // ─── Font Family Selection ──────────────────────────────────────
          Text(
            l10n.appearanceFontFamily.toUpperCase(),
            style: theme.textTheme.labelLarge?.copyWith(
              color: colors.primary,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 12),
          _FontFamilyTile(
            key: const Key('typography-font-sans'),
            family: EntryFontFamily.sans,
            title: l10n.appearanceFontFamilySans,
            subtitle: l10n.appearanceFontFamilySansDesc,
            sampleGlyph: 'Aa',
            glyphFontFamily: null,
            isSelected: typography.fontFamily == EntryFontFamily.sans,
            onTap: () => ref
                .read(typographyProvider.notifier)
                .updateFontFamily(EntryFontFamily.sans),
          ),
          const SizedBox(height: 8),
          _FontFamilyTile(
            key: const Key('typography-font-serif'),
            family: EntryFontFamily.serif,
            title: l10n.appearanceFontFamilySerif,
            subtitle: l10n.appearanceFontFamilySerifDesc,
            sampleGlyph: 'Aa',
            glyphFontFamily: 'serif',
            isSelected: typography.fontFamily == EntryFontFamily.serif,
            onTap: () => ref
                .read(typographyProvider.notifier)
                .updateFontFamily(EntryFontFamily.serif),
          ),
          const SizedBox(height: 8),
          _FontFamilyTile(
            key: const Key('typography-font-monospace'),
            family: EntryFontFamily.monospace,
            title: l10n.appearanceFontFamilyMonospace,
            subtitle: l10n.appearanceFontFamilyMonospaceDesc,
            sampleGlyph: 'Aa',
            glyphFontFamily: 'monospace',
            isSelected: typography.fontFamily == EntryFontFamily.monospace,
            onTap: () => ref
                .read(typographyProvider.notifier)
                .updateFontFamily(EntryFontFamily.monospace),
          ),
          const SizedBox(height: 24),

          // ─── Font Size Section ──────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.appearanceFontSize.toUpperCase(),
                style: theme.textTheme.labelLarge?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${typography.fontSize.round()} pt',
                  style: TextStyle(
                    color: colors.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Card(
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        'A',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      Expanded(
                        child: Slider(
                          key: const Key('typography-size-slider'),
                          value: typography.fontSize,
                          min: TypographySettings.minFontSize,
                          max: TypographySettings.maxFontSize,
                          divisions: 12,
                          label: '${typography.fontSize.round()} pt',
                          onChanged: (val) => ref
                              .read(typographyProvider.notifier)
                              .updateFontSize(val),
                        ),
                      ),
                      Text(
                        'A',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Preset buttons
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _PresetChip(
                          key: const Key('typography-preset-small'),
                          label: l10n.appearanceFontSizeSmall,
                          size: TypographySettings.presetSmall,
                          currentSize: typography.fontSize,
                          onTap: (s) => ref
                              .read(typographyProvider.notifier)
                              .updateFontSize(s),
                        ),
                        const SizedBox(width: 8),
                        _PresetChip(
                          key: const Key('typography-preset-default'),
                          label: l10n.appearanceFontSizeDefault,
                          size: TypographySettings.presetDefault,
                          currentSize: typography.fontSize,
                          onTap: (s) => ref
                              .read(typographyProvider.notifier)
                              .updateFontSize(s),
                        ),
                        const SizedBox(width: 8),
                        _PresetChip(
                          key: const Key('typography-preset-medium'),
                          label: l10n.appearanceFontSizeMedium,
                          size: TypographySettings.presetMedium,
                          currentSize: typography.fontSize,
                          onTap: (s) => ref
                              .read(typographyProvider.notifier)
                              .updateFontSize(s),
                        ),
                        const SizedBox(width: 8),
                        _PresetChip(
                          key: const Key('typography-preset-large'),
                          label: l10n.appearanceFontSizeLarge,
                          size: TypographySettings.presetLarge,
                          currentSize: typography.fontSize,
                          onTap: (s) => ref
                              .read(typographyProvider.notifier)
                              .updateFontSize(s),
                        ),
                        const SizedBox(width: 8),
                        _PresetChip(
                          key: const Key('typography-preset-xlarge'),
                          label: l10n.appearanceFontSizeExtraLarge,
                          size: TypographySettings.presetExtraLarge,
                          currentSize: typography.fontSize,
                          onTap: (s) => ref
                              .read(typographyProvider.notifier)
                              .updateFontSize(s),
                        ),
                      ],
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
}

class _LivePreviewCard extends StatelessWidget {
  const _LivePreviewCard({required this.typography});

  final TypographySettings typography;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    final familyLabel = switch (typography.fontFamily) {
      EntryFontFamily.sans => l10n.appearanceFontFamilySans,
      EntryFontFamily.serif => l10n.appearanceFontFamilySerif,
      EntryFontFamily.monospace => l10n.appearanceFontFamilyMonospace,
    };

    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: colors.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.menu_book_rounded,
                      size: 18,
                      color: colors.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.appearanceLivePreview.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: colors.primary,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$familyLabel • ${typography.fontSize.round()}pt',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Text(
              l10n.appearanceSampleHeadline,
              style: TextStyle(
                fontFamily: typography.fontFamily.fontName,
                fontSize: (typography.fontSize * 1.3).clamp(16.0, 30.0),
                fontWeight: FontWeight.bold,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.appearanceSampleBody,
              style: typography.toTextStyle(
                color: colors.onSurface.withValues(alpha: 0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FontFamilyTile extends StatelessWidget {
  const _FontFamilyTile({
    super.key,
    required this.family,
    required this.title,
    required this.subtitle,
    required this.sampleGlyph,
    required this.glyphFontFamily,
    required this.isSelected,
    required this.onTap,
  });

  final EntryFontFamily family;
  final String title;
  final String subtitle;
  final String sampleGlyph;
  final String? glyphFontFamily;
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
          ? colors.primaryContainer.withValues(alpha: 0.3)
          : colors.surface,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isSelected
                      ? colors.primary
                      : colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    sampleGlyph,
                    style: TextStyle(
                      fontFamily: glyphFontFamily,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? colors.onPrimary : colors.onSurface,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: glyphFontFamily,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? colors.primary : colors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(Icons.check_circle_rounded, color: colors.primary),
            ],
          ),
        ),
      ),
    );
  }
}

class _PresetChip extends StatelessWidget {
  const _PresetChip({
    super.key,
    required this.label,
    required this.size,
    required this.currentSize,
    required this.onTap,
  });

  final String label;
  final double size;
  final double currentSize;
  final ValueChanged<double> onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isSelected = (currentSize - size).abs() < 0.5;

    return ChoiceChip(
      label: Text('$label (${size.round()})'),
      selected: isSelected,
      onSelected: (_) => onTap(size),
      selectedColor: colors.primaryContainer,
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        color: isSelected ? colors.onPrimaryContainer : colors.onSurface,
      ),
    );
  }
}
