import 'package:sreerajp_journal_vault/features/attachments/services/attachment_crypto_storage.dart';

/// Service for querying and changing the attachment storage location.
class AttachmentStorageLocationService {
  AttachmentStorageLocationService();

  /// Returns the current storage location preference.
  Future<AttachmentStorageLocation> getCurrentLocation() async {
    return AttachmentStorageLocation.appPrivate;
  }
}
