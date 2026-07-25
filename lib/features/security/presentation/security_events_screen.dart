import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/features/security/providers/security_providers.dart';

/// Displays a chronological log of security events with severity indicators.
///
/// Users can view all events, filter by severity, and see detailed metadata.
class SecurityEventsScreen extends ConsumerWidget {
  const SecurityEventsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(recentSecurityEventsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Security Events'),
      ),
      body: eventsAsync.when(
        data: (events) {
          if (events.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.shield_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No security events recorded',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: events.length,
            itemBuilder: (context, index) =>
                _SecurityEventTile(event: events[index]),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _SecurityEventTile extends StatelessWidget {
  const _SecurityEventTile({required this.event});

  final SecurityEvent event;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: _severityIcon(event.severity),
        title: Text(
          event.description,
          style: theme.textTheme.bodyMedium,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                _severityChip(event.severity, theme),
                const SizedBox(width: 8),
                Text(
                  event.eventType.replaceAll('_', ' '),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              _formatDateTime(event.createdAt),
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey,
              ),
            ),
          ],
        ),
        trailing: event.metadata != null
            ? IconButton(
                icon: const Icon(Icons.info_outline, size: 20),
                onPressed: () => _showMetadataDialog(context),
              )
            : null,
      ),
    );
  }

  Widget _severityIcon(String severity) {
    switch (severity) {
      case 'critical':
        return const Icon(Icons.error, color: Colors.red);
      case 'warning':
        return const Icon(Icons.warning_amber, color: Colors.orange);
      default:
        return const Icon(Icons.info_outline, color: Colors.blue);
    }
  }

  Widget _severityChip(String severity, ThemeData theme) {
    final Color color;
    switch (severity) {
      case 'critical':
        color = Colors.red;
        break;
      case 'warning':
        color = Colors.orange;
        break;
      default:
        color = Colors.blue;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        severity.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
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
        title: const Text('Event Details'),
        content: SingleChildScrollView(
          child: SelectableText(
            formatted,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
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
