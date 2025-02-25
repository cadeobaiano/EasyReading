import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { AiService } from './ai.service';
import { AiController } from './ai.controller';
import { SpacedRepetitionModule } from '../spaced-repetition/spaced-repetition.module';

@Module({
  imports: [
    ConfigModule,
    SpacedRepetitionModule,
  ],
  providers: [AiService],
  controllers: [AiController],
  exports: [AiService],
})
export class AiModule {}
