import 'package:flutter/material.dart';

/// Categories for reflection cards in the ritual deck, based on
/// core principles of Sanathana Dharma.
///
/// The visible name of each theme is localized in
/// `presentation/ritual_card_text.dart` — this domain type holds no UI text.
enum RitualTheme {
  dharma,
  karma,
  bhakti,
  jnana,
  yoga,
  ahimsa,
  sathya,
  vairagya,
  seva,
  shanti,
}

extension RitualThemeExt on RitualTheme {
  IconData get icon {
    switch (this) {
      case RitualTheme.dharma:
        return Icons.balance_rounded;
      case RitualTheme.karma:
        return Icons.autorenew_rounded;
      case RitualTheme.bhakti:
        return Icons.favorite_outline_rounded;
      case RitualTheme.jnana:
        return Icons.auto_stories_outlined;
      case RitualTheme.yoga:
        return Icons.self_improvement_rounded;
      case RitualTheme.ahimsa:
        return Icons.spa_outlined;
      case RitualTheme.sathya:
        return Icons.lightbulb_outline_rounded;
      case RitualTheme.vairagya:
        return Icons.eco_outlined;
      case RitualTheme.seva:
        return Icons.volunteer_activism_outlined;
      case RitualTheme.shanti:
        return Icons.water_drop_outlined;
    }
  }

  Color get accentColor {
    switch (this) {
      case RitualTheme.dharma:
        return const Color(0xFFF59E0B); // Amber — cosmic order
      case RitualTheme.karma:
        return const Color(0xFFEF4444); // Red — fire of action
      case RitualTheme.bhakti:
        return const Color(0xFFEC4899); // Pink — love and devotion
      case RitualTheme.jnana:
        return const Color(0xFF3B82F6); // Blue — ocean of knowledge
      case RitualTheme.yoga:
        return const Color(0xFF06B6D4); // Cyan — union and calm
      case RitualTheme.ahimsa:
        return const Color(0xFF10B981); // Emerald — compassion
      case RitualTheme.sathya:
        return const Color(0xFFD97706); // Deep amber — truth
      case RitualTheme.vairagya:
        return const Color(0xFF8B5CF6); // Violet — detachment
      case RitualTheme.seva:
        return const Color(0xFF14B8A6); // Teal — service
      case RitualTheme.shanti:
        return const Color(0xFF6366F1); // Indigo — peace
    }
  }
}

/// A reflection card in the Ritual Deck.
///
/// Layer: domain. Two kinds of card share this type:
///
/// * **Curated cards** (`sd_01` … `sd_50`) carry no text here. Their title,
///   prompt, quote and source are user-visible text in all three app languages,
///   so they live in `lib/l10n/*.arb` (keys `descRitualCardNN…`) and are
///   resolved per language by `presentation/ritual_card_text.dart`.
/// * **User-created cards** carry the text the user typed, stored in the
///   database, shown as written in every language.
class RitualCard {
  const RitualCard({
    required this.id,
    required this.number,
    required this.theme,
    required this.title,
    required this.prompt,
    required this.quote,
    this.quoteAuthor,
    this.isUserCreated = false,
    this.dbId,
  });

  /// A curated card. Its text comes from the ARB files.
  const RitualCard.curated({
    required this.id,
    required this.number,
    required this.theme,
  }) : title = '',
       prompt = '',
       quote = '',
       quoteAuthor = null,
       isUserCreated = false,
       dbId = null;

  final String id;
  final int number;
  final RitualTheme theme;

  /// The user's own text. Empty for curated cards.
  final String title;
  final String prompt;
  final String quote;
  final String? quoteAuthor;

  /// True if this card was created by the user (not part of the curated deck).
  final bool isUserCreated;

  /// Database row ID for user-created cards, null for curated cards.
  final int? dbId;

  /// The complete 50-card Sanathana Dharma reflection deck.
  static const List<RitualCard> curatedDeck = [
    // ────────────────────── DHARMA (1–5) ──────────────────────
    RitualCard.curated(id: 'sd_01', number: 1, theme: RitualTheme.dharma),
    RitualCard.curated(id: 'sd_02', number: 2, theme: RitualTheme.dharma),
    RitualCard.curated(id: 'sd_03', number: 3, theme: RitualTheme.dharma),
    RitualCard.curated(id: 'sd_04', number: 4, theme: RitualTheme.dharma),
    RitualCard.curated(id: 'sd_05', number: 5, theme: RitualTheme.dharma),
    // ────────────────────── KARMA (6–10) ──────────────────────
    RitualCard.curated(id: 'sd_06', number: 6, theme: RitualTheme.karma),
    RitualCard.curated(id: 'sd_07', number: 7, theme: RitualTheme.karma),
    RitualCard.curated(id: 'sd_08', number: 8, theme: RitualTheme.karma),
    RitualCard.curated(id: 'sd_09', number: 9, theme: RitualTheme.karma),
    RitualCard.curated(id: 'sd_10', number: 10, theme: RitualTheme.karma),
    // ────────────────────── BHAKTI (11–15) ──────────────────────
    RitualCard.curated(id: 'sd_11', number: 11, theme: RitualTheme.bhakti),
    RitualCard.curated(id: 'sd_12', number: 12, theme: RitualTheme.bhakti),
    RitualCard.curated(id: 'sd_13', number: 13, theme: RitualTheme.bhakti),
    RitualCard.curated(id: 'sd_14', number: 14, theme: RitualTheme.bhakti),
    RitualCard.curated(id: 'sd_15', number: 15, theme: RitualTheme.bhakti),
    // ────────────────────── JNANA (16–22) ──────────────────────
    RitualCard.curated(id: 'sd_16', number: 16, theme: RitualTheme.jnana),
    RitualCard.curated(id: 'sd_17', number: 17, theme: RitualTheme.jnana),
    RitualCard.curated(id: 'sd_18', number: 18, theme: RitualTheme.jnana),
    RitualCard.curated(id: 'sd_19', number: 19, theme: RitualTheme.jnana),
    RitualCard.curated(id: 'sd_20', number: 20, theme: RitualTheme.jnana),
    RitualCard.curated(id: 'sd_21', number: 21, theme: RitualTheme.jnana),
    RitualCard.curated(id: 'sd_22', number: 22, theme: RitualTheme.jnana),
    // ────────────────────── YOGA (23–27) ──────────────────────
    RitualCard.curated(id: 'sd_23', number: 23, theme: RitualTheme.yoga),
    RitualCard.curated(id: 'sd_24', number: 24, theme: RitualTheme.yoga),
    RitualCard.curated(id: 'sd_25', number: 25, theme: RitualTheme.yoga),
    RitualCard.curated(id: 'sd_26', number: 26, theme: RitualTheme.yoga),
    RitualCard.curated(id: 'sd_27', number: 27, theme: RitualTheme.yoga),
    // ────────────────────── AHIMSA (28–31) ──────────────────────
    RitualCard.curated(id: 'sd_28', number: 28, theme: RitualTheme.ahimsa),
    RitualCard.curated(id: 'sd_29', number: 29, theme: RitualTheme.ahimsa),
    RitualCard.curated(id: 'sd_30', number: 30, theme: RitualTheme.ahimsa),
    RitualCard.curated(id: 'sd_31', number: 31, theme: RitualTheme.ahimsa),
    // ────────────────────── SATHYA (32–35) ──────────────────────
    RitualCard.curated(id: 'sd_32', number: 32, theme: RitualTheme.sathya),
    RitualCard.curated(id: 'sd_33', number: 33, theme: RitualTheme.sathya),
    RitualCard.curated(id: 'sd_34', number: 34, theme: RitualTheme.sathya),
    RitualCard.curated(id: 'sd_35', number: 35, theme: RitualTheme.sathya),
    // ────────────────────── VAIRAGYA (36–39) ──────────────────────
    RitualCard.curated(id: 'sd_36', number: 36, theme: RitualTheme.vairagya),
    RitualCard.curated(id: 'sd_37', number: 37, theme: RitualTheme.vairagya),
    RitualCard.curated(id: 'sd_38', number: 38, theme: RitualTheme.vairagya),
    RitualCard.curated(id: 'sd_39', number: 39, theme: RitualTheme.vairagya),
    // ────────────────────── SEVA (40–44) ──────────────────────
    RitualCard.curated(id: 'sd_40', number: 40, theme: RitualTheme.seva),
    RitualCard.curated(id: 'sd_41', number: 41, theme: RitualTheme.seva),
    RitualCard.curated(id: 'sd_42', number: 42, theme: RitualTheme.seva),
    RitualCard.curated(id: 'sd_43', number: 43, theme: RitualTheme.seva),
    RitualCard.curated(id: 'sd_44', number: 44, theme: RitualTheme.seva),
    // ────────────────────── SHANTI (45–50) ──────────────────────
    RitualCard.curated(id: 'sd_45', number: 45, theme: RitualTheme.shanti),
    RitualCard.curated(id: 'sd_46', number: 46, theme: RitualTheme.shanti),
    RitualCard.curated(id: 'sd_47', number: 47, theme: RitualTheme.shanti),
    RitualCard.curated(id: 'sd_48', number: 48, theme: RitualTheme.shanti),
    RitualCard.curated(id: 'sd_49', number: 49, theme: RitualTheme.shanti),
    RitualCard.curated(id: 'sd_50', number: 50, theme: RitualTheme.shanti),
  ];
}
