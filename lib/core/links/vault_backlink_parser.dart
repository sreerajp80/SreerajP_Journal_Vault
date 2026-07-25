import 'package:sreerajp_journal_vault/core/links/vault_backlinks.dart';

/// Extracts vault-internal backlink references from plain entry text.
///
/// Recognized link shapes: `[[journal:42]]`, `[[entry:7]]`. The numeric ID
/// must be a non-negative integer. Duplicates are deduplicated so each
/// `(type, id)` pair appears at most once in the returned list.
class VaultBacklinkParser {
  static final RegExp _pattern =
      RegExp(r'\[\[(journal|entry):(\d+)\]\]');

  static List<VaultBacklinkTarget> parse(String? text) {
    if (text == null || text.isEmpty) return const [];
    final seen = <String>{};
    final out = <VaultBacklinkTarget>[];
    for (final match in _pattern.allMatches(text)) {
      final type = match.group(1) == 'journal'
          ? VaultBacklinkTargetType.journal
          : VaultBacklinkTargetType.entry;
      final id = int.tryParse(match.group(2)!);
      if (id == null) continue;
      final key = '${type.name}:$id';
      if (seen.add(key)) {
        out.add(VaultBacklinkTarget(type: type, targetId: id));
      }
    }
    return out;
  }
}
