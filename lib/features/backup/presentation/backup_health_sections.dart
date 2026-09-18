part of 'backup_health_screen.dart';

extension _BackupHealthScreenStatePart1 on _BackupHealthScreenState {
  Widget _buildHealthStatusCard(
    ThemeData theme,
    AsyncValue<BackupLog?> latestSuccess,
    AsyncValue<int> failureCount,
  ) {
    final l10n = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildHealthIndicator(latestSuccess, failureCount),
                const SizedBox(width: 12),
                Text(
                  l10n.titleBackupStatus,
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            latestSuccess.when(
              data: (log) {
                if (log == null) {
                  return Text(
                    l10n.bodyBackupNoneYet,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow(
                      l10n.labelBackupLastBackup,
                      _formatDateTime(log.completedAt ?? log.startedAt),
                    ),
                    _buildInfoRow(l10n.labelBackupEntries, '${log.entryCount}'),
                    _buildInfoRow(
                      l10n.labelBackupAttachments,
                      '${log.attachmentCount}',
                    ),
                    if (log.sizeBytes != null)
                      _buildInfoRow(
                        l10n.labelBackupSize,
                        _formatBytes(l10n, log.sizeBytes!),
                      ),
                  ],
                );
              },
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text(l10n.errorCommon(e.toString())),
            ),
            const SizedBox(height: 8),
            failureCount.when(
              data: (count) {
                if (count == 0) return const SizedBox.shrink();
                return Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_amber,
                        color: theme.colorScheme.onErrorContainer,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n.errorBackupRecentFailures(count),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onErrorContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthIndicator(
    AsyncValue<BackupLog?> latestSuccess,
    AsyncValue<int> failureCount,
  ) {
    return latestSuccess.when(
      data: (log) {
        final failures = failureCount.whenOrNull(data: (v) => v) ?? 0;
        if (log == null) {
          return const Icon(Icons.circle, color: Colors.grey, size: 16);
        }
        if (failures > 0) {
          return const Icon(Icons.circle, color: Colors.orange, size: 16);
        }
        return const Icon(Icons.circle, color: Colors.green, size: 16);
      },
      loading: () => const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
      error: (_, _) => Icon(Icons.circle, color: Colors.red.shade400, size: 16),
    );
  }

  Widget _buildScheduleCard(
    ThemeData theme,
    AsyncValue<BackupScheduleSettings> settings,
  ) {
    final l10n = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.titleBackupSchedule, style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            settings.when(
              data: (s) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        s.isEnabled
                            ? l10n.labelBackupScheduled(
                                _intervalName(l10n, s.interval),
                              )
                            : l10n.bodyBackupNotScheduled,
                      ),
                      if (s.isEnabled)
                        Chip(
                          label: Text(
                            s.isTimerActive
                                ? l10n.labelBackupTimerActive
                                : l10n.labelBackupTimerInactive,
                            style: theme.textTheme.labelSmall,
                          ),
                          backgroundColor: s.isTimerActive
                              ? Colors.green.shade100
                              : Colors.grey.shade200,
                        ),
                    ],
                  ),
                  if (s.lastRun != null)
                    _buildInfoRow(
                      l10n.labelBackupLastScheduledRun,
                      _formatDateTime(s.lastRun!),
                    ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (s.isEnabled)
                        OutlinedButton(
                          onPressed: _disableSchedule,
                          child: Text(l10n.actionBackupDisable),
                        )
                      else
                        OutlinedButton.icon(
                          onPressed: () =>
                              _rebuild(() => _isConfiguring = true),
                          icon: const Icon(Icons.schedule, size: 18),
                          label: Text(l10n.actionBackupConfigure),
                        ),
                      if (s.isEnabled) ...[
                        const SizedBox(width: 8),
                        OutlinedButton(
                          onPressed: () =>
                              _rebuild(() => _isConfiguring = true),
                          child: Text(l10n.actionBackupChange),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text(l10n.errorCommon(e.toString())),
            ),
            if (_isConfiguring) ...[
              const Divider(height: 24),
              _buildScheduleConfig(theme),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleConfig(ThemeData theme) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.titleBackupConfigure, style: theme.textTheme.titleSmall),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: _selectedInterval,
          decoration: InputDecoration(
            labelText: l10n.labelBackupInterval,
            border: const OutlineInputBorder(),
          ),
          items: [
            DropdownMenuItem(
              value: 'daily',
              child: Text(l10n.labelBackupIntervalDaily),
            ),
            DropdownMenuItem(
              value: 'weekly',
              child: Text(l10n.labelBackupIntervalWeekly),
            ),
            DropdownMenuItem(
              value: 'monthly',
              child: Text(l10n.labelBackupIntervalMonthly),
            ),
          ],
          onChanged: (v) {
            if (v != null) _rebuild(() => _selectedInterval = v);
          },
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: l10n.labelBackupPassword,
            border: const OutlineInputBorder(),
            helperText: l10n.labelBackupPasswordHelper,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            FilledButton(
              onPressed: _saveSchedule,
              child: Text(l10n.actionCommonSave),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: () => _rebuild(() => _isConfiguring = false),
              child: Text(l10n.actionCommonCancel),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBackupHistory(
    ThemeData theme,
    AsyncValue<List<BackupLog>> recentLogs,
  ) {
    final l10n = AppLocalizations.of(context);
    return recentLogs.when(
      data: (logs) {
        if (logs.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Center(
              child: Text(
                l10n.emptyBackupNoHistory,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          );
        }
        return Column(
          children: logs.map((log) => _buildLogTile(theme, log)).toList(),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Text(l10n.errorBackupHistoryLoad(e.toString())),
    );
  }

  Widget _buildLogTile(ThemeData theme, BackupLog log) {
    final l10n = AppLocalizations.of(context);
    final isSuccess = log.status == 'success';
    final isFailed = log.status == 'failed';
    final isInProgress = log.status == 'in_progress';

    IconData icon;
    Color iconColor;
    if (isSuccess) {
      icon = Icons.check_circle;
      iconColor = Colors.green;
    } else if (isFailed) {
      icon = Icons.error;
      iconColor = theme.colorScheme.error;
    } else {
      icon = Icons.hourglass_top;
      iconColor = Colors.orange;
    }

    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(
        l10n.titleBackupLog(
          _triggerName(l10n, log.trigger),
          _statusName(l10n, log.status),
        ),
        style: theme.textTheme.bodyMedium,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_formatDateTime(log.startedAt)),
          if (isSuccess && log.sizeBytes != null)
            Text(
              l10n.descBackupLogCounts(
                log.entryCount,
                log.attachmentCount,
                _formatBytes(l10n, log.sizeBytes!),
              ),
            ),
          if (isFailed && log.errorMessage != null)
            Text(
              log.errorMessage!,
              style: TextStyle(color: theme.colorScheme.error),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          if (isInProgress) Text(l10n.bodyBackupInProgressNote),
        ],
      ),
      isThreeLine: true,
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value),
        ],
      ),
    );
  }

  Future<void> _triggerManualBackup() async {
    final scheduler = ref.read(backupSchedulerProvider);
    final settings = await scheduler.getSettings();

    if (!settings.hasPassword) {
      if (!mounted) return;
      _showPasswordDialog();
      return;
    }

    _rebuild(() => _isBackingUp = true);
    try {
      await scheduler.triggerManualBackup();
      _refreshAll();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).labelBackupSucceeded),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).errorBackup(e.toString()),
            ),
          ),
        );
      }
    } finally {
      if (mounted) _rebuild(() => _isBackingUp = false);
    }
  }
}
