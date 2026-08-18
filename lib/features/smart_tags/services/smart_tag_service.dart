import 'package:sreerajp_journal_vault/core/database/app_database.dart';

/// Suggests existing tags for an entry based on its plain-text content.
///
/// The algorithm tokenises the entry text, normalises each token, then scores
/// existing tags by how often they appear in the text. Only tags that actually
/// occur in the content are returned, ordered by frequency (descending).
///
/// Suggestions are **non-destructive** — the caller decides whether to apply
/// them; the service never writes to the database on its own.
class SmartTagService {
  SmartTagService(this._db);

  final AppDatabase _db;

  /// Returns up to [limit] existing tag suggestions for the given [plainText].
  ///
  /// Each suggestion is a [Tag] that was found as a substring in the entry
  /// content. Multi-word tags are matched as full phrases.
  Future<List<TagSuggestion>> suggest(
    String? plainText, {
    int limit = 10,
  }) async {
    if (plainText == null || plainText.trim().isEmpty) return [];

    final allTags = await _db.tagsDao.getAllTags();
    if (allTags.isEmpty) return [];

    final normalisedText = _normalise(plainText);

    final scored = <TagSuggestion>[];
    for (final tag in allTags) {
      final normalisedTag = _normalise(tag.name);
      if (normalisedTag.isEmpty) continue;

      final count = _countOccurrences(normalisedText, normalisedTag);
      if (count > 0) {
        scored.add(TagSuggestion(tag: tag, score: count));
      }
    }

    scored.sort((a, b) => b.score.compareTo(a.score));
    return scored.take(limit).toList();
  }

  /// Returns suggestions for tags the entry does *not* already have.
  Future<List<TagSuggestion>> suggestNew(
    int entryId,
    String? plainText, {
    int limit = 10,
  }) async {
    final all = await suggest(plainText, limit: limit + 20);
    if (all.isEmpty) return [];

    final existing = await _db.tagsDao.getTagsForEntry(entryId);
    final existingIds = existing.map((t) => t.id).toSet();

    return all
        .where((s) => !existingIds.contains(s.tag.id))
        .take(limit)
        .toList();
  }

  static String _normalise(String input) =>
      input.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), ' ').trim();

  static int _countOccurrences(String text, String pattern) {
    if (pattern.isEmpty) return 0;
    var count = 0;
    var index = 0;
    while (true) {
      index = text.indexOf(pattern, index);
      if (index == -1) break;
      count++;
      index += pattern.length;
    }
    return count;
  }
}

/// A tag suggestion with a relevance score (higher = more relevant).
class TagSuggestion {
  final Tag tag;
  final int score;

  const TagSuggestion({required this.tag, required this.score});
}
