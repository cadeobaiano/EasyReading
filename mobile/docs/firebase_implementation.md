# Implementação do Firebase no EasyReading

Este documento detalha a implementação dos serviços do Firebase no aplicativo EasyReading, especificamente para a plataforma Android.

## Serviços Firebase Utilizados

- **Firebase Authentication**: Para autenticação de usuários
- **Cloud Firestore**: Para armazenamento e sincronização de dados em tempo real
- **Firebase Analytics**: Para análise de comportamento do usuário
- **Firebase Crashlytics**: Para monitoramento de erros e crashes
- **Firebase Cloud Messaging**: Para notificações push

## Configuração Inicial

### Pré-requisitos

- Conta Google com acesso ao [Firebase Console](https://console.firebase.google.com/)
- Flutter instalado (versão 3.29.0+)
- Dependências Flutter configuradas no `pubspec.yaml`

### 1. Criar Projeto no Firebase

1. Acesse o [Firebase Console](https://console.firebase.google.com/)
2. Clique em "Adicionar projeto"
3. Nomeie o projeto como "EasyReading"
4. Siga as instruções para criar o projeto

### 2. Adicionar Aplicativo Android

1. No console do Firebase, clique no ícone do Android para adicionar um aplicativo
2. Informe o pacote do aplicativo: `com.easyreading.app`
3. Adicione outras informações conforme solicitado (apelido, certificado SHA-1)
4. Baixe o arquivo `google-services.json`
5. Coloque o arquivo `google-services.json` no diretório `android/app/`

## Configuração das Dependências

### pubspec.yaml

Adicione as seguintes dependências ao arquivo `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Firebase Core
  firebase_core: ^2.16.0
  
  # Firebase Authentication
  firebase_auth: ^4.10.0
  
  # Cloud Firestore
  cloud_firestore: ^4.9.2
  
  # Firebase Analytics
  firebase_analytics: ^10.5.0
  
  # Firebase Crashlytics
  firebase_crashlytics: ^3.3.6
  
  # Firebase Cloud Messaging
  firebase_messaging: ^14.6.8
```

Execute `flutter pub get` para instalar as dependências.

## Inicialização do Firebase

### Inicialização Básica

Adicione o seguinte código ao seu arquivo `main.dart`:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializa o Firebase
  await Firebase.initializeApp();
  
  // Configura o Crashlytics
  if (!kDebugMode) {
    // Passa todos os erros não capturados para o Crashlytics
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
    
    // Captura erros que ocorrem durante o desenvolvimento assíncrono
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }
  
  runApp(const MyApp());
}
```

## Configuração do Firebase Analytics

### Implementação Básica

Crie um arquivo `analytics_service.dart` para gerenciar os eventos do Analytics:

```dart
import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  FirebaseAnalyticsObserver getAnalyticsObserver() {
    return FirebaseAnalyticsObserver(analytics: _analytics);
  }

  // Evento de início de sessão
  Future<void> logSessionStart() async {
    await _analytics.logAppOpen();
  }

  // Evento de login
  Future<void> logLogin(String method) async {
    await _analytics.logLogin(loginMethod: method);
  }

  // Evento de criação de conta
  Future<void> logSignUp(String method) async {
    await _analytics.logSignUp(signUpMethod: method);
  }

  // Evento de início de prática
  Future<void> logPracticeStart(String deckId, String deckName) async {
    await _analytics.logEvent(
      name: 'practice_start',
      parameters: {
        'deck_id': deckId,
        'deck_name': deckName,
      },
    );
  }

  // Evento de conclusão de prática
  Future<void> logPracticeComplete(
    String deckId, 
    String deckName, 
    int cardsReviewed, 
    int correctAnswers
  ) async {
    await _analytics.logEvent(
      name: 'practice_complete',
      parameters: {
        'deck_id': deckId,
        'deck_name': deckName,
        'cards_reviewed': cardsReviewed,
        'correct_answers': correctAnswers,
        'success_rate': cardsReviewed > 0 ? correctAnswers / cardsReviewed : 0,
      },
    );
  }

  // Evento de criação de deck
  Future<void> logDeckCreated(String deckId, String deckName, int cardCount) async {
    await _analytics.logEvent(
      name: 'deck_created',
      parameters: {
        'deck_id': deckId,
        'deck_name': deckName,
        'card_count': cardCount,
      },
    );
  }

  // Evento de importação de deck
  Future<void> logDeckImported(String deckId, String deckName, int cardCount, String source) async {
    await _analytics.logEvent(
      name: 'deck_imported',
      parameters: {
        'deck_id': deckId,
        'deck_name': deckName,
        'card_count': cardCount,
        'source': source,
      },
    );
  }

  // Evento de uso da IA
  Future<void> logAIUsage(String feature, bool success) async {
    await _analytics.logEvent(
      name: 'ai_feature_used',
      parameters: {
        'feature': feature,
        'success': success,
      },
    );
  }

  // Definir ID de usuário
  Future<void> setUserId(String userId) async {
    await _analytics.setUserId(id: userId);
  }

  // Definir propriedade de usuário
  Future<void> setUserProperty(String name, String value) async {
    await _analytics.setUserProperty(name: name, value: value);
  }
}
```

### Integração com o Router

Adicione o observador ao seu GoRouter:

```dart
import 'package:go_router/go_router.dart';
import 'analytics_service.dart';

final analyticsService = AnalyticsService();

final router = GoRouter(
  observers: [analyticsService.getAnalyticsObserver()],
  routes: [
    // suas rotas aqui
  ],
);
```

## Configuração do Firebase Crashlytics

### Relatório de Erros Manual

Para relatar erros manualmente no Crashlytics:

```dart
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

try {
  // Código que pode gerar erro
} catch (error, stackTrace) {
  // Registra o erro no Crashlytics
  FirebaseCrashlytics.instance.recordError(error, stackTrace, reason: 'Descrição do erro');
}
```

### Informações do Usuário

Para associar informações do usuário aos relatórios do Crashlytics:

```dart
// Definir ID do usuário
FirebaseCrashlytics.instance.setUserIdentifier(userId);

// Adicionar chaves personalizadas
FirebaseCrashlytics.instance.setCustomKey('role', userRole);
FirebaseCrashlytics.instance.setCustomKey('subscription_type', subscriptionType);
```

### Testar o Crashlytics

Para testar se o Crashlytics está funcionando corretamente:

```dart
// Força um crash para teste
FirebaseCrashlytics.instance.crash();
```

## Configuração do Firebase Cloud Messaging (FCM)

### Solicitar Permissões

```dart
import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> requestNotificationPermissions() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );
  
  print('User granted permission: ${settings.authorizationStatus}');
}
```

### Receber Token FCM

```dart
Future<String?> getFirebaseMessagingToken() async {
  return await FirebaseMessaging.instance.getToken();
}
```

### Manipulação de Mensagens

```dart
// Para mensagens em primeiro plano
FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  print('Mensagem recebida em primeiro plano: ${message.notification?.title}');
  // Exibir notificação local
});

// Para mensagens em segundo plano que são clicadas
FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
  print('Notificação aberta pelo usuário: ${message.notification?.title}');
  // Navegue para a tela apropriada
});

// Para mensagens recebidas quando o app está completamente fechado
FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
  if (message != null) {
    print('App aberto por notificação: ${message.notification?.title}');
    // Navegue para a tela apropriada
  }
});
```

## Tópicos FCM para Notificações Segmentadas

```dart
// Inscrever-se em um tópico (por exemplo, para novos conteúdos)
await FirebaseMessaging.instance.subscribeToTopic('new_content');

// Cancelar inscrição em um tópico
await FirebaseMessaging.instance.unsubscribeFromTopic('new_content');
```

## Próximos Passos

1. Configurar regras de segurança do Firestore para garantir a proteção dos dados
2. Implementar funções Cloud para processamento em segundo plano
3. Configurar o Remote Config para recursos baseados em flags
4. Implementar testes de integração para serviços Firebase

## Depuração

### Verificação de Logs do Crashlytics

1. No Firebase Console, acesse a seção Crashlytics
2. Verifique se há eventos de crash registrados
3. Analise os relatórios de erros para identificar problemas

### Verificação de Eventos do Analytics

1. No Firebase Console, acesse a seção Analytics
2. Verifique se os eventos estão sendo registrados
3. Crie audiências e relatórios personalizados conforme necessário

## Recursos

- [Documentação do Firebase para Flutter](https://firebase.google.com/docs/flutter/setup)
- [Documentação do Firebase Authentication](https://firebase.google.com/docs/auth)
- [Documentação do Firestore](https://firebase.google.com/docs/firestore)
- [Documentação do Firebase Analytics](https://firebase.google.com/docs/analytics)
- [Documentação do Firebase Crashlytics](https://firebase.google.com/docs/crashlytics)
- [Documentação do Firebase Cloud Messaging](https://firebase.google.com/docs/cloud-messaging)
