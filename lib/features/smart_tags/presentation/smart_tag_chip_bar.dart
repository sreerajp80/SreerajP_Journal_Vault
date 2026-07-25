import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sreerajp_journal_vault/core/database/database_providers.dart';
import 'package:sreerajp_journal_vault/features/smart_tags/providers/smart_tag_providers.dart';
import 'package:sreerajp_journal_vault/features/smart_tags/services/smart_tag_service.dart';

/// A horizontal chip bar that shows smart tag suggestions for an entry.
///
/// Tapping a suggestion adds it to the entry (non-destructive — user confirms).
/// Existing tags on the entry are shown as filled chips; suggestions as outlined.
class SmartTagChipBar extends ConsumerWidget {
  const SmartTagChipBar({
    super.key,
    required this.entryId,
    required this.plainText,
  });

  final int entryId;
  final String? plainText;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suggestionsAsync = ref.watch(
      smartTagSuggestionsProvider(
        (entryId: entryId, plainText: plainText),
      ),
    );

    return suggestionsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (suggestions) {
        if (suggestions.isEmpty) return const SizedBox.shrink();
        return SizedBox(
          height: 48,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: suggestions.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final suggestion = suggestions[index];
              return _SuggestionChip(
                suggestion: suggestion,
                onAccepted: () => _acceptSuggestion(ref, suggestion),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _acceptSuggestion(WidgetRef ref, TagSuggestion suggestion) async {
    final db = ref.read(appDatabaseProvider);
    await db.tagsDao.addTagToEntry(entryId, suggestion.tag.id);
    // Invalidate suggestions so the accepted tag disappears.
    ref.invalidate(
      smartTagSuggestionsProvider(
        (entryId: entryId, plainText: plainText),
      ),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  const _SuggestionChip({
    required this.suggestion,
    required this.onAccepted,
  });

  final TagSuggestion suggestion;
  final VoidCallback onAccepted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ActionChip(
      label: Text(suggestion.tag.name),
      avatar: Icon(
        Icons.add,
        size: 16,
        color: theme.colorScheme.primary,
      ),
      onPressed: onAccepted,
    );
  }
}
