const admin = require('firebase-admin');
const serviceAccount = require('../service-account.json');
const fs = require('fs');
const path = require('path');

// Configuração do logger
const logFile = path.join(__dirname, '..', 'logs', 'init-firestore.log');
const logDir = path.dirname(logFile);

if (!fs.existsSync(logDir)) {
  fs.mkdirSync(logDir, { recursive: true });
}

if (fs.existsSync(logFile)) {
  fs.unlinkSync(logFile);
}

function log(message, type = 'info') {
  const timestamp = new Date().toISOString();
  const logMessage = `[${timestamp}] [${type.toUpperCase()}] ${message}\n`;
  fs.appendFileSync(logFile, logMessage);
  console.log(message);
}

function displayLog() {
  try {
    const content = fs.readFileSync(logFile, 'utf8');
    console.log('\n=== Conteúdo do arquivo de log ===\n');
    console.log(content);
  } catch (error) {
    console.error('Erro ao ler arquivo de log:', error);
  }
}

log('=== Iniciando configuração do Firestore ===');
log('Project ID: ' + serviceAccount.project_id);
log('Client Email: ' + serviceAccount.client_email);

// Inicializa o Firebase Admin
log('\n[1] Inicializando Firebase Admin...');
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});
log('✓ Firebase Admin inicializado com sucesso');

const db = admin.firestore();
log('✓ Instância do Firestore obtida');

// Função para verificar se já existe um documento de exemplo
async function checkExistingDocument(collectionName, query) {
  try {
    const snapshot = await db.collection(collectionName)
      .where(query.field, '==', query.value)
      .limit(1)
      .get();
    
    return !snapshot.empty ? snapshot.docs[0].ref : null;
  } catch (error) {
    log(`Erro ao verificar documento existente em ${collectionName}: ${error.message}`, 'error');
    return null;
  }
}

// Função auxiliar para criar ou atualizar uma coleção
async function createOrUpdateCollection(collectionName, data, uniqueField) {
  try {
    log(`\n[→] Verificando documento existente em ${collectionName}...`);
    
    const existingDoc = await checkExistingDocument(collectionName, {
      field: uniqueField.field,
      value: uniqueField.value
    });

    let docRef;
    if (existingDoc) {
      log(`[→] Documento encontrado em ${collectionName}, atualizando...`);
      docRef = existingDoc;
      await docRef.update({
        ...data,
        updatedAt: admin.firestore.FieldValue.serverTimestamp()
      });
      log(`✓ Documento atualizado em ${collectionName} (ID: ${docRef.id})`);
    } else {
      log(`[→] Criando novo documento em ${collectionName}...`);
      docRef = db.collection(collectionName).doc();
      await docRef.set({
        id: docRef.id,
        ...data,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp()
      });
      log(`✓ Documento criado em ${collectionName} (ID: ${docRef.id})`);
    }

    const docSnapshot = await docRef.get();
    if (docSnapshot.exists) {
      log(`✓ Documento verificado em ${collectionName}`);
    } else {
      throw new Error(`Documento não encontrado após operação em ${collectionName}`);
    }

    return docRef;
  } catch (error) {
    log(`✗ Erro ao operar em ${collectionName}: ${error.message}`, 'error');
    log(`Stack: ${error.stack}`, 'error');
    throw error;
  }
}

// Criar documentos de exemplo
async function createSampleDocuments() {
  log('\n=== Iniciando criação de documentos de exemplo ===');
  
  try {
    log('\n[2] Criando usuário de exemplo...');
    const userData = {
      email: 'exemplo@easyreading.app',
      name: 'Usuário Exemplo',
      preferences: {
        theme: 'light',
        notifications: true,
        dailyGoal: 20,
        language: 'pt-BR'
      },
      stats: {
        totalCards: 0,
        masteredCards: 0,
        streakDays: 0,
        lastActivity: admin.firestore.FieldValue.serverTimestamp(),
        averageAccuracy: 0,
        totalStudyTime: 0
      }
    };
    const userRef = await createOrUpdateCollection('users', userData, {
      field: 'email',
      value: userData.email
    });

    log('\n[3] Criando deck de exemplo...');
    const deckData = {
      userId: userRef.id,
      name: 'Vocabulário Básico',
      description: 'Deck inicial para prática de vocabulário',
      tags: ['iniciante', 'vocabulário', 'português'],
      stats: {
        totalCards: 0,
        masteredCards: 0,
        averageEaseFactor: 2.5,
        lastStudied: null,
        totalReviews: 0
      },
      visibility: 'private',
      collaborators: []
    };
    const deckRef = await createOrUpdateCollection('decks', deckData, {
      field: 'name',
      value: deckData.name
    });

    log('\n[4] Criando flashcard de exemplo...');
    const cardData = {
      deckId: deckRef.id,
      word: 'exemplo',
      definition: 'Algo que serve para ilustrar ou demonstrar uma ideia',
      example: 'Este é um exemplo de como usar a palavra em uma frase.',
      tags: ['substantivo', 'básico', 'comum'],
      sm2Data: {
        interval: 1,
        easeFactor: 2.5,
        repetitions: 0,
        nextReview: admin.firestore.FieldValue.serverTimestamp(),
        lastReview: null,
        status: 'new'
      },
      stats: {
        totalReviews: 0,
        correctReviews: 0,
        averageTime: 0,
        lastReviewQuality: null,
        masteryProgress: 0
      }
    };
    const cardRef = await createOrUpdateCollection('flashcards', cardData, {
      field: 'word',
      value: cardData.word
    });

    log('\n[5] Criando review de exemplo...');
    const reviewData = {
      userId: userRef.id,
      cardId: cardRef.id,
      deckId: deckRef.id,
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
      quality: 4,
      timeSpent: 5,
      sm2Result: {
        interval: 1,
        easeFactor: 2.5,
        repetitions: 1,
        nextReview: admin.firestore.FieldValue.serverTimestamp(),
        status: 'learning'
      },
      supportPhrases: [
        'Esta palavra é muito comum no dia a dia',
        'Tente criar suas próprias frases usando esta palavra',
        'Associe esta palavra com situações do seu cotidiano'
      ]
    };
    const reviewRef = await createOrUpdateCollection('reviews', reviewData, {
      field: 'cardId',
      value: cardData.id
    });

    log('\n[6] Criando sessão de exemplo...');
    const sessionData = {
      userId: userRef.id,
      startTime: admin.firestore.FieldValue.serverTimestamp(),
      endTime: admin.firestore.FieldValue.serverTimestamp(),
      deckIds: [deckRef.id],
      stats: {
        totalCards: 1,
        correctCards: 1,
        totalTime: 5,
        averageTime: 5,
        accuracy: 100,
        cardsPerMinute: 12
      },
      reviews: [{
        cardId: cardRef.id,
        quality: 4,
        timeSpent: 5,
        status: 'learning'
      }]
    };
    const sessionRef = await createOrUpdateCollection('sessions', sessionData, {
      field: 'userId',
      value: userRef.id
    });

    log('\n=== Resumo da Inicialização ===');
    log('✓ Todas as coleções foram criadas/atualizadas com sucesso!');
    log('\nEstatísticas:');
    log('- Usuários: ' + userRef.id);
    log('- Decks: ' + deckRef.id);
    log('- Flashcards: ' + cardRef.id);
    log('- Reviews: ' + reviewRef.id);
    log('- Sessões: ' + sessionRef.id);

    // Verificação final
    log('\n[7] Realizando verificação final...');
    const collections = await db.listCollections();
    log('Coleções encontradas no Firestore:');
    for (const collection of collections) {
      const snapshot = await collection.get();
      log(`- ${collection.id}: ${snapshot.size} documento(s)`);
    }
    
  } catch (error) {
    log('\n✗ Erro durante a inicialização: ' + error.message, 'error');
    log('Stack: ' + error.stack, 'error');
    throw error;
  }
}

// Executar inicialização
log('\n=== Iniciando processo de criação das coleções ===');
createSampleDocuments().then(() => {
  log('\n✓ Inicialização concluída com sucesso!');
  displayLog();
  process.exit(0);
}).catch(error => {
  log('\n✗ Erro fatal durante a inicialização: ' + error, 'error');
  displayLog();
  process.exit(1);
});
