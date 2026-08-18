import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sreerajp_journal_vault/core/database/database_providers.dart';
import 'package:sreerajp_journal_vault/features/smart_tags/services/smart_tag_service.dart';

final smartTagServiceProvider = Provider<SmartTagService>((ref) {
  return SmartTagService(ref.read(appDatabaseProvider));
});

/// Provides tag suggestions for a specific entry's plain text.
///
/// The family parameter is a record of (entryId, plainText).
final smartTagSuggestionsProvider =
    FutureProvider.family<
      List<TagSuggestion>,
      ({int entryId, String? plainText})
    >((ref, params) {
      final service = ref.read(smartTagServiceProvider);
      return service.suggestNew(params.entryId, params.plainText);
    });
