import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_journal_vault/features/ritual/domain/ritual_card.dart';

void main() {
  group('RitualCard Localization', () {
    test('all 50 curated cards have valid Malayalam translations', () {
      expect(RitualCard.curatedDeck.length, 50);

      for (final card in RitualCard.curatedDeck) {
        expect(
          card.titleMl,
          isNotNull,
          reason: 'Card ${card.id} titleMl is null',
        );
        expect(
          card.titleMl!.trim(),
          isNotEmpty,
          reason: 'Card ${card.id} titleMl is empty',
        );

        expect(
          card.promptMl,
          isNotNull,
          reason: 'Card ${card.id} promptMl is null',
        );
        expect(
          card.promptMl!.trim(),
          isNotEmpty,
          reason: 'Card ${card.id} promptMl is empty',
        );

        expect(
          card.quoteMl,
          isNotNull,
          reason: 'Card ${card.id} quoteMl is null',
        );
        expect(
          card.quoteMl!.trim(),
          isNotEmpty,
          reason: 'Card ${card.id} quoteMl is empty',
        );

        expect(
          card.quoteAuthorMl,
          isNotNull,
          reason: 'Card ${card.id} quoteAuthorMl is null',
        );
        expect(
          card.quoteAuthorMl!.trim(),
          isNotEmpty,
          reason: 'Card ${card.id} quoteAuthorMl is empty',
        );
      }
    });

    test('curated cards return Malayalam when langCode is ml', () {
      final card = RitualCard.curatedDeck.first; // sd_01

      expect(card.localizedTitle('ml'), 'സ്വധർമ്മം');
      expect(card.localizedPrompt('ml'), contains('നിങ്ങളുടെ ജീവിതത്തിന്റെ'));
      expect(card.localizedQuote('ml'), contains('മറ്റൊരാളുടെ ധർമ്മം'));
      expect(card.localizedQuoteAuthor('ml'), 'ഭഗവദ്ഗീത 3.35');
    });

    test('curated cards return English when langCode is en', () {
      final card = RitualCard.curatedDeck.first; // sd_01

      expect(card.localizedTitle('en'), 'Your Swadharma');
      expect(card.localizedPrompt('en'), contains('What is the unique duty'));
      expect(card.localizedQuote('en'), contains('duty imperfectly'));
      expect(card.localizedQuoteAuthor('en'), 'Bhagavad Gita 3.35');
    });

    test('custom cards without Malayalam translation fall back to English', () {
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

      expect(customCard.localizedTitle('ml'), 'My Custom Reflection');
      expect(customCard.localizedPrompt('ml'), 'Custom prompt text');
      expect(customCard.localizedQuote('ml'), 'Custom quote text');
      expect(customCard.localizedQuoteAuthor('ml'), 'Anonymous');
    });

    test('RitualTheme localized names for all 10 themes in en and ml', () {
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
        expect(theme.localizedName('en'), expectedEn[theme]);
        expect(theme.localizedName('ml'), expectedMl[theme]);
      }
    });
  });
}
