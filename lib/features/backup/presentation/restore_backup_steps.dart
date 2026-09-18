part of 'restore_backup_screen.dart';

extension _RestoreBackupScreenStatePart1 on _RestoreBackupScreenState {
  /// PIN first, then the device credential. If the device has neither there is
  /// nothing to check against, so the screen simply opens.
  Future<void> _startUnlock() async {
    if (_checkingLock || _unlocked) return;
    _rebuild(() {
      _checkingLock = true;
      _lockError = null;
    });

    // Read every string before the first await: the context must not be used
    // once an async gap has opened.
    final l10n = AppLocalizations.of(context);

    try {
      final pinService = ref.read(appPinServiceProvider);
      if (await pinService.hasPin()) {
        _rebuild(() => _needsPin = true);
        return;
      }

      final auth = ref.read(biometricAuthenticatorProvider);
      if (!await auth.canAuthenticate()) {
        _rebuild(() => _unlocked = true);
        return;
      }

      final result = await auth.authenticate(
        reason: l10n.labelRestoreUnlockReason,
      );
      if (result == BiometricAuthResult.success ||
          result == BiometricAuthResult.unavailable) {
        _rebuild(() => _unlocked = true);
      } else {
        _rebuild(() => _lockError = l10n.errorRestoreUnlock);
      }
    } finally {
      if (mounted) _rebuild(() => _checkingLock = false);
    }
  }

  Future<void> _verifyPin() async {
    _rebuild(() {
      _checkingLock = true;
      _lockError = null;
    });
    final wrongPinMessage = AppLocalizations.of(context).bodyRestorePinWrong;
    final ok = await ref
        .read(appPinServiceProvider)
        .verifyPin(_pinController.text);
    if (!mounted) return;
    _rebuild(() {
      _checkingLock = false;
      _unlocked = ok;
      _lockError = ok ? null : wrongPinMessage;
    });
    _pinController.clear();
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
              : () => _rebuild(() {
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
            Text(l10n.titleRestorePreview, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            if (createdAt != null)
              Text(l10n.labelRestorePreviewCreated(_formatDateTime(createdAt))),
            Text(
              l10n.bodyRestorePreviewCounts(
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
                  l10n.bodyRestoreLegacyAttachments,
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
        Text(l10n.bodyRestoreMode, style: theme.textTheme.titleMedium),
        RadioGroup<RestoreMode>(
          groupValue: _mode,
          // RadioGroup takes a non-null callback, so "disabled while working"
          // is a guard inside it rather than a null.
          onChanged: (value) {
            if (_busy || value == null) return;
            _rebuild(() => _mode = value);
          },
          child: Column(
            children: [
              RadioListTile<RestoreMode>(
                key: const Key('restore-mode-merge'),
                value: RestoreMode.merge,
                title: Text(l10n.actionRestoreModeMerge),
                subtitle: Text(l10n.descRestoreModeMergeDetail),
              ),
              RadioListTile<RestoreMode>(
                key: const Key('restore-mode-replace'),
                value: RestoreMode.replace,
                title: Text(l10n.actionRestoreModeReplace),
                subtitle: Text(l10n.descRestoreModeReplaceDetail),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _openBackup() async {
    final path = _selectedPath;
    if (path == null) return;

    _rebuild(() {
      _busy = true;
      _error = null;
      _preview = null;
    });

    try {
      final preview = await ref
          .read(backupRestoreServiceProvider)
          .inspect(backupPath: path, password: _passwordController.text);
      if (!mounted) return;
      _rebuild(() => _preview = preview);
    } catch (e) {
      if (!mounted) return;
      _rebuild(() => _error = _messageFor(e));
    } finally {
      if (mounted) _rebuild(() => _busy = false);
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
              ? l10n.bodyRestoreConfirmReplace
              : l10n.bodyRestoreConfirmMerge,
        ),
        content: Text(
          isReplace
              ? l10n.bodyRestoreConfirmReplaceBody
              : l10n.bodyRestoreConfirmMergeBody,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.actionCommonCancel),
          ),
          FilledButton(
            key: const Key('restore-confirm'),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.actionRestore),
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

    _rebuild(() {
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
      _rebuild(() => _error = _messageFor(e));
    } finally {
      if (mounted) _rebuild(() => _busy = false);
    }
  }

  Future<void> _showResult(RestoreResult result) async {
    final l10n = AppLocalizations.of(context);
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          result.wasDryRun
              ? l10n.titleRestoreDryRunResult
              : l10n.titleRestoreResult,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.labelRestoreResultAdded(result.totalAdded)),
            Text(l10n.labelRestoreResultSkipped(result.totalSkipped)),
            Text(l10n.descRestoreResultFiles(result.attachmentFilesRestored)),
            if (result.attachmentFilesFailed > 0)
              Text(l10n.errorRestoreResultFiles(result.attachmentFilesFailed)),
            if (result.safetyBackupPath != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(l10n.descRestoreResultSafetyBackup),
              ),
            if (result.warnings.contains(
              RestoreWarning.legacyAttachmentsNotPortable,
            ))
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(l10n.bodyRestoreLegacyAttachments),
              ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.actionCommonClose),
          ),
        ],
      ),
    );
  }

  /// Turns a service exception into something the user can act on.
  String _messageFor(Object error) {
    final l10n = AppLocalizations.of(context);
    if (error is BackupPasswordException) {
      return l10n.errorRestoreErrorPassword;
    }
    if (error is BackupVersionTooNewException) {
      return l10n.bodyRestoreErrorTooNew;
    }
    if (error is BackupCorruptedException) {
      return error.isWrongPassword
          ? l10n.bodyRestoreErrorWrongPassword
          : l10n.bodyRestoreErrorDamaged;
    }
    return l10n.errorRestoreError(error.toString());
  }

  String _formatDateTime(DateTime dt) =>
      '${dt.year}-${_pad(dt.month)}-${_pad(dt.day)} '
      '${_pad(dt.hour)}:${_pad(dt.minute)}';

  String _pad(int n) => n.toString().padLeft(2, '0');

  String _formatBytes(AppLocalizations l10n, int bytes) {
    if (bytes < 1024) return l10n.labelBackupBytes(bytes);
    if (bytes < 1024 * 1024) {
      return l10n.labelBackupKilobytes((bytes / 1024).toStringAsFixed(1));
    }
    return l10n.labelBackupMegabytes(
      (bytes / (1024 * 1024)).toStringAsFixed(1),
    );
  }
}
