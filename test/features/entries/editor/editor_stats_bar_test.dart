import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_journal_vault/features/entries/presentation/editor/editor_stats_bar.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

void main() {
  group('EditorStatsBar calculation logic', () {
    test('countWords accurately counts words', () {
      expect(EditorStatsBar.countWords(''), 0);
      expect(EditorStatsBar.countWords('   '), 0);
      expect(EditorStatsBar.countWords('Hello'), 1);
      expect(EditorStatsBar.countWords('Hello world'), 2);
      expect(EditorStatsBar.countWords('Hello   world \n this is a test\n'), 6);
    });

    test(
      'countCharacters accurately counts characters excluding trailing newline',
      () {
        expect(EditorStatsBar.countCharacters(''), 0);
        expect(EditorStatsBar.countCharacters('\n'), 0);
        expect(EditorStatsBar.countCharacters('abc\n'), 3);
        expect(EditorStatsBar.countCharacters('abc'), 3);
        expect(EditorStatsBar.countCharacters('Hello World\n'), 11);
      },
    );
  });

  group('EditorStatsBar widget', () {
    Widget buildTestWidget({
      required int wordCount,
      required int characterCount,
      required EditorSaveStatus saveStatus,
      DateTime? lastSavedTime,
      bool compact = false,
    }) {
      return MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en')],
        home: Scaffold(
          body: EditorStatsBar(
            wordCount: wordCount,
            characterCount: characterCount,
            saveStatus: saveStatus,
            lastSavedTime: lastSavedTime,
            compact: compact,
          ),
        ),
      );
    }

    testWidgets('renders word and character counts', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          wordCount: 15,
          characterCount: 92,
          saveStatus: EditorSaveStatus.saved,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('editor-stats-bar')), findsOneWidget);
      expect(find.text('15 words • 92 chars'), findsOneWidget);
    });

    testWidgets('renders saving status', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          wordCount: 5,
          characterCount: 20,
          saveStatus: EditorSaveStatus.saving,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Saving…'), findsOneWidget);
      expect(find.byIcon(Icons.sync), findsOneWidget);
    });

    testWidgets('renders unsaved status', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          wordCount: 5,
          characterCount: 20,
          saveStatus: EditorSaveStatus.unsaved,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Unsaved changes'), findsOneWidget);
      expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
    });

    testWidgets('renders saved status with timestamp', (tester) async {
      final savedTime = DateTime(2026, 8, 21, 10, 45);
      await tester.pumpWidget(
        buildTestWidget(
          wordCount: 10,
          characterCount: 50,
          saveStatus: EditorSaveStatus.saved,
          lastSavedTime: savedTime,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Saved at'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
    });

    testWidgets('renders saved just now when lastSavedTime is null', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestWidget(
          wordCount: 10,
          characterCount: 50,
          saveStatus: EditorSaveStatus.saved,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Saved just now'), findsOneWidget);
    });
  });
}
