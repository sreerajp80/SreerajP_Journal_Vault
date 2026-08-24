import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sreerajp_journal_vault/features/features_catalog/presentation/features_screen.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

Widget _wrap(Widget child) {
  return ProviderScope(
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
  testWidgets(
    'FeaturesScreen renders header card and all categories with tiles',
    (tester) async {
      tester.view.physicalSize = const Size(800, 5000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_wrap(const FeaturesScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Features'), findsOneWidget);
      expect(find.text('SreerajP Journal Vault Features'), findsOneWidget);
      expect(find.text('JOURNALING & RICH TEXT EDITOR'), findsOneWidget);
      expect(find.text('PRIVACY, ENCRYPTION & VAULT SECURITY'), findsOneWidget);
      expect(find.text('SEARCH, TIMELINE & INSIGHTS'), findsOneWidget);
      expect(
        find.text('STORAGE, BACKUPS & MULTI-FORMAT EXPORT'),
        findsOneWidget,
      );

      expect(find.text('Quill Rich Text Editor'), findsOneWidget);
      expect(
        find.text('SQLCipher AES-256 Database Encryption'),
        findsOneWidget,
      );
      expect(find.text('Lightning SQLite FTS Search'), findsOneWidget);
      expect(
        find.text('100% Offline & Zero Network Permission'),
        findsOneWidget,
      );
    },
  );
}
