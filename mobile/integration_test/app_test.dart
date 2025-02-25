import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:easyreading/main.dart' as app;
import 'package:firebase_core/firebase_core.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('end-to-end test', () {
    setUpAll(() async {
      await Firebase.initializeApp();
    });

    testWidgets('login flow test', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Encontra e preenche o campo de email
      final emailField = find.byKey(const Key('email_field'));
      await tester.enterText(emailField, 'test@example.com');

      // Encontra e preenche o campo de senha
      final passwordField = find.byKey(const Key('password_field'));
      await tester.enterText(passwordField, 'password123');

      // Toca no botão de login
      final loginButton = find.byKey(const Key('login_button'));
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      // Verifica se navegou para a tela principal
      expect(find.text('Home'), findsOneWidget);
    });

    testWidgets('create deck flow test', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navega para a tela de decks
      final decksTab = find.text('Decks');
      await tester.tap(decksTab);
      await tester.pumpAndSettle();

      // Toca no botão de adicionar deck
      final addDeckButton = find.byKey(const Key('add_deck_button'));
      await tester.tap(addDeckButton);
      await tester.pumpAndSettle();

      // Preenche os campos do deck
      await tester.enterText(
        find.byKey(const Key('deck_title_field')),
        'Test Deck',
      );
      await tester.enterText(
        find.byKey(const Key('deck_description_field')),
        'Test Description',
      );

      // Salva o deck
      final saveDeckButton = find.byKey(const Key('save_deck_button'));
      await tester.tap(saveDeckButton);
      await tester.pumpAndSettle();

      // Verifica se o deck foi criado
      expect(find.text('Test Deck'), findsOneWidget);
    });

    testWidgets('study session flow test', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Seleciona um deck
      final deckCard = find.text('Test Deck').first;
      await tester.tap(deckCard);
      await tester.pumpAndSettle();

      // Inicia uma sessão de estudo
      final startStudyButton = find.byKey(const Key('start_study_button'));
      await tester.tap(startStudyButton);
      await tester.pumpAndSettle();

      // Verifica se está na tela de estudo
      expect(find.byKey(const Key('flashcard_front')), findsOneWidget);

      // Vira o cartão
      await tester.tap(find.byKey(const Key('flip_card_button')));
      await tester.pumpAndSettle();

      // Verifica se o cartão virou
      expect(find.byKey(const Key('flashcard_back')), findsOneWidget);

      // Avalia o cartão
      await tester.tap(find.byKey(const Key('grade_good_button')));
      await tester.pumpAndSettle();
    });
  });
}
