import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart'
    show FlutterQuillLocalizations;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/core/database/database_providers.dart';
import 'package:sreerajp_journal_vault/core/links/vault_backlinks.dart';
import 'package:sreerajp_journal_vault/features/entries/presentation/entry_editor_screen.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

/// The "Linked from" panel names each entry that links here. An entry with
/// no title is shown with the translated word for "Untitled", never with an
/// English "Entry #" and a row number.
void main() {
  late AppDatabase database;

  setUp(() => database = AppDatabase.forExecutor(NativeDatabase.memory()));
  tearDown(() => database.close());

  testWidgets('an untitled linking entry is shown as Untitled', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 1800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final journalId = await database.journalsDao.createJournal(
      JournalsCompanion.insert(title: 'J'),
    );
    final target = await database.entriesDao.createEntry(
      EntriesCompanion.insert(
        journalId: journalId,
        title: const Value('Target'),
        contentJson: const Value('[{"insert":"Hello\\n"}]'),
      ),
    );
    final source = await database.entriesDao.createEntry(
      EntriesCompanion.insert(journalId: journalId),
    );
    await database.backlinksDao.replaceBacklinksForEntry(source, [
      VaultBacklinkTarget(
        type: VaultBacklinkTargetType.entry,
        targetId: target,
      ),
    ]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(database)],
        child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            FlutterQuillLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en')],
          home: EntryEditorScreen(journalId: journalId, entryId: target),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final row = find.byKey(Key('linked-from-row-$source'));
    expect(row, findsOneWidget);
    expect(
      find.descendant(of: row, matching: find.text('Untitled')),
      findsOneWidget,
    );
    expect(find.textContaining('Entry #'), findsNothing);
  });
}
