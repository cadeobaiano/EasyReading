export interface SM2Data {
  // Número de repetições feitas
  repetitions: number;
  
  // Fator de facilidade do item (começa em 2.5)
  easeFactor: number;
  
  // Intervalo em dias para a próxima revisão
  interval: number;
  
  // Data da próxima revisão
  nextReviewDate: Date;
  
  // Data da última revisão
  lastReviewDate: Date;
  
  // Qualidade da última resposta (0-5)
  lastQuality: number;
}

export interface FlashcardReview {
  flashcardId: string;
  userId: string;
  quality: number; // 0-5
  reviewDate: Date;
}

export enum ReviewQuality {
  BLACKOUT = 0,      // Esqueceu completamente
  DIFFICULT = 1,     // Resposta errada, mas lembrou
  HARD = 2,          // Resposta correta, com dificuldade
  MEDIUM = 3,        // Resposta correta, com esforço médio
  EASY = 4,          // Resposta correta, com algum esforço
  PERFECT = 5,       // Resposta perfeita, sem esforço
}

export interface ReviewResult {
  nextReviewDate: Date;
  interval: number;
  easeFactor: number;
  repetitions: number;
  isGraduated: boolean;
}
