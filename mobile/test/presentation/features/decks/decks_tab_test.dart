import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:easyreading/presentation/features/decks/decks_tab.dart';
import 'package:easyreading/presentation/blocs/decks/decks_bloc.dart';
import 'package:easyreading/domain/models/deck_model.dart';

class MockDecksBloc extends Mock implements DecksBloc {}
class MockGoRouter extends Mock implements GoRouter {}

void main() {
  late MockDecksBloc mockDecksBloc;
  late MockGoRouter mockGoRouter;

  setUp(() {
    mockDecksBloc = MockDecksBloc();
    mockGoRouter = MockGoRouter();

    // Configurar estado inicial do DecksBloc
    when(() => mockDecksBloc.state).thenReturn(
      DecksState(
        decks: [
          DeckModel(
            id: 'deck-1',
            userId: 'user-1',
            title: 'Vocabulário Básico',
            description: 'Palavras do dia a dia',
            visibility: 'public',
            tags: ['básico'],
            collaborators: [],
            stats: DeckStats(totalCards: 50, masteredCards: 20),
          ),
          DeckModel(
            id: 'deck-2',
            userId: 'user-1',
            title: 'Expressões Idiomáticas',
            description: 'Expressões comuns',
            visibility: 'private',
            tags: ['intermediário'],
            collaborators: [],
            stats: DeckStats(totalCards: 30, masteredCards: 10),
          ),
        ],
        isLoading: false,
        error: null,
      ),
    );
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider<DecksBloc>.value(value: mockDecksBloc),
        ],
        child: InheritedGoRouter(
          goRouter: mockGoRouter,
          child: const DecksTab(),
        ),
      ),
    );
  }

  group('DecksTab', () {
    testWidgets('exibe lista de decks corretamente', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Vocabulário Básico'), findsOneWidget);
      expect(find.text('Expressões Idiomáticas'), findsOneWidget);
    });

    testWidgets('exibe estatísticas dos decks', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('50 cards'), findsOneWidget);
      expect(find.text('40% dominado'), findsOneWidget);
    });

    testWidgets('mostra botão de importar deck', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.file_upload), findsOneWidget);
    });

    testWidgets('navega para detalhes do deck ao clicar', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Vocabulário Básico'));
      await tester.pumpAndSettle();

      verify(() => mockGoRouter.push('/decks/deck-1')).called(1);
    });

    testWidgets('mostra diálogo de importação ao clicar no botão importar',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.file_upload));
      await tester.pumpAndSettle();

      expect(find.text('Importar Deck'), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(2)); // Título e descrição
    });

    testWidgets('é responsivo em diferentes tamanhos de tela', (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 480)); // Tela pequena
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.byType(GridView), findsOneWidget);
      
      await tester.binding.setSurfaceSize(const Size(1024, 768)); // Tela grande
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.byType(GridView), findsOneWidget);
    });

    testWidgets('exibe mensagem quando não há decks', (tester) async {
      when(() => mockDecksBloc.state).thenReturn(
        const DecksState(
          decks: [],
          isLoading: false,
          error: null,
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Nenhum deck encontrado'), findsOneWidget);
    });
  });
}
