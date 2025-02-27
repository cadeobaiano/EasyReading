import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:easyreading/presentation/features/profile/profile_tab.dart';
import 'package:easyreading/presentation/blocs/profile/profile_bloc.dart';
import 'package:easyreading/domain/models/user_model.dart';
import 'package:easyreading/domain/models/user_statistics.dart';

class MockProfileBloc extends Mock implements ProfileBloc {}
class MockGoRouter extends Mock implements GoRouter {}

void main() {
  late MockProfileBloc mockProfileBloc;
  late MockGoRouter mockGoRouter;

  setUp(() {
    mockProfileBloc = MockProfileBloc();
    mockGoRouter = MockGoRouter();

    // Configurar estado inicial do ProfileBloc
    when(() => mockProfileBloc.state).thenReturn(
      ProfileState(
        profile: UserModel(
          id: 'user-1',
          email: 'test@example.com',
          name: 'Test User',
          photoUrl: 'https://example.com/photo.jpg',
        ),
        statistics: UserStatistics(
          totalWords: 100,
          masteredWords: 40,
          averageAccuracy: 0.75,
          studyStreak: 5,
          totalStudyTime: Duration(hours: 10),
          lastStudySession: DateTime.now(),
        ),
        isLoading: false,
        error: null,
      ),
    );
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider<ProfileBloc>.value(value: mockProfileBloc),
        ],
        child: InheritedGoRouter(
          goRouter: mockGoRouter,
          child: const ProfileTab(),
        ),
      ),
    );
  }

  group('ProfileTab', () {
    testWidgets('exibe informações do perfil corretamente', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Test User'), findsOneWidget);
      expect(find.text('test@example.com'), findsOneWidget);
    });

    testWidgets('exibe estatísticas do usuário', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('100 palavras'), findsOneWidget);
      expect(find.text('40 dominadas'), findsOneWidget);
      expect(find.text('75% precisão'), findsOneWidget);
      expect(find.text('5 dias seguidos'), findsOneWidget);
    });

    testWidgets('exibe seção de configurações', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Configurações'), findsOneWidget);
      expect(find.byIcon(Icons.notifications), findsOneWidget);
      expect(find.byIcon(Icons.language), findsOneWidget);
      expect(find.byIcon(Icons.dark_mode), findsOneWidget);
    });

    testWidgets('permite editar perfil', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.edit));
      await tester.pumpAndSettle();

      expect(find.text('Editar Perfil'), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(2)); // Nome e foto URL
    });

    testWidgets('exibe gráfico de progresso', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.byType(Card), findsNWidgets(4)); // Cards de estatísticas
      expect(find.text('Progresso'), findsOneWidget);
    });

    testWidgets('é responsivo em diferentes tamanhos de tela', (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 480)); // Tela pequena
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.byType(SingleChildScrollView), findsOneWidget);
      
      await tester.binding.setSurfaceSize(const Size(1024, 768)); // Tela grande
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('permite fazer logout', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Sair'));
      await tester.pumpAndSettle();

      // Verifica se o diálogo de confirmação é exibido
      expect(find.text('Deseja realmente sair?'), findsOneWidget);
      
      // Confirma o logout
      await tester.tap(find.text('Sim'));
      await tester.pumpAndSettle();

      verify(() => mockProfileBloc.add(LogoutRequested())).called(1);
    });
  });
}
