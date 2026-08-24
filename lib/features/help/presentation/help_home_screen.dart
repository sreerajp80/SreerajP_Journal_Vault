import 'package:flutter/material.dart';

import 'package:sreerajp_journal_vault/features/help/presentation/attachments_ocr_help_screen.dart';
import 'package:sreerajp_journal_vault/features/help/presentation/backup_restore_help_screen.dart';
import 'package:sreerajp_journal_vault/features/help/presentation/biometrics_pin_help_screen.dart';
import 'package:sreerajp_journal_vault/features/help/presentation/encryption_security_help_screen.dart';
import 'package:sreerajp_journal_vault/features/help/presentation/export_formats_help_screen.dart';
import 'package:sreerajp_journal_vault/features/help/presentation/faq_troubleshooting_help_screen.dart';
import 'package:sreerajp_journal_vault/features/help/presentation/insights_help_screen.dart';
import 'package:sreerajp_journal_vault/features/help/presentation/journal_locks_help_screen.dart';
import 'package:sreerajp_journal_vault/features/help/presentation/journal_organization_help_screen.dart';
import 'package:sreerajp_journal_vault/features/help/presentation/screenshot_audit_help_screen.dart';
import 'package:sreerajp_journal_vault/features/help/presentation/search_timeline_help_screen.dart';
import 'package:sreerajp_journal_vault/features/help/presentation/storage_migration_help_screen.dart';
import 'package:sreerajp_journal_vault/features/help/presentation/tags_help_screen.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

/// Help Center hub reached from Settings → Help.
class HelpHomeScreen extends StatelessWidget {
  const HelpHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.helpTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          _buildHeaderCard(context, l10n),
          const SizedBox(height: 24),

          _buildSectionHeader(
            context,
            l10n.helpSectionWriting,
            Icons.edit_note_outlined,
          ),
          const SizedBox(height: 10),
          _HelpTopicCard(
            icon: Icons.menu_book_outlined,
            title: l10n.helpTopicJournalOrg,
            subtitle: l10n.helpTopicJournalOrgSubtitle,
            onTap: () => _push(context, const JournalOrganizationHelpScreen()),
          ),
          const SizedBox(height: 10),
          _HelpTopicCard(
            icon: Icons.document_scanner_outlined,
            title: l10n.helpTopicAttachmentsOcr,
            subtitle: l10n.helpTopicAttachmentsOcrSubtitle,
            onTap: () => _push(context, const AttachmentsOcrHelpScreen()),
          ),
          const SizedBox(height: 10),
          _HelpTopicCard(
            icon: Icons.sell_outlined,
            title: l10n.helpTopicTags,
            subtitle: l10n.helpTopicTagsSubtitle,
            onTap: () => _push(context, const TagsHelpScreen()),
          ),
          const SizedBox(height: 24),

          _buildSectionHeader(
            context,
            l10n.helpSectionSecurity,
            Icons.shield_outlined,
          ),
          const SizedBox(height: 10),
          _HelpTopicCard(
            icon: Icons.lock_outline,
            title: l10n.helpTopicEncryption,
            subtitle: l10n.helpTopicEncryptionSubtitle,
            onTap: () => _push(context, const EncryptionSecurityHelpScreen()),
          ),
          const SizedBox(height: 10),
          _HelpTopicCard(
            icon: Icons.fingerprint,
            title: l10n.helpTopicBiometrics,
            subtitle: l10n.helpTopicBiometricsSubtitle,
            onTap: () => _push(context, const BiometricsPinHelpScreen()),
          ),
          const SizedBox(height: 10),
          _HelpTopicCard(
            icon: Icons.password_rounded,
            title: l10n.helpTopicJournalLocks,
            subtitle: l10n.helpTopicJournalLocksSubtitle,
            onTap: () => _push(context, const JournalLocksHelpScreen()),
          ),
          const SizedBox(height: 10),
          _HelpTopicCard(
            icon: Icons.screenshot_outlined,
            title: l10n.helpTopicScreenshotAudit,
            subtitle: l10n.helpTopicScreenshotAuditSubtitle,
            onTap: () => _push(context, const ScreenshotAuditHelpScreen()),
          ),
          const SizedBox(height: 24),

          _buildSectionHeader(
            context,
            l10n.helpSectionSearch,
            Icons.insights_outlined,
          ),
          const SizedBox(height: 10),
          _HelpTopicCard(
            icon: Icons.search_rounded,
            title: l10n.helpTopicSearchTimeline,
            subtitle: l10n.helpTopicSearchTimelineSubtitle,
            onTap: () => _push(context, const SearchTimelineHelpScreen()),
          ),
          const SizedBox(height: 10),
          _HelpTopicCard(
            icon: Icons.auto_graph_rounded,
            title: l10n.helpTopicInsights,
            subtitle: l10n.helpTopicInsightsSubtitle,
            onTap: () => _push(context, const InsightsHelpScreen()),
          ),
          const SizedBox(height: 24),

          _buildSectionHeader(
            context,
            l10n.helpSectionStorage,
            Icons.inventory_2_outlined,
          ),
          const SizedBox(height: 10),
          _HelpTopicCard(
            icon: Icons.sd_card_outlined,
            title: l10n.helpTopicStorageMigration,
            subtitle: l10n.helpTopicStorageMigrationSubtitle,
            onTap: () => _push(context, const StorageMigrationHelpScreen()),
          ),
          const SizedBox(height: 10),
          _HelpTopicCard(
            icon: Icons.backup_outlined,
            title: l10n.helpTopicBackupRestore,
            subtitle: l10n.helpTopicBackupRestoreSubtitle,
            onTap: () => _push(context, const BackupRestoreHelpScreen()),
          ),
          const SizedBox(height: 10),
          _HelpTopicCard(
            icon: Icons.picture_as_pdf_outlined,
            title: l10n.helpTopicExportFormats,
            subtitle: l10n.helpTopicExportFormatsSubtitle,
            onTap: () => _push(context, const ExportFormatsHelpScreen()),
          ),
          const SizedBox(height: 24),

          _buildSectionHeader(
            context,
            l10n.helpSectionFaq,
            Icons.question_answer_outlined,
          ),
          const SizedBox(height: 10),
          _HelpTopicCard(
            icon: Icons.help_outline,
            title: l10n.helpTopicFaq,
            subtitle: l10n.helpTopicFaqSubtitle,
            onTap: () => _push(context, const FaqTroubleshootingHelpScreen()),
          ),
        ],
      ),
    );
  }

  void _push(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
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
                Icons.help_center_rounded,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.helpHeaderTitle,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.helpHeaderSubtitle,
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

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            title.toUpperCase(),
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _HelpTopicCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _HelpTopicCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

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
                child: Icon(icon, color: accent, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 13,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
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
