// Layer: service. Changes tags and their links. Knows nothing about widgets
// or UI strings.

import 'package:sreerajp_journal_vault/core/database/app_database.dart';

/// Renames, recolours and deletes tags, and tags entries.
class TagService {
  TagService(this._db);

  final AppDatabase _db;

  /// Renames tag [tagId]. Returns false when the name cannot be used (for
  /// example, another tag already has it).
  Future<bool> renameTag(int tagId, String name) =>
      _db.tagsDao.renameTag(tagId, name);

  /// Sets the colour of tag [tagId]; null goes back to the default colour.
  Future<void> setTagColor(int tagId, int? colorArgb) =>
      _db.tagsDao.setTagColor(tagId, colorArgb);

  /// Deletes tag [tagId] and unlinks it from every entry and journal.
  Future<void> deleteTag(int tagId) => _db.tagsDao.deleteTagWithLinks(tagId);

  /// Adds tag [tagId] to entry [entryId].
  Future<void> addTagToEntry(int entryId, int tagId) =>
      _db.tagsDao.addTagToEntry(entryId, tagId);
}
