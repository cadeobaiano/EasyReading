import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import '../../lib/data/repositories/deck_repository.dart';
import '../../lib/domain/models/deck_model.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late DeckRepository deckRepository;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    deckRepository = DeckRepository(fakeFirestore);
  });

  group('DeckRepository', () {
    test('create should add a new deck to Firestore', () async {
      final deck = DeckModel(
        id: '',
        userId: 'user123',
        title: 'Test Deck',
        description: 'Test Description',
        visibility: 'private',
        tags: ['test'],
        collaborators: [],
        stats: DeckStats(totalCards: 0, masteredCards: 0),
      );

      final createdDeck = await deckRepository.create(deck);

      expect(createdDeck.id, isNotEmpty);
      expect(createdDeck.title, equals(deck.title));
      expect(createdDeck.userId, equals(deck.userId));
    });

    test('read should return deck by id', () async {
      final deck = DeckModel(
        id: 'deck123',
        userId: 'user123',
        title: 'Test Deck',
        description: 'Test Description',
        visibility: 'private',
        tags: ['test'],
        collaborators: [],
        stats: DeckStats(totalCards: 0, masteredCards: 0),
      );

      await fakeFirestore.collection('decks').doc(deck.id).set(deck.toJson());

      final retrievedDeck = await deckRepository.read(deck.id);

      expect(retrievedDeck, isNotNull);
      expect(retrievedDeck?.id, equals(deck.id));
      expect(retrievedDeck?.title, equals(deck.title));
    });

    test('update should modify existing deck', () async {
      final deck = DeckModel(
        id: 'deck123',
        userId: 'user123',
        title: 'Test Deck',
        description: 'Test Description',
        visibility: 'private',
        tags: ['test'],
        collaborators: [],
        stats: DeckStats(totalCards: 0, masteredCards: 0),
      );

      await fakeFirestore.collection('decks').doc(deck.id).set(deck.toJson());

      final updatedDeck = deck.copyWith(title: 'Updated Title');
      await deckRepository.update(updatedDeck);

      final retrievedDeck = await deckRepository.read(deck.id);
      expect(retrievedDeck?.title, equals('Updated Title'));
    });

    test('delete should remove deck', () async {
      final deck = DeckModel(
        id: 'deck123',
        userId: 'user123',
        title: 'Test Deck',
        description: 'Test Description',
        visibility: 'private',
        tags: ['test'],
        collaborators: [],
        stats: DeckStats(totalCards: 0, masteredCards: 0),
      );

      await fakeFirestore.collection('decks').doc(deck.id).set(deck.toJson());
      await deckRepository.delete(deck.id);

      final retrievedDeck = await deckRepository.read(deck.id);
      expect(retrievedDeck, isNull);
    });

    test('watchPublicDecks should stream public decks', () async {
      final publicDeck = DeckModel(
        id: 'deck123',
        userId: 'user123',
        title: 'Public Deck',
        description: 'Test Description',
        visibility: 'public',
        tags: ['test'],
        collaborators: [],
        stats: DeckStats(totalCards: 0, masteredCards: 0),
      );

      await fakeFirestore.collection('decks').doc(publicDeck.id).set(publicDeck.toJson());

      expect(
        deckRepository.watchPublicDecks(),
        emits(isA<List<DeckModel>>().having(
          (list) => list.length,
          'length',
          1,
        )),
      );
    });

    test('watchUserDecks should stream user decks', () async {
      final userId = 'user123';
      final userDeck = DeckModel(
        id: 'deck123',
        userId: userId,
        title: 'User Deck',
        description: 'Test Description',
        visibility: 'private',
        tags: ['test'],
        collaborators: [],
        stats: DeckStats(totalCards: 0, masteredCards: 0),
      );

      await fakeFirestore.collection('decks').doc(userDeck.id).set(userDeck.toJson());

      expect(
        deckRepository.watchUserDecks(userId),
        emits(isA<List<DeckModel>>().having(
          (list) => list.length,
          'length',
          1,
        )),
      );
    });
  });
}
