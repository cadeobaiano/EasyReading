import { ObjectId } from 'mongodb';

/**
 * Representa o nível de dificuldade de um flashcard
 */
export enum DifficultyLevel {
  EASY = 'EASY',
  MEDIUM = 'MEDIUM',
  HARD = 'HARD'
}

/**
 * Representa o status de um flashcard no processo de aprendizado
 */
export enum LearningStatus {
  NEW = 'NEW',
  LEARNING = 'LEARNING',
  REVIEWING = 'REVIEWING',
  MASTERED = 'MASTERED'
}

/**
 * Interface base para todas as entidades
 */
interface BaseEntity {
  id: ObjectId;
  createdAt: Date;
  updatedAt: Date;
  isActive: boolean;
}

/**
 * Representa um usuário no sistema
 */
export interface User extends BaseEntity {
  email: string;
  name: string;
  photoUrl?: string;
  preferences: {
    dailyGoal: number;
    notificationsEnabled: boolean;
    theme: 'light' | 'dark';
    language: string;
  };
  statistics: {
    totalCards: number;
    masteredCards: number;
    streakDays: number;
    lastActivity: Date;
  };
  decks: ObjectId[]; // Referência aos decks do usuário
}

/**
 * Representa um deck de flashcards
 */
export interface Deck extends BaseEntity {
  name: string;
  description: string;
  category: string;
  tags: string[];
  owner: ObjectId; // Referência ao usuário criador
  isPublic: boolean;
  statistics: {
    totalCards: number;
    activeUsers: number;
    averageCompletion: number;
  };
  flashcards: ObjectId[]; // Referência aos flashcards
}

/**
 * Representa um flashcard individual
 */
export interface Flashcard extends BaseEntity {
  deckId: ObjectId; // Referência ao deck pai
  front: {
    content: string;
    type: 'text' | 'image' | 'audio';
    mediaUrl?: string;
  };
  back: {
    content: string;
    type: 'text' | 'image' | 'audio';
    mediaUrl?: string;
  };
  supportPhrases: {
    content: string;
    generatedAt: Date;
    aiModel: string;
  }[];
  sm2Data: {
    interval: number; // Em dias
    repetitions: number;
    easeFactor: number;
    nextReview: Date;
    lastDifficulty: DifficultyLevel;
  };
  learningStatus: LearningStatus;
  tags: string[];
}

/**
 * Representa uma sessão de treino
 */
export interface TrainingSession extends BaseEntity {
  userId: ObjectId; // Referência ao usuário
  deckId: ObjectId; // Referência ao deck
  startTime: Date;
  endTime?: Date;
  reviews: {
    flashcardId: ObjectId;
    difficulty: DifficultyLevel;
    timeSpent: number; // Em segundos
    supportPhrasesShown: boolean;
  }[];
  statistics: {
    totalCards: number;
    correctAnswers: number;
    averageTimePerCard: number;
    masteredCards: number;
  };
}

/**
 * Representa o progresso do usuário em um deck específico
 */
export interface UserDeckProgress extends BaseEntity {
  userId: ObjectId;
  deckId: ObjectId;
  lastSession: Date;
  statistics: {
    totalReviews: number;
    masteredCards: number;
    streakDays: number;
    completionRate: number;
  };
  cardProgress: {
    flashcardId: ObjectId;
    learningStatus: LearningStatus;
    nextReview: Date;
    reviewHistory: {
      date: Date;
      difficulty: DifficultyLevel;
    }[];
  }[];
}

/**
 * Representa uma notificação para o usuário
 */
export interface UserNotification extends BaseEntity {
  userId: ObjectId;
  type: 'reminder' | 'achievement' | 'system';
  title: string;
  message: string;
  read: boolean;
  actionUrl?: string;
  metadata?: Record<string, any>;
}

/**
 * Representa uma conquista do usuário
 */
export interface Achievement extends BaseEntity {
  userId: ObjectId;
  type: string;
  title: string;
  description: string;
  unlockedAt: Date;
  metadata: {
    criteria: Record<string, any>;
    progress: number;
    maxProgress: number;
  };
}
