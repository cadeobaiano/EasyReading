import { IsString, IsNotEmpty } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class LoginDto {
  @ApiProperty({
    description: 'Token de autenticação do Firebase',
    example: 'eyJhbGciOiJSUzI1NiIsImtpZCI6IjFlOTczZWUzNjc...',
  })
  @IsString()
  @IsNotEmpty()
  firebaseToken: string;
}
