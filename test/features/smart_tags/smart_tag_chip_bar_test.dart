import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/core/database/database_providers.dart';
import 'package:sreerajp_journal_vault/features/smart_tags/presentation/smart_tag_chip_bar.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forExecutor(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  Future<int> seedEntry() async {
    final journalId = await db.journalsDao.createJournal(
      JournalsCompanion.insert(title: 'Journal'),
    );
    return db.entriesDao.createEntry(
      EntriesCompanion.insert(journalId: journalId),
    );
  }

  Future<void> pumpBar(
    WidgetTester tester, {
    required int entryId,
    required String? plainText,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SmartTagChipBar(entryId: entryId, plainText: plainText),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('renders a chip for each tag found in the entry text', (
    tester,
  ) async {
    await db.tagsDao.getOrCreateTag('travel');
    await db.tagsDao.getOrCreateTag('packing');
    await db.tagsDao.getOrCreateTag('unrelated');
    final entryId = await seedEntry();

    await pumpBar(
      tester,
      entryId: entryId,
      plainText: 'Travel day — finished packing the bags.',
    );

    expect(find.text('travel'), findsOneWidget);
    expect(find.text('packing'), findsOneWidget);
    expect(find.text('unrelated'), findsNothing);
  });

  testWidgets('renders nothing when no tag matches', (tester) async {
    await db.tagsDao.getOrCreateTag('work');
    final entryId = await seedEntry();

    await pumpBar(tester, entryId: entryId, plainText: 'A quiet day at home.');

    expect(find.byType(ActionChip), findsNothing);
  });

  testWidgets('tapping a chip applies the tag to the entry', (tester) async {
    await db.tagsDao.getOrCreateTag('travel');
    final entryId = await seedEntry();

    await pumpBar(tester, entryId: entryId, plainText: 'Travel day.');
    expect(await db.tagsDao.getTagsForEntry(entryId), isEmpty);

    await tester.tap(find.text('travel'));
    await tester.pumpAndSettle();

    final applied = await db.tagsDao.getTagsForEntry(entryId);
    expect(applied.map((t) => t.name), ['travel']);
  });

  testWidgets('an applied tag stops being suggested', (tester) async {
    await db.tagsDao.getOrCreateTag('travel');
    final entryId = await seedEntry();

    await pumpBar(tester, entryId: entryId, plainText: 'Travel day.');
    await tester.tap(find.text('travel'));
    await tester.pumpAndSettle();

    // The widget invalidates its own provider after accepting, so the chip
    // should be gone without any external rebuild.
    expect(find.text('travel'), findsNothing);
  });
}
