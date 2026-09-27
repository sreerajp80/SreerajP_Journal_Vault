// Layer: service. Creates, changes and deletes the user's own entry
// templates. Knows nothing about widgets or UI strings.

import 'package:drift/drift.dart' show Value;
import 'package:sreerajp_journal_vault/core/database/app_database.dart';

/// The user's own entry templates.
///
/// An empty description or default title is stored as none.
class UserTemplateService {
  UserTemplateService(this._db);

  final AppDatabase _db;

  /// Creates a template and returns its ID.
  Future<int> createTemplate({
    required String name,
    required String description,
    required String defaultTitle,
    required String contentJson,
  }) => _db.userTemplatesDao.createUserTemplate(
    UserTemplatesCompanion.insert(
      name: name,
      description: Value(description.isEmpty ? null : description),
      defaultTitle: Value(defaultTitle.isEmpty ? null : defaultTitle),
      contentJson: contentJson,
    ),
  );

  /// Replaces the fields of [existing] and stamps the change time.
  Future<bool> updateTemplate(
    UserTemplate existing, {
    required String name,
    required String description,
    required String defaultTitle,
    required String contentJson,
  }) => _db.userTemplatesDao.updateUserTemplate(
    existing.copyWith(
      name: name,
      description: Value(description.isEmpty ? null : description),
      defaultTitle: Value(defaultTitle.isEmpty ? null : defaultTitle),
      contentJson: contentJson,
      updatedAt: DateTime.now(),
    ),
  );

  /// Deletes template [templateId].
  Future<void> deleteTemplate(int templateId) =>
      _db.userTemplatesDao.deleteUserTemplate(templateId);
}
