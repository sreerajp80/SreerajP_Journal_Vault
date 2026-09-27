import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_journal_vault/features/entries/domain/table_data.dart';
import 'package:sreerajp_journal_vault/features/entries/services/entry_plain_text.dart';

void main() {
  test('gives the words inside a table, so search can find them', () {
    final table = TableData(
      cells: [
        [
          [
            {'insert': 'Name'},
          ],
          [
            {'insert': 'City'},
          ],
        ],
        [
          [
            {
              'insert': 'Anu',
              'attributes': {'bold': true},
            },
          ],
          [
            {'insert': 'Kochi'},
          ],
        ],
      ],
    );
    final text = entryPlainText([
      {'insert': 'Before\n'},
      {
        'insert': {'table': table.toJsonString()},
      },
      {'insert': '\nAfter\n'},
    ]);
    expect(text, 'Before\nName City\nAnu Kochi\nAfter\n');
  });

  test('matches Document.toPlainText when there is no table', () {
    final ops = [
      {'insert': 'Hello '},
      {
        'insert': 'world',
        'attributes': {'bold': true},
      },
      {
        'insert': '\n',
        'attributes': {'header': 1},
      },
      {
        'insert': {'callout': '{"style":"info","text":"x"}'},
      },
      {'insert': '\nend\n'},
    ];
    expect(entryPlainText(ops), Document.fromJson(ops).toPlainText());
  });

  test('a damaged table stays one placeholder character', () {
    final text = entryPlainText([
      {
        'insert': {'table': 'not json'},
      },
      {'insert': '\n'},
    ]);
    expect(text, '${Embed.kObjectReplacementCharacter}\n');
  });
}
