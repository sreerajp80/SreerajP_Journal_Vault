import 'dart:convert';

// Layer: domain. Pure Dart: no Flutter, no database, no widgets.

/// Quill embed type of an inline picture. Must match
/// `VaultImageEmbed.vaultImageType`; a test checks that it does.
const String vaultImageEmbedKey = 'vault_image';

/// Quill embed type of a drawing. Must match `DrawingEmbed.drawingType`; a
/// test checks that it does.
const String drawingEmbedKey = 'drawing';

/// The attachment IDs of every picture and drawing shown in [deltaJson], an
/// entry's Quill delta as decoded JSON (a list of operations).
///
/// Services use this where they cannot import the embed widgets. Anything it
/// cannot read is skipped, never thrown.
Set<int> attachmentIdsInDelta(Object? deltaJson) {
  final ids = <int>{};
  if (deltaJson is! List) return ids;
  for (final op in deltaJson) {
    if (op is! Map) continue;
    final insert = op['insert'];
    if (insert is! Map) continue;
    for (final key in const [vaultImageEmbedKey, drawingEmbedKey]) {
      final id = _attachmentId(insert[key]);
      if (id != null) ids.add(id);
    }
  }
  return ids;
}

int? _attachmentId(Object? embedData) {
  Object? data = embedData;
  if (data is String) {
    try {
      data = jsonDecode(data);
    } on FormatException {
      return null;
    }
  }
  if (data is! Map) return null;
  final id = data['attachmentId'];
  final parsed = id is int ? id : int.tryParse('$id');
  return parsed == null || parsed <= 0 ? null : parsed;
}
