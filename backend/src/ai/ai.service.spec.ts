import { Test, TestingModule } from '@nestjs/testing';
import { ConfigService } from '@nestjs/config';
import { AiService } from './ai.service';
import { SpacedRepetitionService } from '../spaced-repetition/spaced-repetition.service';
import OpenAI from 'openai';

jest.mock('openai');

describe('AiService', () => {
  let service: AiService;
  let spacedRepetitionService: SpacedRepetitionService;
  let mockOpenAI: jest.Mocked<OpenAI>;

  const mockConfigService = {
    get: jest.fn().mockReturnValue('mock-api-key'),
  };

  const mockSpacedRepetitionService = {
    getUserStatistics: jest.fn(),
  };

  beforeEach(async () => {
    mockOpenAI = {
      chat: {
        completions: {
          create: jest.fn(),
        },
      },
    } as any;

    (OpenAI as jest.Mock).mockImplementation(() => mockOpenAI);

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        AiService,
        {
          provide: ConfigService,
          useValue: mockConfigService,
        },
        {
          provide: SpacedRepetitionService,
          useValue: mockSpacedRepetitionService,
        },
      ],
    }).compile();

    service = module.get<AiService>(AiService);
    spacedRepetitionService = module.get<SpacedRepetitionService>(SpacedRepetitionService);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  describe('generateSupportSentences', () => {
    const mockUserStats = {
      totalCards: 100,
      masteredCards: 60,
      averageEaseFactor: 2.6,
    };

    const mockOpenAIResponse = {
      choices: [
        {
          message: {
            content: '["Frase 1", "Frase 2", "Frase 3"]',
          },
        },
      ],
    };

    beforeEach(() => {
      mockSpacedRepetitionService.getUserStatistics.mockResolvedValue(mockUserStats);
      mockOpenAI.chat.completions.create.mockResolvedValue(mockOpenAIResponse as any);
    });

    it('should generate support sentences successfully', async () => {
      // Arrange
      const userId = 'user123';
      const flashcardId = 'card456';
      const word = 'perseverança';
      const definition = 'Qualidade de quem persevera';

      // Act
      const sentences = await service.generateSupportSentences(
        userId,
        flashcardId,
        word,
        definition,
      );

      // Assert
      expect(sentences).toHaveLength(3);
      expect(sentences).toContain('Frase 1');
      expect(sentences).toContain('Frase 2');
      expect(sentences).toContain('Frase 3');
      expect(mockOpenAI.chat.completions.create).toHaveBeenCalledTimes(1);
    });

    it('should adapt difficulty based on user statistics', async () => {
      // Arrange
      const advancedStats = {
        totalCards: 100,
        masteredCards: 85,
        averageEaseFactor: 2.8,
      };
      mockSpacedRepetitionService.getUserStatistics.mockResolvedValue(advancedStats);

      // Act
      await service.generateSupportSentences(
        'user123',
        'card456',
        'palavra',
        'definição',
      );

      // Assert
      const callArgs = mockOpenAI.chat.completions.create.mock.calls[0][0];
      expect(callArgs.messages[1].content).toContain('avançado');
    });

    it('should handle OpenAI API errors gracefully', async () => {
      // Arrange
      mockOpenAI.chat.completions.create.mockRejectedValue(new Error('API Error'));

      // Act & Assert
      await expect(
        service.generateSupportSentences(
          'user123',
          'card456',
          'palavra',
          'definição',
        ),
      ).rejects.toThrow('Erro ao gerar frases de apoio');
    });

    it('should handle invalid JSON response', async () => {
      // Arrange
      const invalidResponse = {
        choices: [
          {
            message: {
              content: 'Invalid JSON',
            },
          },
        ],
      };
      mockOpenAI.chat.completions.create.mockResolvedValue(invalidResponse as any);

      // Act
      const sentences = await service.generateSupportSentences(
        'user123',
        'card456',
        'palavra',
        'definição',
      );

      // Assert
      expect(sentences).toEqual([]);
    });
  });

  describe('generateLearningTips', () => {
    const mockUserStats = {
      totalCards: 50,
      masteredCards: 20,
      averageEaseFactor: 2.3,
    };

    const mockOpenAIResponse = {
      choices: [
        {
          message: {
            content: 'Dica personalizada para memorização',
          },
        },
      ],
    };

    beforeEach(() => {
      mockSpacedRepetitionService.getUserStatistics.mockResolvedValue(mockUserStats);
      mockOpenAI.chat.completions.create.mockResolvedValue(mockOpenAIResponse as any);
    });

    it('should generate learning tips based on difficulty', async () => {
      // Arrange
      const userId = 'user123';
      const flashcardId = 'card456';
      const word = 'palavra';
      const difficulty = 'difícil';

      // Act
      const tip = await service.generateLearningTips(
        userId,
        flashcardId,
        word,
        difficulty,
      );

      // Assert
      expect(tip).toBe('Dica personalizada para memorização');
      expect(mockOpenAI.chat.completions.create).toHaveBeenCalledTimes(1);
      const callArgs = mockOpenAI.chat.completions.create.mock.calls[0][0];
      expect(callArgs.messages[1].content).toContain(difficulty);
    });

    it('should handle API errors when generating tips', async () => {
      // Arrange
      mockOpenAI.chat.completions.create.mockRejectedValue(new Error('API Error'));

      // Act & Assert
      await expect(
        service.generateLearningTips(
          'user123',
          'card456',
          'palavra',
          'difícil',
        ),
      ).rejects.toThrow('Erro ao gerar dica de aprendizado');
    });
  });
});
