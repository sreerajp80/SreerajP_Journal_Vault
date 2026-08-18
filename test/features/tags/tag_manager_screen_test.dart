import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/core/database/database_providers.dart';
import 'package:sreerajp_journal_vault/features/tags/domain/tag_colors.dart';
import 'package:sreerajp_journal_vault/features/tags/presentation/tag_manager_screen.dart';
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

  Future<void> pumpScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: TagManagerScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  // The menu is a PopupMenuButton over a private enum, so find.byType cannot
  // name it — the tooltip is the stable handle.
  final menuButton = find.byTooltip('Tag actions');

  Future<void> openMenu(WidgetTester tester, String action) async {
    await tester.tap(menuButton.first);
    await tester.pumpAndSettle();
    await tester.tap(find.text(action));
    await tester.pumpAndSettle();
  }

  testWidgets('shows a message when there are no tags', (tester) async {
    await pumpScreen(tester);

    expect(find.textContaining('No tags yet'), findsOneWidget);
  });

  testWidgets('lists every tag in name order', (tester) async {
    await db.tagsDao.getOrCreateTag('work');
    await db.tagsDao.getOrCreateTag('health');

    await pumpScreen(tester);

    final titles = tester
        .widgetList<ListTile>(find.byType(ListTile))
        .map((tile) => (tile.title! as Text).data)
        .toList();

    expect(titles, ['#health', '#work']);
  });

  testWidgets('marks a tag with no stored colour as automatic', (tester) async {
    await db.tagsDao.getOrCreateTag('work');

    await pumpScreen(tester);

    expect(find.text('Automatic colour'), findsOneWidget);
  });

  testWidgets('renaming a tag writes the new name', (tester) async {
    await db.tagsDao.getOrCreateTag('work');

    await pumpScreen(tester);
    await openMenu(tester, 'Rename');

    await tester.enterText(
      find.byKey(const Key('tag-rename-field')),
      'day job',
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect((await db.tagsDao.getAllTags()).single.name, 'day job');
    expect(find.text('#day job'), findsOneWidget);
  });

  testWidgets('a rename that clashes is refused and reported', (tester) async {
    await db.tagsDao.getOrCreateTag('health');
    await db.tagsDao.getOrCreateTag('work');

    await pumpScreen(tester);
    // The first tile is 'health'; try to rename it onto 'work'.
    await openMenu(tester, 'Rename');
    await tester.enterText(find.byKey(const Key('tag-rename-field')), 'work');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.textContaining('already used'), findsOneWidget);
    final names = (await db.tagsDao.getAllTags()).map((t) => t.name);
    expect(names, containsAll(['health', 'work']));
  });

  testWidgets('choosing a colour stores it', (tester) async {
    await db.tagsDao.getOrCreateTag('work');

    await pumpScreen(tester);
    await openMenu(tester, 'Choose colour');

    final picked = kTagPalette[0];
    await tester.tap(find.byKey(ValueKey('tag-color-${picked.toARGB32()}')));
    await tester.pumpAndSettle();

    expect((await db.tagsDao.getAllTags()).single.colorArgb, picked.toARGB32());
    expect(find.text('Automatic colour'), findsNothing);
  });

  testWidgets('resetting a colour clears it', (tester) async {
    final id = await db.tagsDao.getOrCreateTag('work');
    await db.tagsDao.setTagColor(id, kTagPalette[0].toARGB32());

    await pumpScreen(tester);
    await openMenu(tester, 'Reset to automatic');

    expect((await db.tagsDao.getAllTags()).single.colorArgb, isNull);
    expect(find.text('Automatic colour'), findsOneWidget);
  });

  testWidgets('the reset action is hidden for an automatic colour', (
    tester,
  ) async {
    await db.tagsDao.getOrCreateTag('work');

    await pumpScreen(tester);
    await tester.tap(menuButton.first);
    await tester.pumpAndSettle();

    expect(find.text('Reset to automatic'), findsNothing);
  });

  testWidgets('deleting a tag removes it and its links', (tester) async {
    final journalId = await db.journalsDao.createJournal(
      JournalsCompanion.insert(title: 'Diary'),
    );
    final tagId = await db.tagsDao.getOrCreateTag('work');
    await db.journalTagsDao.addTagToJournal(journalId, tagId);

    await pumpScreen(tester);
    await openMenu(tester, 'Delete');

    await tester.tap(find.widgetWithText(TextButton, 'Delete'));
    await tester.pumpAndSettle();

    expect(await db.tagsDao.getAllTags(), isEmpty);
    expect(await db.journalTagsDao.getTagsForJournal(journalId), isEmpty);
    expect(find.textContaining('No tags yet'), findsOneWidget);
  });

  testWidgets('cancelling a delete keeps the tag', (tester) async {
    await db.tagsDao.getOrCreateTag('work');

    await pumpScreen(tester);
    await openMenu(tester, 'Delete');

    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pumpAndSettle();

    expect(await db.tagsDao.getAllTags(), hasLength(1));
  });
}
