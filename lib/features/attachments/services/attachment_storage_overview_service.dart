// Layer: service. Reads what the storage settings screen shows. Knows
// nothing about widgets or UI strings.

import 'package:sreerajp_journal_vault/core/database/app_database.dart';

/// Where attachments are stored, and how much space they take.
typedef AttachmentStorageOverview = ({AppSetting settings, int totalBytes});

/// Reads the storage settings and the total size of all attachments.
class AttachmentStorageOverviewService {
  AttachmentStorageOverviewService(this._db);

  final AppDatabase _db;

  /// The current settings and the summed size of every attachment.
  Future<AttachmentStorageOverview> load() async {
    final settings = await _db.appSettingsDao.getSettings();
    final attachments = await _db.attachmentsDao.getAllAttachments();
    final total = attachments.fold<int>(0, (sum, a) => sum + a.sizeBytes);
    return (settings: settings, totalBytes: total);
  }
}
