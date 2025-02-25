import {
  Controller,
  Get,
  Put,
  Delete,
  Body,
  Param,
  UseGuards,
  Request,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiResponse } from '@nestjs/swagger';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { UsersService } from './users.service';
import { UpdateUserDto } from './dto/update-user.dto';

@ApiTags('Usuários')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('users')
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Get('profile')
  @ApiOperation({ summary: 'Obter perfil do usuário atual' })
  @ApiResponse({ status: 200, description: 'Perfil obtido com sucesso' })
  async getProfile(@Request() req) {
    return this.usersService.findById(req.user.id);
  }

  @Put('profile')
  @ApiOperation({ summary: 'Atualizar perfil do usuário atual' })
  @ApiResponse({ status: 200, description: 'Perfil atualizado com sucesso' })
  async updateProfile(@Request() req, @Body() updateUserDto: UpdateUserDto) {
    return this.usersService.update(req.user.id, updateUserDto);
  }

  @Put('preferences')
  @ApiOperation({ summary: 'Atualizar preferências do usuário' })
  @ApiResponse({ status: 200, description: 'Preferências atualizadas com sucesso' })
  async updatePreferences(@Request() req, @Body() preferences: any) {
    return this.usersService.updatePreferences(req.user.id, preferences);
  }

  @Delete('profile')
  @ApiOperation({ summary: 'Excluir conta do usuário atual' })
  @ApiResponse({ status: 200, description: 'Conta excluída com sucesso' })
  async deleteProfile(@Request() req) {
    return this.usersService.delete(req.user.id);
  }
}
