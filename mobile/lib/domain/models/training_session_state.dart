import 'package:equatable/equatable.dart';

enum CardState {
  front,
  back,
  completed,
}

enum DifficultyLevel {
  hard,
  medium,
  easy,
}

class TrainingSessionState extends Equatable {
  final String currentWord;
  final String definition;
  final List<String> supportPhrases;
  final CardState cardState;
  final bool isLoadingPhrases;
  final String? error;
  final int currentCardIndex;
  final int totalCards;
  
  // Campos adicionais para revisão
  final double? reviewPriority;
  final int? repetitions;
  final DateTime? nextReview;

  const TrainingSessionState({
    required this.currentWord,
    required this.definition,
    this.supportPhrases = const [],
    this.cardState = CardState.front,
    this.isLoadingPhrases = false,
    this.error,
    this.currentCardIndex = 0,
    required this.totalCards,
    this.reviewPriority,
    this.repetitions,
    this.nextReview,
  });

  TrainingSessionState copyWith({
    String? currentWord,
    String? definition,
    List<String>? supportPhrases,
    CardState? cardState,
    bool? isLoadingPhrases,
    String? error,
    int? currentCardIndex,
    int? totalCards,
    double? reviewPriority,
    int? repetitions,
    DateTime? nextReview,
  }) {
    return TrainingSessionState(
      currentWord: currentWord ?? this.currentWord,
      definition: definition ?? this.definition,
      supportPhrases: supportPhrases ?? this.supportPhrases,
      cardState: cardState ?? this.cardState,
      isLoadingPhrases: isLoadingPhrases ?? this.isLoadingPhrases,
      error: error,
      currentCardIndex: currentCardIndex ?? this.currentCardIndex,
      totalCards: totalCards ?? this.totalCards,
      reviewPriority: reviewPriority ?? this.reviewPriority,
      repetitions: repetitions ?? this.repetitions,
      nextReview: nextReview ?? this.nextReview,
    );
  }

  @override
  List<Object?> get props => [
        currentWord,
        definition,
        supportPhrases,
        cardState,
        isLoadingPhrases,
        error,
        currentCardIndex,
        totalCards,
        reviewPriority,
        repetitions,
        nextReview,
      ];
}
