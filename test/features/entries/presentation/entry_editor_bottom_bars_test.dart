import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart'
    show ChangeSource, FlutterQuillLocalizations, QuillEditor;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/core/database/database_providers.dart';
import 'package:sreerajp_journal_vault/features/entries/presentation/entry_editor_screen.dart';
import 'package:sreerajp_journal_vault/features/smart_tags/presentation/smart_tag_chip_bar.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

class _TestApp extends StatelessWidget {
  const _TestApp({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        FlutterQuillLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],
      home: child,
    );
  }
}

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase.forExecutor(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  Future<void> pumpEditor(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 1800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final journalId = await database.journalsDao.createJournal(
      JournalsCompanion.insert(title: 'Bottom Bars Journal'),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(database)],
        child: _TestApp(child: EntryEditorScreen(journalId: journalId)),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }

  /// Lets the 2.5s auto-save timer run out so no timer is left pending.
  Future<void> drainAutoSave(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
  }

  testWidgets('toolbar tab button types a tab character at the caret', (
    tester,
  ) async {
    await pumpEditor(tester);

    final controller = tester
        .widget<QuillEditor>(find.byType(QuillEditor))
        .controller;
    controller.document.insert(0, 'ab');
    controller.updateSelection(
      const TextSelection.collapsed(offset: 1),
      ChangeSource.local,
    );
    await tester.pump();

    await tester.tap(find.byKey(const Key('editor-insert-tab')));
    await tester.pump();

    expect(controller.document.toPlainText(), 'a\tb\n');
    // The caret follows the inserted tab.
    expect(controller.selection.baseOffset, 2);

    await drainAutoSave(tester);
  });

  testWidgets('panels under the editor are hidden while the caret is in it', (
    tester,
  ) async {
    await pumpEditor(tester);

    final bodyFocusNode = tester
        .widget<QuillEditor>(find.byType(QuillEditor))
        .focusNode;

    // Not typing: the smart-tag bar is built below the editor as usual.
    expect(find.byType(SmartTagChipBar), findsOneWidget);

    bodyFocusNode.requestFocus();
    // Two pumps: the first applies the focus change, the second rebuilds with
    // the listener's setState.
    await tester.pump();
    await tester.pump();

    // Typing: nothing below the caret may change height, so it is not built.
    // This bar is the one that grew from 0 to 48px mid-keystroke and pushed
    // the last line out of sight.
    expect(find.byType(SmartTagChipBar), findsNothing);

    bodyFocusNode.unfocus();
    await tester.pump();
    await tester.pump();

    expect(find.byType(SmartTagChipBar), findsOneWidget);

    await drainAutoSave(tester);
  });

  testWidgets('mood picker is behind its button, not always on screen', (
    tester,
  ) async {
    await pumpEditor(tester);

    // The old always-visible mood row is gone from the editor column.
    expect(find.byKey(const Key('entry-mood-picker')), findsNothing);

    await tester.tap(find.byKey(const Key('entry-mood-button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('entry-mood-picker')), findsOneWidget);
    expect(find.byKey(const Key('entry-mood-4')), findsOneWidget);

    await tester.tap(find.byKey(const Key('entry-mood-4')));
    await tester.pumpAndSettle();

    // Picking closes the sheet and marks the entry unsaved.
    expect(find.byKey(const Key('entry-mood-picker')), findsNothing);
    final saveButton = tester.widget<IconButton>(
      find.byKey(const Key('entry-save-button')),
    );
    expect(saveButton.onPressed, isNotNull);

    await drainAutoSave(tester);
  });
}
