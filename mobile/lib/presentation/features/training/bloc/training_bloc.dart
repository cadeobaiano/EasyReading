import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_reading/domain/models/training_session_state.dart';
import 'package:easy_reading/domain/services/ai_service.dart';
import 'package:easy_reading/domain/services/sm2_service.dart';

// Events
abstract class TrainingEvent {}

class StartTrainingSession extends TrainingEvent {}

class FlipCard extends TrainingEvent {}

class RateCard extends TrainingEvent {
  final DifficultyLevel difficulty;
  RateCard({required this.difficulty});
}

class TrainingBloc extends Bloc<TrainingEvent, TrainingSessionState> {
  final String deckId;
  final AIService _aiService;

  TrainingBloc({
    required this.deckId,
    AIService? aiService,
  }) : _aiService = aiService ?? AIService(apiKey: 'YOUR_API_KEY'),
       super(const TrainingSessionState(
         currentWord: '',
         definition: '',
         totalCards: 0,
       )) {
    on<StartTrainingSession>(_onStartTrainingSession);
    on<FlipCard>(_onFlipCard);
    on<RateCard>(_onRateCard);
  }

  Future<void> _onStartTrainingSession(
    StartTrainingSession event,
    Emitter<TrainingSessionState> emit,
  ) async {
    // TODO: Carregar cards do deck do Firebase
    // Por enquanto, usando dados de exemplo
    emit(const TrainingSessionState(
      currentWord: 'Exemplo',
      definition: 'Uma coisa ou caso que serve para ilustrar uma regra geral',
      totalCards: 10,
      currentCardIndex: 0,
    ));
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
    // Calcula próximo intervalo usando SM2
    final quality = SM2Service.difficultyToQuality(event.difficulty.name);
    final nextReview = SM2Service.calculateNextInterval(
      repetitions: 1, // TODO: Pegar do banco
      easeFactor: 2.5, // TODO: Pegar do banco
      quality: quality,
    );

    // TODO: Atualizar dados no Firebase
    
    // Avança para o próximo card
    if (state.currentCardIndex < state.totalCards - 1) {
      emit(TrainingSessionState(
        currentWord: 'Próxima Palavra', // TODO: Pegar próxima palavra do deck
        definition: 'Próxima definição',
        totalCards: state.totalCards,
        currentCardIndex: state.currentCardIndex + 1,
      ));
    } else {
      // TODO: Mostrar tela de conclusão da sessão
    }
  }
}
