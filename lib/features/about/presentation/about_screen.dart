import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sreerajp_journal_vault/features/about/application/about_metadata.dart';
import 'package:sreerajp_journal_vault/features/about/presentation/made_with_love.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

/// Displays app metadata: name, description, version, build timestamp, and the
/// attribution rows from `assets/config/app_config.json`.
///
/// Per guideline.md section 1.6 this screen MUST NOT hard-code row names such
/// as `author` or `email`. Every attribution row comes from the config's
/// `details` map, rendered in file order, with its label translated and its
/// value resolved for the active language. Per section 1.7 the screen always
/// ends with the "Made with ❤️ from India" badge.
class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final metadataAsync = ref.watch(aboutMetadataProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.titleAbout)),
      body: metadataAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.errorAboutLoad),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => ref.invalidate(aboutMetadataProvider),
                child: Text(l10n.errorCommonRetry),
              ),
            ],
          ),
        ),
        data: (metadata) {
          final description = metadata.description.resolve(lang);
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            children: [
              Text(
                metadata.appName.resolve(lang),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              if (description.trim().isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
              const SizedBox(height: 16),
              // Every row below comes from the config. Skip blank keys or values.
              for (final entry in metadata.details.entries)
                if (entry.key.trim().isNotEmpty &&
                    entry.value.resolve(lang).trim().isNotEmpty)
                  _InfoRow(
                    label: aboutDetailLabel(l10n, entry.key),
                    value: entry.value.resolve(lang),
                  ),
              // Runtime values, not config: these stay explicit.
              _InfoRow(
                label: l10n.labelAboutVersionBuild,
                value: metadata.versionBuild,
              ),
              _InfoRow(
                label: l10n.labelAboutLastBuild,
                value:
                    metadata.lastBuildTimestamp ??
                    l10n.bodyAboutBuildDateUnavailable,
              ),
              // Fixed signature badge — always the last element (§1.7).
              const SafeArea(top: false, child: MadeWithLove()),
            ],
          );
        },
      ),
    );
  }
}

/// Maps a config detail key to its translated label, falling back to the raw
/// key so a newly added row still renders (guideline.md section 1.6).
String aboutDetailLabel(AppLocalizations l10n, String key) {
  switch (key) {
    case 'author':
      return l10n.aboutDetailAuthor;
    case 'email':
      return l10n.aboutDetailEmail;
    case 'license':
      return l10n.aboutDetailLicense;
    case 'aiUsed':
      return l10n.aboutDetailAiUsed;
    case 'ideUsed':
      return l10n.aboutDetailIdeUsed;
    default:
      return key;
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
