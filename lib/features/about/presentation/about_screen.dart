import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sreerajp_journal_vault/features/about/application/about_metadata.dart';

/// Displays app metadata: name, description, version, build timestamp, and the
/// attribution rows from `assets/config/app_config.json`.
///
/// Per guideline.md section 1.6 this screen MUST NOT hard-code row names such
/// as `Author` or `Email`. Every attribution row comes from the config's
/// `details` map, rendered in file order.
class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metadataAsync = ref.watch(aboutMetadataProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: metadataAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Unable to load app metadata'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => ref.invalidate(aboutMetadataProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (metadata) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              metadata.appName,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            if (metadata.description.trim().isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                metadata.description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
            const SizedBox(height: 16),
            // Every row below comes from the config. Skip blank keys or values.
            for (final entry in metadata.details.entries)
              if (entry.key.trim().isNotEmpty && entry.value.trim().isNotEmpty)
                _InfoRow(label: entry.key, value: entry.value),
            // Runtime values, not config: these stay explicit.
            _InfoRow(label: 'App Version / Build', value: metadata.versionBuild),
            _InfoRow(
              label: 'Last Build Timestamp',
              value: metadata.lastBuildTimestamp,
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelSmall),
          Text(value),
        ],
      ),
    );
  }
}
