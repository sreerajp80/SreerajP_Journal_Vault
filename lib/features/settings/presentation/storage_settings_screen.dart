import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/core/database/database_providers.dart';
import 'package:sreerajp_journal_vault/features/attachments/providers/attachment_providers.dart';
import 'package:sreerajp_journal_vault/features/attachments/services/attachment_crypto_storage.dart';
import 'package:sreerajp_journal_vault/features/backup/presentation/backup_health_screen.dart';
import 'package:sreerajp_journal_vault/features/export/presentation/export_screen.dart';
import 'package:sreerajp_journal_vault/features/export/presentation/open_encrypted_export_screen.dart';
import 'package:sreerajp_journal_vault/features/import/presentation/import_screen.dart';
import 'package:sreerajp_journal_vault/features/journal_lock/providers/journal_lock_providers.dart';
import 'package:sreerajp_journal_vault/features/sync/presentation/sync_landing_screen.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

part 'migration_progress_dialog.dart';

class StorageSettingsScreen extends StatelessWidget {
  const StorageSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.titleSettingsSectionStorage)),
      body: ListView(
        key: const Key('settings-storage-list'),
        children: const [StorageSection()],
      ),
    );
  }
}

class StorageSection extends ConsumerStatefulWidget {
  const StorageSection({super.key});

  @override
  ConsumerState<StorageSection> createState() => _StorageSectionState();
}

class _StorageSectionState extends ConsumerState<StorageSection> {
  AppSetting? _settings;
  int? _totalBytes;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (!mounted) return;
    final db = ref.read(appDatabaseProvider);
    final settings = await db.appSettingsDao.getSettings();
    final attachments = await db.attachmentsDao.getAllAttachments();
    final total = attachments.fold<int>(0, (sum, a) => sum + a.sizeBytes);
    if (!mounted) return;
    setState(() {
      _settings = settings;
      _totalBytes = total;
    });
  }

  String _locationLabel(AppLocalizations l10n, AppSetting s) {
    final loc = AttachmentStorageLocation.fromSettingsValue(
      s.attachmentStorageLocation,
    );
    if (loc != AttachmentStorageLocation.sdCard) {
      return l10n.labelStorageAppPrivate;
    }
    final label = s.attachmentStorageTreeLabel;
    return label == null
        ? l10n.labelStorageSdCard
        : l10n.labelStorageSdCardNamed(label);
  }

  /// `attachmentMigrationStatus` is a database code, not text for the user.
  String _migrationStatusLabel(AppLocalizations l10n, AppSetting s) {
    switch (s.attachmentMigrationStatus) {
      case 'running':
        return l10n.descStorageMigrationRunning(
          s.attachmentMigrationProcessedCount,
          s.attachmentMigrationTotalCount,
        );
      case 'failed':
        // The stored reason is an internal note written when the move failed.
        // The user gets the same sentence in their own language instead.
        return l10n.descStorageMigrationFailedShort;
      default:
        return l10n.labelStorageMigrationIdle;
    }
  }

  String _formatBytes(AppLocalizations l10n, int bytes) {
    if (bytes < 1024) return l10n.labelStorageBytes(bytes);
    if (bytes < 1024 * 1024) {
      return l10n.labelStorageKilobytes((bytes / 1024).toStringAsFixed(1));
    }
    if (bytes < 1024 * 1024 * 1024) {
      return l10n.labelStorageMegabytes(
        (bytes / (1024 * 1024)).toStringAsFixed(1),
      );
    }
    return l10n.labelStorageGigabytes(
      (bytes / (1024 * 1024 * 1024)).toStringAsFixed(2),
    );
  }

  Future<void> _changeLocation(AttachmentStorageLocation target) async {
    final settings = _settings;
    if (settings == null) return;

    String? treeUri;
    String? treeLabel;
    if (target == AttachmentStorageLocation.sdCard) {
      final picker = ref.read(attachmentStoragePickerProvider);
      final selection = await picker.pickStorageTree();
      if (selection == null) return;
      treeUri = selection.treeUri;
      treeLabel = selection.displayName;
    }

    if (!mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final l10n = AppLocalizations.of(dialogContext);
        return AlertDialog(
          title: Text(l10n.bodyStorageMigrate),
          content: Text(
            l10n.bodyStorageMigrateBody(
              target == AttachmentStorageLocation.sdCard
                  ? l10n.labelStorageSdCard
                  : l10n.labelStorageAppPrivate,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(l10n.actionCommonCancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(l10n.actionStorageMigrate),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !mounted) return;

    await _runMigration(target: target, treeUri: treeUri, treeLabel: treeLabel);
  }

  Future<void> _runMigration({
    required AttachmentStorageLocation target,
    String? treeUri,
    String? treeLabel,
  }) async {
    final controller = MigrationProgressController();

    final dialogFuture = showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => MigrationProgressDialog(controller: controller),
    );

    final service = ref.read(attachmentStorageMigrationServiceProvider);
    String? errorMessage;
    var cancelled = false;
    try {
      await service.migrateTo(
        targetLocation: target,
        targetTreeUri: treeUri,
        targetTreeLabel: treeLabel,
        onProgress: controller.update,
        isCancelled: () => controller.cancelRequested,
      );
    } catch (e) {
      cancelled = controller.cancelRequested;
      if (!cancelled) errorMessage = e.toString();
    }

    controller.complete();
    await dialogFuture;

    await _load();

    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    if (cancelled) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.bodyStorageMigrationCancelled)),
      );
    } else if (errorMessage != null) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.errorStorageMigrationFailed)),
      );
    } else {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.bodyStorageMigrationComplete)),
      );
    }
  }

  Future<void> _retryMigration() async {
    final settings = _settings;
    if (settings == null) return;
    final target = AttachmentStorageLocation.fromSettingsValue(
      settings.attachmentMigrationTarget ?? settings.attachmentStorageLocation,
    );
    await _runMigration(
      target: target,
      treeUri: settings.attachmentStorageTreeUri,
      treeLabel: settings.attachmentStorageTreeLabel,
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = _settings;
    if (settings == null) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    final canRetry = settings.attachmentMigrationStatus == 'failed';
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        ListTile(
          key: const Key('settings-attachment-storage-location'),
          title: Text(l10n.titleStorageLocation),
          subtitle: Text(_locationLabel(l10n, settings)),
          trailing: const Icon(Icons.chevron_right),
          onTap: () async {
            final selection = await showDialog<AttachmentStorageLocation>(
              context: context,
              builder: (dialogContext) {
                final l10n = AppLocalizations.of(dialogContext);
                return SimpleDialog(
                  title: Text(l10n.titleStorageLocationDialogTitle),
                  children: [
                    SimpleDialogOption(
                      key: const Key('storage-location-app-private'),
                      onPressed: () => Navigator.pop(
                        dialogContext,
                        AttachmentStorageLocation.appPrivate,
                      ),
                      child: Text(l10n.labelStorageAppPrivate),
                    ),
                    SimpleDialogOption(
                      key: const Key('storage-location-sd-card'),
                      onPressed: () => Navigator.pop(
                        dialogContext,
                        AttachmentStorageLocation.sdCard,
                      ),
                      child: Text(l10n.labelStorageSdCard),
                    ),
                  ],
                );
              },
            );
            if (selection != null) await _changeLocation(selection);
          },
        ),
        ListTile(
          key: const Key('settings-migrate-storage'),
          title: Text(l10n.labelStorageMigrateRow),
          subtitle: Text(_migrationStatusLabel(l10n, settings)),
          trailing: canRetry
              ? TextButton(
                  key: const Key('settings-migrate-storage-retry'),
                  onPressed: _retryMigration,
                  child: Text(l10n.errorCommonRetry),
                )
              : null,
        ),
        ListTile(
          key: const Key('settings-storage-usage'),
          title: Text(l10n.labelStorageUsage),
          subtitle: Text(
            _totalBytes == null
                ? l10n.bodyStorageUnknown
                : _formatBytes(l10n, _totalBytes!),
          ),
        ),
        ListTile(
          key: const Key('settings-backup-health'),
          title: Text(l10n.labelStorageBackupHealth),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute<void>(builder: (_) => const BackupHealthScreen()),
          ),
        ),
        ListTile(
          key: const Key('settings-import-data'),
          title: Text(l10n.labelStorageImportData),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _pickImportTarget(context, ref),
        ),
        ListTile(
          key: const Key('settings-export-data'),
          title: Text(AppLocalizations.of(context).labelExportData),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _pickExportTarget(context, ref),
        ),
        ListTile(
          key: const Key('settings-open-encrypted-export'),
          title: Text(l10n.actionSettingsOpenEncryptedExport),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (_) => const OpenEncryptedExportScreen(),
            ),
          ),
        ),
        ListTile(
          key: const Key('settings-device-sync'),
          title: Text(l10n.titleSyncLanding),
          subtitle: Text(l10n.descSyncLanding),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute<void>(builder: (_) => const SyncLandingScreen()),
          ),
        ),
      ],
    );
  }

  Future<void> _pickImportTarget(BuildContext context, WidgetRef ref) async {
    final db = ref.read(appDatabaseProvider);
    final journals = await db.journalsDao.getAllJournals();
    if (!context.mounted) return;
    if (journals.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).bodyStorageImportNeedsJournal,
          ),
        ),
      );
      return;
    }

    final selected = await showDialog<Journal>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: Text(
          AppLocalizations.of(dialogContext).titleStorageImportChooseJournal,
        ),
        children: [
          for (final j in journals)
            SimpleDialogOption(
              key: Key('import-target-journal-${j.id}'),
              onPressed: () => Navigator.pop(dialogContext, j),
              child: Text(j.title),
            ),
        ],
      ),
    );
    if (selected == null || !context.mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) =>
            ImportScreen(journalId: selected.id, journalTitle: selected.title),
      ),
    );
  }

  /// Asks which journal to export from, then opens the export screen.
  ///
  /// **Locked journals are not offered here.** The journal detail screen is
  /// where a lock is opened; a journal the user has not unlocked this session
  /// must not be exportable from a settings menu that never asked for the
  /// password. If every journal is locked, the user is told to open one first
  /// rather than being shown an empty list.
  Future<void> _pickExportTarget(BuildContext context, WidgetRef ref) async {
    final db = ref.read(appDatabaseProvider);
    final journals = await db.journalsDao.getAllJournals();
    if (!context.mounted) return;

    if (journals.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).bodyExportNoJournals),
        ),
      );
      return;
    }

    final unlockedIds = ref.read(unlockedJournalIdsProvider);
    final available = journals
        .where((j) => !j.isLocked || unlockedIds.contains(j.id))
        .toList();

    if (available.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).bodyExportAllLocked),
        ),
      );
      return;
    }

    final selected = await showDialog<Journal>(
      context: context,
      builder: (_) => SimpleDialog(
        title: Text(AppLocalizations.of(context).titleExportChooseJournal),
        children: [
          for (final j in available)
            SimpleDialogOption(
              key: Key('export-target-journal-${j.id}'),
              onPressed: () => Navigator.pop(context, j),
              child: Text(j.title),
            ),
        ],
      ),
    );
    if (selected == null || !context.mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) =>
            ExportScreen(journalId: selected.id, journalTitle: selected.title),
      ),
    );
  }
}
