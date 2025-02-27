import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:easyreading/features/gamification/services/gamification_service.dart';
import 'package:easyreading/features/study_session/models/study_session.dart';
import 'package:easyreading/features/gamification/models/achievement.dart';
import 'package:easyreading/features/gamification/models/level.dart';

class MockStudySession extends Mock implements StudySession {}

void main() {
  late GamificationService gamificationService;

  setUp(() {
    gamificationService = GamificationService();
  });

  group('Cálculo de Pontos', () {
    test('calcula pontos corretamente para sessão difícil', () {
      final session = StudySession(
        id: 'test-session',
        userId: 'user-1',
        deckId: 'deck-1',
        correctAnswers: 8,
        totalCards: 10,
        difficulty: 'hard',
        startTime: DateTime.now(),
        endTime: DateTime.now().add(const Duration(minutes: 15)),
      );

      final points = gamificationService.calculatePoints(session);
      
      // Base: 8 acertos * 10 pontos = 80
      // Multiplicador de dificuldade (hard) = 2x
      // Total esperado: 160 pontos
      expect(points, equals(160));
    });

    test('calcula pontos corretamente para sessão média', () {
      final session = StudySession(
        id: 'test-session',
        userId: 'user-1',
        deckId: 'deck-1',
        correctAnswers: 8,
        totalCards: 10,
        difficulty: 'medium',
        startTime: DateTime.now(),
        endTime: DateTime.now().add(const Duration(minutes: 15)),
      );

      final points = gamificationService.calculatePoints(session);
      
      // Base: 8 acertos * 10 pontos = 80
      // Multiplicador de dificuldade (medium) = 1.5x
      // Total esperado: 120 pontos
      expect(points, equals(120));
    });

    test('aplica bônus por streak de estudo', () {
      final session = StudySession(
        id: 'test-session',
        userId: 'user-1',
        deckId: 'deck-1',
        correctAnswers: 8,
        totalCards: 10,
        difficulty: 'medium',
        startTime: DateTime.now(),
        endTime: DateTime.now().add(const Duration(minutes: 15)),
        studyStreak: 5, // 5 dias seguidos
      );

      final points = gamificationService.calculatePoints(session);
      
      // Base: 120 pontos (como no teste anterior)
      // Bônus de streak: 25% (5 dias * 5%)
      // Total esperado: 150 pontos
      expect(points, equals(150));
    });
  });

  group('Sistema de Níveis', () {
    test('calcula nível corretamente baseado em XP', () {
      final level = gamificationService.calculateLevel(1000); // 1000 XP
      
      // Cada nível requer XP = nível * 100
      // 1000 XP deve resultar em nível 4
      expect(level.current, equals(4));
      expect(level.xpForNext, equals(500)); // Faltam 500 XP para nível 5
    });

    test('calcula progresso percentual para próximo nível', () {
      final level = gamificationService.calculateLevel(350); // 350 XP
      
      // Nível 2 (200 XP) para 3 (300 XP)
      // 350 - 300 = 50 XP no nível atual
      // Nível 3 requer 300 XP, então progresso = 50/300 = ~16.67%
      expect(level.progressToNext, closeTo(16.67, 0.01));
    });
  });

  group('Sistema de Conquistas', () {
    test('desbloqueia conquista por precisão perfeita', () {
      final session = StudySession(
        id: 'test-session',
        userId: 'user-1',
        deckId: 'deck-1',
        correctAnswers: 10,
        totalCards: 10,
        difficulty: 'hard',
        startTime: DateTime.now(),
        endTime: DateTime.now().add(const Duration(minutes: 15)),
      );

      final achievements = gamificationService.checkAchievements(session);
      
      expect(
        achievements,
        contains(
          predicate<Achievement>(
            (a) => a.id == 'perfect_session' && !a.wasUnlockedBefore,
          ),
        ),
      );
    });

    test('desbloqueia conquista por streak de estudo', () {
      final session = StudySession(
        id: 'test-session',
        userId: 'user-1',
        deckId: 'deck-1',
        correctAnswers: 8,
        totalCards: 10,
        difficulty: 'medium',
        startTime: DateTime.now(),
        endTime: DateTime.now().add(const Duration(minutes: 15)),
        studyStreak: 7, // 7 dias seguidos
      );

      final achievements = gamificationService.checkAchievements(session);
      
      expect(
        achievements,
        contains(
          predicate<Achievement>(
            (a) => a.id == 'week_streak' && !a.wasUnlockedBefore,
          ),
        ),
      );
    });

    test('não desbloqueia conquista já obtida', () {
      final session = StudySession(
        id: 'test-session',
        userId: 'user-1',
        deckId: 'deck-1',
        correctAnswers: 10,
        totalCards: 10,
        difficulty: 'hard',
        startTime: DateTime.now(),
        endTime: DateTime.now().add(const Duration(minutes: 15)),
        unlockedAchievements: ['perfect_session'],
      );

      final achievements = gamificationService.checkAchievements(session);
      
      expect(
        achievements,
        isNot(
          contains(
            predicate<Achievement>(
              (a) => a.id == 'perfect_session',
            ),
          ),
        ),
      );
    });
  });

  group('Cálculo de Multiplicadores', () {
    test('aplica multiplicador de combo', () {
      final session = StudySession(
        id: 'test-session',
        userId: 'user-1',
        deckId: 'deck-1',
        correctAnswers: 8,
        totalCards: 10,
        difficulty: 'medium',
        startTime: DateTime.now(),
        endTime: DateTime.now().add(const Duration(minutes: 15)),
        currentCombo: 5, // 5 acertos seguidos
      );

      final points = gamificationService.calculatePoints(session);
      
      // Base: 120 pontos
      // Bônus de combo: 25% (5 acertos * 5%)
      // Total esperado: 150 pontos
      expect(points, equals(150));
    });

    test('aplica multiplicador de tempo de resposta', () {
      final session = StudySession(
        id: 'test-session',
        userId: 'user-1',
        deckId: 'deck-1',
        correctAnswers: 8,
        totalCards: 10,
        difficulty: 'medium',
        startTime: DateTime.now(),
        endTime: DateTime.now().add(const Duration(minutes: 15)),
        averageResponseTime: const Duration(seconds: 2),
      );

      final points = gamificationService.calculatePoints(session);
      
      // Base: 120 pontos
      // Bônus de tempo rápido: 20%
      // Total esperado: 144 pontos
      expect(points, equals(144));
    });
  });
}
