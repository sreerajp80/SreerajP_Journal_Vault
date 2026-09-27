import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart'
    show FlutterQuillLocalizations, QuillController, QuillEditor;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/core/database/database_providers.dart';
import 'package:sreerajp_journal_vault/features/entries/presentation/entry_editor_screen.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

/// Text typed in the editor must never be lost: not when the screen closes
/// before the 2.5-second autosave, and not when the app goes to the
/// background.
void main() {
  late AppDatabase database;
  late int journalId;
  late int entryId;
  final navigatorKey = GlobalKey<NavigatorState>();

  setUp(() async {
    database = AppDatabase.forExecutor(NativeDatabase.memory());
    journalId = await database.journalsDao.createJournal(
      JournalsCompanion.insert(title: 'J'),
    );
    entryId = await database.entriesDao.createEntry(
      EntriesCompanion.insert(
        journalId: journalId,
        title: const Value('Day'),
        contentJson: const Value('[{"insert":"Start\\n"}]'),
        plainText: const Value('Start'),
      ),
    );
  });

  tearDown(() async {
    await database.close();
  });

  /// Opens the editor for the entry on top of a plain home screen.
  Future<QuillController> openEditor(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 1800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(database)],
        child: MaterialApp(
          navigatorKey: navigatorKey,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            FlutterQuillLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en')],
          home: const Scaffold(body: Text('HOME')),
        ),
      ),
    );
    navigatorKey.currentState!.push(
      MaterialPageRoute<void>(
        builder: (_) =>
            EntryEditorScreen(journalId: journalId, entryId: entryId),
      ),
    );
    await tester.pumpAndSettle();
    return tester.widget<QuillEditor>(find.byType(QuillEditor)).controller;
  }

  /// Types [text] at the start of the body.
  Future<void> type(
    WidgetTester tester,
    QuillController controller,
    String text,
  ) async {
    controller.replaceText(0, 0, text, null);
    await tester.pump();
  }

  Future<Entry> savedEntry() => database.entriesDao.getEntryById(entryId);

  testWidgets('closing the screen right after typing saves the text', (
    tester,
  ) async {
    final controller = await openEditor(tester);
    await type(tester, controller, 'Late words ');

    // Well inside the 2.5-second autosave window.
    await tester.pump(const Duration(milliseconds: 300));
    navigatorKey.currentState!.pop();
    await tester.pumpAndSettle();

    final entry = await savedEntry();
    expect(entry.plainText, contains('Late words'));
    expect(entry.contentJson, contains('Late words'));
  });

  testWidgets('going to the background saves at once', (tester) async {
    final controller = await openEditor(tester);
    await type(tester, controller, 'Backgrounded ');

    // The same order Android goes through when the user presses Home.
    for (final state in const [
      AppLifecycleState.inactive,
      AppLifecycleState.hidden,
      AppLifecycleState.paused,
    ]) {
      tester.binding.handleAppLifecycleStateChanged(state);
    }
    await tester.pump();

    expect((await savedEntry()).plainText, contains('Backgrounded'));

    for (final state in const [
      AppLifecycleState.hidden,
      AppLifecycleState.inactive,
      AppLifecycleState.resumed,
    ]) {
      tester.binding.handleAppLifecycleStateChanged(state);
    }
    await tester.pumpAndSettle();
  });

  testWidgets('closing without changes writes nothing', (tester) async {
    await openEditor(tester);

    navigatorKey.currentState!.pop();
    await tester.pumpAndSettle();

    final entry = await savedEntry();
    expect(entry.contentJson, '[{"insert":"Start\\n"}]');
    expect(
      await database.entryRevisionsDao.getRevisionsForEntry(entryId),
      isEmpty,
    );
  });

  testWidgets('text typed after an autosave is saved when the screen closes', (
    tester,
  ) async {
    final controller = await openEditor(tester);
    await type(tester, controller, 'First ');
    // Let the autosave run.
    await tester.pump(const Duration(milliseconds: 2600));
    await tester.pump();
    expect((await savedEntry()).plainText, contains('First'));

    await type(tester, controller, 'Second ');
    navigatorKey.currentState!.pop();
    await tester.pumpAndSettle();

    final entry = await savedEntry();
    expect(entry.plainText, contains('Second'));
    expect(entry.plainText, contains('First'));
  });
}
