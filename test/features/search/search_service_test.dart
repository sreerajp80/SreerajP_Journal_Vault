import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/features/search/services/search_service.dart';

void main() {
  late AppDatabase db;
  late SearchService service;

  setUp(() {
    db = AppDatabase.forExecutor(NativeDatabase.memory());
    service = SearchService(db);
  });

  tearDown(() => db.close());

  test('createPreset stores the entries filter, allPresets lists it', () async {
    await service.createPreset(name: 'All', query: 'rain', entriesOnly: false);
    await service.createPreset(
      name: 'Entries',
      query: 'sun',
      entriesOnly: true,
    );

    final presets = await service.allPresets();
    expect(presets.map((p) => p.name), ['All', 'Entries']);
    expect(presets.map((p) => p.resultType), [null, 'entries']);
  });

  test('searchEntries finds an entry by its text', () async {
    final journal = await db.journalsDao.createJournal(
      JournalsCompanion.insert(title: 'J'),
    );
    await db.entriesDao.createEntry(
      EntriesCompanion.insert(
        journalId: journal,
        title: const Value('Monsoon'),
        plainText: const Value('heavy rain in Kochi'),
      ),
    );

    final results = await service.searchEntries('rain');

    expect(results, hasLength(1));
    expect(results.single.journalId, journal);
  });
}
