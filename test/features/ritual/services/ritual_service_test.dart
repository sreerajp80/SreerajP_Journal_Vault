import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/features/ritual/domain/ritual_card.dart';
import 'package:sreerajp_journal_vault/features/ritual/domain/spaced_repetition.dart';
import 'package:sreerajp_journal_vault/features/ritual/services/ritual_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('RitualCard & Deck', () {
    test(
      'contains exactly 50 curated Sanathana Dharma reflection cards across all 10 themes',
      () {
        const deck = RitualCard.curatedDeck;
        expect(deck.length, 50);

        final themes = deck.map((c) => c.theme).toSet();
        expect(themes.length, 10);
        for (final t in RitualTheme.values) {
          expect(themes.contains(t), isTrue);
        }
      },
    );

    test('each card has unique id and valid metadata', () {
      const deck = RitualCard.curatedDeck;
      final ids = deck.map((c) => c.id).toSet();
      expect(ids.length, 50);

      for (final card in deck) {
        expect(card.title.isNotEmpty, isTrue);
        expect(card.prompt.isNotEmpty, isTrue);
        expect(card.quote.isNotEmpty, isTrue);
        expect(card.number >= 1 && card.number <= 50, isTrue);
        expect(card.id.startsWith('sd_'), isTrue);
      }
    });
  });

  group('Spaced Repetition Engine', () {
    final now = DateTime(2026, 8, 24);

    test('initial card state is due immediately', () {
      final initial = CardReviewState.initial('sd_01', now);
      expect(initial.repetitionLevel, 0);
      expect(initial.reviewCount, 0);
      expect(initial.lastReviewedAt, isNull);
      expect(initial.isDue(now), isTrue);
    });

    test('Hard rating resets level and schedules next review in 1 day', () {
      final state = CardReviewState(
        cardId: 'sd_01',
        repetitionLevel: 3,
        reviewCount: 5,
        lastReviewedAt: now.subtract(const Duration(days: 10)),
        nextReviewDate: now,
      );

      final next = state.applyRating(RepetitionRating.hard, now);
      expect(next.repetitionLevel, 0);
      expect(next.reviewCount, 6);
      expect(next.nextReviewDate, DateTime(2026, 8, 25));
    });

    test('Revision rating keeps level and schedules next review in 3 days', () {
      final state = CardReviewState(
        cardId: 'sd_01',
        repetitionLevel: 2,
        reviewCount: 3,
        lastReviewedAt: now.subtract(const Duration(days: 4)),
        nextReviewDate: now,
      );

      final next = state.applyRating(RepetitionRating.revision, now);
      expect(next.repetitionLevel, 2);
      expect(next.reviewCount, 4);
      expect(next.nextReviewDate, DateTime(2026, 8, 27));
    });

    test(
      'Easy rating increases level and scales interval by 7 * level days',
      () {
        final state = CardReviewState(
          cardId: 'sd_01',
          reviewCount: 1,
          lastReviewedAt: now.subtract(const Duration(days: 1)),
          nextReviewDate: now,
        );

        // Level 0 -> Level 1 -> interval = 7 days
        final level1 = state.applyRating(RepetitionRating.easy, now);
        expect(level1.repetitionLevel, 1);
        expect(level1.nextReviewDate, DateTime(2026, 8, 31));

        // Level 1 -> Level 2 -> interval = 14 days
        final level2 = level1.applyRating(
          RepetitionRating.easy,
          DateTime(2026, 8, 31),
        );
        expect(level2.repetitionLevel, 2);
        expect(level2.nextReviewDate, DateTime(2026, 9, 14));
      },
    );

    test('JSON serialization round trip', () {
      final original = CardReviewState(
        cardId: 'sd_05',
        repetitionLevel: 2,
        reviewCount: 4,
        lastReviewedAt: now,
        nextReviewDate: now.add(const Duration(days: 14)),
      );

      final json = original.toJson();
      final restored = CardReviewState.fromJson(json);

      expect(restored.cardId, original.cardId);
      expect(restored.repetitionLevel, original.repetitionLevel);
      expect(restored.reviewCount, original.reviewCount);
      expect(restored.nextReviewDate, original.nextReviewDate);
    });
  });

  group('RitualService', () {
    late SharedPreferences prefs;
    late AppDatabase db;
    late RitualService service;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      db = AppDatabase.forExecutor(NativeDatabase.memory());
      service = RitualService(prefs, db.userRitualCardsDao);
    });

    tearDown(() async {
      await db.close();
    });

    test('getTodayCard returns unreviewed card first', () {
      final todayCard = service.getTodayCard();
      expect(todayCard.id, 'sd_01');
    });

    test(
      'rateCard persists updated SRS state and rotates today card',
      () async {
        final todayCard = service.getTodayCard();
        expect(todayCard.id, 'sd_01');

        await service.rateCard(todayCard.id, RepetitionRating.easy);

        final state = service.getReviewState(todayCard.id);
        expect(state.repetitionLevel, 1);
        expect(state.reviewCount, 1);

        // Now today's card should be the next unreviewed card
        final nextToday = service.getTodayCard();
        expect(nextToday.id, 'sd_02');
      },
    );

    test('breath technique and settings management', () async {
      expect(service.getBreathTechnique(), BreathTechnique.boxBreathing);
      expect(service.getBreathCycles(), 2);
      expect(service.getLaunchOnStartup(), isFalse);

      await service.setBreathTechnique(BreathTechnique.relaxing478);
      await service.setBreathCycles(4);
      await service.setLaunchOnStartup(true);

      expect(service.getBreathTechnique(), BreathTechnique.relaxing478);
      expect(service.getBreathCycles(), 4);
      expect(service.getLaunchOnStartup(), isTrue);
    });

    test('resetAllCardReviews clears all SRS states', () async {
      await service.rateCard('sd_01', RepetitionRating.easy);
      await service.rateCard('sd_02', RepetitionRating.hard);

      expect(service.getReviewState('sd_01').reviewCount, 1);
      expect(service.getReviewState('sd_02').reviewCount, 1);

      await service.resetAllCardReviews();

      expect(service.getReviewState('sd_01').reviewCount, 0);
      expect(service.getReviewState('sd_02').reviewCount, 0);
    });

    test('user card CRUD and merged deck', () async {
      final initialCards = await service.getAllCards();
      expect(initialCards.length, 50);

      // Create a user card
      final cardId = await service.addUserCard(
        theme: RitualTheme.jnana,
        title: 'Atma Jnana Reflection',
        prompt: 'How are you practicing self inquiry today?',
        quote: 'Prajnanam Brahma',
        quoteAuthor: 'Aitareya Upanishad',
      );

      final userCards = await service.getUserCards();
      expect(userCards.length, 1);
      expect(userCards.first.title, 'Atma Jnana Reflection');
      expect(userCards.first.theme, RitualTheme.jnana);
      expect(userCards.first.isUserCreated, isTrue);
      expect(userCards.first.number, 51);
      expect(userCards.first.dbId, cardId);

      final mergedCards = await service.getAllCards();
      expect(mergedCards.length, 51);
      expect(mergedCards.last.title, 'Atma Jnana Reflection');

      // Update user card
      await service.updateUserCard(
        id: cardId,
        theme: RitualTheme.bhakti,
        title: 'Bhakti Yoga Reflection',
        prompt: 'Updated prompt',
        quote: 'Updated quote',
        quoteAuthor: 'Gita',
      );

      final updatedUserCards = await service.getUserCards();
      expect(updatedUserCards.first.title, 'Bhakti Yoga Reflection');
      expect(updatedUserCards.first.theme, RitualTheme.bhakti);

      // Delete user card
      await service.deleteUserCard(cardId);
      final afterDelete = await service.getUserCards();
      expect(afterDelete.isEmpty, isTrue);

      final afterDeleteMerged = await service.getAllCards();
      expect(afterDeleteMerged.length, 50);
    });
  });
}
