import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

void main() {
  group('AppLocalizations Localization & Bilingual Support', () {
    test('supportedLocales includes both en and ml', () {
      const locales = AppLocalizations.supportedLocales;
      expect(locales, contains(const Locale('en')));
      expect(locales, contains(const Locale('ml')));
    });

    test('English translations load correctly', () async {
      final l10n = await AppLocalizations.delegate.load(const Locale('en'));
      expect(l10n.appTitle, 'SreerajP Journal Vault');
      expect(l10n.commonCancel, 'Cancel');
      expect(l10n.drawingStrokeFine, 'Fine (2px)');
      expect(l10n.drawingDefaultTitle, 'Drawing');
      expect(l10n.imageDefaultTitle, 'Image');
      expect(l10n.audioPauseTooltip, 'Pause');
      expect(l10n.audioPlayTooltip, 'Play');
      expect(l10n.importIntoJournal('My Journal'), 'Import into "My Journal"');
      expect(l10n.helpTopicJournalOrg, 'Journal Organization & Templates');
      expect(l10n.featuresCategoryJournaling, 'Journaling & Rich Text Editor');
    });

    test(
      'Malayalam translations load correctly and match vocabulary',
      () async {
        final l10n = await AppLocalizations.delegate.load(const Locale('ml'));
        expect(l10n.appTitle, 'ശ്രീരാജ്‌പി ജേണൽ വോൾട്ട്');
        expect(l10n.commonCancel, 'റദ്ദാക്കുക');
        expect(l10n.drawingStrokeFine, 'നേർത്തത് (2px)');
        expect(l10n.drawingDefaultTitle, 'രേഖാചിത്രം');
        expect(l10n.imageDefaultTitle, 'ചിത്രം');
        expect(l10n.audioPauseTooltip, 'താൽക്കാലികമായി നിർത്തുക');
        expect(l10n.audioPlayTooltip, 'പ്ലേ ചെയ്യുക');
        expect(
          l10n.importIntoJournal('എന്റെ ജേണൽ'),
          '"എന്റെ ജേണൽ" എന്നതിലേക്ക് ഇംപോർട്ട് ചെയ്യുക',
        );
        expect(l10n.helpTopicJournalOrg, 'ജേണൽ ക്രമീകരണവും ടെംപ്ലേറ്റുകളും');
        expect(
          l10n.featuresCategoryJournaling,
          'എഴുത്തും റിച്ച് ടെക്സ്റ്റ് എഡിറ്ററും',
        );
      },
    );

    testWidgets('Widget renders correctly in Malayalam locale', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('ml'),
          home: Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context);
              return Scaffold(
                appBar: AppBar(title: Text(l10n.appTitle)),
                body: Center(
                  child: Column(
                    children: [
                      Text(l10n.lockGateHeadline),
                      Text(l10n.drawingStrokeFine),
                      Text(l10n.helpTopicJournalOrg),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('ശ്രീരാജ്‌പി ജേണൽ വോൾട്ട്'), findsOneWidget);
      expect(
        find.text('നിങ്ങളുടെ ജേണൽ ലോക്ക് ചെയ്തിരിക്കുന്നു'),
        findsOneWidget,
      );
      expect(find.text('നേർത്തത് (2px)'), findsOneWidget);
      expect(find.text('ജേണൽ ക്രമീകരണവും ടെംപ്ലേറ്റുകളും'), findsOneWidget);
    });
  });
}
