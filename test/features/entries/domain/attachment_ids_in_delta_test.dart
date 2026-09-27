import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_journal_vault/features/entries/domain/attachment_ids_in_delta.dart';
import 'package:sreerajp_journal_vault/features/entries/presentation/editor/drawing_embed.dart';
import 'package:sreerajp_journal_vault/features/entries/presentation/editor/image_embed.dart';

void main() {
  test('embed keys match the embed widgets', () {
    expect(vaultImageEmbedKey, VaultImageEmbed.vaultImageType);
    expect(drawingEmbedKey, DrawingEmbed.drawingType);
  });

  test('finds picture and drawing IDs and ignores everything else', () {
    final delta = [
      {'insert': 'Some text\n'},
      {
        'insert': {
          vaultImageEmbedKey: jsonEncode({'attachmentId': 3, 'fileName': 'a'}),
        },
      },
      {
        'insert': {
          drawingEmbedKey: const DrawingEmbedData(
            attachmentId: 9,
            fileName: 'd.png',
          ).encode(),
        },
      },
      {
        'insert': {
          drawingEmbedKey: jsonEncode({'attachmentId': '12'}),
        },
      },
      {
        'insert': {'table': '{"rows":[]}'},
      },
      {
        'insert': {vaultImageEmbedKey: 'not json'},
      },
      {
        'insert': {
          drawingEmbedKey: jsonEncode({'attachmentId': 0}),
        },
      },
      {'insert': '\n'},
    ];

    expect(attachmentIdsInDelta(delta), {3, 9, 12});
  });

  test('anything that is not a delta gives no IDs', () {
    expect(attachmentIdsInDelta(null), isEmpty);
    expect(attachmentIdsInDelta({'ops': []}), isEmpty);
    expect(attachmentIdsInDelta(['text', 4]), isEmpty);
  });
}
