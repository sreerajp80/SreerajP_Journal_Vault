import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sreerajp_journal_vault/features/backup/domain/backup_format.dart';
import 'package:sreerajp_journal_vault/features/backup/domain/restore_models.dart';
import 'package:sreerajp_journal_vault/features/backup/providers/backup_providers.dart';
import 'package:sreerajp_journal_vault/features/backup/services/backup_service.dart';
import 'package:sreerajp_journal_vault/features/lock_gate/providers/lock_gate_providers.dart';
import 'package:sreerajp_journal_vault/features/lock_gate/services/biometric_authenticator.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

/// Reads a backup archive back into the app.
///
/// The screen walks one way down the page: unlock, choose a file, enter its
/// password, look at what is inside, pick replace or merge, and only then
/// restore. A dry run sits next to the restore button so the user can see
/// what would happen before anything changes.
///
/// The unlock step exists because restoring rewrites the journal, so it is
/// protected the same way opening the app is.
class RestoreBackupScreen extends ConsumerStatefulWidget {
  const RestoreBackupScreen({super.key});

  @override
  ConsumerState<RestoreBackupScreen> createState() =>
      _RestoreBackupScreenState();
}

class _RestoreBackupScreenState extends ConsumerState<RestoreBackupScreen> {
  final _passwordController = TextEditingController();
  final _pinController = TextEditingController();

  bool _unlocked = false;
  bool _checkingLock = false;
  bool _needsPin = false;
  String? _lockError;

  String? _selectedPath;
  String? _selectedFileName;

  BackupPreview? _preview;
  RestoreMode _mode = RestoreMode.merge;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Ask straight away: the user came here to restore, not to press Unlock.
    WidgetsBinding.instance.addPostFrameCallback((_) => _startUnlock());
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.restoreTitle)),
      body: _unlocked ? _buildRestoreFlow(l10n) : _buildLockGate(l10n),
    );
  }

  // ─────────────────────────── the gate ───────────────────────────

  Widget _buildLockGate(AppLocalizations l10n) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.lock_outline,
              size: 48,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(l10n.restoreLockedTitle, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              l10n.restoreLockedBody,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            if (_needsPin) ...[
              TextField(
                key: const Key('restore-pin-field'),
                controller: _pinController,
                obscureText: true,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: l10n.restoreEnterPin,
                  border: const OutlineInputBorder(),
                ),
                onSubmitted: (_) => _verifyPin(),
              ),
              const SizedBox(height: 12),
              FilledButton(
                key: const Key('restore-pin-submit'),
                onPressed: _checkingLock ? null : _verifyPin,
                child: Text(l10n.restoreUnlockAction),
              ),
            ] else
              FilledButton.icon(
                key: const Key('restore-unlock'),
                onPressed: _checkingLock ? null : _startUnlock,
                icon: const Icon(Icons.lock_open),
                label: Text(l10n.restoreUnlockAction),
              ),
            if (_lockError != null) ...[
              const SizedBox(height: 12),
              Text(
                _lockError!,
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// PIN first, then the device credential. If the device has neither there is
  /// nothing to check against, so the screen simply opens.
  Future<void> _startUnlock() async {
    if (_checkingLock || _unlocked) return;
    setState(() {
      _checkingLock = true;
      _lockError = null;
    });

    // Read every string before the first await: the context must not be used
    // once an async gap has opened.
    final l10n = AppLocalizations.of(context);

    try {
      final pinService = ref.read(appPinServiceProvider);
      if (await pinService.hasPin()) {
        setState(() => _needsPin = true);
        return;
      }

      final auth = ref.read(biometricAuthenticatorProvider);
      if (!await auth.canAuthenticate()) {
        setState(() => _unlocked = true);
        return;
      }

      final result = await auth.authenticate(reason: l10n.restoreUnlockReason);
      if (result == BiometricAuthResult.success ||
          result == BiometricAuthResult.unavailable) {
        setState(() => _unlocked = true);
      } else {
        setState(() => _lockError = l10n.restoreUnlockFailed);
      }
    } finally {
      if (mounted) setState(() => _checkingLock = false);
    }
  }

  Future<void> _verifyPin() async {
    setState(() {
      _checkingLock = true;
      _lockError = null;
    });
    final wrongPinMessage = AppLocalizations.of(context).restorePinWrong;
    final ok = await ref
        .read(appPinServiceProvider)
        .verifyPin(_pinController.text);
    if (!mounted) return;
    setState(() {
      _checkingLock = false;
      _unlocked = ok;
      _lockError = ok ? null : wrongPinMessage;
    });
    _pinController.clear();
  }

  // ─────────────────────────── the flow ───────────────────────────

  Widget _buildRestoreFlow(AppLocalizations l10n) {
    final theme = Theme.of(context);
    final backups = ref.watch(availableBackupFilesProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(l10n.restorePickHeading, style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        backups.when(
          data: (files) => files.isEmpty
              ? Text(
                  l10n.restoreNoBackupsFound,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                )
              : Column(
                  children: [
                    for (final file in files) _buildBackupTile(l10n, file),
                  ],
                ),
          loading: () => const LinearProgressIndicator(),
          error: (e, _) => Text(l10n.commonError(e.toString())),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          key: const Key('restore-pick-file'),
          onPressed: _busy ? null : _pickFile,
          icon: const Icon(Icons.folder_open),
          label: Text(l10n.restorePickFromDevice),
        ),
        if (_selectedFileName != null) ...[
          const SizedBox(height: 8),
          Text(
            l10n.restoreSelectedFile(_selectedFileName!),
            style: theme.textTheme.bodyMedium,
          ),
        ],

        const Divider(height: 32),

        TextField(
          key: const Key('restore-password-field'),
          controller: _passwordController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: l10n.restorePasswordLabel,
            helperText: l10n.restorePasswordHelper,
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          key: const Key('restore-open-backup'),
          onPressed: _busy || _selectedPath == null ? null : _openBackup,
          icon: const Icon(Icons.lock_open),
          label: Text(l10n.restoreOpenBackupAction),
        ),

        if (_error != null) ...[
          const SizedBox(height: 12),
          Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
        ],

        if (_busy) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 12),
              Text(l10n.restoreWorking),
            ],
          ),
        ],

        if (_preview != null) ...[
          const Divider(height: 32),
          _buildPreviewCard(l10n, _preview!),
          const SizedBox(height: 16),
          _buildModePicker(l10n),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            key: const Key('restore-dry-run'),
            onPressed: _busy ? null : () => _runRestore(dryRun: true),
            icon: const Icon(Icons.science_outlined),
            label: Text(l10n.restoreDryRunAction),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.restoreDryRunHelper,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            key: const Key('restore-run'),
            onPressed: _busy ? null : _confirmAndRestore,
            icon: const Icon(Icons.restore),
            label: Text(l10n.restoreAction),
          ),
        ],
      ],
    );
  }

  Widget _buildBackupTile(AppLocalizations l10n, BackupFileInfo file) {
    final selected = _selectedPath == file.path;
    return Semantics(
      selected: selected,
      button: true,
      label: file.fileName,
      child: Card(
        child: ListTile(
          leading: Icon(
            selected
                ? Icons.radio_button_checked
                : Icons.radio_button_unchecked,
          ),
          title: Text(file.fileName),
          subtitle: Text(
            '${_formatDateTime(file.createdAt)} · '
            '${_formatBytes(l10n, file.sizeBytes)}',
          ),
          onTap: _busy
              ? null
              : () => setState(() {
                  _selectedPath = file.path;
                  _selectedFileName = file.fileName;
                  _preview = null;
                  _error = null;
                }),
        ),
      ),
    );
  }

  Widget _buildPreviewCard(AppLocalizations l10n, BackupPreview preview) {
    final theme = Theme.of(context);
    final createdAt = preview.manifest.createdAt;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.restorePreviewHeading,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            if (createdAt != null)
              Text(l10n.restorePreviewCreated(_formatDateTime(createdAt))),
            Text(
              l10n.restorePreviewCounts(
                preview.journalCount,
                preview.entryCount,
                preview.attachmentCount,
              ),
            ),
            Text(_formatBytes(l10n, preview.sizeBytes)),
            if (!preview.hasPortableAttachments) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  l10n.restoreLegacyAttachmentsWarning,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onErrorContainer,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildModePicker(AppLocalizations l10n) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.restoreModeHeading, style: theme.textTheme.titleMedium),
        RadioGroup<RestoreMode>(
          groupValue: _mode,
          // RadioGroup takes a non-null callback, so "disabled while working"
          // is a guard inside it rather than a null.
          onChanged: (value) {
            if (_busy || value == null) return;
            setState(() => _mode = value);
          },
          child: Column(
            children: [
              RadioListTile<RestoreMode>(
                key: const Key('restore-mode-merge'),
                value: RestoreMode.merge,
                title: Text(l10n.restoreModeMerge),
                subtitle: Text(l10n.restoreModeMergeDetail),
              ),
              RadioListTile<RestoreMode>(
                key: const Key('restore-mode-replace'),
                value: RestoreMode.replace,
                title: Text(l10n.restoreModeReplace),
                subtitle: Text(l10n.restoreModeReplaceDetail),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─────────────────────────── actions ───────────────────────────

  Future<void> _pickFile() async {
    final picked = await ref.read(backupFilePickerProvider).pickBackupFile();
    if (picked == null || !mounted) return;
    setState(() {
      _selectedPath = picked.path;
      _selectedFileName = picked.fileName;
      _preview = null;
      _error = null;
    });
  }

  Future<void> _openBackup() async {
    final path = _selectedPath;
    if (path == null) return;

    setState(() {
      _busy = true;
      _error = null;
      _preview = null;
    });

    try {
      final preview = await ref
          .read(backupRestoreServiceProvider)
          .inspect(backupPath: path, password: _passwordController.text);
      if (!mounted) return;
      setState(() => _preview = preview);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = _messageFor(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _confirmAndRestore() async {
    final l10n = AppLocalizations.of(context);
    final isReplace = _mode == RestoreMode.replace;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          isReplace
              ? l10n.restoreConfirmReplaceTitle
              : l10n.restoreConfirmMergeTitle,
        ),
        content: Text(
          isReplace
              ? l10n.restoreConfirmReplaceBody
              : l10n.restoreConfirmMergeBody,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            key: const Key('restore-confirm'),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.restoreAction),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      await _runRestore(dryRun: false);
    }
  }

  Future<void> _runRestore({required bool dryRun}) async {
    final path = _selectedPath;
    if (path == null) return;

    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      final result = await ref
          .read(backupRestoreServiceProvider)
          .restore(
            backupPath: path,
            password: _passwordController.text,
            mode: _mode,
            dryRun: dryRun,
          );
      if (!mounted) return;
      // A finished restore changes the counts the backup screen shows.
      ref.invalidate(availableBackupFilesProvider);
      ref.invalidate(recentBackupLogsProvider);
      ref.invalidate(latestSuccessfulBackupProvider);
      await _showResult(result);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = _messageFor(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _showResult(RestoreResult result) async {
    final l10n = AppLocalizations.of(context);
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          result.wasDryRun
              ? l10n.restoreDryRunResultTitle
              : l10n.restoreResultTitle,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.restoreResultAdded(result.totalAdded)),
            Text(l10n.restoreResultSkipped(result.totalSkipped)),
            Text(l10n.restoreResultFiles(result.attachmentFilesRestored)),
            if (result.attachmentFilesFailed > 0)
              Text(l10n.restoreResultFilesFailed(result.attachmentFilesFailed)),
            if (result.safetyBackupPath != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(l10n.restoreResultSafetyBackup),
              ),
            if (result.warnings.contains(
              RestoreWarning.legacyAttachmentsNotPortable,
            ))
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(l10n.restoreLegacyAttachmentsWarning),
              ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.commonClose),
          ),
        ],
      ),
    );
  }

  /// Turns a service exception into something the user can act on.
  String _messageFor(Object error) {
    final l10n = AppLocalizations.of(context);
    if (error is BackupPasswordException) {
      return l10n.restoreErrorPasswordTooShort;
    }
    if (error is BackupVersionTooNewException) {
      return l10n.restoreErrorTooNew;
    }
    if (error is BackupCorruptedException) {
      return error.isWrongPassword
          ? l10n.restoreErrorWrongPassword
          : l10n.restoreErrorDamaged;
    }
    return l10n.restoreErrorFailed(error.toString());
  }

  String _formatDateTime(DateTime dt) =>
      '${dt.year}-${_pad(dt.month)}-${_pad(dt.day)} '
      '${_pad(dt.hour)}:${_pad(dt.minute)}';

  String _pad(int n) => n.toString().padLeft(2, '0');

  String _formatBytes(AppLocalizations l10n, int bytes) {
    if (bytes < 1024) return l10n.backupBytes(bytes);
    if (bytes < 1024 * 1024) {
      return l10n.backupKilobytes((bytes / 1024).toStringAsFixed(1));
    }
    return l10n.backupMegabytes((bytes / (1024 * 1024)).toStringAsFixed(1));
  }
}
