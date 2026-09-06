import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart'
    show FlutterQuillLocalizations, QuillEditor;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/core/database/database_providers.dart';
import 'package:sreerajp_journal_vault/features/entries/presentation/entry_editor_screen.dart';
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

  testWidgets('body editor keeps focus after typing and deleting a character', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1200, 1800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final journalId = await database.journalsDao.createJournal(
      JournalsCompanion.insert(title: 'Focus Test Journal'),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(database)],
        child: _TestApp(child: EntryEditorScreen(journalId: journalId)),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    final editor = tester.widget<QuillEditor>(find.byType(QuillEditor));
    final bodyFocusNode = editor.focusNode;
    final controller = editor.controller;

    bodyFocusNode.requestFocus();
    await tester.pump();
    expect(bodyFocusNode.hasFocus, isTrue);

    // Type a few characters. Each document change rebuilds the screen through
    // the live word/character counter.
    controller.document.insert(0, 'Hello');
    await tester.pump();

    // Now delete one character, the way backspace does.
    controller.replaceText(4, 1, '', null);
    await tester.pump();

    final editorAfter = tester.widget<QuillEditor>(find.byType(QuillEditor));

    // The rebuild must not hand the editor a brand new focus node — that is
    // what used to drop focus and send the caret to the title field.
    expect(identical(editorAfter.focusNode, bodyFocusNode), isTrue);
    expect(
      identical(editorAfter.scrollController, editor.scrollController),
      isTrue,
    );
    expect(bodyFocusNode.hasFocus, isTrue);
    expect(controller.document.toPlainText().trim(), 'Hell');

    // Let the 2.5s auto-save timer run out so no timer is left pending.
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
  });
}
