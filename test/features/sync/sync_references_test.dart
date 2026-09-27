import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/features/sync/services/sync_engine.dart';
import 'package:sreerajp_journal_vault/features/sync/services/sync_references.dart';

void main() {
  test('every listed reference and file column exists in the schema', () async {
    // A renamed column must break this test, not sync.
    final db = AppDatabase.forExecutor(NativeDatabase.memory());
    addTearDown(db.close);
    Set<String> columnsOf(String table) => {
      for (final c
          in db.allTables
              .singleWhere((t) => t.actualTableName == table)
              .$columns)
        c.name,
    };

    for (final table in syncReferenceColumns.entries) {
      expect(SyncEngine.syncableTables, contains(table.key));
      for (final column in table.value.entries) {
        expect(columnsOf(table.key), contains(column.key));
        expect(SyncEngine.syncableTables, contains(column.value));
      }
    }
    expect(columnsOf('backlinks'), containsAll(['target_type', 'target_id']));
    for (final table in syncFileTables) {
      expect(
        columnsOf(table),
        containsAll([...syncDeviceFileColumns, 'file_name']),
      );
    }
    for (final table in syncTextTables) {
      expect(columnsOf(table), containsAll(['content_json', 'plain_text']));
    }
  });

  test('syncRef and syncIdOfRef round trip; a raw number is no ref', () {
    expect(syncIdOfRef(syncRef('abc')), 'abc');
    expect(syncRef(null), isNull);
    expect(syncIdOfRef(7), isNull);
    expect(syncIdOfRef({'other': 'x'}), isNull);
  });

  final content = jsonEncode([
    {'insert': 'Go to [[entry:4]] and [[journal:2]]\n'},
    {
      'insert': {
        'vault_image': jsonEncode({'attachmentId': 11, 'fileName': 'a'}),
      },
    },
    {
      'insert': {
        'drawing': jsonEncode({'attachmentId': 12, 'fileName': 'd'}),
      },
    },
    {'insert': '\n'},
  ]);

  test('textReferences finds pictures, drawings and wiki links', () {
    final refs = textReferences(
      contentJson: content,
      plainText: 'also [[entry:5]]',
    );
    expect(refs['attachments'], {11, 12});
    expect(refs['entries'], {4, 5});
    expect(refs['journals'], {2});
  });

  test('rewriteContentJson maps known IDs and leaves the rest', () {
    final rewritten = rewriteContentJson(content, {
      'attachments': {11: 101},
      'entries': {4: 40},
    });
    final ops = jsonDecode(rewritten!) as List;
    expect(ops[0]['insert'], 'Go to [[entry:40]] and [[journal:2]]\n');
    expect(
      (jsonDecode(ops[1]['insert']['vault_image'] as String)
          as Map)['attachmentId'],
      101,
    );
    expect(
      (jsonDecode(ops[2]['insert']['drawing'] as String)
          as Map)['attachmentId'],
      12,
    );
  });

  test('rewriteWikiLinks and unreadable content', () {
    expect(
      rewriteWikiLinks('[[journal:2]] [[entry:9]]', {
        'journals': {2: 3},
      }),
      '[[journal:3]] [[entry:9]]',
    );
    expect(rewriteContentJson(null, const {}), isNull);
    expect(
      rewriteContentJson('not json [[entry:1]]', {
        'entries': {1: 2},
      }),
      'not json [[entry:2]]',
    );
  });
}
