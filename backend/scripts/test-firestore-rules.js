const firebase = require('@firebase/testing');
const fs = require('fs');
const path = require('path');

const projectId = "easyreading-a2bde";
const rules = fs.readFileSync(path.join(__dirname, '..', 'firestore.rules'), 'utf8');

// Funções auxiliares para criar contextos de autenticação
function getAuthedFirestore(auth) {
  return firebase.initializeTestApp({ projectId, auth }).firestore();
}

function getAdminFirestore() {
  return firebase.initializeAdminApp({ projectId }).firestore();
}

// Função para limpar após os testes
async function clearFirestoreData() {
  await firebase.clearFirestoreData({ projectId });
}

// Dados de exemplo para testes
const testUser = {
  id: 'user123',
  email: 'test@example.com',
  name: 'Test User'
};

const testDeck = {
  id: 'deck123',
  userId: 'user123',
  name: 'Test Deck',
  visibility: 'private',
  collaborators: ['user456']
};

const testCard = {
  id: 'card123',
  deckId: 'deck123',
  word: 'test'
};

const testReview = {
  id: 'review123',
  userId: 'user123',
  cardId: 'card123'
};

const testSession = {
  id: 'session123',
  userId: 'user123'
};

// Testes
describe('Firestore Security Rules', () => {
  beforeAll(async () => {
    await firebase.loadFirestoreRules({ projectId, rules });
  });

  beforeEach(async () => {
    await clearFirestoreData();
    const admin = getAdminFirestore();
    
    // Configurar dados de teste
    await admin.doc('users/user123').set(testUser);
    await admin.doc('decks/deck123').set(testDeck);
    await admin.doc('flashcards/card123').set(testCard);
    await admin.doc('reviews/review123').set(testReview);
    await admin.doc('sessions/session123').set(testSession);
  });

  afterAll(async () => {
    await Promise.all(firebase.apps().map(app => app.delete()));
  });

  // Testes para Users
  describe('Users Collection', () => {
    test('allow authenticated users to read their own data', async () => {
      const db = getAuthedFirestore({ uid: 'user123' });
      await firebase.assertSucceeds(db.doc('users/user123').get());
    });

    test('deny unauthenticated users to read data', async () => {
      const db = getAuthedFirestore(null);
      await firebase.assertFails(db.doc('users/user123').get());
    });
  });

  // Testes para Decks
  describe('Decks Collection', () => {
    test('allow owner to read private deck', async () => {
      const db = getAuthedFirestore({ uid: 'user123' });
      await firebase.assertSucceeds(db.doc('decks/deck123').get());
    });

    test('allow collaborator to read private deck', async () => {
      const db = getAuthedFirestore({ uid: 'user456' });
      await firebase.assertSucceeds(db.doc('decks/deck123').get());
    });

    test('deny non-collaborator to read private deck', async () => {
      const db = getAuthedFirestore({ uid: 'user789' });
      await firebase.assertFails(db.doc('decks/deck123').get());
    });
  });

  // Testes para Flashcards
  describe('Flashcards Collection', () => {
    test('allow deck owner to read flashcard', async () => {
      const db = getAuthedFirestore({ uid: 'user123' });
      await firebase.assertSucceeds(db.doc('flashcards/card123').get());
    });

    test('deny non-deck-owner to read flashcard', async () => {
      const db = getAuthedFirestore({ uid: 'user789' });
      await firebase.assertFails(db.doc('flashcards/card123').get());
    });
  });

  // Testes para Reviews
  describe('Reviews Collection', () => {
    test('allow owner to read review', async () => {
      const db = getAuthedFirestore({ uid: 'user123' });
      await firebase.assertSucceeds(db.doc('reviews/review123').get());
    });

    test('deny non-owner to read review', async () => {
      const db = getAuthedFirestore({ uid: 'user456' });
      await firebase.assertFails(db.doc('reviews/review123').get());
    });
  });

  // Testes para Sessions
  describe('Sessions Collection', () => {
    test('allow owner to read session', async () => {
      const db = getAuthedFirestore({ uid: 'user123' });
      await firebase.assertSucceeds(db.doc('sessions/session123').get());
    });

    test('deny non-owner to read session', async () => {
      const db = getAuthedFirestore({ uid: 'user456' });
      await firebase.assertFails(db.doc('sessions/session123').get());
    });
  });
});
