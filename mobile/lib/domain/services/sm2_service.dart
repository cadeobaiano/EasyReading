class SM2Service {
  static const double _minEaseFactor = 1.3;

  /// Calcula o próximo intervalo de revisão usando o algoritmo SM2
  /// 
  /// [repetitions] - Número de repetições bem-sucedidas
  /// [easeFactor] - Fator de facilidade atual
  /// [quality] - Qualidade da resposta (0-5)
  /// 
  /// Retorna um Map com:
  /// - interval: Próximo intervalo em dias
  /// - easeFactor: Novo fator de facilidade
  /// - repetitions: Novo contador de repetições
  static Map<String, num> calculateNextInterval({
    required int repetitions,
    required double easeFactor,
    required int quality,
  }) {
    // Ajusta a qualidade para escala 0-5 do SM2
    // difícil = 2, médio = 3, fácil = 4
    int adjustedQuality = quality + 2;

    // Se a resposta foi ruim, reinicia as repetições
    if (adjustedQuality < 3) {
      return {
        'interval': 1,
        'easeFactor': easeFactor,
        'repetitions': 0,
      };
    }

    // Calcula novo fator de facilidade
    double newEaseFactor = easeFactor +
        (0.1 - (5 - adjustedQuality) * (0.08 + (5 - adjustedQuality) * 0.02));
    
    // Garante que o fator de facilidade não fique muito baixo
    newEaseFactor = newEaseFactor < _minEaseFactor ? _minEaseFactor : newEaseFactor;

    // Calcula próximo intervalo
    int nextInterval;
    int newRepetitions = repetitions + 1;

    if (newRepetitions == 1) {
      nextInterval = 1;
    } else if (newRepetitions == 2) {
      nextInterval = 6;
    } else {
      nextInterval = ((repetitions - 1) * easeFactor).round();
    }

    return {
      'interval': nextInterval,
      'easeFactor': newEaseFactor,
      'repetitions': newRepetitions,
    };
  }

  /// Converte o nível de dificuldade em qualidade para o algoritmo SM2
  static int difficultyToQuality(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'hard':
        return 0;
      case 'medium':
        return 1;
      case 'easy':
        return 2;
      default:
        return 1;
    }
  }
}
