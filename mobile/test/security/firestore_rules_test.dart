import 'package:test/test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import '../../lib/data/repositories/deck_repository.dart';
import '../../lib/domain/models/deck_model.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late MockFirebaseAuth mockAuth;
  late DeckRepository deckRepository;
  late MockUser testUser;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    testUser = MockUser(
      uid: 'test-user-id',
      email: 'test@example.com',
    );
    mockAuth = MockFirebaseAuth(mockUser: testUser);
    deckRepository = DeckRepository(fakeFirestore);
  });

  group('Firestore Security Rules', () {
    test('authenticated user can create their own deck', () async {
      final deck = DeckModel(
        id: '',
        userId: testUser.uid,
        title: 'My Deck',
        description: 'Test Description',
        visibility: 'private',
        tags: ['test'],
        collaborators: [],
        stats: DeckStats(totalCards: 0, masteredCards: 0),
      );

      expect(() async {
        await deckRepository.create(deck);
      }, completes);
    });

    test('authenticated user can read public decks', () async {
      final publicDeck = DeckModel(
        id: 'public-deck',
        userId: 'other-user',
        title: 'Public Deck',
        description: 'Test Description',
        visibility: 'public',
        tags: ['test'],
        collaborators: [],
        stats: DeckStats(totalCards: 0, masteredCards: 0),
      );

      await fakeFirestore.collection('decks').doc(publicDeck.id).set(publicDeck.toJson());

      expect(() async {
        await deckRepository.read(publicDeck.id);
      }, completes);
    });

    test('authenticated user can update their own deck', () async {
      final deck = DeckModel(
        id: 'my-deck',
        userId: testUser.uid,
        title: 'My Deck',
        description: 'Test Description',
        visibility: 'private',
        tags: ['test'],
        collaborators: [],
        stats: DeckStats(totalCards: 0, masteredCards: 0),
      );

      await fakeFirestore.collection('decks').doc(deck.id).set(deck.toJson());

      expect(() async {
        await deckRepository.update(deck.copyWith(title: 'Updated Title'));
      }, completes);
    });

    test('authenticated user cannot update other user\'s deck', () async {
      final otherUserDeck = DeckModel(
        id: 'other-deck',
        userId: 'other-user',
        title: 'Other Deck',
        description: 'Test Description',
        visibility: 'private',
        tags: ['test'],
        collaborators: [],
        stats: DeckStats(totalCards: 0, masteredCards: 0),
      );

      await fakeFirestore.collection('decks').doc(otherUserDeck.id).set(otherUserDeck.toJson());

      expect(() async {
        await deckRepository.update(otherUserDeck.copyWith(title: 'Hacked Title'));
      }, throwsA(anything));
    });

    test('collaborator can read and update shared deck', () async {
      final sharedDeck = DeckModel(
        id: 'shared-deck',
        userId: 'other-user',
        title: 'Shared Deck',
        description: 'Test Description',
        visibility: 'private',
        tags: ['test'],
        collaborators: [testUser.uid],
        stats: DeckStats(totalCards: 0, masteredCards: 0),
      );

      await fakeFirestore.collection('decks').doc(sharedDeck.id).set(sharedDeck.toJson());

      expect(() async {
        final deck = await deckRepository.read(sharedDeck.id);
        expect(deck, isNotNull);
        await deckRepository.update(deck!.copyWith(title: 'Updated by Collaborator'));
      }, completes);
    });

    test('non-collaborator cannot read private deck', () async {
      final privateDeck = DeckModel(
        id: 'private-deck',
        userId: 'other-user',
        title: 'Private Deck',
        description: 'Test Description',
        visibility: 'private',
        tags: ['test'],
        collaborators: ['another-user'],
        stats: DeckStats(totalCards: 0, masteredCards: 0),
      );

      await fakeFirestore.collection('decks').doc(privateDeck.id).set(privateDeck.toJson());

      expect(() async {
        await deckRepository.read(privateDeck.id);
      }, throwsA(anything));
    });
  });
}
