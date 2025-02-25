import { Injectable, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { FirebaseService } from '../firebase/firebase.service';
import { UsersService } from '../users/users.service';
import { LoginDto } from './dto/login.dto';
import { RegisterDto } from './dto/register.dto';

@Injectable()
export class AuthService {
  constructor(
    private readonly firebaseService: FirebaseService,
    private readonly usersService: UsersService,
    private readonly jwtService: JwtService,
  ) {}

  async validateFirebaseToken(token: string) {
    try {
      const decodedToken = await this.firebaseService.verifyToken(token);
      return decodedToken;
    } catch (error) {
      throw new UnauthorizedException('Token inválido');
    }
  }

  async login(loginDto: LoginDto) {
    try {
      const decodedToken = await this.validateFirebaseToken(loginDto.firebaseToken);
      const user = await this.usersService.findById(decodedToken.uid);

      if (!user) {
        throw new UnauthorizedException('Usuário não encontrado');
      }

      const accessToken = this.generateToken(user);

      return {
        user,
        accessToken,
      };
    } catch (error) {
      throw new UnauthorizedException('Credenciais inválidas');
    }
  }

  async register(registerDto: RegisterDto) {
    try {
      // Criar usuário no Firebase Authentication
      const firebaseUser = await this.firebaseService.createUser(
        registerDto.email,
        registerDto.password,
      );

      // Criar perfil do usuário no Firestore
      const user = await this.usersService.create({
        id: firebaseUser.uid,
        email: registerDto.email,
        name: registerDto.name,
        preferences: {
          language: 'pt',
          isDarkMode: false,
          notificationSettings: {
            enabled: true,
            dailyReminder: true,
            reminderTime: '20:00',
          },
        },
      });

      const accessToken = this.generateToken(user);

      return {
        user,
        accessToken,
      };
    } catch (error) {
      // Se houver erro, limpar usuário criado no Firebase
      if (error.uid) {
        await this.firebaseService.deleteUser(error.uid);
      }
      throw error;
    }
  }

  private generateToken(user: any) {
    const payload = {
      sub: user.id,
      email: user.email,
    };

    return this.jwtService.sign(payload);
  }
}
