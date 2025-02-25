import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_reading/domain/models/flashcard.dart';
import 'package:easy_reading/domain/models/flashcard_filter.dart';
import 'package:easy_reading/domain/services/flashcard_service.dart';

// Events
abstract class WordsPortalEvent {}

class LoadFlashcards extends WordsPortalEvent {}

class UpdateFilter extends WordsPortalEvent {
  final FlashcardFilter filter;
  UpdateFilter(this.filter);
}

// State
class WordsPortalState {
  final List<Flashcard> flashcards;
  final FlashcardFilter filter;
  final bool isLoading;
  final String? error;
  final int masteredCount;
  final double averageSuccessRate;

  const WordsPortalState({
    this.flashcards = const [],
    this.filter = const FlashcardFilter(),
    this.isLoading = false,
    this.error,
    this.masteredCount = 0,
    this.averageSuccessRate = 0.0,
  });

  WordsPortalState copyWith({
    List<Flashcard>? flashcards,
    FlashcardFilter? filter,
    bool? isLoading,
    String? error,
    int? masteredCount,
    double? averageSuccessRate,
  }) {
    return WordsPortalState(
      flashcards: flashcards ?? this.flashcards,
      filter: filter ?? this.filter,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      masteredCount: masteredCount ?? this.masteredCount,
      averageSuccessRate: averageSuccessRate ?? this.averageSuccessRate,
    );
  }
}

// Bloc
class WordsPortalBloc extends Bloc<WordsPortalEvent, WordsPortalState> {
  final FlashcardService _flashcardService;

  WordsPortalBloc({FlashcardService? flashcardService})
      : _flashcardService = flashcardService ?? FlashcardService(),
        super(const WordsPortalState()) {
    on<LoadFlashcards>(_onLoadFlashcards);
    on<UpdateFilter>(_onUpdateFilter);
  }

  Future<void> _onLoadFlashcards(
    LoadFlashcards event,
    Emitter<WordsPortalState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final flashcards = await _flashcardService.getTrainedFlashcards();
      final filteredCards = _applyFilter(flashcards, state.filter);
      final stats = _calculateStats(filteredCards);

      emit(state.copyWith(
        flashcards: filteredCards,
        isLoading: false,
        masteredCount: stats.$1,
        averageSuccessRate: stats.$2,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Erro ao carregar flashcards: ${e.toString()}',
      ));
    }
  }

  Future<void> _onUpdateFilter(
    UpdateFilter event,
    Emitter<WordsPortalState> emit,
  ) async {
    final filteredCards = _applyFilter(state.flashcards, event.filter);
    final stats = _calculateStats(filteredCards);

    emit(state.copyWith(
      filter: event.filter,
      flashcards: filteredCards,
      masteredCount: stats.$1,
      averageSuccessRate: stats.$2,
    ));
  }

  List<Flashcard> _applyFilter(List<Flashcard> cards, FlashcardFilter filter) {
    var filtered = cards.where((card) {
      if (filter.searchQuery.isNotEmpty &&
          !card.word.toLowerCase().contains(filter.searchQuery.toLowerCase())) {
        return false;
      }

      if (filter.difficulty != FilterDifficulty.all) {
        final isCorrectDifficulty = switch (filter.difficulty) {
          FilterDifficulty.easy => card.easeFactor >= 2.5,
          FilterDifficulty.medium =>
            card.easeFactor >= 1.5 && card.easeFactor < 2.5,
          FilterDifficulty.hard => card.easeFactor < 1.5,
          FilterDifficulty.all => true,
        };
        if (!isCorrectDifficulty) return false;
      }

      if (filter.minSuccessRate != null &&
          card.successRate < filter.minSuccessRate!) {
        return false;
      }

      if (filter.maxSuccessRate != null &&
          card.successRate > filter.maxSuccessRate!) {
        return false;
      }

      if (filter.startDate != null && card.lastReviewDate != null &&
          card.lastReviewDate!.isBefore(filter.startDate!)) {
        return false;
      }

      if (filter.endDate != null && card.lastReviewDate != null &&
          card.lastReviewDate!.isAfter(filter.endDate!)) {
        return false;
      }

      return true;
    }).toList();

    filtered.sort((a, b) {
      int compare;
      switch (filter.sortBy) {
        case SortBy.word:
          compare = a.word.compareTo(b.word);
          break;
        case SortBy.lastReview:
          compare = (a.lastReviewDate ?? DateTime(0))
              .compareTo(b.lastReviewDate ?? DateTime(0));
          break;
        case SortBy.successRate:
          compare = a.successRate.compareTo(b.successRate);
          break;
        case SortBy.difficulty:
          compare = a.easeFactor.compareTo(b.easeFactor);
          break;
      }
      return filter.ascending ? compare : -compare;
    });

    return filtered;
  }

  (int, double) _calculateStats(List<Flashcard> cards) {
    if (cards.isEmpty) return (0, 0.0);

    final masteredCount =
        cards.where((card) => card.successRate >= 0.8).length;
    final totalSuccessRate =
        cards.fold(0.0, (sum, card) => sum + card.successRate);
    final averageSuccessRate = totalSuccessRate / cards.length;

    return (masteredCount, averageSuccessRate);
  }
}
