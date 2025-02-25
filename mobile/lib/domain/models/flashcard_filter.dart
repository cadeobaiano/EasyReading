enum SortBy {
  word,
  lastReview,
  successRate,
  difficulty
}

enum FilterDifficulty {
  all,
  easy,
  medium,
  hard
}

class FlashcardFilter {
  final String searchQuery;
  final SortBy sortBy;
  final bool ascending;
  final FilterDifficulty difficulty;
  final double? minSuccessRate;
  final double? maxSuccessRate;
  final DateTime? startDate;
  final DateTime? endDate;

  const FlashcardFilter({
    this.searchQuery = '',
    this.sortBy = SortBy.lastReview,
    this.ascending = false,
    this.difficulty = FilterDifficulty.all,
    this.minSuccessRate,
    this.maxSuccessRate,
    this.startDate,
    this.endDate,
  });

  FlashcardFilter copyWith({
    String? searchQuery,
    SortBy? sortBy,
    bool? ascending,
    FilterDifficulty? difficulty,
    double? minSuccessRate,
    double? maxSuccessRate,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return FlashcardFilter(
      searchQuery: searchQuery ?? this.searchQuery,
      sortBy: sortBy ?? this.sortBy,
      ascending: ascending ?? this.ascending,
      difficulty: difficulty ?? this.difficulty,
      minSuccessRate: minSuccessRate ?? this.minSuccessRate,
      maxSuccessRate: maxSuccessRate ?? this.maxSuccessRate,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }
}
