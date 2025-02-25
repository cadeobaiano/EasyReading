import { Module, Global } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { FirebaseService } from './firebase.service';

@Global()
@Module({
  imports: [ConfigModule],
  providers: [
    {
      provide: FirebaseService,
      useFactory: (configService: ConfigService) => {
        return new FirebaseService(configService);
      },
      inject: [ConfigService],
    },
  ],
  exports: [FirebaseService],
})
export class FirebaseModule {}
