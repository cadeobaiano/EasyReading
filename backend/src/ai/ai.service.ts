import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import OpenAI from 'openai';
import { SpacedRepetitionService } from '../spaced-repetition/spaced-repetition.service';

@Injectable()
export class AiService {
  private readonly openai: OpenAI;
  private readonly logger = new Logger(AiService.name);

  constructor(
    private readonly configService: ConfigService,
    private readonly spacedRepetitionService: SpacedRepetitionService,
  ) {
    this.openai = new OpenAI({
      apiKey: this.configService.get<string>('OPENAI_API_KEY'),
    });
  }

  /**
   * Gera frases de apoio contextuais para um flashcard
   */
  async generateSupportSentences(
    userId: string,
    flashcardId: string,
    word: string,
    definition: string,
    userLevel: string = 'intermediário',
  ) {
    try {
      // Obter estatísticas do usuário para personalização
      const userStats = await this.spacedRepetitionService.getUserStatistics(userId);
      
      // Determinar o nível de dificuldade baseado nas estatísticas
      const difficulty = this.calculateDifficulty(userStats);

      const prompt = this.createPrompt(word, definition, difficulty, userLevel);

      const response = await this.openai.chat.completions.create({
        model: 'gpt-4',
        messages: [
          {
            role: 'system',
            content: `Você é um assistente especializado em ensino de idiomas. 
            Gere três frases de exemplo em português que utilizem a palavra fornecida.
            As frases devem ser naturais, contextuais e adequadas ao nível do aluno.
            Cada frase deve demonstrar um uso diferente ou contexto da palavra.
            Formate a saída como um array JSON com três strings.`,
          },
          {
            role: 'user',
            content: prompt,
          },
        ],
        temperature: 0.7,
        max_tokens: 300,
      });

      const content = response.choices[0]?.message?.content;
      if (!content) {
        throw new Error('Não foi possível gerar frases de apoio');
      }

      // Parse do JSON retornado
      try {
        const sentences = JSON.parse(content);
        return Array.isArray(sentences) ? sentences.slice(0, 3) : [];
      } catch (error) {
        this.logger.error('Erro ao fazer parse das frases geradas:', error);
        return [];
      }
    } catch (error) {
      this.logger.error('Erro ao gerar frases de apoio:', error);
      throw new Error('Erro ao gerar frases de apoio');
    }
  }

  /**
   * Calcula a dificuldade apropriada baseada nas estatísticas do usuário
   */
  private calculateDifficulty(userStats: any): string {
    const { masteredCards, totalCards, averageEaseFactor } = userStats;
    
    if (totalCards === 0) return 'básico';
    
    const masteryRate = masteredCards / totalCards;
    
    if (masteryRate > 0.8 && averageEaseFactor > 2.5) {
      return 'avançado';
    } else if (masteryRate > 0.5 && averageEaseFactor > 2.0) {
      return 'intermediário';
    } else {
      return 'básico';
    }
  }

  /**
   * Cria o prompt para a API da OpenAI
   */
  private createPrompt(
    word: string,
    definition: string,
    difficulty: string,
    userLevel: string,
  ): string {
    return `
    Palavra: "${word}"
    Definição: "${definition}"
    Nível do usuário: ${userLevel}
    Dificuldade sugerida: ${difficulty}

    Por favor, gere três frases de exemplo que:
    1. Usem a palavra de forma natural e contextual
    2. Sejam apropriadas para o nível ${userLevel}
    3. Demonstrem diferentes usos ou contextos da palavra
    4. Sejam claras e fáceis de entender
    5. Ajudem a reforçar o significado da palavra

    Retorne apenas um array JSON com as três frases, sem explicações adicionais.
    `;
  }

  /**
   * Gera dicas personalizadas para ajudar no aprendizado
   */
  async generateLearningTips(
    userId: string,
    flashcardId: string,
    word: string,
    userDifficulty: 'difícil' | 'médio' | 'fácil',
  ) {
    try {
      const userStats = await this.spacedRepetitionService.getUserStatistics(userId);
      
      const prompt = `
        Palavra: "${word}"
        Dificuldade reportada: ${userDifficulty}
        Nível de domínio: ${this.calculateDifficulty(userStats)}

        Gere uma dica personalizada para ajudar o usuário a memorizar esta palavra.
        A dica deve ser específica para o nível de dificuldade reportado e considerar
        o nível atual de domínio do usuário.
      `;

      const response = await this.openai.chat.completions.create({
        model: 'gpt-4',
        messages: [
          {
            role: 'system',
            content: 'Você é um tutor especializado em técnicas de memorização e aprendizado de idiomas.',
          },
          {
            role: 'user',
            content: prompt,
          },
        ],
        temperature: 0.7,
        max_tokens: 150,
      });

      return response.choices[0]?.message?.content || 'Não foi possível gerar uma dica';
    } catch (error) {
      this.logger.error('Erro ao gerar dica de aprendizado:', error);
      throw new Error('Erro ao gerar dica de aprendizado');
    }
  }
}
