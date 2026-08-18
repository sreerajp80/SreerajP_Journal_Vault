import 'package:file_picker/file_picker.dart';
import 'package:mime/mime.dart';

import 'package:sreerajp_journal_vault/features/attachments/services/attachment_picker_service.dart';

/// [AttachmentPickerService] backed by the system file picker.
class FilePickerAttachmentPickerService implements AttachmentPickerService {
  @override
  Future<PickedAttachmentData?> pickAttachment() async {
    final result = await FilePicker.pickFiles(withData: true);
    if (result == null || result.files.isEmpty) return null;

    final file = result.files.first;
    final bytes = file.bytes;
    if (bytes == null) return null;

    final name = file.name;
    final mime = lookupMimeType(name) ?? 'application/octet-stream';

    return PickedAttachmentData(fileName: name, mimeType: mime, bytes: bytes);
  }
}
