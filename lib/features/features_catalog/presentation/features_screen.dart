import 'package:flutter/material.dart';

import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

class _AppFeature {
  final String title;
  final String description;
  final IconData icon;
  final List<String> highlights;

  const _AppFeature({
    required this.title,
    required this.description,
    required this.icon,
    required this.highlights,
  });
}

class _FeatureCategory {
  final String name;
  final String subtitle;
  final IconData icon;
  final List<_AppFeature> features;

  const _FeatureCategory({
    required this.name,
    required this.subtitle,
    required this.icon,
    required this.features,
  });
}

/// Lists all features of SreerajP Journal Vault, grouped by category with visual cards.
class FeaturesScreen extends StatelessWidget {
  const FeaturesScreen({super.key});

  List<_FeatureCategory> _getCategories(AppLocalizations l10n) => [
    _FeatureCategory(
      name: l10n.featuresCategoryJournaling,
      subtitle: l10n.featuresCategoryJournalingSubtitle,
      icon: Icons.edit_note_outlined,
      features: [
        _AppFeature(
          title: l10n.featureQuillTitle,
          description: l10n.featureQuillDesc,
          icon: Icons.format_paint_outlined,
          highlights: const [
            'Rich Typography',
            'Header Styles',
            'Lists & Quotes',
            'Smooth Scrolling',
          ],
        ),
        _AppFeature(
          title: l10n.featureTemplatesTitle,
          description: l10n.featureTemplatesDesc,
          icon: Icons.dashboard_customize_outlined,
          highlights: const [
            '8 Starter Templates',
            'Reflection Prompts',
            'One-Tap Selection',
          ],
        ),
        _AppFeature(
          title: l10n.featureMediaOcrTitle,
          description: l10n.featureMediaOcrDesc,
          icon: Icons.document_scanner_outlined,
          highlights: const [
            'Offline OCR Scanner',
            'AES-256 Encrypted',
            'Images & Audio',
          ],
        ),
        _AppFeature(
          title: l10n.featureTagsTitle,
          description: l10n.featureTagsDesc,
          icon: Icons.sell_outlined,
          highlights: const [
            'Custom Tag Colors',
            'Tag Manager',
            'Cross-Journal Filters',
          ],
        ),
        _AppFeature(
          title: l10n.featureMultiJournalTitle,
          description: l10n.featureMultiJournalDesc,
          icon: Icons.menu_book_outlined,
          highlights: const [
            'Multi-Journal Support',
            'Custom Descriptions',
            'Per-Journal Tagging',
          ],
        ),
        _AppFeature(
          title: l10n.featureRitualTitle,
          description: l10n.featureRitualDesc,
          icon: Icons.self_improvement_rounded,
          highlights: const [
            'Centering Breath Timer',
            '18 Reflection Cards',
            'Spaced Repetition (SRS)',
            'Direct Editor Launch',
          ],
        ),
      ],
    ),
    _FeatureCategory(
      name: l10n.featuresCategorySecurity,
      subtitle: l10n.featuresCategorySecuritySubtitle,
      icon: Icons.shield_outlined,
      features: [
        _AppFeature(
          title: l10n.featureSqlcipherTitle,
          description: l10n.featureSqlcipherDesc,
          icon: Icons.lock_outline,
          highlights: const [
            'SQLCipher Engine',
            'AES-256-GCM',
            'Hardware Keystore Keys',
          ],
        ),
        _AppFeature(
          title: l10n.featureBiometricsTitle,
          description: l10n.featureBiometricsDesc,
          icon: Icons.fingerprint,
          highlights: const [
            'Fingerprint & Face Unlock',
            'App PIN Fallback',
            'Instant Auto-Lock',
          ],
        ),
        _AppFeature(
          title: l10n.featureJournalLockTitle,
          description: l10n.featureJournalLockDesc,
          icon: Icons.password_rounded,
          highlights: const [
            'PBKDF2 Derivation',
            'Per-Journal Passwords',
            'Session Unlock',
          ],
        ),
        _AppFeature(
          title: l10n.featureAttachmentLockTitle,
          description: l10n.featureAttachmentLockDesc,
          icon: Icons.file_present_outlined,
          highlights: const [
            'Individual File Lock',
            'Isolated Decryption',
            'Attachment Privacy',
          ],
        ),
        _AppFeature(
          title: l10n.featureScreenshotGuardTitle,
          description: l10n.featureScreenshotGuardDesc,
          icon: Icons.screenshot_outlined,
          highlights: const [
            'FLAG_SECURE Defense',
            'Task Switcher Masking',
            'Togglable in Settings',
          ],
        ),
        _AppFeature(
          title: l10n.featureTamperAuditTitle,
          description: l10n.featureTamperAuditDesc,
          icon: Icons.history_edu_outlined,
          highlights: const [
            'Audit Trail Log',
            'Failed PIN Tracking',
            'Local Device Only',
          ],
        ),
        _AppFeature(
          title: l10n.featureAutoLockTitle,
          description: l10n.featureAutoLockDesc,
          icon: Icons.timer_outlined,
          highlights: const [
            '4 Inactivity Profiles',
            'Background Protection',
            'Instant Lock Option',
          ],
        ),
        _AppFeature(
          title: l10n.featureOfflineTitle,
          description: l10n.featureOfflineDesc,
          icon: Icons.wifi_off_outlined,
          highlights: const [
            'Zero Permissions',
            'No Internet Access',
            'No Analytics',
          ],
        ),
      ],
    ),
    _FeatureCategory(
      name: l10n.featuresCategoryDiscovery,
      subtitle: l10n.featuresCategoryDiscoverySubtitle,
      icon: Icons.insights_outlined,
      features: [
        _AppFeature(
          title: l10n.featureFtsSearchTitle,
          description: l10n.featureFtsSearchDesc,
          icon: Icons.search_rounded,
          highlights: const [
            'SQLite FTS5 Indexing',
            'Sub-Millisecond Speed',
            'Tag & Body Matching',
          ],
        ),
        _AppFeature(
          title: l10n.featureSearchPresetsTitle,
          description: l10n.featureSearchPresetsDesc,
          icon: Icons.bookmark_border_rounded,
          highlights: const [
            'Saved Filters',
            'One-Tap Chips',
            'Custom Preset Names',
          ],
        ),
        _AppFeature(
          title: l10n.featureTimelineTitle,
          description: l10n.featureTimelineDesc,
          icon: Icons.calendar_month_outlined,
          highlights: const [
            'Visual Activity Dots',
            'Day-by-Day View',
            'Direct Date Jumping',
          ],
        ),
        _AppFeature(
          title: l10n.featureInsightsTitle,
          description: l10n.featureInsightsDesc,
          icon: Icons.auto_graph_rounded,
          highlights: const [
            'Habit Streak Tracking',
            'Word Count Graphs',
            'Active Days Heatmap',
          ],
        ),
      ],
    ),
    _FeatureCategory(
      name: l10n.featuresCategoryStorage,
      subtitle: l10n.featuresCategoryStorageSubtitle,
      icon: Icons.inventory_2_outlined,
      features: [
        _AppFeature(
          title: l10n.featureStorageMigrationTitle,
          description: l10n.featureStorageMigrationDesc,
          icon: Icons.sd_card_outlined,
          highlights: const [
            'Live SD Card Migration',
            'Zero-Downtime Move',
            'AES-256 Retained',
          ],
        ),
        _AppFeature(
          title: l10n.featureEncryptedBackupsTitle,
          description: l10n.featureEncryptedBackupsDesc,
          icon: Icons.backup_outlined,
          highlights: const [
            'Password-Sealed .jvbk',
            'Full Vault Archive',
            'Backup Health Monitor',
          ],
        ),
        _AppFeature(
          title: l10n.featureMultiExportTitle,
          description: l10n.featureMultiExportDesc,
          icon: Icons.picture_as_pdf_outlined,
          highlights: const [
            'Formatted PDF Export',
            'Markdown ZIP Archives',
            'Raw JSON Dump',
          ],
        ),
        _AppFeature(
          title: l10n.featureEncryptedReaderTitle,
          description: l10n.featureEncryptedReaderDesc,
          icon: Icons.lock_open_outlined,
          highlights: const [
            'In-App Reader Tool',
            'Password Verification',
            'Standalone Access',
          ],
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final categories = _getCategories(l10n);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.featuresTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          _buildHeaderCard(context, l10n),
          const SizedBox(height: 24),
          for (var c = 0; c < categories.length; c++) ...[
            if (c > 0) const SizedBox(height: 24),
            _buildCategoryHeader(context, categories[c]),
            const SizedBox(height: 10),
            _buildCategoryCard(context, categories[c]),
          ],
        ],
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;

    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              accent.withValues(alpha: 0.12),
              theme.colorScheme.secondary.withValues(alpha: 0.04),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: Colors.white,
                size: 30,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.featuresHeaderTitle,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.featuresHeaderSubtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryHeader(BuildContext context, _FeatureCategory category) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(category.icon, size: 18, color: accent),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.name.toUpperCase(),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  category.subtitle,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${category.features.length}',
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, _FeatureCategory category) {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: category.features.length,
        separatorBuilder: (_, _) => Divider(
          height: 1,
          thickness: 0.8,
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
        itemBuilder: (context, i) =>
            _FeatureTile(feature: category.features[i]),
      ),
    );
  }
}

class _FeatureTile extends StatefulWidget {
  final _AppFeature feature;
  const _FeatureTile({required this.feature});

  @override
  State<_FeatureTile> createState() => _FeatureTileState();
}

class _FeatureTileState extends State<_FeatureTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;
    final f = widget.feature;

    return InkWell(
      onTap: () => setState(() => _expanded = !_expanded),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(f.icon, size: 22, color: accent),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        f.title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        f.description,
                        maxLines: _expanded ? null : 2,
                        overflow: _expanded
                            ? TextOverflow.visible
                            : TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    size: 20,
                    color: theme.colorScheme.onSurfaceVariant.withValues(
                      alpha: 0.6,
                    ),
                  ),
                ),
              ],
            ),
            if (_expanded && f.highlights.isNotEmpty) ...[
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.only(left: 54),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: f.highlights
                      .map(
                        (h) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: accent.withValues(alpha: 0.2),
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            h,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: accent,
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
