import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Configurações padrão do Firebase para o projeto EasyReading
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'Configurações para Web não definidas.',
      );
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'Plataforma ${defaultTargetPlatform.toString()} não suportada',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDqWbHQ8l8KeueAVzrBW7p6DvfESVY5MMI',
    appId: '1:662523299244:android:28c744d190ee536b7ae609',
    messagingSenderId: '662523299244',
    projectId: 'easyreading-a2bde',
    storageBucket: 'easyreading-a2bde.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    // TODO: Adicionar configurações do iOS quando o app for registrado
    apiKey: 'PLACEHOLDER',
    appId: 'PLACEHOLDER',
    messagingSenderId: '662523299244',
    projectId: 'easyreading-a2bde',
    storageBucket: 'easyreading-a2bde.firebasestorage.app',
  );
}
