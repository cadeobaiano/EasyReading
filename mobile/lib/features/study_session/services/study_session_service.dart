import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/study_session.dart';
import '../../flashcard/models/flashcard.dart';
import '../../../services/openai_service.dart';
import '../../gamification/services/points_service.dart';
import '../../gamification/services/achievement_service.dart';

class StudySessionService {
  final FirebaseFirestore _firestore;
  final OpenAIService _openAIService;
  final PointsService _pointsService;
  final AchievementService _achievementService;

  StudySessionService({
    required FirebaseFirestore firestore,
    required OpenAIService openAIService,
    required PointsService pointsService,
    required AchievementService achievementService,
  })  : _firestore = firestore,
        _openAIService = openAIService,
        _pointsService = pointsService,
        _achievementService = achievementService;

  Future<StudySession> startSession(String userId, String deckId) async {
    final session = StudySession(
      id: _firestore.collection('sessions').doc().id,
      userId: userId,
      deckId: deckId,
      startTime: DateTime.now(),
    );

    await _firestore.collection('sessions').doc(session.id).set(session.toJson());
    return session;
  }

  Future<void> endSession(StudySession session) async {
    session.endTime = DateTime.now();
    
    // Calculate points
    final basePoints = session.correctAnswers * 10;
    final accuracyBonus = session.accuracy >= 90 ? 50 : 0;
    final streakMultiplier = await _pointsService.getStreakMultiplier(session.userId);
    
    session.earnedPoints = ((basePoints + accuracyBonus) * streakMultiplier).round();
    
    // Update user progress and check achievements
    await Future.wait([
      _pointsService.addPoints(session.userId, session.earnedPoints),
      _achievementService.checkSessionAchievements(session),
      _firestore.collection('sessions').doc(session.id).update(session.toJson()),
    ]);
  }

  Future<List<String>> generateSupportPhrases(Flashcard card, String difficulty) async {
    return await _openAIService.generateExampleSentences(
      word: card.front,
      language: "English", // TODO: Get from user preferences
      count: 3,
    );
  }

  Future<void> updateCardDifficulty(
    StudySession session,
    String cardId,
    String difficulty,
  ) async {
    // Update SM2 data
    final sm2Score = _calculateSM2Score(difficulty);
    await _firestore.collection('flashcards').doc(cardId).update({
      'sm2Data.grade': sm2Score,
      'sm2Data.lastReview': FieldValue.serverTimestamp(),
    });

    // Track difficult words for AI support
    if (difficulty == 'hard') {
      session.difficultWords.add(cardId);
      await _firestore.collection('sessions').doc(session.id).update({
        'difficultWords': FieldValue.arrayUnion([cardId]),
      });
    }

    // Update session statistics
    session.cardDifficulties[cardId] = sm2Score;
    session.cardsReviewed++;
    if (sm2Score >= 4) {
      session.correctAnswers++;
    }

    await _firestore.collection('sessions').doc(session.id).update({
      'cardDifficulties': session.cardDifficulties,
      'cardsReviewed': session.cardsReviewed,
      'correctAnswers': session.correctAnswers,
    });
  }

  int _calculateSM2Score(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return 5;
      case 'medium':
        return 3;
      case 'hard':
        return 1;
      default:
        return 0;
    }
  }
}
