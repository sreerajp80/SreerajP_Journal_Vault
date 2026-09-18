import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sreerajp_journal_vault/features/backup/domain/backup_format.dart';
import 'package:sreerajp_journal_vault/features/backup/domain/restore_models.dart';
import 'package:sreerajp_journal_vault/features/backup/providers/backup_providers.dart';
import 'package:sreerajp_journal_vault/features/backup/services/backup_service.dart';
import 'package:sreerajp_journal_vault/features/lock_gate/providers/lock_gate_providers.dart';
import 'package:sreerajp_journal_vault/features/lock_gate/services/biometric_authenticator.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

part 'restore_backup_steps.dart';

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
  /// Lets the extensions in this library's part files rebuild the
  /// widget: `setState` is protected, so they cannot call it directly.
  void _rebuild(VoidCallback fn) => setState(fn);

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
      appBar: AppBar(title: Text(l10n.titleRestore)),
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
            Text(l10n.titleRestoreLocked, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              l10n.bodyRestoreLocked,
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
                  labelText: l10n.labelRestoreEnterPin,
                  border: const OutlineInputBorder(),
                ),
                onSubmitted: (_) => _verifyPin(),
              ),
              const SizedBox(height: 12),
              FilledButton(
                key: const Key('restore-pin-submit'),
                onPressed: _checkingLock ? null : _verifyPin,
                child: Text(l10n.actionRestoreUnlock),
              ),
            ] else
              FilledButton.icon(
                key: const Key('restore-unlock'),
                onPressed: _checkingLock ? null : _startUnlock,
                icon: const Icon(Icons.lock_open),
                label: Text(l10n.actionRestoreUnlock),
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

  // ─────────────────────────── the flow ───────────────────────────

  Widget _buildRestoreFlow(AppLocalizations l10n) {
    final theme = Theme.of(context);
    final backups = ref.watch(availableBackupFilesProvider);

    // The backup file list has no upper bound, so it is built lazily; the
    // fixed controls around it stay in plain slivers.
    Widget box(Widget child) => SliverToBoxAdapter(child: child);

    final Widget backupList = backups.when(
      data: (files) => files.isEmpty
          ? box(
              Text(
                l10n.bodyRestoreNoBackupsFound,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            )
          : SliverList.builder(
              itemCount: files.length,
              itemBuilder: (context, index) =>
                  _buildBackupTile(l10n, files[index]),
            ),
      loading: () => box(const LinearProgressIndicator()),
      error: (e, _) => box(Text(l10n.errorCommon(e.toString()))),
    );

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          sliver: SliverList.list(
            children: [
              Text(l10n.titleRestorePick, style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
            ],
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: backupList,
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          sliver: SliverList.list(
            children: [
              const SizedBox(height: 8),
              OutlinedButton.icon(
                key: const Key('restore-pick-file'),
                onPressed: _busy ? null : _pickFile,
                icon: const Icon(Icons.folder_open),
                label: Text(l10n.actionRestorePickFromDevice),
              ),
              if (_selectedFileName != null) ...[
                const SizedBox(height: 8),
                Text(
                  l10n.labelRestoreSelectedFile(_selectedFileName!),
                  style: theme.textTheme.bodyMedium,
                ),
              ],

              const Divider(height: 32),

              TextField(
                key: const Key('restore-password-field'),
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: l10n.labelRestorePassword,
                  helperText: l10n.bodyRestorePasswordHelper,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                key: const Key('restore-open-backup'),
                onPressed: _busy || _selectedPath == null ? null : _openBackup,
                icon: const Icon(Icons.lock_open),
                label: Text(l10n.actionRestoreOpenBackup),
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
                    Text(l10n.bodyRestoreWorking),
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
                  label: Text(l10n.actionRestoreDryRun),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.bodyRestoreDryRunHelper,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  key: const Key('restore-run'),
                  onPressed: _busy ? null : _confirmAndRestore,
                  icon: const Icon(Icons.restore),
                  label: Text(l10n.actionRestore),
                ),
              ],
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
}
