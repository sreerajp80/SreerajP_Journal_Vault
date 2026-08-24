import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/features/ritual/domain/ritual_card.dart';
import 'package:sreerajp_journal_vault/features/ritual/domain/spaced_repetition.dart';

/// Breathing techniques available in Ritual Mode.
enum BreathTechnique {
  /// 4s Inhale - 4s Hold - 4s Exhale - 4s Hold (Classic Box Breathing)
  boxBreathing,

  /// 4s Inhale - 7s Hold - 8s Exhale (Relaxing Pranayama)
  relaxing478,

  /// 4s Inhale - 4s Exhale (Simple Calm)
  simpleCalm,
}

extension BreathTechniqueExt on BreathTechnique {
  String get displayName {
    switch (this) {
      case BreathTechnique.boxBreathing:
        return 'Box Breathing (4-4-4-4)';
      case BreathTechnique.relaxing478:
        return 'Relaxing Breath (4-7-8)';
      case BreathTechnique.simpleCalm:
        return 'Calm Rhythm (4-4)';
    }
  }

  int get inhaleSeconds => 4;

  int get holdInhaleSeconds {
    switch (this) {
      case BreathTechnique.boxBreathing:
        return 4;
      case BreathTechnique.relaxing478:
        return 7;
      case BreathTechnique.simpleCalm:
        return 0;
    }
  }

  int get exhaleSeconds {
    switch (this) {
      case BreathTechnique.boxBreathing:
        return 4;
      case BreathTechnique.relaxing478:
        return 8;
      case BreathTechnique.simpleCalm:
        return 4;
    }
  }

  int get holdExhaleSeconds {
    switch (this) {
      case BreathTechnique.boxBreathing:
        return 4;
      case BreathTechnique.relaxing478:
        return 0;
      case BreathTechnique.simpleCalm:
        return 0;
    }
  }

  int get cycleDurationSeconds =>
      inhaleSeconds + holdInhaleSeconds + exhaleSeconds + holdExhaleSeconds;
}

/// Service managing Ritual practice state, Spaced Repetition queue, and user preferences.
class RitualService {
  static const String _keyPrefix = 'ritual_card_srs_';
  static const String _prefLaunchOnStartup = 'ritual_launch_on_startup';
  static const String _prefBreathTechnique = 'ritual_breath_technique';
  static const String _prefBreathCycles = 'ritual_breath_cycles';

  final SharedPreferences _prefs;
  final UserRitualCardsDao? _userCardsDao;

  RitualService(this._prefs, [this._userCardsDao]);

  /// Returns all 50 curated Sanathana Dharma reflection cards.
  List<RitualCard> getCuratedCards() => RitualCard.curatedDeck;

  /// Returns all cards — curated deck + user-created cards.
  ///
  /// User-created cards are appended after the curated deck,
  /// numbered starting from 51.
  Future<List<RitualCard>> getAllCards() async {
    final curated = getCuratedCards();
    final userCards = await getUserCards();
    return [...curated, ...userCards];
  }

  /// Returns all cards synchronously (curated only, no DB call).
  ///
  /// Use [getAllCards] when you need user cards as well.
  List<RitualCard> getAllCardsSynchronous() => getCuratedCards();

  /// Converts database rows to [RitualCard] instances.
  List<RitualCard> _convertUserCards(List<UserRitualCard> dbCards) {
    final curatedCount = RitualCard.curatedDeck.length;
    return dbCards.asMap().entries.map((entry) {
      final idx = entry.key;
      final row = entry.value;
      return RitualCard(
        id: 'user_card_${row.id}',
        number: curatedCount + idx + 1,
        theme: _parseTheme(row.theme),
        title: row.title,
        prompt: row.prompt,
        quote: row.quote,
        quoteAuthor: row.quoteAuthor,
        isUserCreated: true,
        dbId: row.id,
      );
    }).toList();
  }

  /// Returns only user-created cards from the database.
  Future<List<RitualCard>> getUserCards() async {
    if (_userCardsDao == null) return [];
    final dbCards = await _userCardsDao.getAllCards();
    return _convertUserCards(dbCards);
  }

  /// Watches user-created cards from the database as a stream.
  Stream<List<RitualCard>> watchUserCards() {
    if (_userCardsDao == null) return const Stream.empty();
    return _userCardsDao.watchAllCards().map(_convertUserCards);
  }

  /// Creates a new user ritual card in the database.
  Future<int> addUserCard({
    required RitualTheme theme,
    required String title,
    required String prompt,
    required String quote,
    String? quoteAuthor,
  }) async {
    if (_userCardsDao == null) {
      throw StateError('User cards DAO not available');
    }
    return _userCardsDao.createCard(
      UserRitualCardsCompanion.insert(
        theme: theme.name,
        title: title,
        prompt: prompt,
        quote: quote,
        quoteAuthor: Value(quoteAuthor),
      ),
    );
  }

  /// Updates an existing user ritual card.
  Future<void> updateUserCard({
    required int id,
    required RitualTheme theme,
    required String title,
    required String prompt,
    required String quote,
    String? quoteAuthor,
  }) async {
    if (_userCardsDao == null) {
      throw StateError('User cards DAO not available');
    }
    await _userCardsDao.updateCard(
      id,
      UserRitualCardsCompanion(
        theme: Value(theme.name),
        title: Value(title),
        prompt: Value(prompt),
        quote: Value(quote),
        quoteAuthor: Value(quoteAuthor),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Deletes a user-created card from the database.
  Future<void> deleteUserCard(int id) async {
    if (_userCardsDao == null) {
      throw StateError('User cards DAO not available');
    }
    await _userCardsDao.deleteCard(id);
    // Also clean up SRS data for this card.
    await _prefs.remove('${_keyPrefix}user_card_$id');
  }

  /// Parses a theme name back to a [RitualTheme] enum value.
  static RitualTheme _parseTheme(String name) {
    return RitualTheme.values.firstWhere(
      (t) => t.name == name,
      orElse: () => RitualTheme.dharma,
    );
  }

  /// Loads the review state for a single card by its ID.
  CardReviewState getReviewState(String cardId) {
    final raw = _prefs.getString('$_keyPrefix$cardId');
    if (raw == null) {
      return CardReviewState.initial(cardId);
    }
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return CardReviewState.fromJson(map);
    } catch (_) {
      return CardReviewState.initial(cardId);
    }
  }

  /// Saves the review state for a single card.
  Future<void> saveReviewState(CardReviewState state) async {
    final raw = jsonEncode(state.toJson());
    await _prefs.setString('$_keyPrefix${state.cardId}', raw);
  }

  /// Records a rating for a card and updates its spaced repetition interval.
  Future<CardReviewState> rateCard(
    String cardId,
    RepetitionRating rating,
  ) async {
    final current = getReviewState(cardId);
    final updated = current.applyRating(rating);
    await saveReviewState(updated);
    return updated;
  }

  /// Selects the recommended card for today's ritual practice.
  ///
  /// Priority:
  /// 1. Cards that are currently due/overdue for spaced repetition review.
  /// 2. Cards that have never been reviewed yet (sorted by card number).
  /// 3. Cards with the oldest `lastReviewedAt` date.
  ///
  /// Uses the curated deck only (synchronous). To include user cards,
  /// call [getTodayCardFromPool] with the full card list.
  RitualCard getTodayCard([DateTime? now]) {
    return getTodayCardFromPool(getCuratedCards(), now);
  }

  /// Selects the recommended card from a given pool of cards.
  RitualCard getTodayCardFromPool(List<RitualCard> pool, [DateTime? now]) {
    if (pool.isEmpty) return RitualCard.curatedDeck.first;
    final currentTime = now ?? DateTime.now();
    final List<({RitualCard card, CardReviewState state})> items = pool
        .map((c) => (card: c, state: getReviewState(c.id)))
        .toList();

    // 1. Due cards
    final dueCards = items.where((i) => i.state.isDue(currentTime)).toList();
    if (dueCards.isNotEmpty) {
      // Prioritize unreviewed cards first, then oldest last reviewed, tie-breaking by card number
      dueCards.sort((a, b) {
        if (a.state.reviewCount == 0 && b.state.reviewCount > 0) return -1;
        if (b.state.reviewCount == 0 && a.state.reviewCount > 0) return 1;
        final aTime =
            a.state.lastReviewedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bTime =
            b.state.lastReviewedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final timeComp = aTime.compareTo(bTime);
        if (timeComp != 0) return timeComp;
        return a.card.number.compareTo(b.card.number);
      });
      return dueCards.first.card;
    }

    // 2. Unreviewed cards
    final unreviewed = items.where((i) => i.state.reviewCount == 0).toList();
    if (unreviewed.isNotEmpty) {
      unreviewed.sort((a, b) => a.card.number.compareTo(b.card.number));
      return unreviewed.first.card;
    }

    // 3. Oldest review date
    items.sort((a, b) {
      final aTime =
          a.state.lastReviewedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bTime =
          b.state.lastReviewedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final timeComp = aTime.compareTo(bTime);
      if (timeComp != 0) return timeComp;
      return a.card.number.compareTo(b.card.number);
    });

    return items.first.card;
  }

  /// Returns whether the user has enabled automatic Ritual Mode on app startup.
  bool getLaunchOnStartup() => _prefs.getBool(_prefLaunchOnStartup) ?? false;

  /// Sets whether Ritual Mode should launch on app startup.
  Future<void> setLaunchOnStartup(bool value) =>
      _prefs.setBool(_prefLaunchOnStartup, value);

  /// Returns the configured breathing technique.
  BreathTechnique getBreathTechnique() {
    final index = _prefs.getInt(_prefBreathTechnique);
    if (index != null && index >= 0 && index < BreathTechnique.values.length) {
      return BreathTechnique.values[index];
    }
    return BreathTechnique.boxBreathing;
  }

  /// Sets the preferred breathing technique.
  Future<void> setBreathTechnique(BreathTechnique technique) =>
      _prefs.setInt(_prefBreathTechnique, technique.index);

  /// Returns the configured number of breathing cycles (default: 2 cycles).
  int getBreathCycles() => _prefs.getInt(_prefBreathCycles) ?? 2;

  /// Sets the configured number of breathing cycles (1 to 5).
  Future<void> setBreathCycles(int cycles) =>
      _prefs.setInt(_prefBreathCycles, cycles.clamp(1, 5));

  /// Resets review history for all curated cards.
  Future<void> resetAllCardReviews() async {
    for (final card in getCuratedCards()) {
      await _prefs.remove('$_keyPrefix${card.id}');
    }
    // Also reset user card reviews.
    final userCards = await getUserCards();
    for (final card in userCards) {
      await _prefs.remove('$_keyPrefix${card.id}');
    }
  }
}
