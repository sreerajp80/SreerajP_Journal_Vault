// Layer: service (pure Dart). Knows which synced columns hold row IDs, and
// how to swap row IDs for sync IDs and back. A row's `id` is local to one
// phone; a sync ID is the same on both. No raw row ID may cross between
// phones.

import 'dart:convert';

/// The key that marks a reference in a record sent over sync:
/// `{"$ref": "<sync id>"}` in place of a row ID.
const String syncRefKey = r'$ref';

/// Record key holding the sync IDs of the rows an entry's text points at.
const String syncTextRefsKey = '_textRefs';

/// Record key holding an attachment's file bytes, base64.
const String syncFileKey = '_fileBase64';

/// Columns that point at a row of another table, per synced table.
///
/// `backlinks.target_id` is not listed: its table depends on `target_type`;
/// see [backlinkTargetTable].
const Map<String, Map<String, String>> syncReferenceColumns = {
  'entries': {'journal_id': 'journals'},
  'journal_tags': {'journal_id': 'journals', 'tag_id': 'tags'},
  'entry_tags': {'entry_id': 'entries', 'tag_id': 'tags'},
  'attachments': {'entry_id': 'entries'},
  'backlinks': {'source_entry_id': 'entries'},
  'entry_revisions': {'entry_id': 'entries'},
  'voice_notes': {'entry_id': 'entries'},
};

/// The table a backlink's `target_id` points at, by its `target_type`.
const Map<String, String> backlinkTargetTable = {
  'entry': 'entries',
  'journal': 'journals',
};

/// Tables whose rows hold an encrypted file.
const Set<String> syncFileTables = {'attachments', 'voice_notes'};

/// Columns that describe a file stored on **this** phone. They mean nothing
/// on another phone and are never sent.
const Set<String> syncDeviceFileColumns = {
  'encrypted_path',
  'nonce_base64',
  'key_reference',
};

/// Tables whose text may hold picture embeds and wiki links.
const Set<String> syncTextTables = {'entries', 'entry_revisions'};

/// Embed types whose data carries an `attachmentId`.
const List<String> _embedKeys = ['vault_image', 'drawing'];

final RegExp _wikiLink = RegExp(r'\[\[(journal|entry):(\d+)\]\]');

/// A reference value as sent: `{"$ref": syncId}`, or null when the row has
/// no reference.
Map<String, String>? syncRef(String? syncId) =>
    syncId == null ? null : {syncRefKey: syncId};

/// The sync ID in a sent reference value, or null when [value] is not one.
/// A raw number (the old format) is not a reference.
String? syncIdOfRef(Object? value) {
  if (value is Map && value[syncRefKey] is String) {
    return value[syncRefKey] as String;
  }
  return null;
}

/// The row IDs an entry's text points at, by table: pictures and drawings
/// (`attachments`), and wiki links (`entries`, `journals`).
Map<String, Set<int>> textReferences({
  required String? contentJson,
  required String? plainText,
}) {
  final refs = <String, Set<int>>{
    'attachments': <int>{},
    'entries': <int>{},
    'journals': <int>{},
  };
  final delta = _decodeDelta(contentJson);
  if (delta != null) {
    for (final op in delta) {
      final insert = op is Map ? op['insert'] : null;
      if (insert is! Map) continue;
      for (final key in _embedKeys) {
        final id = _embedAttachmentId(insert[key]);
        if (id != null) refs['attachments']!.add(id);
      }
    }
  }
  for (final text in [contentJson, plainText]) {
    if (text == null) continue;
    for (final m in _wikiLink.allMatches(text)) {
      final table = m.group(1) == 'journal' ? 'journals' : 'entries';
      refs[table]!.add(int.parse(m.group(2)!));
    }
  }
  return refs;
}

/// Rewrites the row IDs in [contentJson]: embed `attachmentId`s through
/// `idMaps['attachments']`, and wiki links through `idMaps['entries']` and
/// `idMaps['journals']`. An ID without a mapping is left as it is. Returns
/// the input unchanged when it cannot be read.
String? rewriteContentJson(
  String? contentJson,
  Map<String, Map<int, int>> idMaps,
) {
  if (contentJson == null || contentJson.isEmpty) return contentJson;
  final delta = _decodeDelta(contentJson);
  if (delta == null) return rewriteWikiLinks(contentJson, idMaps);
  final attachments = idMaps['attachments'] ?? const {};
  final out = <Object?>[];
  for (final op in delta) {
    if (op is Map) {
      final copy = Map<String, dynamic>.from(op);
      final insert = copy['insert'];
      if (insert is String) {
        copy['insert'] = rewriteWikiLinks(insert, idMaps);
      } else if (insert is Map) {
        final embed = Map<String, dynamic>.from(insert);
        for (final key in _embedKeys) {
          if (embed[key] != null) {
            embed[key] = _rewriteEmbed(embed[key], attachments);
          }
        }
        copy['insert'] = embed;
      }
      out.add(copy);
    } else {
      out.add(op);
    }
  }
  return jsonEncode(out);
}

/// Rewrites `[[entry:N]]` and `[[journal:N]]` in [text] to local IDs. A link
/// without a mapping is left as it is.
String? rewriteWikiLinks(String? text, Map<String, Map<int, int>> idMaps) {
  if (text == null) return null;
  return text.replaceAllMapped(_wikiLink, (m) {
    final table = m.group(1) == 'journal' ? 'journals' : 'entries';
    final mapped = idMaps[table]?[int.parse(m.group(2)!)];
    return mapped == null ? m.group(0)! : '[[${m.group(1)}:$mapped]]';
  });
}

List<dynamic>? _decodeDelta(String? contentJson) {
  if (contentJson == null || contentJson.isEmpty) return null;
  try {
    final decoded = jsonDecode(contentJson);
    return decoded is List ? decoded : null;
  } on FormatException {
    return null;
  }
}

Map<String, dynamic>? _embedData(Object? embed) {
  Object? data = embed;
  if (data is String) {
    try {
      data = jsonDecode(data);
    } on FormatException {
      return null;
    }
  }
  return data is Map ? Map<String, dynamic>.from(data) : null;
}

int? _embedAttachmentId(Object? embed) {
  final id = _embedData(embed)?['attachmentId'];
  final parsed = id is int ? id : int.tryParse('$id');
  return parsed == null || parsed <= 0 ? null : parsed;
}

Object? _rewriteEmbed(Object? embed, Map<int, int> attachments) {
  final data = _embedData(embed);
  final id = _embedAttachmentId(embed);
  if (data == null || id == null || !attachments.containsKey(id)) return embed;
  data['attachmentId'] = attachments[id];
  // Keep the embed's own form: the editor stores the data as a JSON string.
  return embed is String ? jsonEncode(data) : data;
}
