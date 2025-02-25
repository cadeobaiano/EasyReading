import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_reading/domain/models/training_session_state.dart';
import 'package:easy_reading/domain/services/ai_service.dart';
import 'package:easy_reading/domain/services/sm2_service.dart';
import 'package:easy_reading/domain/services/review_service.dart';

// Events
abstract class ReviewEvent {}

class StartReviewSession extends ReviewEvent {}

class FlipCard extends ReviewEvent {}

class RateCard extends ReviewEvent {
  final DifficultyLevel difficulty;
  RateCard({required this.difficulty});
}

class ReviewBloc extends Bloc<ReviewEvent, TrainingSessionState> {
  final String deckId;
  final AIService _aiService;
  final ReviewService _reviewService;
  List<Map<String, dynamic>> _reviewCards = [];

  ReviewBloc({
    required this.deckId,
    AIService? aiService,
  }) : _aiService = aiService ?? AIService(apiKey: 'YOUR_API_KEY'),
       super(const TrainingSessionState(
         currentWord: '',
         definition: '',
         totalCards: 0,
       )) {
    on<StartReviewSession>(_onStartReviewSession);
    on<FlipCard>(_onFlipCard);
    on<RateCard>(_onRateCard);
  }

  Future<void> _onStartReviewSession(
    StartReviewSession event,
    Emitter<TrainingSessionState> emit,
  ) async {
    // TODO: Carregar cards que precisam de revisão do Firebase
    // Por enquanto, usando dados de exemplo
    _reviewCards = [
      {
        'word': 'Exemplo',
        'definition': 'Uma coisa ou caso que serve para ilustrar uma regra geral',
        'nextReview': DateTime.now().subtract(const Duration(days: 2)),
        'repetitions': 1,
        'easeFactor': 1.4,
        'lastDifficulty': DifficultyLevel.hard,
      },
      // Adicionar mais cards...
    ];

    // Ordena cards por prioridade
    _reviewCards = ReviewService.prioritizeFlashcards(_reviewCards);

    if (_reviewCards.isNotEmpty) {
      final firstCard = _reviewCards.first;
      final priority = ReviewService.calculateReviewPriority(
        nextReview: firstCard['nextReview'],
        repetitions: firstCard['repetitions'],
        easeFactor: firstCard['easeFactor'],
        lastDifficulty: firstCard['lastDifficulty'],
      );

      emit(TrainingSessionState(
        currentWord: firstCard['word'],
        definition: firstCard['definition'],
        totalCards: _reviewCards.length,
        currentCardIndex: 0,
        reviewPriority: priority,
        repetitions: firstCard['repetitions'],
        nextReview: firstCard['nextReview'],
      ));
    }
  }

  Future<void> _onFlipCard(
    FlipCard event,
    Emitter<TrainingSessionState> emit,
  ) async {
    if (state.cardState == CardState.front) {
      emit(state.copyWith(
        cardState: CardState.back,
        isLoadingPhrases: true,
      ));

      try {
        final phrases = await _aiService.generateSupportPhrases(
          word: state.currentWord,
          definition: state.definition,
          // Solicita frases mais detalhadas para cards difíceis
          numberOfPhrases: 4,
        );

        emit(state.copyWith(
          supportPhrases: phrases,
          isLoadingPhrases: false,
        ));
      } catch (e) {
        emit(state.copyWith(
          error: 'Erro ao gerar frases de apoio',
          isLoadingPhrases: false,
        ));
      }
    }
  }

  Future<void> _onRateCard(
    RateCard event,
    Emitter<TrainingSessionState> emit,
  ) async {
    final currentCard = _reviewCards[state.currentCardIndex];
    
    // Calcula próximo intervalo usando SM2
    final quality = SM2Service.difficultyToQuality(event.difficulty.name);
    final nextReview = SM2Service.calculateNextInterval(
      repetitions: currentCard['repetitions'],
      easeFactor: currentCard['easeFactor'],
      quality: quality,
    );

    // TODO: Atualizar dados no Firebase
    
    // Avança para o próximo card
    if (state.currentCardIndex < state.totalCards - 1) {
      final nextCard = _reviewCards[state.currentCardIndex + 1];
      final priority = ReviewService.calculateReviewPriority(
        nextReview: nextCard['nextReview'],
        repetitions: nextCard['repetitions'],
        easeFactor: nextCard['easeFactor'],
        lastDifficulty: nextCard['lastDifficulty'],
      );

      emit(TrainingSessionState(
        currentWord: nextCard['word'],
        definition: nextCard['definition'],
        totalCards: state.totalCards,
        currentCardIndex: state.currentCardIndex + 1,
        reviewPriority: priority,
        repetitions: nextCard['repetitions'],
        nextReview: nextCard['nextReview'],
      ));
    } else {
      // TODO: Mostrar tela de conclusão da revisão
    }
  }
}
