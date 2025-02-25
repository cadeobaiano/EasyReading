import 'package:easy_reading/domain/models/training_session_state.dart';

class ReviewService {
  /// Determina se um flashcard precisa de revisão com base nos dados do SM2
  static bool needsReview({
    required DateTime nextReview,
    required int repetitions,
    required double easeFactor,
    required DifficultyLevel lastDifficulty,
  }) {
    final now = DateTime.now();
    
    // Cards que precisam de revisão:
    // 1. Data de revisão já passou
    // 2. Última dificuldade foi 'hard'
    // 3. Fator de facilidade está baixo
    // 4. Poucas repetições bem-sucedidas
    return now.isAfter(nextReview) ||
           lastDifficulty == DifficultyLevel.hard ||
           easeFactor < 1.5 ||
           repetitions < 2;
  }

  /// Calcula a prioridade de revisão de um card
  /// Retorna um valor de 0 a 1, onde 1 é a maior prioridade
  static double calculateReviewPriority({
    required DateTime nextReview,
    required int repetitions,
    required double easeFactor,
    required DifficultyLevel lastDifficulty,
  }) {
    double priority = 0.0;
    
    // Fatores que aumentam a prioridade:
    
    // 1. Tempo desde a data de revisão
    final daysOverdue = DateTime.now().difference(nextReview).inDays;
    if (daysOverdue > 0) {
      priority += 0.3 * (daysOverdue / 7).clamp(0.0, 1.0);
    }
    
    // 2. Última dificuldade reportada
    switch (lastDifficulty) {
      case DifficultyLevel.hard:
        priority += 0.3;
      case DifficultyLevel.medium:
        priority += 0.15;
      case DifficultyLevel.easy:
        priority += 0.0;
    }
    
    // 3. Fator de facilidade baixo
    if (easeFactor < 2.5) {
      priority += 0.2 * ((2.5 - easeFactor) / 1.2).clamp(0.0, 1.0);
    }
    
    // 4. Poucas repetições
    if (repetitions < 5) {
      priority += 0.2 * ((5 - repetitions) / 5);
    }
    
    return priority.clamp(0.0, 1.0);
  }

  /// Ordena os flashcards por prioridade de revisão
  static List<Map<String, dynamic>> prioritizeFlashcards(
    List<Map<String, dynamic>> flashcards,
  ) {
    return flashcards
      ..sort((a, b) {
        final priorityA = calculateReviewPriority(
          nextReview: a['nextReview'],
          repetitions: a['repetitions'],
          easeFactor: a['easeFactor'],
          lastDifficulty: a['lastDifficulty'],
        );
        
        final priorityB = calculateReviewPriority(
          nextReview: b['nextReview'],
          repetitions: b['repetitions'],
          easeFactor: b['easeFactor'],
          lastDifficulty: b['lastDifficulty'],
        );
        
        return priorityB.compareTo(priorityA);
      });
  }
}
