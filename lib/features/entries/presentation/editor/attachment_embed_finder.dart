import 'package:flutter_quill/flutter_quill.dart';

import 'package:sreerajp_journal_vault/features/entries/presentation/editor/drawing_embed.dart';
import 'package:sreerajp_journal_vault/features/entries/presentation/editor/image_embed.dart';

/// Document offsets of every picture or drawing in [document] that shows the
/// attachment [attachmentId], in document order.
///
/// Used after an attachment is deleted, so its picture can be taken out of the
/// text instead of staying behind as a broken image.
List<int> attachmentEmbedOffsets(Document document, int attachmentId) {
  final offsets = <int>[];
  var offset = 0;
  for (final op in document.toDelta().toList()) {
    final data = op.data;
    if (op.isInsert && data is Map) {
      final int? id;
      if (data.containsKey(VaultImageEmbed.vaultImageType)) {
        id = VaultImageData.parse(
          data[VaultImageEmbed.vaultImageType],
        ).attachmentId;
      } else if (data.containsKey(DrawingEmbed.drawingType)) {
        id = DrawingEmbedData.parse(
          data[DrawingEmbed.drawingType],
        ).attachmentId;
      } else {
        id = null;
      }
      if (id == attachmentId) offsets.add(offset);
    }
    offset += op.length ?? 0;
  }
  return offsets;
}
