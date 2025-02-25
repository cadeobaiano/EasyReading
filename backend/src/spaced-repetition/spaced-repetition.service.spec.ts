import { Test, TestingModule } from '@nestjs/testing';
import { SpacedRepetitionService } from './spaced-repetition.service';
import { FirebaseService } from '../firebase/firebase.service';
import { ReviewQuality } from './models/sm2-data.model';

describe('SpacedRepetitionService', () => {
  let service: SpacedRepetitionService;
  let firebaseService: FirebaseService;

  const mockFirebaseService = {
    getDocument: jest.fn(),
    setDocument: jest.fn(),
    queryCollection: jest.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        SpacedRepetitionService,
        {
          provide: FirebaseService,
          useValue: mockFirebaseService,
        },
      ],
    }).compile();

    service = module.get<SpacedRepetitionService>(SpacedRepetitionService);
    firebaseService = module.get<FirebaseService>(FirebaseService);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  describe('processReview', () => {
    it('should process a new flashcard review correctly', async () => {
      // Arrange
      const review = {
        userId: 'user123',
        flashcardId: 'card456',
        quality: ReviewQuality.EASY,
        reviewDate: new Date(),
      };

      mockFirebaseService.getDocument.mockResolvedValueOnce(null);

      // Act
      const result = await service.processReview(review);

      // Assert
      expect(result.repetitions).toBe(1);
      expect(result.interval).toBe(1);
      expect(result.easeFactor).toBeGreaterThan(2.5);
      expect(firebaseService.setDocument).toHaveBeenCalled();
    });

    it('should update existing flashcard review correctly', async () => {
      // Arrange
      const review = {
        userId: 'user123',
        flashcardId: 'card456',
        quality: ReviewQuality.EASY,
        reviewDate: new Date(),
      };

      const existingProgress = {
        repetitions: 1,
        easeFactor: 2.5,
        interval: 1,
        nextReviewDate: new Date(),
        lastReviewDate: new Date(),
        lastQuality: ReviewQuality.EASY,
      };

      mockFirebaseService.getDocument.mockResolvedValueOnce(existingProgress);

      // Act
      const result = await service.processReview(review);

      // Assert
      expect(result.repetitions).toBe(2);
      expect(result.interval).toBe(6);
      expect(result.easeFactor).toBeGreaterThan(2.5);
      expect(firebaseService.setDocument).toHaveBeenCalled();
    });

    it('should reset progress for difficult reviews', async () => {
      // Arrange
      const review = {
        userId: 'user123',
        flashcardId: 'card456',
        quality: ReviewQuality.DIFFICULT,
        reviewDate: new Date(),
      };

      const existingProgress = {
        repetitions: 2,
        easeFactor: 2.5,
        interval: 6,
        nextReviewDate: new Date(),
        lastReviewDate: new Date(),
        lastQuality: ReviewQuality.EASY,
      };

      mockFirebaseService.getDocument.mockResolvedValueOnce(existingProgress);

      // Act
      const result = await service.processReview(review);

      // Assert
      expect(result.repetitions).toBe(0);
      expect(result.interval).toBe(1);
      expect(result.easeFactor).toBeLessThan(2.5);
      expect(firebaseService.setDocument).toHaveBeenCalled();
    });
  });

  describe('getDueFlashcards', () => {
    it('should return flashcards due for review', async () => {
      // Arrange
      const userId = 'user123';
      const mockDueCards = {
        docs: [
          { id: 'user123_card1' },
          { id: 'user123_card2' },
        ],
      };

      mockFirebaseService.queryCollection.mockResolvedValueOnce(mockDueCards);

      // Act
      const result = await service.getDueFlashcards(userId);

      // Assert
      expect(result).toHaveLength(2);
      expect(result).toContain('card1');
      expect(result).toContain('card2');
    });
  });

  describe('getUserStatistics', () => {
    it('should calculate user statistics correctly', async () => {
      // Arrange
      const userId = 'user123';
      const mockCards = {
        size: 5,
        docs: [
          { data: () => ({ repetitions: 5, easeFactor: 2.6 }) },
          { data: () => ({ repetitions: 3, easeFactor: 2.3 }) },
          { data: () => ({ repetitions: 0, easeFactor: 2.5 }) },
          { data: () => ({ repetitions: 6, easeFactor: 2.7 }) },
          { data: () => ({ repetitions: 1, easeFactor: 2.2 }) },
        ],
      };

      mockFirebaseService.queryCollection.mockResolvedValueOnce(mockCards);

      // Act
      const stats = await service.getUserStatistics(userId);

      // Assert
      expect(stats.totalCards).toBe(5);
      expect(stats.masteredCards).toBe(2); // Cards com repetitions >= 5 e easeFactor > 2.5
      expect(stats.learningCards).toBe(2); // Cards com 0 < repetitions < 5
      expect(stats.newCards).toBe(1); // Cards com repetitions = 0
      expect(stats.averageEaseFactor).toBeCloseTo(2.46);
    });
  });

  describe('convertUserRatingToQuality', () => {
    it('should convert user ratings to SM2 quality values correctly', () => {
      expect(service.convertUserRatingToQuality('difícil')).toBe(ReviewQuality.HARD);
      expect(service.convertUserRatingToQuality('médio')).toBe(ReviewQuality.MEDIUM);
      expect(service.convertUserRatingToQuality('fácil')).toBe(ReviewQuality.EASY);
    });
  });
});
