import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_journal_vault/features/entries/presentation/editor/dictation_sheet.dart';
import 'package:sreerajp_journal_vault/features/entries/providers/dictation_providers.dart';
import 'package:sreerajp_journal_vault/features/entries/services/dictation_service.dart';
import 'package:sreerajp_journal_vault/features/entries/services/speech_engine.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

import '../../../../helpers/fake_speech_engine.dart';

/// Keeps the language choice in memory instead of SharedPreferences.
class _MemoryLanguageStore extends DictationLanguageStore {
  _MemoryLanguageStore();

  String? saved;

  @override
  Future<String?> read() async => saved;

  @override
  Future<void> save(String languageTag) async => saved = languageTag;
}

void main() {
  late FakeSpeechEngine engine;
  String? sheetResult;
  bool sheetClosed = false;

  Future<void> openSheet(WidgetTester tester) async {
    sheetResult = null;
    sheetClosed = false;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          speechEngineProvider.overrideWithValue(engine),
          dictationServiceFactoryProvider.overrideWithValue(
            () => DictationService(
              engine,
              restartDelay: const Duration(milliseconds: 1),
              finalResultWait: Duration.zero,
            ),
          ),
          dictationLanguageStoreProvider.overrideWithValue(
            _MemoryLanguageStore(),
          ),
        ],
        child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en')],
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () async {
                  sheetResult = await showDictationSheet(context);
                  sheetClosed = true;
                },
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  setUp(() => engine = FakeSpeechEngine());

  testWidgets('starts listening and shows final and partial text', (
    tester,
  ) async {
    await openSheet(tester);

    expect(engine.listenLocales, ['en-US']);
    expect(
      find.text('Start speaking. Your words will appear here.'),
      findsOneWidget,
    );

    engine.finalResult('Dear diary');
    engine.partial('today was');
    await tester.pump();
    await tester.pump();

    final live = tester.widget<Text>(
      find.byKey(const Key('dictation-live-text')),
    );
    expect(live.textSpan!.toPlainText(), 'Dear diary today was');
  });

  testWidgets('Done makes the text editable and Insert returns it', (
    tester,
  ) async {
    await openSheet(tester);
    engine.finalResult('Dear diary');
    await tester.pump();

    await tester.tap(find.byKey(const Key('dictation-done')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('dictation-text-field')), findsOneWidget);
    await tester.enterText(
      find.byKey(const Key('dictation-text-field')),
      'Dear diary, hello',
    );
    await tester.tap(find.byKey(const Key('dictation-insert')));
    await tester.pumpAndSettle();

    expect(sheetClosed, isTrue);
    expect(sheetResult, 'Dear diary, hello');
  });

  testWidgets('Discard returns nothing', (tester) async {
    await openSheet(tester);
    engine.finalResult('not wanted');
    await tester.pump();

    await tester.tap(find.byKey(const Key('dictation-discard')));
    await tester.pumpAndSettle();

    expect(sheetClosed, isTrue);
    expect(sheetResult, isNull);
    expect(engine.cancelCalls, 1);
  });

  testWidgets('explains when offline recognition is unavailable', (
    tester,
  ) async {
    engine.status = OnDeviceSpeechStatus.unavailable;
    await openSheet(tester);

    expect(find.byKey(const Key('dictation-error')), findsOneWidget);
    expect(engine.listenLocales, isEmpty);

    await tester.tap(find.byKey(const Key('dictation-close')));
    await tester.pumpAndSettle();
    expect(sheetResult, isNull);
  });

  testWidgets('pause button stops and resumes listening', (tester) async {
    await openSheet(tester);

    await tester.tap(find.byKey(const Key('dictation-pause-toggle')));
    await tester.pump();
    expect(engine.stopCalls, 1);
    expect(find.byTooltip('Resume'), findsOneWidget);

    await tester.tap(find.byKey(const Key('dictation-pause-toggle')));
    await tester.pump();
    expect(engine.listenLocales, hasLength(2));
    expect(find.byTooltip('Pause'), findsOneWidget);
  });
}
