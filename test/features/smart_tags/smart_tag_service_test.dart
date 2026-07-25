import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/features/smart_tags/services/smart_tag_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late SmartTagService service;

  setUp(() async {
    db = AppDatabase.forExecutor(NativeDatabase.memory());
    service = SmartTagService(db);
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> seedTags(List<String> names) async {
    for (final n in names) {
      await db.tagsDao.getOrCreateTag(n);
    }
  }

  group('suggest', () {
    test('returns empty list for empty / null text', () async {
      await seedTags(['work']);
      expect(await service.suggest(null), isEmpty);
      expect(await service.suggest(''), isEmpty);
      expect(await service.suggest('   '), isEmpty);
    });

    test('returns empty list when no tags are stored', () async {
      expect(await service.suggest('any text'), isEmpty);
    });

    test('matches case-insensitively', () async {
      // getOrCreateTag normalises tag names to lowercase.
      await seedTags(['Work', 'travel']);
      final suggestions = await service.suggest('My WORK is going well');
      expect(suggestions.map((s) => s.tag.name), contains('work'));
    });

    test('orders suggestions by occurrence count (descending)', () async {
      await seedTags(['focus', 'travel', 'idea']);
      final text =
          'idea of travel and idea about idea of focus on travel';
      // counts: idea=3, travel=2, focus=1
      final suggestions = await service.suggest(text);
      expect(
        suggestions.map((s) => s.tag.name).toList(),
        ['idea', 'travel', 'focus'],
      );
      expect(
        suggestions.map((s) => s.score).toList(),
        [3, 2, 1],
      );
    });

    test('honors the limit parameter', () async {
      await seedTags(['a', 'b', 'c', 'd', 'e']);
      final text = 'a b c d e a b';
      final suggestions = await service.suggest(text, limit: 3);
      expect(suggestions, hasLength(3));
    });

    test('only returns tags that actually appear in the text', () async {
      await seedTags(['present', 'absent']);
      final text = 'this text mentions present';
      final suggestions = await service.suggest(text);
      expect(suggestions.map((s) => s.tag.name).toList(), ['present']);
    });

    test('handles multi-word tags as a single phrase', () async {
      await seedTags(['deep work']);
      final suggestions = await service.suggest(
        'doing some deep work today',
      );
      expect(suggestions.single.tag.name, 'deep work');
    });

    test('strips punctuation when matching tags', () async {
      await seedTags(['focus']);
      final suggestions = await service.suggest('really, focus! today.');
      expect(suggestions.single.tag.name, 'focus');
    });
  });

  group('suggestNew', () {
    test('excludes tags already attached to the entry', () async {
      final journalId = await db.journalsDao.createJournal(
        JournalsCompanion.insert(title: 'J'),
      );
      final entryId = await db.entriesDao.createEntry(
        EntriesCompanion.insert(journalId: journalId),
      );
      final tagA = await db.tagsDao.getOrCreateTag('alpha');
      await db.tagsDao.getOrCreateTag('beta');
      await db.tagsDao.addTagToEntry(entryId, tagA);

      final suggestions = await service.suggestNew(
        entryId,
        'alpha and beta both appear',
      );
      expect(
        suggestions.map((s) => s.tag.name).toList(),
        ['beta'],
      );
    });

    test('returns up to limit fresh suggestions', () async {
      final journalId = await db.journalsDao.createJournal(
        JournalsCompanion.insert(title: 'J'),
      );
      final entryId = await db.entriesDao.createEntry(
        EntriesCompanion.insert(journalId: journalId),
      );
      await seedTags(['a', 'b', 'c', 'd', 'e']);
      final suggestions = await service.suggestNew(
        entryId,
        'a b c d e',
        limit: 2,
      );
      expect(suggestions, hasLength(2));
    });
  });
}
