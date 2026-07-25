class PickedAttachmentData {
  const PickedAttachmentData({
    required this.fileName,
    required this.mimeType,
    required this.bytes,
  });

  final String fileName;
  final String mimeType;
  final List<int> bytes;
}

abstract class AttachmentPickerService {
  Future<PickedAttachmentData?> pickAttachment();
}
