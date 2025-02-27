import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:easyreading/main.dart' as app;
import 'package:mocktail/mocktail.dart';
import 'package:easyreading/features/auth/services/auth_service.dart';
import 'package:easyreading/features/study_session/services/study_session_service.dart';
import 'package:easyreading/features/deck/services/deck_service.dart';
import 'package:easyreading/features/ai/services/openai_service.dart';

class MockAuthService extends Mock implements AuthService {}
class MockStudySessionService extends Mock implements StudySessionService {}
class MockDeckService extends Mock implements DeckService {}
class MockOpenAIService extends Mock implements OpenAIService {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late MockAuthService mockAuthService;
  late MockStudySessionService mockStudySessionService;
  late MockDeckService mockDeckService;
  late MockOpenAIService mockOpenAIService;

  setUp(() {
    mockAuthService = MockAuthService();
    mockStudySessionService = MockStudySessionService();
    mockDeckService = MockDeckService();
    mockOpenAIService = MockOpenAIService();
  });

  group('Fluxo Completo do App', () {
    testWidgets('Login até conclusão de sessão de estudo', (tester) async {
      // Inicializa o app
      app.main();
      await tester.pumpAndSettle();

      // 1. Login
      await _performLogin(tester);
      await tester.pumpAndSettle();

      // Verifica se está na tela inicial
      expect(find.text('Bem-vindo de volta!'), findsOneWidget);

      // 2. Navegação entre abas
      await _testTabNavigation(tester);

      // 3. Fluxo "Praticar Agora"
      await _testPracticeNowFlow(tester);

      // 4. Verificação do feedback final
      await _verifyFeedback(tester);
    });

    testWidgets('Fluxo de Revisão de Erros', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      await _performLogin(tester);
      await tester.pumpAndSettle();

      // Navega para "Revisar Erros"
      await tester.tap(find.text('Revisar Erros'));
      await tester.pumpAndSettle();

      // Verifica se está na tela de revisão
      expect(find.text('Revisão de Palavras'), findsOneWidget);

      // Completa a sessão de revisão
      await _completeReviewSession(tester);

      // Verifica feedback específico de revisão
      expect(find.text('Revisão Concluída!'), findsOneWidget);
    });

    testWidgets('Visualização de Palavras e Estatísticas', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      await _performLogin(tester);
      await tester.pumpAndSettle();

      // Navega para "Ver Palavras"
      await tester.tap(find.text('Ver Palavras'));
      await tester.pumpAndSettle();

      // Verifica elementos da lista de palavras
      expect(find.text('Palavras Aprendidas'), findsOneWidget);
      expect(find.byType(ListView), findsOneWidget);

      // Verifica estatísticas
      await _checkStatistics(tester);
    });
  });

  group('Cenários de Erro', () {
    testWidgets('Falha na autenticação', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Simula falha no login
      when(() => mockAuthService.signIn(any(), any()))
          .thenThrow(Exception('Falha na autenticação'));

      // Tenta fazer login
      await _performLogin(tester);
      await tester.pumpAndSettle();

      // Verifica mensagem de erro
      expect(find.text('Não foi possível fazer login. Tente novamente.'), findsOneWidget);
    });

    testWidgets('Falha na sincronização de deck', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      await _performLogin(tester);
      await tester.pumpAndSettle();

      // Simula falha na sincronização
      when(() => mockDeckService.syncDecks())
          .thenThrow(Exception('Erro de sincronização'));

      // Navega para aba Decks
      await tester.tap(find.text('Decks'));
      await tester.pumpAndSettle();

      // Verifica mensagem de erro e botão de retry
      expect(find.text('Erro ao sincronizar decks'), findsOneWidget);
      expect(find.text('Tentar Novamente'), findsOneWidget);

      // Tenta sincronizar novamente
      await tester.tap(find.text('Tentar Novamente'));
      await tester.pumpAndSettle();
    });

    testWidgets('Falha na API OpenAI', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      await _performLogin(tester);
      await tester.pumpAndSettle();

      // Simula falha na API
      when(() => mockOpenAIService.generateSupportPhrase(
        context: any(named: 'context'),
        difficulty: any(named: 'difficulty'),
      )).thenThrow(Exception('API Error'));

      // Inicia sessão de estudo
      await _startStudySession(tester);

      // Verifica se mensagem padrão é exibida
      expect(find.text('Continue praticando! Você está indo bem.'), findsOneWidget);
    });
  });
}

Future<void> _performLogin(WidgetTester tester) async {
  await tester.enterText(find.byKey(const Key('email_field')), 'test@example.com');
  await tester.enterText(find.byKey(const Key('password_field')), 'password123');
  await tester.tap(find.text('Entrar'));
}

Future<void> _testTabNavigation(WidgetTester tester) async {
  // Home -> Decks
  await tester.tap(find.text('Decks'));
  await tester.pumpAndSettle();
  expect(find.text('Meus Decks'), findsOneWidget);

  // Decks -> Perfil
  await tester.tap(find.text('Perfil'));
  await tester.pumpAndSettle();
  expect(find.text('Meu Perfil'), findsOneWidget);

  // Perfil -> Home
  await tester.tap(find.text('Home'));
  await tester.pumpAndSettle();
  expect(find.text('Praticar Agora'), findsOneWidget);
}

Future<void> _testPracticeNowFlow(WidgetTester tester) async {
  await tester.tap(find.text('Praticar Agora'));
  await tester.pumpAndSettle();

  // Simula respostas do usuário
  for (var i = 0; i < 5; i++) {
    await _answerQuestion(tester, correct: i % 2 == 0);
    await tester.pumpAndSettle();
  }
}

Future<void> _answerQuestion(WidgetTester tester, {required bool correct}) async {
  if (correct) {
    await tester.tap(find.text('Sei'));
  } else {
    await tester.tap(find.text('Não Sei'));
  }
  await tester.pumpAndSettle();
}

Future<void> _verifyFeedback(WidgetTester tester) async {
  expect(find.text('Sessão Concluída!'), findsOneWidget);
  expect(find.textContaining('Taxa de Acerto:'), findsOneWidget);
  expect(find.textContaining('Palavras Aprendidas:'), findsOneWidget);
  expect(find.textContaining('Progresso:'), findsOneWidget);
}

Future<void> _completeReviewSession(WidgetTester tester) async {
  // Simula revisão de 3 palavras
  for (var i = 0; i < 3; i++) {
    await _answerQuestion(tester, correct: true);
    await tester.pumpAndSettle();
  }
}

Future<void> _checkStatistics(WidgetTester tester) async {
  expect(find.textContaining('Total de Palavras:'), findsOneWidget);
  expect(find.textContaining('Média de Acertos:'), findsOneWidget);
  expect(find.textContaining('Tempo de Estudo:'), findsOneWidget);
}

Future<void> _startStudySession(WidgetTester tester) async {
  await tester.tap(find.text('Praticar Agora'));
  await tester.pumpAndSettle();
  
  // Responde primeira questão
  await _answerQuestion(tester, correct: true);
  await tester.pumpAndSettle();
}
