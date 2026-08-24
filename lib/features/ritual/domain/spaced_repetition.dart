/// Rating feedback given during card or past entry reflection.
enum RepetitionRating {
  /// Hard: Resurfaces tomorrow (1 day). Resets repetition level.
  hard,

  /// Revision: Needs review soon (3 days). Keeps current level.
  revision,

  /// Easy: Mastered / well-integrated (7 × (level + 1) days). Increases level.
  easy,
}

/// Spaced repetition state for a single card or resurfaced entry.
class CardReviewState {
  final String cardId;
  final int repetitionLevel;
  final int reviewCount;
  final DateTime? lastReviewedAt;
  final DateTime nextReviewDate;

  const CardReviewState({
    required this.cardId,
    this.repetitionLevel = 0,
    this.reviewCount = 0,
    this.lastReviewedAt,
    required this.nextReviewDate,
  });

  /// Factory for a brand-new unreviewed card.
  factory CardReviewState.initial(String cardId, [DateTime? now]) {
    final current = now ?? DateTime.now();
    return CardReviewState(cardId: cardId, nextReviewDate: current);
  }

  /// Calculates the next review state given a user rating.
  CardReviewState applyRating(RepetitionRating rating, [DateTime? now]) {
    final current = now ?? DateTime.now();
    int newLevel = repetitionLevel;
    int intervalDays = 1;

    switch (rating) {
      case RepetitionRating.hard:
        newLevel = 0;
        intervalDays = 1;
        break;
      case RepetitionRating.revision:
        // Keep current level, review in 3 days
        intervalDays = 3;
        break;
      case RepetitionRating.easy:
        // Increase level, scale interval: 7 * (level + 1)
        newLevel = repetitionLevel + 1;
        intervalDays = 7 * newLevel;
        break;
    }

    final nextReview = DateTime(
      current.year,
      current.month,
      current.day,
    ).add(Duration(days: intervalDays));

    return CardReviewState(
      cardId: cardId,
      repetitionLevel: newLevel,
      reviewCount: reviewCount + 1,
      lastReviewedAt: current,
      nextReviewDate: nextReview,
    );
  }

  /// Serializes to a JSON-compatible map for persistence.
  Map<String, dynamic> toJson() => {
    'cardId': cardId,
    'repetitionLevel': repetitionLevel,
    'reviewCount': reviewCount,
    'lastReviewedAt': lastReviewedAt?.toIso8601String(),
    'nextReviewDate': nextReviewDate.toIso8601String(),
  };

  /// Deserializes from a JSON-compatible map.
  factory CardReviewState.fromJson(Map<String, dynamic> json) {
    return CardReviewState(
      cardId: json['cardId'] as String,
      repetitionLevel: (json['repetitionLevel'] as num?)?.toInt() ?? 0,
      reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
      lastReviewedAt: json['lastReviewedAt'] != null
          ? DateTime.tryParse(json['lastReviewedAt'] as String)
          : null,
      nextReviewDate: json['nextReviewDate'] != null
          ? DateTime.parse(json['nextReviewDate'] as String)
          : DateTime.now(),
    );
  }

  /// True if the card is due for review today or overdue.
  bool isDue([DateTime? now]) {
    final today = now ?? DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    final reviewDateStart = DateTime(
      nextReviewDate.year,
      nextReviewDate.month,
      nextReviewDate.day,
    );
    return reviewDateStart.isBefore(todayStart) ||
        reviewDateStart.isAtSameMomentAs(todayStart);
  }
}
