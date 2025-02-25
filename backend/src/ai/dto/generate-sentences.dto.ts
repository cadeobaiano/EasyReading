import { IsString, IsNotEmpty, IsOptional } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class GenerateSentencesDto {
  @ApiProperty({
    description: 'ID do flashcard',
    example: 'abc123',
  })
  @IsString()
  @IsNotEmpty()
  flashcardId: string;

  @ApiProperty({
    description: 'Palavra ou termo do flashcard',
    example: 'perseverança',
  })
  @IsString()
  @IsNotEmpty()
  word: string;

  @ApiProperty({
    description: 'Definição da palavra',
    example: 'Qualidade de quem persevera; persistência, constância.',
  })
  @IsString()
  @IsNotEmpty()
  definition: string;

  @ApiProperty({
    description: 'Nível do usuário',
    example: 'intermediário',
    required: false,
  })
  @IsString()
  @IsOptional()
  userLevel?: string;
}

export class GenerateTipsDto {
  @ApiProperty({
    description: 'ID do flashcard',
    example: 'abc123',
  })
  @IsString()
  @IsNotEmpty()
  flashcardId: string;

  @ApiProperty({
    description: 'Palavra ou termo do flashcard',
    example: 'perseverança',
  })
  @IsString()
  @IsNotEmpty()
  word: string;

  @ApiProperty({
    description: 'Dificuldade reportada pelo usuário',
    example: 'difícil',
    enum: ['difícil', 'médio', 'fácil'],
  })
  @IsString()
  @IsNotEmpty()
  difficulty: 'difícil' | 'médio' | 'fácil';
}
