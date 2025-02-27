import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:easy_reading/presentation/features/main/main_screen.dart';
import 'package:easy_reading/presentation/blocs/auth/auth_bloc.dart';

class MockAuthBloc extends Mock implements AuthBloc {}
class MockGoRouter extends Mock implements GoRouter {}

void main() {
  late MockAuthBloc mockAuthBloc;
  late MockGoRouter mockGoRouter;

  setUp(() {
    mockAuthBloc = MockAuthBloc();
    mockGoRouter = MockGoRouter();

    when(() => mockGoRouter.location).thenReturn('/');
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>.value(value: mockAuthBloc),
        ],
        child: InheritedGoRouter(
          goRouter: mockGoRouter,
          child: const MainScreen(),
        ),
      ),
    );
  }

  group('MainScreen UI Tests', () {
    testWidgets('exibe bottom navigation bar com três itens', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.byType(BottomNavigationBar), findsOneWidget);
      expect(find.byIcon(Icons.home), findsOneWidget);
      expect(find.byIcon(Icons.library_books), findsOneWidget);
      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('navega entre as abas corretamente', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Verifica aba inicial (Home)
      expect(find.text('Home'), findsOneWidget);
      
      // Navega para Decks
      await tester.tap(find.byIcon(Icons.library_books));
      await tester.pumpAndSettle();
      expect(find.text('Decks'), findsOneWidget);

      // Navega para Profile
      await tester.tap(find.byIcon(Icons.person));
      await tester.pumpAndSettle();
      expect(find.text('Perfil'), findsOneWidget);
    });

    testGoldens('renderiza corretamente em diferentes tamanhos de tela', (tester) async {
      final builder = DeviceBuilder()
        ..overrideDevicesForAllScenarios(devices: [
          Device.phone,
          Device.iphone11,
          Device.tablet,
          Device.tabletLandscape,
        ])
        ..addScenario(
          widget: createWidgetUnderTest(),
          name: 'main_screen',
        );

      await tester.pumpDeviceBuilder(builder);
      await screenMatchesGolden(tester, 'main_screen_responsive');
    });

    testWidgets('mantém estado ao mudar orientação', (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 800));
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Navega para Decks
      await tester.tap(find.byIcon(Icons.library_books));
      await tester.pumpAndSettle();

      // Muda para landscape
      await tester.binding.setSurfaceSize(const Size(800, 400));
      await tester.pumpAndSettle();

      // Verifica se ainda está na aba Decks
      expect(find.text('Decks'), findsOneWidget);
    });
  });
}
