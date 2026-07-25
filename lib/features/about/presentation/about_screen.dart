import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sreerajp_journal_vault/features/about/application/about_metadata.dart';

/// Displays app metadata: name, version, build timestamp, and attribution.
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
            const SizedBox(height: 16),
            _InfoRow(label: 'Author', value: metadata.author),
            _InfoRow(label: 'AI Used', value: metadata.aiUsed),
            _InfoRow(label: 'IDE Used', value: metadata.ideUsed),
            _InfoRow(label: 'App Version / Build', value: metadata.versionBuild),
            _InfoRow(label: 'Last Build Timestamp', value: metadata.lastBuildTimestamp),
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
