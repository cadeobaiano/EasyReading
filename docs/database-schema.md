# Modelagem do Banco de Dados - EasyReading

## Visão Geral
Este documento detalha a estrutura do banco de dados do EasyReading, implementado no Firebase Firestore.

## Coleções

### Users
Armazena informações dos usuários.

```typescript
interface User {
  id: string;                    // UID do Firebase Auth
  email: string;                 // Email do usuário
  name: string;                  // Nome completo
  createdAt: Timestamp;          // Data de criação
  preferences: {
    theme: 'light' | 'dark';     // Tema preferido
    notifications: boolean;       // Notificações ativas
    dailyGoal: number;           // Meta diária de cards
  };
  stats: {
    totalCards: number;          // Total de cards estudados
    masteredCards: number;       // Cards dominados
    streakDays: number;          // Dias consecutivos
    lastActivity: Timestamp;     // Última atividade
  };
}
```

### Decks
Coleção de decks de flashcards.

```typescript
interface Deck {
  id: string;                    // ID único do deck
  userId: string;                // ID do proprietário
  name: string;                  // Nome do deck
  description: string;           // Descrição
  tags: string[];               // Tags para categorização
  createdAt: Timestamp;         // Data de criação
  updatedAt: Timestamp;         // Última atualização
  stats: {
    totalCards: number;         // Total de cards
    masteredCards: number;      // Cards dominados
    averageEaseFactor: number;  // Dificuldade média
  };
  visibility: 'private' | 'public'; // Visibilidade do deck
  collaborators?: string[];     // IDs de colaboradores
}
```

### Flashcards
Cards individuais dentro dos decks.

```typescript
interface Flashcard {
  id: string;                   // ID único do card
  deckId: string;               // ID do deck
  word: string;                 // Palavra ou termo
  definition: string;           // Definição
  example: string;              // Exemplo de uso
  tags: string[];              // Tags específicas
  createdAt: Timestamp;        // Data de criação
  sm2Data: {
    interval: number;          // Intervalo atual (dias)
    easeFactor: number;       // Fator de facilidade
    repetitions: number;      // Número de repetições
    nextReview: Timestamp;    // Próxima revisão
    lastReview: Timestamp;    // Última revisão
  };
  stats: {
    totalReviews: number;     // Total de revisões
    correctReviews: number;   // Revisões corretas
    averageTime: number;      // Tempo médio (segundos)
  };
}
```

### Reviews
Histórico de revisões dos flashcards.

```typescript
interface Review {
  id: string;                  // ID único da revisão
  userId: string;             // ID do usuário
  cardId: string;             // ID do flashcard
  deckId: string;             // ID do deck
  timestamp: Timestamp;       // Data/hora da revisão
  quality: number;            // Qualidade (0-5)
  timeSpent: number;         // Tempo gasto (segundos)
  sm2Result: {
    interval: number;        // Novo intervalo
    easeFactor: number;     // Novo fator de facilidade
    repetitions: number;    // Número de repetições
  };
  supportPhrases: string[]; // Frases de apoio geradas
}
```

### Sessions
Sessões de estudo.

```typescript
interface Session {
  id: string;                 // ID único da sessão
  userId: string;            // ID do usuário
  startTime: Timestamp;      // Início da sessão
  endTime: Timestamp;        // Fim da sessão
  deckIds: string[];        // Decks estudados
  stats: {
    totalCards: number;     // Cards revisados
    correctCards: number;   // Cards corretos
    totalTime: number;      // Tempo total (segundos)
    averageTime: number;    // Tempo médio por card
  };
  reviews: {
    cardId: string;        // ID do card
    quality: number;       // Qualidade da revisão
    timeSpent: number;    // Tempo gasto
  }[];
}
```

## Índices

### Índices Simples
- users.email
- decks.userId
- flashcards.deckId
- reviews.userId
- sessions.userId

### Índices Compostos
1. Flashcards para revisão:
   ```
   flashcards: [
     deckId ASC,
     sm2Data.nextReview ASC
   ]
   ```

2. Histórico de revisões:
   ```
   reviews: [
     userId ASC,
     timestamp DESC
   ]
   ```

3. Decks por popularidade:
   ```
   decks: [
     visibility ASC,
     stats.totalCards DESC
   ]
   ```

## Regras de Segurança

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Funções auxiliares
    function isAuthenticated() {
      return request.auth != null;
    }
    
    function isOwner(userId) {
      return request.auth.uid == userId;
    }
    
    function isCollaborator(deckData) {
      return request.auth.uid in deckData.collaborators;
    }

    // Regras para Users
    match /users/{userId} {
      allow read: if isAuthenticated();
      allow write: if isOwner(userId);
    }

    // Regras para Decks
    match /decks/{deckId} {
      allow read: if resource.data.visibility == 'public' || 
                    isOwner(resource.data.userId) ||
                    isCollaborator(resource.data);
      allow write: if isOwner(resource.data.userId);
    }

    // Regras para Flashcards
    match /flashcards/{cardId} {
      allow read: if get(/databases/$(database)/documents/decks/$(resource.data.deckId))
                    .data.visibility == 'public' ||
                    isOwner(get(/databases/$(database)/documents/decks/$(resource.data.deckId))
                    .data.userId);
      allow write: if isOwner(get(/databases/$(database)/documents/decks/$(resource.data.deckId))
                    .data.userId);
    }

    // Regras para Reviews
    match /reviews/{reviewId} {
      allow read: if isOwner(resource.data.userId);
      allow create: if isOwner(request.resource.data.userId);
    }

    // Regras para Sessions
    match /sessions/{sessionId} {
      allow read: if isOwner(resource.data.userId);
      allow create: if isOwner(request.resource.data.userId);
    }
  }
}
```

## Backup e Recuperação

### Estratégia de Backup
1. **Backups Diários**
   - Exportação completa do Firestore
   - Armazenamento no Google Cloud Storage
   - Retenção por 30 dias

2. **Backups Semanais**
   - Armazenamento de longo prazo
   - Retenção por 1 ano

### Procedimento de Recuperação
1. Identificar o ponto de restauração
2. Importar dados do backup
3. Validar integridade
4. Atualizar índices

## Migração e Versionamento

### Estratégia de Migração
1. **Versionamento de Schema**
   - Manter versão atual do schema
   - Scripts de migração incrementais

2. **Procedimento de Update**
   - Migração em background
   - Validação de dados
   - Rollback automatizado

### Scripts de Migração
Exemplo de script de migração:

```typescript
async function migrateFlashcards(db: Firestore) {
  const cards = await db.collection('flashcards').get();
  
  for (const card of cards.docs) {
    const data = card.data();
    
    // Adiciona novo campo
    await card.ref.update({
      'sm2Data.lastInterval': data.sm2Data.interval,
      'stats.averageTime': calculateAverageTime(data),
    });
  }
}
```
