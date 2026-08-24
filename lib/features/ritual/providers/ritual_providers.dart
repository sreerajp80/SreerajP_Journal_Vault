import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sreerajp_journal_vault/core/database/database_providers.dart';
import 'package:sreerajp_journal_vault/features/ritual/domain/ritual_card.dart';
import 'package:sreerajp_journal_vault/features/ritual/domain/spaced_repetition.dart';
import 'package:sreerajp_journal_vault/features/ritual/services/ritual_service.dart';

/// Provider for SharedPreferences used across Ritual Mode.
/// Initialized with an in-memory/fallback or overridden at app root.
final ritualSharedPrefsProvider = Provider<SharedPreferences?>((ref) {
  return null;
});

/// Future provider that retrieves SharedPreferences if not already provided synchronously.
final ritualSharedPrefsFutureProvider = FutureProvider<SharedPreferences>((
  ref,
) async {
  final sync = ref.watch(ritualSharedPrefsProvider);
  if (sync != null) return sync;
  return await SharedPreferences.getInstance();
});

/// Provider for the RitualService, wired with both SharedPreferences
/// and the user ritual cards DAO.
final ritualServiceProvider = Provider<RitualService?>((ref) {
  final prefs = ref.watch(ritualSharedPrefsProvider);
  if (prefs == null) return null;
  final db = ref.watch(appDatabaseProvider);
  return RitualService(prefs, db.userRitualCardsDao);
});

/// State for the featured daily ritual card and deck status.
class RitualState {
  final RitualCard currentCard;
  final CardReviewState currentReviewState;
  final List<RitualCard> deck;
  final BreathTechnique breathTechnique;
  final int breathCycles;
  final bool launchOnStartup;
  final bool isLoading;

  const RitualState({
    required this.currentCard,
    required this.currentReviewState,
    required this.deck,
    this.breathTechnique = BreathTechnique.boxBreathing,
    this.breathCycles = 2,
    this.launchOnStartup = false,
    this.isLoading = false,
  });

  RitualState copyWith({
    RitualCard? currentCard,
    CardReviewState? currentReviewState,
    List<RitualCard>? deck,
    BreathTechnique? breathTechnique,
    int? breathCycles,
    bool? launchOnStartup,
    bool? isLoading,
  }) {
    return RitualState(
      currentCard: currentCard ?? this.currentCard,
      currentReviewState: currentReviewState ?? this.currentReviewState,
      deck: deck ?? this.deck,
      breathTechnique: breathTechnique ?? this.breathTechnique,
      breathCycles: breathCycles ?? this.breathCycles,
      launchOnStartup: launchOnStartup ?? this.launchOnStartup,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// Notifier managing Ritual Mode UI state and user interactions.
class RitualNotifier extends Notifier<RitualState> {
  @override
  RitualState build() {
    const curatedDeck = RitualCard.curatedDeck;
    final prefs = ref.watch(ritualSharedPrefsProvider);

    if (prefs != null) {
      final db = ref.watch(appDatabaseProvider);
      final service = RitualService(prefs, db.userRitualCardsDao);
      final todayCard = service.getTodayCard();
      final reviewState = service.getReviewState(todayCard.id);
      final technique = service.getBreathTechnique();
      final cycles = service.getBreathCycles();
      final launchOnStartup = service.getLaunchOnStartup();

      // Kick off async load of user cards to merge into the deck.
      Future.microtask(() => _loadUserCards(service));

      return RitualState(
        currentCard: todayCard,
        currentReviewState: reviewState,
        deck: curatedDeck,
        breathTechnique: technique,
        breathCycles: cycles,
        launchOnStartup: launchOnStartup,
      );
    }

    final initialCard = curatedDeck.first;
    Future.microtask(() => _asyncInit());
    return RitualState(
      currentCard: initialCard,
      currentReviewState: CardReviewState.initial(initialCard.id),
      deck: curatedDeck,
      isLoading: true,
    );
  }

  Future<void> _asyncInit() async {
    final prefs = await SharedPreferences.getInstance();
    final db = ref.read(appDatabaseProvider);
    final service = RitualService(prefs, db.userRitualCardsDao);
    final allCards = await service.getAllCards();
    final todayCard = service.getTodayCardFromPool(allCards);
    final reviewState = service.getReviewState(todayCard.id);
    final technique = service.getBreathTechnique();
    final cycles = service.getBreathCycles();
    final launchOnStartup = service.getLaunchOnStartup();

    state = state.copyWith(
      currentCard: todayCard,
      currentReviewState: reviewState,
      deck: allCards,
      breathTechnique: technique,
      breathCycles: cycles,
      launchOnStartup: launchOnStartup,
      isLoading: false,
    );
  }

  /// Loads user cards and merges them into the deck.
  Future<void> _loadUserCards(RitualService service) async {
    final allCards = await service.getAllCards();
    final todayCard = service.getTodayCardFromPool(allCards);
    final reviewState = service.getReviewState(todayCard.id);
    state = state.copyWith(
      deck: allCards,
      currentCard: todayCard,
      currentReviewState: reviewState,
    );
  }

  /// Reloads the full card deck (curated + user) from the database.
  Future<void> refreshDeck() async {
    final service = _getService();
    if (service == null) return;
    final allCards = await service.getAllCards();
    state = state.copyWith(deck: allCards);
  }

  /// Rates the current card and updates its SRS schedule.
  Future<void> rateCurrentCard(RepetitionRating rating) async {
    final service = await _getOrCreateService();
    final updated = await service.rateCard(state.currentCard.id, rating);
    state = state.copyWith(currentReviewState: updated);
  }

  /// Sets the active card (e.g. from the deck selector or shuffle).
  Future<void> selectCard(RitualCard card) async {
    final service = await _getOrCreateService();
    final reviewState = service.getReviewState(card.id);
    state = state.copyWith(currentCard: card, currentReviewState: reviewState);
  }

  /// Shuffles to a random card from the deck different from the current one.
  Future<void> shuffleCard() async {
    final deck = state.deck;
    if (deck.length <= 1) return;
    final others = deck.where((c) => c.id != state.currentCard.id).toList();
    others.shuffle();
    await selectCard(others.first);
  }

  /// Creates a new user ritual card.
  Future<void> addUserCard({
    required RitualTheme theme,
    required String title,
    required String prompt,
    required String quote,
    String? quoteAuthor,
  }) async {
    final service = await _getOrCreateService();
    await service.addUserCard(
      theme: theme,
      title: title,
      prompt: prompt,
      quote: quote,
      quoteAuthor: quoteAuthor,
    );
    await refreshDeck();
  }

  /// Updates an existing user ritual card.
  Future<void> updateUserCard({
    required int dbId,
    required RitualTheme theme,
    required String title,
    required String prompt,
    required String quote,
    String? quoteAuthor,
  }) async {
    final service = await _getOrCreateService();
    await service.updateUserCard(
      id: dbId,
      theme: theme,
      title: title,
      prompt: prompt,
      quote: quote,
      quoteAuthor: quoteAuthor,
    );
    await refreshDeck();
  }

  /// Deletes a user-created card.
  Future<void> deleteUserCard(int dbId) async {
    final service = await _getOrCreateService();
    await service.deleteUserCard(dbId);
    // If the deleted card was the current card, switch to today's card.
    if (state.currentCard.dbId == dbId) {
      final allCards = await service.getAllCards();
      final todayCard = service.getTodayCardFromPool(allCards);
      final reviewState = service.getReviewState(todayCard.id);
      state = state.copyWith(
        deck: allCards,
        currentCard: todayCard,
        currentReviewState: reviewState,
      );
    } else {
      await refreshDeck();
    }
  }

  /// Updates the breathing technique preference.
  Future<void> setBreathTechnique(BreathTechnique technique) async {
    final service = await _getOrCreateService();
    await service.setBreathTechnique(technique);
    state = state.copyWith(breathTechnique: technique);
  }

  /// Updates the breath cycles preference.
  Future<void> setBreathCycles(int cycles) async {
    final service = await _getOrCreateService();
    await service.setBreathCycles(cycles);
    state = state.copyWith(breathCycles: cycles);
  }

  /// Toggles whether to open in Ritual Mode on app launch.
  Future<void> setLaunchOnStartup(bool enabled) async {
    final service = await _getOrCreateService();
    await service.setLaunchOnStartup(enabled);
    state = state.copyWith(launchOnStartup: enabled);
  }

  /// Gets the service from the provider (synchronous, may be null).
  RitualService? _getService() {
    return ref.read(ritualServiceProvider);
  }

  /// Gets or creates a RitualService instance.
  Future<RitualService> _getOrCreateService() async {
    final existing = _getService();
    if (existing != null) return existing;
    final prefs = await SharedPreferences.getInstance();
    final db = ref.read(appDatabaseProvider);
    return RitualService(prefs, db.userRitualCardsDao);
  }
}

final ritualNotifierProvider = NotifierProvider<RitualNotifier, RitualState>(
  RitualNotifier.new,
);
