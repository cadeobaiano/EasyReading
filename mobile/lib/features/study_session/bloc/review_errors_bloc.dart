import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/study_session.dart';
import '../services/study_session_service.dart';
import '../services/difficult_cards_service.dart';
import '../../flashcard/models/flashcard.dart';

// Events
abstract class ReviewErrorsEvent {}

class ReviewErrorsStarted extends ReviewErrorsEvent {}

class ReviewErrorsCardFlipped extends ReviewErrorsEvent {}

class ReviewErrorsDifficultySelected extends ReviewErrorsEvent {
  final String difficulty;

  ReviewErrorsDifficultySelected(this.difficulty);
}

// States
abstract class ReviewErrorsState {}

class ReviewErrorsLoading extends ReviewErrorsState {}

class ReviewErrorsEmpty extends ReviewErrorsState {}

class ReviewErrorsActive extends ReviewErrorsState {
  final StudySession session;
  final Flashcard currentCard;
  final int currentCardIndex;
  final int totalCards;
  final int remainingCards;
  final bool isCardFlipped;
  final List<String> supportPhrases;

  ReviewErrorsActive({
    required this.session,
    required this.currentCard,
    required this.currentCardIndex,
    required this.totalCards,
    required this.remainingCards,
    required this.isCardFlipped,
    required this.supportPhrases,
  });
}

class ReviewErrorsComplete extends ReviewErrorsState {
  final StudySession session;

  ReviewErrorsComplete(this.session);
}

class ReviewErrorsBloc extends Bloc<ReviewErrorsEvent, ReviewErrorsState> {
  final DifficultCardsService _difficultCardsService;
  final StudySessionService _studySessionService;
  late StudySession _currentSession;
  late List<Flashcard> _cards;
  int _currentCardIndex = 0;
  bool _isCardFlipped = false;
  List<String> _currentSupportPhrases = [];

  ReviewErrorsBloc({
    required DifficultCardsService difficultCardsService,
    required StudySessionService studySessionService,
  })  : _difficultCardsService = difficultCardsService,
        _studySessionService = studySessionService,
        super(ReviewErrorsLoading()) {
    on<ReviewErrorsStarted>(_onStarted);
    on<ReviewErrorsCardFlipped>(_onCardFlipped);
    on<ReviewErrorsDifficultySelected>(_onDifficultySelected);
  }

  Future<void> _onStarted(
    ReviewErrorsStarted event,
    Emitter<ReviewErrorsState> emit,
  ) async {
    try {
      // Carregar cards difíceis
      _cards = await _difficultCardsService.getDifficultCards('currentUserId');

      if (_cards.isEmpty) {
        emit(ReviewErrorsEmpty());
        return;
      }

      // Iniciar nova sessão
      _currentSession = await _studySessionService.startSession(
        'currentUserId',
        'difficult_cards_session',
      );

      emit(ReviewErrorsActive(
        session: _currentSession,
        currentCard: _cards[_currentCardIndex],
        currentCardIndex: _currentCardIndex,
        totalCards: _cards.length,
        remainingCards: _cards.length - _currentCardIndex,
        isCardFlipped: _isCardFlipped,
        supportPhrases: _currentSupportPhrases,
      ));
    } catch (e) {
      print('Error starting review errors session: $e');
      emit(ReviewErrorsEmpty());
    }
  }

  Future<void> _onCardFlipped(
    ReviewErrorsCardFlipped event,
    Emitter<ReviewErrorsState> emit,
  ) async {
    _isCardFlipped = true;
    
    if (_currentSupportPhrases.isEmpty) {
      _currentSupportPhrases = await _studySessionService.generateSupportPhrases(
        _cards[_currentCardIndex],
        'hard', // Sempre gerar frases considerando difícil para mais contexto
      );
    }

    emit(ReviewErrorsActive(
      session: _currentSession,
      currentCard: _cards[_currentCardIndex],
      currentCardIndex: _currentCardIndex,
      totalCards: _cards.length,
      remainingCards: _cards.length - _currentCardIndex,
      isCardFlipped: _isCardFlipped,
      supportPhrases: _currentSupportPhrases,
    ));
  }

  Future<void> _onDifficultySelected(
    ReviewErrorsDifficultySelected event,
    Emitter<ReviewErrorsState> emit,
  ) async {
    final currentCard = _cards[_currentCardIndex];
    
    // Atualizar dificuldade e estatísticas
    await Future.wait([
      _studySessionService.updateCardDifficulty(
        _currentSession,
        currentCard.id,
        event.difficulty,
      ),
      _difficultCardsService.updateDifficultCardStats(
        'currentUserId',
        currentCard.id,
        event.difficulty != 'hard',
      ),
    ]);

    _currentCardIndex++;
    _isCardFlipped = false;
    _currentSupportPhrases = [];

    if (_currentCardIndex >= _cards.length) {
      await _studySessionService.endSession(_currentSession);
      emit(ReviewErrorsComplete(_currentSession));
    } else {
      emit(ReviewErrorsActive(
        session: _currentSession,
        currentCard: _cards[_currentCardIndex],
        currentCardIndex: _currentCardIndex,
        totalCards: _cards.length,
        remainingCards: _cards.length - _currentCardIndex,
        isCardFlipped: _isCardFlipped,
        supportPhrases: _currentSupportPhrases,
      ));
    }
  }
}
