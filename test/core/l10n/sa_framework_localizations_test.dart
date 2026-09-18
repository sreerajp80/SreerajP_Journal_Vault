import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sreerajp_journal_vault/core/l10n/app_locales.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

// Engineering standard §8.3.1: Flutter ships no Sanskrit framework strings, so
// this is the most likely Sanskrit runtime failure. Pump under `sa`, open a
// date picker and a dialog, and expect no exception.
void main() {
  Widget app(Widget home) => MaterialApp(
    locale: const Locale('sa'),
    localizationsDelegates: appLocalizationsDelegates,
    supportedLocales: appSupportedLocales,
    home: home,
  );

  testWidgets('Sanskrit locale loads app strings and framework strings', (
    tester,
  ) async {
    late BuildContext captured;
    await tester.pumpWidget(
      app(
        Builder(
          builder: (context) {
            captured = context;
            return const Scaffold();
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(Localizations.localeOf(captured), const Locale('sa'));
    expect(AppLocalizations.of(captured).localeName, 'sa');
    // The framework strings come from the English fallback.
    expect(MaterialLocalizations.of(captured).okButtonLabel, 'OK');
    expect(tester.takeException(), isNull);
  });

  testWidgets('date picker opens under Sanskrit without throwing', (
    tester,
  ) async {
    await tester.pumpWidget(
      app(
        Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => showDatePicker(
                context: context,
                initialDate: DateTime(2026, 9, 15),
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.byType(DatePickerDialog), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('alert dialog opens under Sanskrit without throwing', (
    tester,
  ) async {
    await tester.pumpWidget(
      app(
        Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => showDialog<void>(
                context: context,
                builder: (_) => const AlertDialog(content: Text('body')),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
