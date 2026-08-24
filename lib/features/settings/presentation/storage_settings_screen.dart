import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/core/database/database_providers.dart';
import 'package:sreerajp_journal_vault/features/attachments/providers/attachment_providers.dart';
import 'package:sreerajp_journal_vault/features/attachments/services/attachment_crypto_storage.dart';
import 'package:sreerajp_journal_vault/features/backup/presentation/backup_health_screen.dart';
import 'package:sreerajp_journal_vault/features/export/export_strings.dart';
import 'package:sreerajp_journal_vault/features/export/presentation/export_screen.dart';
import 'package:sreerajp_journal_vault/features/export/presentation/open_encrypted_export_screen.dart';
import 'package:sreerajp_journal_vault/features/import/presentation/import_screen.dart';
import 'package:sreerajp_journal_vault/features/journal_lock/providers/journal_lock_providers.dart';
import 'package:sreerajp_journal_vault/features/sync/presentation/sync_landing_screen.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

class StorageSettingsScreen extends StatelessWidget {
  const StorageSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsSectionStorage)),
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
    if (loc != AttachmentStorageLocation.sdCard) return l10n.storageAppPrivate;
    final label = s.attachmentStorageTreeLabel;
    return label == null ? l10n.storageSdCard : l10n.storageSdCardNamed(label);
  }

  /// `attachmentMigrationStatus` is a database code, not text for the user.
  String _migrationStatusLabel(AppLocalizations l10n, AppSetting s) {
    switch (s.attachmentMigrationStatus) {
      case 'running':
        return l10n.storageMigrationRunning(
          s.attachmentMigrationProcessedCount,
          s.attachmentMigrationTotalCount,
        );
      case 'failed':
        return s.attachmentMigrationFailure ?? l10n.storageMigrationFailedShort;
      default:
        return l10n.storageMigrationIdle;
    }
  }

  String _formatBytes(AppLocalizations l10n, int bytes) {
    if (bytes < 1024) return l10n.storageBytes(bytes);
    if (bytes < 1024 * 1024) {
      return l10n.storageKilobytes((bytes / 1024).toStringAsFixed(1));
    }
    if (bytes < 1024 * 1024 * 1024) {
      return l10n.storageMegabytes((bytes / (1024 * 1024)).toStringAsFixed(1));
    }
    return l10n.storageGigabytes(
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
          title: Text(l10n.storageMigrateTitle),
          content: Text(
            l10n.storageMigrateBody(
              target == AttachmentStorageLocation.sdCard
                  ? l10n.storageSdCard
                  : l10n.storageAppPrivate,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(l10n.commonCancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(l10n.storageMigrateAction),
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
        SnackBar(content: Text(l10n.storageMigrationCancelled)),
      );
    } else if (errorMessage != null) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.storageMigrationFailed(errorMessage))),
      );
    } else {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.storageMigrationComplete)),
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
          title: Text(l10n.storageLocationTitle),
          subtitle: Text(_locationLabel(l10n, settings)),
          trailing: const Icon(Icons.chevron_right),
          onTap: () async {
            final selection = await showDialog<AttachmentStorageLocation>(
              context: context,
              builder: (dialogContext) {
                final l10n = AppLocalizations.of(dialogContext);
                return SimpleDialog(
                  title: Text(l10n.storageLocationDialogTitle),
                  children: [
                    SimpleDialogOption(
                      key: const Key('storage-location-app-private'),
                      onPressed: () => Navigator.pop(
                        dialogContext,
                        AttachmentStorageLocation.appPrivate,
                      ),
                      child: Text(l10n.storageAppPrivate),
                    ),
                    SimpleDialogOption(
                      key: const Key('storage-location-sd-card'),
                      onPressed: () => Navigator.pop(
                        dialogContext,
                        AttachmentStorageLocation.sdCard,
                      ),
                      child: Text(l10n.storageSdCard),
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
          title: Text(l10n.storageMigrateRow),
          subtitle: Text(_migrationStatusLabel(l10n, settings)),
          trailing: canRetry
              ? TextButton(
                  key: const Key('settings-migrate-storage-retry'),
                  onPressed: _retryMigration,
                  child: Text(l10n.commonRetry),
                )
              : null,
        ),
        ListTile(
          key: const Key('settings-storage-usage'),
          title: Text(l10n.storageUsage),
          subtitle: Text(
            _totalBytes == null
                ? l10n.storageUnknown
                : _formatBytes(l10n, _totalBytes!),
          ),
        ),
        ListTile(
          key: const Key('settings-backup-health'),
          title: Text(l10n.storageBackupHealth),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute<void>(builder: (_) => const BackupHealthScreen()),
          ),
        ),
        ListTile(
          key: const Key('settings-import-data'),
          title: Text(l10n.storageImportData),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _pickImportTarget(context, ref),
        ),
        ListTile(
          key: const Key('settings-export-data'),
          title: const Text(ExportStrings.exportDataTile),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _pickExportTarget(context, ref),
        ),
        ListTile(
          key: const Key('settings-open-encrypted-export'),
          title: Text(l10n.settingsOpenEncryptedExport),
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
          title: Text(l10n.syncLandingTitle),
          subtitle: Text(l10n.syncLandingSubtitle),
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
          content: Text(AppLocalizations.of(context).storageImportNeedsJournal),
        ),
      );
      return;
    }

    final selected = await showDialog<Journal>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: Text(
          AppLocalizations.of(dialogContext).storageImportChooseJournal,
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
        const SnackBar(content: Text(ExportStrings.noJournalsToExport)),
      );
      return;
    }

    final unlockedIds = ref.read(unlockedJournalIdsProvider);
    final available = journals
        .where((j) => !j.isLocked || unlockedIds.contains(j.id))
        .toList();

    if (available.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(ExportStrings.allJournalsLocked)),
      );
      return;
    }

    final selected = await showDialog<Journal>(
      context: context,
      builder: (_) => SimpleDialog(
        title: const Text(ExportStrings.chooseJournalToExport),
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

class MigrationProgressController extends ChangeNotifier {
  int _processed = 0;
  int _total = 0;
  bool _cancelRequested = false;
  bool _completed = false;

  int get processed => _processed;
  int get total => _total;
  bool get cancelRequested => _cancelRequested;
  bool get completed => _completed;

  void update(int processed, int total) {
    _processed = processed;
    _total = total;
    notifyListeners();
  }

  void cancel() {
    if (_cancelRequested) return;
    _cancelRequested = true;
    notifyListeners();
  }

  void complete() {
    if (_completed) return;
    _completed = true;
    notifyListeners();
  }
}

class MigrationProgressDialog extends StatefulWidget {
  const MigrationProgressDialog({super.key, required this.controller});

  final MigrationProgressController controller;

  @override
  State<MigrationProgressDialog> createState() =>
      _MigrationProgressDialogState();
}

class _MigrationProgressDialogState extends State<MigrationProgressDialog> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleChange);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleChange);
    super.dispose();
  }

  void _handleChange() {
    if (!mounted) return;
    if (widget.controller.completed) {
      Navigator.of(context).pop();
    } else {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = widget.controller;
    final progress = c.total == 0 ? null : c.processed / c.total;
    return AlertDialog(
      title: Text(l10n.migrationDialogTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LinearProgressIndicator(value: progress),
          const SizedBox(height: 12),
          Text(
            c.cancelRequested
                ? l10n.migrationCancelling
                : l10n.migrationProgress(
                    '${c.processed}',
                    c.total == 0 ? l10n.migrationUnknownTotal : '${c.total}',
                  ),
          ),
        ],
      ),
      actions: [
        TextButton(
          key: const Key('migration-cancel-button'),
          onPressed: c.cancelRequested ? null : c.cancel,
          child: Text(l10n.commonCancel),
        ),
      ],
    );
  }
}
