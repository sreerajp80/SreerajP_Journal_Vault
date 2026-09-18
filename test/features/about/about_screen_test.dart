import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_journal_vault/core/config/config_service.dart';
import 'package:sreerajp_journal_vault/core/constants/build_date.g.dart';
import 'package:sreerajp_journal_vault/core/l10n/app_locales.dart';
import 'package:sreerajp_journal_vault/features/about/application/about_metadata.dart';
import 'package:sreerajp_journal_vault/features/about/presentation/about_screen.dart';
import 'package:sreerajp_journal_vault/features/about/presentation/made_with_love.dart';

void main() {
  Widget wrap(ConfigService service, {Locale locale = const Locale('en')}) {
    return ProviderScope(
      overrides: [configServiceProvider.overrideWithValue(service)],
      child: MaterialApp(
        locale: locale,
        localizationsDelegates: appLocalizationsDelegates,
        supportedLocales: appSupportedLocales,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          useMaterial3: true,
        ),
        home: const AboutScreen(),
      ),
    );
  }

  const json = '''
{
  "appName": "Test Vault",
  "description": {
    "en": "A test description.",
    "ml": "ഒരു പരീക്ഷണ വിവരണം.",
    "sa": "परीक्षावर्णनम्।"
  },
  "version": "2.3.4",
  "build": "9",
  "details": {
    "author": "Test Author",
    "customRow": "Custom Value"
  }
}
''';

  testWidgets('about renders every details row from config, in file order', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(wrap(ConfigService(loadAsset: (_) async => json)));
    await tester.pumpAndSettle();

    expect(find.text('Test Vault'), findsOneWidget);
    expect(find.text('A test description.'), findsOneWidget);
    expect(find.text('2.3.4 (build 9)'), findsOneWidget);

    // A known key gets its translated label; an unknown key still renders,
    // under its raw name — the loop is generic.
    expect(find.text('Author'), findsOneWidget);
    expect(find.text('Test Author'), findsOneWidget);
    expect(find.text('customRow'), findsOneWidget);
    expect(find.text('Custom Value'), findsOneWidget);

    expect(find.text(kBuildDate), findsOneWidget);
  });

  testWidgets('labels and prose follow the selected language', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        ConfigService(loadAsset: (_) async => json),
        locale: const Locale('sa'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('परीक्षावर्णनम्।'), findsOneWidget);
    expect(find.text('लेखकः'), findsOneWidget);
    // A plain value is the same in every language.
    expect(find.text('Test Author'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('about ends with the Made with love badge', (
    WidgetTester tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(wrap(ConfigService(loadAsset: (_) async => json)));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.byType(MadeWithLove), 200);
    expect(find.byType(MadeWithLove), findsOneWidget);

    // Last child of the list, below every other row.
    final list = tester.widget<ListView>(find.byType(ListView));
    final children =
        (list.childrenDelegate as SliverChildListDelegate).children;
    final last = children.last;
    expect(last, isA<SafeArea>());
    expect((last as SafeArea).child, isA<MadeWithLove>());

    // Screen readers hear words, not an emoji name; the heart is an icon.
    expect(find.bySemanticsLabel('Made with love from India'), findsOneWidget);
    final heart = tester.widget<Icon>(
      find.descendant(
        of: find.byType(MadeWithLove),
        matching: find.byIcon(Icons.favorite),
      ),
    );
    expect(heart.color, const Color(0xFFE53935));
    semantics.dispose();
  });

  testWidgets('badge wording keeps the heart in Malayalam and Sanskrit', (
    WidgetTester tester,
  ) async {
    for (final locale in const [Locale('ml'), Locale('sa')]) {
      await tester.pumpWidget(
        wrap(ConfigService(loadAsset: (_) async => json), locale: locale),
      );
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.byType(MadeWithLove), 200);
      expect(
        find.descendant(
          of: find.byType(MadeWithLove),
          matching: find.byIcon(Icons.favorite),
        ),
        findsOneWidget,
      );
    }
  });

  testWidgets('about skips rows with a blank key or value', (
    WidgetTester tester,
  ) async {
    const blanks = '''
{
  "appName": "Test Vault",
  "description": "",
  "version": "1.0.0",
  "build": "1",
  "details": {
    "kept": "yes",
    "   ": "orphan value",
    "orphanKey": "  "
  }
}
''';

    await tester.pumpWidget(
      wrap(ConfigService(loadAsset: (_) async => blanks)),
    );
    await tester.pumpAndSettle();

    expect(find.text('kept'), findsOneWidget);
    expect(find.text('orphan value'), findsNothing);
    expect(find.text('orphanKey'), findsNothing);
  });

  testWidgets(
    'about falls back instead of erroring when the asset is missing',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        wrap(
          ConfigService(
            loadAsset: (_) async => throw StateError('asset missing'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // A missing config must never show the error state — ConfigService
      // degrades to AppConfig.fallback, so the screen still renders.
      expect(find.text('Unable to load app metadata'), findsNothing);
      expect(find.text('SreerajP Journal Vault'), findsOneWidget);
      expect(find.text('0.0.0 (build 0)'), findsOneWidget);
    },
  );
}
