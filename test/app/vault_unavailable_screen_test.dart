import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_journal_vault/app/vault_unavailable_app.dart';
import 'package:sreerajp_journal_vault/core/database/database_open_failure.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

/// The screen shown when the encrypted vault will not open.
///
/// The point of these tests is what the screen must *not* do: offer any way to
/// delete, reset, or start a fresh vault. At this moment the app cannot tell a
/// lost key from a temporary fault, and the wrong button here destroys a
/// journal that might still be recoverable.
void main() {
  Future<void> pumpFor(
    WidgetTester tester,
    DatabaseOpenFailureKind kind,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: VaultUnavailableScreen(failure: DatabaseOpenFailure(kind)),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('explains a lost key and promises nothing was deleted', (
    tester,
  ) async {
    await pumpFor(tester, DatabaseOpenFailureKind.keyUnavailable);

    expect(find.text('Vault unavailable'), findsOneWidget);
    expect(
      find.textContaining('key that unlocks your journal'),
      findsOneWidget,
    );
    expect(find.textContaining('Nothing has been deleted'), findsOneWidget);
  });

  testWidgets('gives each failure its own reason', (tester) async {
    await pumpFor(tester, DatabaseOpenFailureKind.conversionFailed);
    expect(find.textContaining('left exactly as it was'), findsOneWidget);

    await pumpFor(tester, DatabaseOpenFailureKind.cipherUnavailable);
    expect(find.textContaining('cannot encrypt the vault'), findsOneWidget);

    await pumpFor(tester, DatabaseOpenFailureKind.openFailed);
    expect(find.textContaining('cannot be read'), findsOneWidget);
  });

  testWidgets('offers nothing to press', (tester) async {
    await pumpFor(tester, DatabaseOpenFailureKind.keyUnavailable);

    expect(find.byType(ElevatedButton), findsNothing);
    expect(find.byType(TextButton), findsNothing);
    expect(find.byType(OutlinedButton), findsNothing);
    expect(find.byType(FloatingActionButton), findsNothing);
  });
}
