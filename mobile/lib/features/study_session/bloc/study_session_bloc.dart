import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/study_session.dart';
import '../services/study_session_service.dart';
import '../../flashcard/models/flashcard.dart';

// Events
abstract class StudySessionEvent {}

class StudySessionStarted extends StudySessionEvent {}

class StudySessionCardFlipped extends StudySessionEvent {}

class StudySessionDifficultySelected extends StudySessionEvent {
  final String difficulty;

  StudySessionDifficultySelected(this.difficulty);
}

class StudySessionExited extends StudySessionEvent {}

// States
abstract class StudySessionState {}

class StudySessionLoading extends StudySessionState {}

class StudySessionActive extends StudySessionState {
  final StudySession session;
  final Flashcard currentCard;
  final int currentCardIndex;
  final int totalCards;
  final bool isCardFlipped;
  final List<String> supportPhrases;

  StudySessionActive({
    required this.session,
    required this.currentCard,
    required this.currentCardIndex,
    required this.totalCards,
    required this.isCardFlipped,
    required this.supportPhrases,
  });
}

class StudySessionComplete extends StudySessionState {
  final StudySession session;

  StudySessionComplete(this.session);
}

// BLoC
class StudySessionBloc extends Bloc<StudySessionEvent, StudySessionState> {
  final StudySessionService _studySessionService;
  final String _deckId;
  late StudySession _currentSession;
  late List<Flashcard> _cards;
  int _currentCardIndex = 0;
  bool _isCardFlipped = false;
  List<String> _currentSupportPhrases = [];

  StudySessionBloc({
    required StudySessionService studySessionService,
    required String deckId,
  })  : _studySessionService = studySessionService,
        _deckId = deckId,
        super(StudySessionLoading()) {
    on<StudySessionStarted>(_onSessionStarted);
    on<StudySessionCardFlipped>(_onCardFlipped);
    on<StudySessionDifficultySelected>(_onDifficultySelected);
    on<StudySessionExited>(_onSessionExited);
  }

  Future<void> _onSessionStarted(
    StudySessionStarted event,
    Emitter<StudySessionState> emit,
  ) async {
    try {
      // Start new session
      _currentSession = await _studySessionService.startSession(
        'currentUserId', // TODO: Get from auth service
        _deckId,
      );

      // Load cards for the deck
      // TODO: Implement card loading from Firestore
      _cards = [];

      if (_cards.isEmpty) {
        emit(StudySessionComplete(_currentSession));
        return;
      }

      emit(StudySessionActive(
        session: _currentSession,
        currentCard: _cards[_currentCardIndex],
        currentCardIndex: _currentCardIndex,
        totalCards: _cards.length,
        isCardFlipped: _isCardFlipped,
        supportPhrases: _currentSupportPhrases,
      ));
    } catch (e) {
      // TODO: Handle error state
      print('Error starting session: $e');
    }
  }

  Future<void> _onCardFlipped(
    StudySessionCardFlipped event,
    Emitter<StudySessionState> emit,
  ) async {
    _isCardFlipped = true;
    
    if (_currentSupportPhrases.isEmpty) {
      _currentSupportPhrases = await _studySessionService.generateSupportPhrases(
        _cards[_currentCardIndex],
        'medium', // Default difficulty for generating phrases
      );
    }

    emit(StudySessionActive(
      session: _currentSession,
      currentCard: _cards[_currentCardIndex],
      currentCardIndex: _currentCardIndex,
      totalCards: _cards.length,
      isCardFlipped: _isCardFlipped,
      supportPhrases: _currentSupportPhrases,
    ));
  }

  Future<void> _onDifficultySelected(
    StudySessionDifficultySelected event,
    Emitter<StudySessionState> emit,
  ) async {
    await _studySessionService.updateCardDifficulty(
      _currentSession,
      _cards[_currentCardIndex].id,
      event.difficulty,
    );

    _currentCardIndex++;
    _isCardFlipped = false;
    _currentSupportPhrases = [];

    if (_currentCardIndex >= _cards.length) {
      await _studySessionService.endSession(_currentSession);
      emit(StudySessionComplete(_currentSession));
    } else {
      emit(StudySessionActive(
        session: _currentSession,
        currentCard: _cards[_currentCardIndex],
        currentCardIndex: _currentCardIndex,
        totalCards: _cards.length,
        isCardFlipped: _isCardFlipped,
        supportPhrases: _currentSupportPhrases,
      ));
    }
  }

  Future<void> _onSessionExited(
    StudySessionExited event,
    Emitter<StudySessionState> emit,
  ) async {
    await _studySessionService.endSession(_currentSession);
    emit(StudySessionComplete(_currentSession));
  }
}
