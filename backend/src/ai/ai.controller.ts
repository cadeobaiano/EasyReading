import {
  Controller,
  Post,
  Body,
  UseGuards,
  Request,
  HttpException,
  HttpStatus,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiResponse } from '@nestjs/swagger';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { AiService } from './ai.service';
import { GenerateSentencesDto, GenerateTipsDto } from './dto/generate-sentences.dto';

@ApiTags('Inteligência Artificial')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('ai')
export class AiController {
  constructor(private readonly aiService: AiService) {}

  @Post('generate-sentences')
  @ApiOperation({ summary: 'Gerar frases de apoio para flashcard' })
  @ApiResponse({ status: 200, description: 'Frases geradas com sucesso' })
  @ApiResponse({ status: 500, description: 'Erro ao gerar frases' })
  async generateSentences(
    @Request() req,
    @Body() generateDto: GenerateSentencesDto,
  ) {
    try {
      const sentences = await this.aiService.generateSupportSentences(
        req.user.id,
        generateDto.flashcardId,
        generateDto.word,
        generateDto.definition,
        generateDto.userLevel,
      );

      return {
        success: true,
        sentences,
      };
    } catch (error) {
      throw new HttpException(
        'Erro ao gerar frases de apoio',
        HttpStatus.INTERNAL_SERVER_ERROR,
      );
    }
  }

  @Post('generate-tips')
  @ApiOperation({ summary: 'Gerar dicas de aprendizado personalizadas' })
  @ApiResponse({ status: 200, description: 'Dica gerada com sucesso' })
  @ApiResponse({ status: 500, description: 'Erro ao gerar dica' })
  async generateTips(@Request() req, @Body() generateDto: GenerateTipsDto) {
    try {
      const tip = await this.aiService.generateLearningTips(
        req.user.id,
        generateDto.flashcardId,
        generateDto.word,
        generateDto.difficulty,
      );

      return {
        success: true,
        tip,
      };
    } catch (error) {
      throw new HttpException(
        'Erro ao gerar dica de aprendizado',
        HttpStatus.INTERNAL_SERVER_ERROR,
      );
    }
  }
}
