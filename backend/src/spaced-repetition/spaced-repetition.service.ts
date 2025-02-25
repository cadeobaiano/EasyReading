import { Injectable } from '@nestjs/common';
import { FirebaseService } from '../firebase/firebase.service';
import { SM2Data, FlashcardReview, ReviewQuality, ReviewResult } from './models/sm2-data.model';

@Injectable()
export class SpacedRepetitionService {
  private readonly collection = 'flashcard_progress';

  constructor(private readonly firebaseService: FirebaseService) {}

  /**
   * Processa uma revisão de flashcard usando o algoritmo SM2
   */
  async processReview(review: FlashcardReview): Promise<ReviewResult> {
    const progressKey = `${review.userId}_${review.flashcardId}`;
    const currentProgress = await this.getProgress(progressKey);
    
    const result = this.calculateNextReview(
      review.quality,
      currentProgress || this.getInitialProgress(),
    );

    await this.saveProgress(progressKey, {
      repetitions: result.repetitions,
      easeFactor: result.easeFactor,
      interval: result.interval,
      nextReviewDate: result.nextReviewDate,
      lastReviewDate: review.reviewDate,
      lastQuality: review.quality,
    });

    return result;
  }

  /**
   * Calcula a próxima revisão baseado no algoritmo SM2
   */
  private calculateNextReview(quality: number, currentData: SM2Data): ReviewResult {
    // Limita a qualidade entre 0 e 5
    quality = Math.min(Math.max(quality, 0), 5);

    let { repetitions, easeFactor, interval } = currentData;
    let isGraduated = false;

    // Atualiza o fator de facilidade (EF)
    // EF' = EF + (0.1 - (5 - q) * (0.08 + (5 - q) * 0.02))
    easeFactor = Math.max(
      1.3,
      easeFactor + (0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02)),
    );

    // Se a resposta foi correta (qualidade >= 3)
    if (quality >= 3) {
      if (repetitions === 0) {
        interval = 1;
        isGraduated = true;
      } else if (repetitions === 1) {
        interval = 6;
      } else {
        interval = Math.round(interval * easeFactor);
      }
      repetitions++;
    }
    // Se a resposta foi incorreta (qualidade < 3)
    else {
      repetitions = 0;
      interval = 1;
    }

    // Calcula a próxima data de revisão
    const nextReviewDate = new Date();
    nextReviewDate.setDate(nextReviewDate.getDate() + interval);

    return {
      nextReviewDate,
      interval,
      easeFactor,
      repetitions,
      isGraduated,
    };
  }

  /**
   * Obtém o progresso atual de um flashcard
   */
  private async getProgress(progressKey: string): Promise<SM2Data | null> {
    const doc = await this.firebaseService.getDocument(
      this.collection,
      progressKey,
    );
    return doc as SM2Data | null;
  }

  /**
   * Salva o progresso de um flashcard
   */
  private async saveProgress(progressKey: string, data: SM2Data): Promise<void> {
    await this.firebaseService.setDocument(
      this.collection,
      progressKey,
      data,
    );
  }

  /**
   * Retorna o progresso inicial para um novo flashcard
   */
  private getInitialProgress(): SM2Data {
    const now = new Date();
    return {
      repetitions: 0,
      easeFactor: 2.5,
      interval: 0,
      nextReviewDate: now,
      lastReviewDate: now,
      lastQuality: 0,
    };
  }

  /**
   * Obtém os flashcards que precisam ser revisados
   */
  async getDueFlashcards(userId: string): Promise<string[]> {
    const now = new Date();
    
    const results = await this.firebaseService.queryCollection(
      this.collection,
      [
        { field: 'userId', operator: '==', value: userId },
        { field: 'nextReviewDate', operator: '<=', value: now },
      ],
    );

    return results.docs.map(doc => doc.id.split('_')[1]); // Extrai o flashcardId
  }

  /**
   * Converte a classificação do usuário para o valor de qualidade do SM2
   */
  convertUserRatingToQuality(rating: 'difícil' | 'médio' | 'fácil'): number {
    switch (rating.toLowerCase()) {
      case 'difícil':
        return ReviewQuality.HARD;
      case 'médio':
        return ReviewQuality.MEDIUM;
      case 'fácil':
        return ReviewQuality.EASY;
      default:
        return ReviewQuality.MEDIUM;
    }
  }

  /**
   * Obtém estatísticas de revisão para um usuário
   */
  async getUserStatistics(userId: string) {
    const results = await this.firebaseService.queryCollection(
      this.collection,
      [{ field: 'userId', operator: '==', value: userId }],
    );

    const stats = {
      totalCards: results.size,
      masteredCards: 0,
      learningCards: 0,
      newCards: 0,
      averageEaseFactor: 0,
    };

    let totalEaseFactor = 0;

    results.docs.forEach(doc => {
      const data = doc.data() as SM2Data;
      if (data.repetitions >= 5 && data.easeFactor > 2.5) {
        stats.masteredCards++;
      } else if (data.repetitions > 0) {
        stats.learningCards++;
      } else {
        stats.newCards++;
      }
      totalEaseFactor += data.easeFactor;
    });

    if (stats.totalCards > 0) {
      stats.averageEaseFactor = totalEaseFactor / stats.totalCards;
    }

    return stats;
  }
}
