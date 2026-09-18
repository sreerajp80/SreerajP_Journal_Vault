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
      expect(l10n.titleApp, 'SreerajP Journal Vault');
      expect(l10n.actionCommonCancel, 'Cancel');
      expect(l10n.labelDrawingStrokeFine, 'Fine (2px)');
      expect(l10n.titleDrawingDefault, 'Drawing');
      expect(l10n.titleImageDefault, 'Image');
      expect(l10n.tooltipAudioPause, 'Pause');
      expect(l10n.tooltipAudioPlay, 'Play');
      expect(
        l10n.titleImportIntoJournal('My Journal'),
        'Import into "My Journal"',
      );
      expect(l10n.helpTopicJournalOrg, 'Journal Organization & Templates');
      expect(
        l10n.labelFeaturesCategoryJournaling,
        'Journaling & Rich Text Editor',
      );
    });

    test(
      'Malayalam translations load correctly and match vocabulary',
      () async {
        final l10n = await AppLocalizations.delegate.load(const Locale('ml'));
        expect(l10n.titleApp, 'ശ്രീരാജ്‌പി ജേണൽ വോൾട്ട്');
        expect(l10n.actionCommonCancel, 'റദ്ദാക്കുക');
        expect(l10n.labelDrawingStrokeFine, 'നേർത്തത് (2px)');
        expect(l10n.titleDrawingDefault, 'രേഖാചിത്രം');
        expect(l10n.titleImageDefault, 'ചിത്രം');
        expect(l10n.tooltipAudioPause, 'താൽക്കാലികമായി നിർത്തുക');
        expect(l10n.tooltipAudioPlay, 'പ്ലേ ചെയ്യുക');
        expect(
          l10n.titleImportIntoJournal('എന്റെ ജേണൽ'),
          '"എന്റെ ജേണൽ" എന്നതിലേക്ക് ഇംപോർട്ട് ചെയ്യുക',
        );
        expect(l10n.helpTopicJournalOrg, 'ജേണൽ ക്രമീകരണവും ടെംപ്ലേറ്റുകളും');
        expect(
          l10n.labelFeaturesCategoryJournaling,
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
                appBar: AppBar(title: Text(l10n.titleApp)),
                body: Center(
                  child: Column(
                    children: [
                      Text(l10n.labelLockGateHeadline),
                      Text(l10n.labelDrawingStrokeFine),
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
