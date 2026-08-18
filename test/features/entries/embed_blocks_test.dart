import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_journal_vault/features/entries/presentation/editor/callout_embed.dart';
import 'package:sreerajp_journal_vault/features/entries/presentation/editor/image_embed.dart';
import 'package:sreerajp_journal_vault/features/entries/presentation/editor/table_embed.dart';

void main() {
  group('CalloutEmbed', () {
    test('create produces valid JSON with style and text', () {
      final embed = CalloutEmbed.create(style: 'warning', text: 'Be careful');

      expect(embed.style, 'warning');
      expect(embed.text, 'Be careful');

      final parsed = jsonDecode(embed.data) as Map<String, dynamic>;
      expect(parsed['style'], 'warning');
      expect(parsed['text'], 'Be careful');
    });

    test('defaults to info style and empty text', () {
      final embed = CalloutEmbed.create();
      expect(embed.style, 'info');
      expect(embed.text, '');
    });

    test('type key matches calloutType constant', () {
      final embed = CalloutEmbed.create(style: 'tip');
      expect(embed.type, CalloutEmbed.calloutType);
      expect(embed.type, 'callout');
    });
  });

  group('TableEmbed', () {
    test('create generates correct grid dimensions', () {
      final embed = TableEmbed.create(rowCount: 2, colCount: 4);
      final rows = embed.rows;

      expect(rows.length, 2);
      expect(rows[0].length, 4);
      expect(rows[1].length, 4);
      // All cells empty.
      for (final row in rows) {
        for (final cell in row) {
          expect(cell, '');
        }
      }
    });

    test('fromRows preserves data', () {
      final data = [
        ['Header 1', 'Header 2'],
        ['Cell A', 'Cell B'],
      ];
      final embed = TableEmbed.fromRows(data);
      expect(embed.rows, data);
    });

    test('defaults to 3x3 table', () {
      final embed = TableEmbed.create();
      expect(embed.rows.length, 3);
      expect(embed.rows[0].length, 3);
    });

    test('type key matches tableType constant', () {
      final embed = TableEmbed.create();
      expect(embed.type, TableEmbed.tableType);
      expect(embed.type, 'table');
    });
  });

  group('VaultImageEmbed', () {
    test('create round-trips the attachment id, name and width', () {
      final embed = VaultImageEmbed.create(
        attachmentId: 12,
        fileName: 'beach.jpg',
        widthFactor: VaultImageData.mediumWidth,
      );

      final data = embed.imageData;
      expect(data.attachmentId, 12);
      expect(data.fileName, 'beach.jpg');
      expect(data.widthFactor, VaultImageData.mediumWidth);
    });

    test('defaults to full width', () {
      final embed = VaultImageEmbed.create(attachmentId: 1, fileName: 'a.png');
      expect(embed.imageData.widthFactor, VaultImageData.fullWidth);
    });

    test('never stores image bytes — only the attachment id', () {
      final embed = VaultImageEmbed.create(attachmentId: 7, fileName: 'x.png');
      final parsed = jsonDecode(embed.data) as Map<String, dynamic>;
      expect(parsed.keys, {'attachmentId', 'fileName', 'widthFactor'});
    });

    test('type key matches vaultImageType constant', () {
      final embed = VaultImageEmbed.create(attachmentId: 1, fileName: 'a.png');
      expect(embed.type, VaultImageEmbed.vaultImageType);
      // Deliberately not Quill's built-in 'image' type, which would put the
      // picture itself into the unencrypted document JSON.
      expect(embed.type, 'vault_image');
      expect(embed.type, isNot('image'));
    });

    test('an unexpected width snaps to the nearest offered size', () {
      final data = VaultImageData.parse(
        jsonEncode({
          'attachmentId': 3,
          'fileName': 'a.png',
          'widthFactor': 9.5,
        }),
      );
      expect(data.widthFactor, VaultImageData.fullWidth);

      final tiny = VaultImageData.parse(
        jsonEncode({
          'attachmentId': 3,
          'fileName': 'a.png',
          'widthFactor': 0.01,
        }),
      );
      expect(tiny.widthFactor, VaultImageData.smallWidth);
    });

    test('unreadable data parses to id 0 rather than throwing', () {
      for (final raw in <Object?>['not json', '[]', '', null, 42]) {
        final data = VaultImageData.parse(raw);
        expect(data.attachmentId, 0);
        expect(data.fileName, '');
      }
    });

    test('a missing width falls back to full width', () {
      final data = VaultImageData.parse(
        jsonEncode({'attachmentId': 5, 'fileName': 'a.png'}),
      );
      expect(data.attachmentId, 5);
      expect(data.widthFactor, VaultImageData.fullWidth);
    });
  });
}
