import { IsString, IsEmail, IsNotEmpty, IsObject } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class CreateUserDto {
  @ApiProperty({
    description: 'ID do usuário (UID do Firebase)',
    example: 'abc123xyz',
  })
  @IsString()
  @IsNotEmpty()
  id: string;

  @ApiProperty({
    description: 'Nome do usuário',
    example: 'João Silva',
  })
  @IsString()
  @IsNotEmpty()
  name: string;

  @ApiProperty({
    description: 'Email do usuário',
    example: 'joao@email.com',
  })
  @IsEmail()
  @IsNotEmpty()
  email: string;

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
  preferences: any;
}
