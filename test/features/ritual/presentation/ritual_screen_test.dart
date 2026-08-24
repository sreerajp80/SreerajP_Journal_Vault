import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/core/database/database_providers.dart';
import 'package:sreerajp_journal_vault/features/ritual/presentation/create_ritual_card_screen.dart';
import 'package:sreerajp_journal_vault/features/ritual/presentation/ritual_deck_screen.dart';
import 'package:sreerajp_journal_vault/features/ritual/presentation/ritual_screen.dart';
import 'package:sreerajp_journal_vault/features/ritual/providers/ritual_providers.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

Widget _wrapWithScope(
  Widget child, {
  required SharedPreferences prefs,
  required AppDatabase db,
}) {
  return ProviderScope(
    overrides: [
      ritualSharedPrefsProvider.overrideWithValue(prefs),
      appDatabaseProvider.overrideWithValue(db),
    ],
    child: MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        FlutterQuillLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences prefs;
  late AppDatabase db;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    db = AppDatabase.forExecutor(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  testWidgets(
    'RitualScreen renders Step 1 Breathe and navigates to Step 2 Reflect',
    (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _wrapWithScope(const RitualScreen(), prefs: prefs, db: db),
      );
      await tester.pumpAndSettle();

      // Verify AppBar and progress indicator
      expect(find.text('Ritual Practice'), findsOneWidget);
      expect(find.text('Breathe'), findsOneWidget);
      expect(find.text('Reflect'), findsOneWidget);
      expect(find.text('Write'), findsOneWidget);

      // Verify Breathing step components
      expect(find.text('Centering Breath'), findsOneWidget);
      expect(find.text('Skip to Prompt'), findsOneWidget);

      // Tap 'Skip to Prompt' to jump to Step 2 (Reflect)
      await tester.tap(find.text('Skip to Prompt'));
      await tester.pumpAndSettle();

      // Verify Sanathana Dharma Reflection Card components
      expect(find.text('DHARMA'), findsOneWidget);
      expect(find.text('Your Swadharma'), findsOneWidget);
      expect(find.text('Shuffle'), findsOneWidget);

      // Verify SRS rating buttons
      expect(find.text('Hard'), findsOneWidget);
      expect(find.text('Revision'), findsOneWidget);
      expect(find.text('Easy'), findsOneWidget);

      // Rate card as Easy
      await tester.tap(find.text('Easy'));
      await tester.pumpAndSettle();

      // Tap 'Proceed to Journal'
      final proceedBtn = find.text('Proceed to Journal');
      await tester.ensureVisible(proceedBtn);
      await tester.tap(proceedBtn);
      await tester.pumpAndSettle();

      // Verify Step 3 Journal components
      expect(find.text('Ready to Reflect'), findsOneWidget);
      expect(find.text('Begin Journaling'), findsOneWidget);
      expect(find.text('Complete Practice Only'), findsOneWidget);
    },
  );

  testWidgets('RitualDeckScreen renders all cards and filters by theme', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      _wrapWithScope(const RitualDeckScreen(), prefs: prefs, db: db),
    );
    await tester.pumpAndSettle();

    expect(find.text('Reflection Deck'), findsOneWidget);
    expect(find.text('All Themes'), findsOneWidget);
    expect(find.text('Dharma'), findsOneWidget);
    expect(find.text('Karma'), findsOneWidget);
    expect(find.text('Bhakti'), findsOneWidget);

    // Filter by Karma
    await tester.tap(find.text('Karma'));
    await tester.pumpAndSettle();

    expect(find.text('Action Without Attachment'), findsOneWidget);
    expect(find.text('Nishkama Karma'), findsOneWidget);
  });

  testWidgets('CreateRitualCardScreen validates input and creates card', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      _wrapWithScope(const CreateRitualCardScreen(), prefs: prefs, db: db),
    );
    await tester.pumpAndSettle();

    expect(find.text('Create Card'), findsNWidgets(2)); // AppBar + button
    expect(find.text('Theme'), findsOneWidget);

    // Try saving empty form
    final saveBtn = find.widgetWithText(FilledButton, 'Create Card');
    await tester.ensureVisible(saveBtn);
    await tester.tap(saveBtn);
    await tester.pumpAndSettle();

    expect(find.text('A title is required.'), findsOneWidget);

    // Fill form
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Title'),
      'My Dharmic Insight',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Reflection Question'),
      'How am I living truth today?',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Teaching or Quote'),
      'Satyam Vada, Dharmam Chara',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Source (optional)'),
      'Taittiriya Upanishad',
    );

    // Scroll to save button and tap
    await tester.ensureVisible(saveBtn);
    await tester.tap(saveBtn);
    await tester.pumpAndSettle();

    // Verify card in database
    final cards = await db.userRitualCardsDao.getAllCards();
    expect(cards.length, 1);
    expect(cards.first.title, 'My Dharmic Insight');
  });
}
