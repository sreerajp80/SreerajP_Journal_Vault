import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_journal_vault/features/ritual/domain/ritual_card.dart';
import 'package:sreerajp_journal_vault/features/ritual/presentation/ritual_card_text.dart';
import 'package:sreerajp_journal_vault/features/ritual/services/ritual_service.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

void main() {
  final en = lookupAppLocalizations(const Locale('en'));
  final ml = lookupAppLocalizations(const Locale('ml'));
  final sa = lookupAppLocalizations(const Locale('sa'));

  group('RitualCard localization', () {
    test(
      'all 50 curated cards have text in English, Malayalam and Sanskrit',
      () {
        expect(RitualCard.curatedDeck.length, 50);

        for (final l10n in [en, ml, sa]) {
          for (final card in RitualCard.curatedDeck) {
            final where = '${card.id} in ${l10n.localeName}';
            expect(
              card.titleIn(l10n).trim(),
              isNotEmpty,
              reason: '$where title',
            );
            expect(
              card.promptIn(l10n).trim(),
              isNotEmpty,
              reason: '$where prompt',
            );
            expect(
              card.quoteIn(l10n).trim(),
              isNotEmpty,
              reason: '$where quote',
            );
            expect(
              card.sourceIn(l10n)?.trim(),
              isNotEmpty,
              reason: '$where source',
            );
          }
        }
      },
    );

    test('translated card text differs from English', () {
      for (final card in RitualCard.curatedDeck) {
        for (final l10n in [ml, sa]) {
          expect(
            card.promptIn(l10n),
            isNot(card.promptIn(en)),
            reason: '${card.id} prompt is untranslated in ${l10n.localeName}',
          );
        }
      }
    });

    test('curated card 1 reads correctly in each language', () {
      final card = RitualCard.curatedDeck.first; // sd_01

      expect(card.titleIn(en), 'Your Swadharma');
      expect(card.promptIn(en), contains('What is the unique duty'));
      expect(card.quoteIn(en), contains('duty imperfectly'));
      expect(card.sourceIn(en), 'Bhagavad Gita 3.35');

      expect(card.titleIn(ml), 'സ്വധർമ്മം');
      expect(card.promptIn(ml), contains('നിങ്ങളുടെ ജീവിതത്തിന്റെ'));
      expect(card.sourceIn(ml), 'ഭഗവദ്ഗീത 3.35');

      expect(card.titleIn(sa), 'स्वधर्मः');
      expect(card.quoteIn(sa), startsWith('श्रेयान्स्वधर्मो'));
    });

    test(
      'user-created cards show the text the user typed in every language',
      () {
        const customCard = RitualCard(
          id: 'user_01',
          number: 51,
          theme: RitualTheme.dharma,
          title: 'My Custom Reflection',
          prompt: 'Custom prompt text',
          quote: 'Custom quote text',
          quoteAuthor: 'Anonymous',
          isUserCreated: true,
        );

        for (final l10n in [en, ml, sa]) {
          expect(customCard.titleIn(l10n), 'My Custom Reflection');
          expect(customCard.promptIn(l10n), 'Custom prompt text');
          expect(customCard.quoteIn(l10n), 'Custom quote text');
          expect(customCard.sourceIn(l10n), 'Anonymous');
        }
      },
    );

    test('RitualTheme names for all 10 themes in en, ml and sa', () {
      const expectedEn = {
        RitualTheme.dharma: 'Dharma',
        RitualTheme.karma: 'Karma',
        RitualTheme.bhakti: 'Bhakti',
        RitualTheme.jnana: 'Jnana',
        RitualTheme.yoga: 'Yoga',
        RitualTheme.ahimsa: 'Ahimsa',
        RitualTheme.sathya: 'Sathya',
        RitualTheme.vairagya: 'Vairagya',
        RitualTheme.seva: 'Seva',
        RitualTheme.shanti: 'Shanti',
      };

      const expectedMl = {
        RitualTheme.dharma: 'ധർമ്മം',
        RitualTheme.karma: 'കർമ്മം',
        RitualTheme.bhakti: 'ഭക്തി',
        RitualTheme.jnana: 'ജ്ഞാനം',
        RitualTheme.yoga: 'യോഗം',
        RitualTheme.ahimsa: 'അഹിംസ',
        RitualTheme.sathya: 'സത്യം',
        RitualTheme.vairagya: 'വൈരാഗ്യം',
        RitualTheme.seva: 'സേവനം',
        RitualTheme.shanti: 'ശാന്തി',
      };

      for (final theme in RitualTheme.values) {
        expect(theme.nameIn(en), expectedEn[theme]);
        expect(theme.nameIn(ml), expectedMl[theme]);
        expect(theme.nameIn(sa).trim(), isNotEmpty);
      }
    });

    test('breathing technique names and rhythms', () {
      expect(BreathTechnique.boxBreathing.nameIn(en), 'Box breathing');
      expect(BreathTechnique.boxBreathing.rhythm, '4-4-4-4');
      expect(BreathTechnique.relaxing478.rhythm, '4-7-8');
      expect(BreathTechnique.simpleCalm.rhythm, '4-4');
      for (final t in BreathTechnique.values) {
        expect(t.nameIn(sa), isNot(t.nameIn(en)));
      }
    });
  });
}
