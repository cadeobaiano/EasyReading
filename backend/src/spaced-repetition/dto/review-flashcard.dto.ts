import { IsString, IsNotEmpty, IsEnum } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export enum UserRating {
  DIFICIL = 'difícil',
  MEDIO = 'médio',
  FACIL = 'fácil',
}

export class ReviewFlashcardDto {
  @ApiProperty({
    description: 'ID do flashcard',
    example: 'abc123',
  })
  @IsString()
  @IsNotEmpty()
  flashcardId: string;

  @ApiProperty({
    description: 'Classificação do usuário para o flashcard',
    enum: UserRating,
    example: 'médio',
  })
  @IsEnum(UserRating)
  @IsNotEmpty()
  rating: UserRating;
}
