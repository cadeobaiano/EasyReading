import { IsString, IsOptional, IsObject } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class UpdateUserDto {
  @ApiProperty({
    description: 'Nome do usuário',
    example: 'João Silva',
  })
  @IsString()
  @IsOptional()
  name?: string;

  @ApiProperty({
    description: 'URL da foto do perfil',
    example: 'https://example.com/photo.jpg',
  })
  @IsString()
  @IsOptional()
  photoUrl?: string;

  @ApiProperty({
    description: 'Preferências do usuário',
    example: {
      language: 'pt',
      isDarkMode: false,
      notificationSettings: {
        enabled: true,
        dailyReminder: true,
        reminderTime: '20:00',
      },
    },
  })
  @IsObject()
  @IsOptional()
  preferences?: any;
}
