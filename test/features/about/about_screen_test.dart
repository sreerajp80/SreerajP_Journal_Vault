import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_journal_vault/core/config/config_service.dart';
import 'package:sreerajp_journal_vault/features/about/application/about_metadata.dart';
import 'package:sreerajp_journal_vault/features/about/presentation/about_screen.dart';

void main() {
  Widget wrap(ConfigService service) {
    return ProviderScope(
      overrides: [configServiceProvider.overrideWithValue(service)],
      child: MaterialApp(
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          useMaterial3: true,
        ),
        home: const AboutScreen(),
      ),
    );
  }

  testWidgets('about renders every details row from config, in file order', (
    WidgetTester tester,
  ) async {
    const json = '''
{
  "appName": "Test Vault",
  "description": "A test description.",
  "version": "2.3.4",
  "build": "9",
  "details": {
    "Author": "Test Author",
    "Custom Row": "Custom Value"
  }
}
''';

    await tester.pumpWidget(
      wrap(ConfigService(loadAsset: (_) async => json)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Test Vault'), findsOneWidget);
    expect(find.text('A test description.'), findsOneWidget);
    expect(find.text('2.3.4 (build 9)'), findsOneWidget);

    // Both rows render purely because they are in the config — the screen has
    // no knowledge of either name. "Custom Row" proves the loop is generic.
    expect(find.text('Author'), findsOneWidget);
    expect(find.text('Test Author'), findsOneWidget);
    expect(find.text('Custom Row'), findsOneWidget);
    expect(find.text('Custom Value'), findsOneWidget);

    expect(find.text(missingBuildTimestampLabel), findsOneWidget);
  });

  testWidgets('about skips rows with a blank key or value', (
    WidgetTester tester,
  ) async {
    const json = '''
{
  "appName": "Test Vault",
  "description": "",
  "version": "1.0.0",
  "build": "1",
  "details": {
    "Kept": "yes",
    "   ": "orphan value",
    "Orphan Key": "  "
  }
}
''';

    await tester.pumpWidget(
      wrap(ConfigService(loadAsset: (_) async => json)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Kept'), findsOneWidget);
    expect(find.text('orphan value'), findsNothing);
    expect(find.text('Orphan Key'), findsNothing);
  });

  testWidgets('about falls back instead of erroring when the asset is missing', (
    WidgetTester tester,
  ) async {
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
    expect(find.text('SreerajP_Journal_Vault'), findsOneWidget);
    expect(find.text('0.0.0 (build 0)'), findsOneWidget);
  });
}
