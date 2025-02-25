# Modelo de Dados - Aplicativo de Flashcards

## Visão Geral
Este documento descreve o modelo de dados do aplicativo de flashcards, detalhando as entidades principais, seus atributos e relacionamentos.

## Entidades Principais

### 1. User (Usuário)
Representa um usuário do sistema.

#### Atributos Principais:
- `id`: Identificador único
- `email`: Email do usuário
- `name`: Nome do usuário
- `photoUrl`: URL da foto de perfil (opcional)
- `preferences`: Configurações do usuário
  - `dailyGoal`: Meta diária de cards
  - `notificationsEnabled`: Status das notificações
  - `theme`: Tema da interface
  - `language`: Idioma preferido
- `statistics`: Estatísticas do usuário
  - `totalCards`: Total de cards estudados
  - `masteredCards`: Cards dominados
  - `streakDays`: Dias consecutivos de estudo
  - `lastActivity`: Última atividade
- `decks`: Referências aos decks do usuário

### 2. Deck
Representa uma coleção de flashcards.

#### Atributos Principais:
- `id`: Identificador único
- `name`: Nome do deck
- `description`: Descrição do deck
- `category`: Categoria do deck
- `tags`: Tags para categorização
- `owner`: Referência ao usuário criador
- `isPublic`: Visibilidade do deck
- `statistics`: Estatísticas do deck
  - `totalCards`: Total de cards
  - `activeUsers`: Usuários ativos
  - `averageCompletion`: Taxa média de conclusão
- `flashcards`: Referências aos flashcards

### 3. Flashcard
Representa um card individual de estudo.

#### Atributos Principais:
- `id`: Identificador único
- `deckId`: Referência ao deck pai
- `front`: Conteúdo frontal do card
  - `content`: Conteúdo principal
  - `type`: Tipo de conteúdo (texto/imagem/áudio)
  - `mediaUrl`: URL da mídia (se aplicável)
- `back`: Conteúdo do verso do card
- `supportPhrases`: Frases de apoio geradas por IA
  - `content`: Conteúdo da frase
  - `generatedAt`: Data de geração
  - `aiModel`: Modelo de IA usado
- `sm2Data`: Dados do algoritmo SM2
  - `interval`: Intervalo entre revisões
  - `repetitions`: Número de repetições
  - `easeFactor`: Fator de facilidade
  - `nextReview`: Data da próxima revisão
  - `lastDifficulty`: Última dificuldade registrada
- `learningStatus`: Status de aprendizado
- `tags`: Tags para categorização

### 4. TrainingSession (Sessão de Treino)
Representa uma sessão de estudo.

#### Atributos Principais:
- `id`: Identificador único
- `userId`: Referência ao usuário
- `deckId`: Referência ao deck
- `startTime`: Início da sessão
- `endTime`: Fim da sessão
- `reviews`: Revisões realizadas
  - `flashcardId`: Card revisado
  - `difficulty`: Dificuldade reportada
  - `timeSpent`: Tempo gasto
  - `supportPhrasesShown`: Uso de frases de apoio
- `statistics`: Estatísticas da sessão
  - `totalCards`: Cards revisados
  - `correctAnswers`: Respostas corretas
  - `averageTimePerCard`: Tempo médio por card
  - `masteredCards`: Cards dominados

### 5. UserDeckProgress (Progresso no Deck)
Rastreia o progresso do usuário em um deck específico.

#### Atributos Principais:
- `id`: Identificador único
- `userId`: Referência ao usuário
- `deckId`: Referência ao deck
- `lastSession`: Última sessão
- `statistics`: Estatísticas de progresso
- `cardProgress`: Progresso por card
  - `flashcardId`: Referência ao card
  - `learningStatus`: Status atual
  - `nextReview`: Próxima revisão
  - `reviewHistory`: Histórico de revisões

## Relacionamentos

1. **User → Decks**
   - Um usuário pode ter múltiplos decks
   - Relacionamento 1:N

2. **Deck → Flashcards**
   - Um deck contém múltiplos flashcards
   - Relacionamento 1:N

3. **User → TrainingSession**
   - Um usuário tem múltiplas sessões de treino
   - Relacionamento 1:N

4. **User → UserDeckProgress**
   - Um usuário tem um progresso por deck
   - Relacionamento 1:1 (por deck)

## Índices Recomendados

1. **User**
   - `email` (único)
   - `lastActivity`

2. **Deck**
   - `owner`
   - `category`
   - `tags`

3. **Flashcard**
   - `deckId`
   - `learningStatus`
   - `sm2Data.nextReview`

4. **TrainingSession**
   - `userId`
   - `deckId`
   - `startTime`

5. **UserDeckProgress**
   - `userId_deckId` (composto)
   - `lastSession`

## Considerações de Escalabilidade

1. **Sharding**
   - Sharding por `userId` para distribuição de carga
   - Considerar sharding por `deckId` para decks populares

2. **Caching**
   - Cache de decks populares
   - Cache de estatísticas de usuário
   - Cache de sessões ativas

3. **Otimizações**
   - Agregações pré-calculadas para estatísticas
   - Lazy loading de frases de apoio
   - Compressão de dados históricos
