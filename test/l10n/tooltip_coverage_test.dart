import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/core/database/database_providers.dart';
import 'package:sreerajp_journal_vault/core/l10n/app_locales.dart';
import 'package:sreerajp_journal_vault/features/export/presentation/export_screen.dart';
import 'package:sreerajp_journal_vault/features/export/providers/export_providers.dart';
import 'package:sreerajp_journal_vault/features/security/presentation/tamper_alerts_screen.dart';
import 'package:sreerajp_journal_vault/features/security/providers/security_providers.dart';
import 'package:sreerajp_journal_vault/features/security/services/security_event_service.dart';

import '../helpers/tooltip_expectations.dart';

/// Every icon-only control has a tooltip, in every shipped language.
///
/// Engineering standard §7.8. The helper is run on real screens under
/// English, Malayalam and Sanskrit, so a tooltip that exists in one language
/// but resolves to nothing in another is caught too.
void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase.forExecutor(NativeDatabase.memory());
  });

  tearDown(() async => database.close());

  Future<void> pump(WidgetTester tester, Locale locale, Widget home) async {
    await tester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          securityEventServiceProvider.overrideWithValue(
            SecurityEventService(database: database),
          ),
          tamperEventsProvider.overrideWith(
            (ref) => Stream.value(const <SecurityEvent>[]),
          ),
          pdfExportAvailableProvider.overrideWith((ref) async => true),
        ],
        child: MaterialApp(
          locale: locale,
          localizationsDelegates: appLocalizationsDelegates,
          supportedLocales: appSupportedLocales,
          home: home,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  for (final locale in appSupportedLocales) {
    group('${locale.languageCode}:', () {
      testWidgets('Tamper alerts screen', (tester) async {
        await pump(tester, locale, const TamperAlertsScreen());
        expectAllIconButtonsHaveTooltips(tester);
      });

      testWidgets('Export screen', (tester) async {
        await pump(
          tester,
          locale,
          const ExportScreen(journalId: 1, journalTitle: 'Journal'),
        );
        expectAllIconButtonsHaveTooltips(tester);
      });
    });
  }
}
