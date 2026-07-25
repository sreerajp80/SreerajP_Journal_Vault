import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_journal_vault/features/entries/presentation/editor/callout_embed.dart';
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

}
