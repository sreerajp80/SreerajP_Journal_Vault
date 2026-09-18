import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/features/security/providers/security_providers.dart';
import 'package:sreerajp_journal_vault/features/security/services/security_event_service.dart';
import 'package:sreerajp_journal_vault/features/security/presentation/security_event_text.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

/// Screen presenting vault tamper detection status, on-demand integrity
/// verification, educational information, and past tamper alert events.
class TamperAlertsScreen extends ConsumerStatefulWidget {
  const TamperAlertsScreen({super.key});

  @override
  ConsumerState<TamperAlertsScreen> createState() => _TamperAlertsScreenState();
}

class _TamperAlertsScreenState extends ConsumerState<TamperAlertsScreen> {
  VaultIntegrityReport? _lastReport;
  bool _isScanning = false;

  Future<void> _runScan() async {
    setState(() => _isScanning = true);
    try {
      final service = ref.read(securityEventServiceProvider);
      final report = await service.runVaultIntegrityCheck();
      if (!mounted) return;
      setState(() {
        _lastReport = report;
        _isScanning = false;
      });

      final l10n = AppLocalizations.of(context);
      final message = report.isClean
          ? l10n.bodyTamperAlertsScanCompleteClean
          : l10n.bodyTamperAlertsScanCompleteIssues(report.tamperIssues);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: report.isClean ? Colors.green : Colors.red,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isScanning = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).errorCommon(e.toString())),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final tamperEventsAsync = ref.watch(tamperEventsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.titleTamperAlerts)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Status banner card
          _VaultStatusCard(
            report: _lastReport,
            isScanning: _isScanning,
            onVerify: _runScan,
          ),
          const SizedBox(height: 16),

          // Educational info card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n.titleTamperAlertsHowItWorks,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.bodyTamperAlertsHowItWorks,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Tamper alert history section
          Text(
            l10n.titleTamperAlertsHistory,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          tamperEventsAsync.when(
            data: (events) {
              if (events.isEmpty) {
                return Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.verified_user_outlined,
                          size: 48,
                          color: Colors.green,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          l10n.bodyTamperAlertsNoHistory,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return Column(
                children: events
                    .map((event) => _TamperEventTile(event: event))
                    .toList(),
              );
            },
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (e, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(l10n.errorCommon(e.toString())),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VaultStatusCard extends StatelessWidget {
  const _VaultStatusCard({
    required this.report,
    required this.isScanning,
    required this.onVerify,
  });

  final VaultIntegrityReport? report;
  final bool isScanning;
  final VoidCallback onVerify;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final hasIssues = report != null && !report!.isClean;

    final statusColor = hasIssues ? Colors.red : Colors.green;
    final statusIcon = hasIssues ? Icons.gpp_bad_outlined : Icons.verified_user;
    final statusTitle = hasIssues
        ? l10n.bodyTamperAlertsStatusIssues
        : l10n.bodyTamperAlertsStatusVerified;
    final statusDetail = hasIssues
        ? l10n.bodyTamperAlertsStatusIssuesDetail(report!.tamperIssues)
        : l10n.descTamperAlertsStatusVerifiedDetail;

    return Card(
      key: const Key('tamper-alerts-status-card'),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(statusIcon, color: statusColor, size: 36),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        statusTitle,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(statusDetail, style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
            if (report != null) ...[
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${report!.scannedEntries} entries (${report!.scannedJournals} journals)',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    _formatTime(report!.checkedAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                key: const Key('tamper-alerts-verify-button'),
                onPressed: isScanning ? null : onVerify,
                icon: isScanning
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.security, size: 18),
                label: Text(
                  isScanning
                      ? l10n.bodyTamperAlertsVerifying
                      : l10n.actionTamperAlertsVerify,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
  }
}

class _TamperEventTile extends StatelessWidget {
  const _TamperEventTile({required this.event});

  final SecurityEvent event;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.error_outline, color: Colors.red),
        title: Text(
          event.descriptionIn(AppLocalizations.of(context)),
          style: theme.textTheme.bodyMedium,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // What the check actually found — which row, and how it did not
            // match. This is diagnostic detail recorded when the event
            // happened, not a phrase that can be translated after the fact.
            Text(event.description, style: theme.textTheme.bodySmall),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    event.severity.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _formatDateTime(event.createdAt),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: event.metadata != null
            ? IconButton(
                icon: const Icon(Icons.info_outline, size: 20),
                tooltip: AppLocalizations.of(context).tooltipShowDetails,
                onPressed: () => _showMetadataDialog(context),
              )
            : null,
      ),
    );
  }

  void _showMetadataDialog(BuildContext context) {
    String formatted;
    try {
      final decoded = jsonDecode(event.metadata!);
      formatted = const JsonEncoder.withIndent('  ').convert(decoded);
    } catch (_) {
      formatted = event.metadata!;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).titleSecurityEventDetails),
        content: SingleChildScrollView(
          child: SelectableText(
            formatted,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context).actionCommonClose),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
