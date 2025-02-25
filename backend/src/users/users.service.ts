import { Injectable, NotFoundException } from '@nestjs/common';
import { FirebaseService } from '../firebase/firebase.service';
import { CreateUserDto } from './dto/create-user.dto';
import { UpdateUserDto } from './dto/update-user.dto';

@Injectable()
export class UsersService {
  private readonly collection = 'users';

  constructor(private readonly firebaseService: FirebaseService) {}

  async create(createUserDto: CreateUserDto) {
    await this.firebaseService.setDocument(
      this.collection,
      createUserDto.id,
      {
        ...createUserDto,
        createdAt: new Date(),
        updatedAt: new Date(),
      },
    );

    return this.findById(createUserDto.id);
  }

  async findById(id: string) {
    const user = await this.firebaseService.getDocument(this.collection, id);
    
    if (!user) {
      throw new NotFoundException('Usuário não encontrado');
    }

    return {
      id,
      ...user,
    };
  }

  async update(id: string, updateUserDto: UpdateUserDto) {
    const user = await this.findById(id);

    await this.firebaseService.updateDocument(
      this.collection,
      id,
      {
        ...updateUserDto,
        updatedAt: new Date(),
      },
    );

    return this.findById(id);
  }

  async updatePreferences(id: string, preferences: any) {
    const user = await this.findById(id);

    await this.firebaseService.updateDocument(
      this.collection,
      id,
      {
        preferences,
        updatedAt: new Date(),
      },
    );

    return this.findById(id);
  }

  async updateStatistics(id: string, statistics: any) {
    const user = await this.findById(id);

    await this.firebaseService.updateDocument(
      this.collection,
      id,
      {
        statistics,
        updatedAt: new Date(),
      },
    );

    return this.findById(id);
  }

  async delete(id: string) {
    const user = await this.findById(id);
    await this.firebaseService.deleteDocument(this.collection, id);
    return { success: true };
  }
}
