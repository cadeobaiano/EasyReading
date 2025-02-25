import {
  Controller,
  Post,
  Get,
  Body,
  UseGuards,
  Request,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiResponse } from '@nestjs/swagger';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { SpacedRepetitionService } from './spaced-repetition.service';
import { ReviewFlashcardDto } from './dto/review-flashcard.dto';

@ApiTags('Repetição Espaçada')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('spaced-repetition')
export class SpacedRepetitionController {
  constructor(private readonly spacedRepetitionService: SpacedRepetitionService) {}

  @Post('review')
  @ApiOperation({ summary: 'Registrar revisão de flashcard' })
  @ApiResponse({ status: 200, description: 'Revisão registrada com sucesso' })
  async reviewFlashcard(@Request() req, @Body() reviewDto: ReviewFlashcardDto) {
    const quality = this.spacedRepetitionService.convertUserRatingToQuality(
      reviewDto.rating,
    );

    const review = {
      userId: req.user.id,
      flashcardId: reviewDto.flashcardId,
      quality,
      reviewDate: new Date(),
    };

    return this.spacedRepetitionService.processReview(review);
  }

  @Get('due')
  @ApiOperation({ summary: 'Obter flashcards para revisão' })
  @ApiResponse({ status: 200, description: 'Lista de flashcards para revisar' })
  async getDueFlashcards(@Request() req) {
    return this.spacedRepetitionService.getDueFlashcards(req.user.id);
  }

  @Get('statistics')
  @ApiOperation({ summary: 'Obter estatísticas de revisão' })
  @ApiResponse({ status: 200, description: 'Estatísticas obtidas com sucesso' })
  async getStatistics(@Request() req) {
    return this.spacedRepetitionService.getUserStatistics(req.user.id);
  }
}
