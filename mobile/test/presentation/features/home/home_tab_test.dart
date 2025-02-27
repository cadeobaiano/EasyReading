import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:easyreading/presentation/features/home/home_tab.dart';
import 'package:easyreading/presentation/blocs/auth/auth_bloc.dart';
import 'package:easyreading/domain/models/user_model.dart';

class MockAuthBloc extends Mock implements AuthBloc {}
class MockGoRouter extends Mock implements GoRouter {}

void main() {
  late MockAuthBloc mockAuthBloc;
  late MockGoRouter mockGoRouter;

  setUp(() {
    mockAuthBloc = MockAuthBloc();
    mockGoRouter = MockGoRouter();

    // Configurar comportamento padrão do AuthBloc
    when(() => mockAuthBloc.state).thenReturn(
      AuthState.authenticated(
        UserModel(
          id: 'test-user',
          email: 'test@example.com',
          name: 'Test User',
        ),
      ),
    );
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>.value(value: mockAuthBloc),
        ],
        child: InheritedGoRouter(
          goRouter: mockGoRouter,
          child: const HomeTab(),
        ),
      ),
    );
  }

  group('HomeTab', () {
    testWidgets('exibe todos os botões principais', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Praticar Agora'), findsOneWidget);
      expect(find.text('Ver Palavras'), findsOneWidget);
      expect(find.text('Revisar Erros'), findsOneWidget);
    });

    testWidgets('exibe estatísticas do usuário', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.byType(Card), findsNWidgets(3)); // Cards de estatísticas
      expect(find.byIcon(Icons.trending_up), findsOneWidget); // Ícone de progresso
    });

    testWidgets('navega para sessão de estudo ao clicar em Praticar Agora',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Praticar Agora'));
      await tester.pumpAndSettle();

      verify(() => mockGoRouter.push('/study-session')).called(1);
    });

    testWidgets('navega para portal de palavras ao clicar em Ver Palavras',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Ver Palavras'));
      await tester.pumpAndSettle();

      verify(() => mockGoRouter.push('/word-portal')).called(1);
    });

    testWidgets('navega para revisão ao clicar em Revisar Erros', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Revisar Erros'));
      await tester.pumpAndSettle();

      verify(() => mockGoRouter.push('/review-errors')).called(1);
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
  });
}
