import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:easyreading/main.dart' as app;
import 'package:mocktail/mocktail.dart';
import 'package:easyreading/features/auth/services/auth_service.dart';
import 'package:easyreading/features/study_session/services/study_session_service.dart';
import 'package:easyreading/features/deck/services/deck_service.dart';
import 'package:easyreading/features/sync/services/sync_service.dart';
import 'package:easyreading/core/network/network_info.dart';

class MockAuthService extends Mock implements AuthService {}
class MockStudySessionService extends Mock implements StudySessionService {}
class MockDeckService extends Mock implements DeckService {}
class MockSyncService extends Mock implements SyncService {}
class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late MockAuthService mockAuthService;
  late MockStudySessionService mockStudySessionService;
  late MockDeckService mockDeckService;
  late MockSyncService mockSyncService;
  late MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockAuthService = MockAuthService();
    mockStudySessionService = MockStudySessionService();
    mockDeckService = MockDeckService();
    mockSyncService = MockSyncService();
    mockNetworkInfo = MockNetworkInfo();
  });

  group('Cenários de Erro e Recuperação', () {
    testWidgets('Recuperação de falha na conexão', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Simula sem conexão
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);

      // Tenta sincronizar
      await tester.tap(find.text('Sincronizar'));
      await tester.pumpAndSettle();

      // Verifica mensagem de erro
      expect(find.text('Sem conexão com a internet'), findsOneWidget);
      expect(find.text('Tentar Novamente'), findsOneWidget);

      // Simula recuperação da conexão
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);

      // Tenta novamente
      await tester.tap(find.text('Tentar Novamente'));
      await tester.pumpAndSettle();

      // Verifica sucesso
      expect(find.text('Sincronização concluída'), findsOneWidget);
    });

    testWidgets('Recuperação de sessão interrompida', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      await _performLogin(tester);
      await tester.pumpAndSettle();

      // Inicia sessão
      await tester.tap(find.text('Praticar Agora'));
      await tester.pumpAndSettle();

      // Simula erro durante a sessão
      when(() => mockStudySessionService.saveProgress(any()))
          .thenThrow(Exception('Erro ao salvar progresso'));

      // Responde questão
      await _answerQuestion(tester);
      await tester.pumpAndSettle();

      // Verifica diálogo de erro
      expect(find.text('Erro ao salvar progresso'), findsOneWidget);
      expect(find.text('Continuar Offline'), findsOneWidget);
      expect(find.text('Tentar Sincronizar'), findsOneWidget);

      // Escolhe continuar offline
      await tester.tap(find.text('Continuar Offline'));
      await tester.pumpAndSettle();

      // Verifica se sessão continua
      expect(find.text('Próxima Palavra'), findsOneWidget);
    });

    testWidgets('Falha na importação de deck', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      await _performLogin(tester);
      await tester.pumpAndSettle();

      // Navega para Decks
      await tester.tap(find.text('Decks'));
      await tester.pumpAndSettle();

      // Simula erro na importação
      when(() => mockDeckService.importDeck(any()))
          .thenThrow(Exception('Arquivo inválido'));

      // Tenta importar
      await tester.tap(find.text('Importar Deck'));
      await tester.pumpAndSettle();

      // Verifica mensagem de erro
      expect(find.text('Erro ao importar deck'), findsOneWidget);
      expect(find.text('O arquivo selecionado é inválido'), findsOneWidget);
    });

    testWidgets('Timeout na sincronização', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      await _performLogin(tester);
      await tester.pumpAndSettle();

      // Simula timeout
      when(() => mockSyncService.syncData())
          .thenAnswer((_) async {
            await Future.delayed(const Duration(seconds: 31));
            throw Exception('Timeout');
          });

      // Inicia sincronização
      await tester.tap(find.text('Sincronizar'));
      await tester.pumpAndSettle();

      // Verifica mensagem de timeout
      expect(find.text('A sincronização demorou muito'), findsOneWidget);
      expect(find.text('Seus dados estão salvos localmente'), findsOneWidget);
    });

    testWidgets('Erro de permissão', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      await _performLogin(tester);
      await tester.pumpAndSettle();

      // Simula erro de permissão
      when(() => mockDeckService.createDeck(any()))
          .thenThrow(Exception('Permission denied'));

      // Tenta criar deck
      await tester.tap(find.text('Novo Deck'));
      await tester.pumpAndSettle();

      // Verifica mensagem de erro
      expect(find.text('Sem permissão'), findsOneWidget);
      expect(
        find.text('Você não tem permissão para criar novos decks'),
        findsOneWidget
      );
    });
  });
}

Future<void> _performLogin(WidgetTester tester) async {
  await tester.enterText(find.byKey(const Key('email_field')), 'test@example.com');
  await tester.enterText(find.byKey(const Key('password_field')), 'password123');
  await tester.tap(find.text('Entrar'));
}

Future<void> _answerQuestion(WidgetTester tester) async {
  await tester.tap(find.text('Sei'));
  await tester.pumpAndSettle();
}
