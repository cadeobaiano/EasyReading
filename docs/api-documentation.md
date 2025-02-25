# Documentação da API EasyReading

## Visão Geral
Esta documentação detalha os endpoints disponíveis na API do EasyReading, incluindo exemplos de requisições e respostas.

## Base URL
```
https://api.easyreading.app/v1
```

## Autenticação

Todas as requisições (exceto login e registro) devem incluir o token JWT no header:
```http
Authorization: Bearer <seu_token_jwt>
```

## Endpoints

### Autenticação

#### POST /auth/login
Login do usuário.

**Request:**
```json
{
  "email": "usuario@exemplo.com",
  "password": "senha123"
}
```

**Response (200 OK):**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": "123",
    "email": "usuario@exemplo.com",
    "name": "João Silva"
  }
}
```

#### POST /auth/register
Registra um novo usuário.

**Request:**
```json
{
  "name": "João Silva",
  "email": "usuario@exemplo.com",
  "password": "senha123"
}
```

**Response (201 Created):**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": "123",
    "email": "usuario@exemplo.com",
    "name": "João Silva"
  }
}
```

### Decks

#### GET /decks
Lista todos os decks do usuário.

**Response (200 OK):**
```json
{
  "decks": [
    {
      "id": "deck123",
      "name": "Vocabulário Avançado",
      "description": "Palavras do nível C1",
      "totalCards": 50,
      "masteredCards": 20,
      "createdAt": "2025-02-25T14:30:00Z"
    }
  ]
}
```

#### POST /decks
Cria um novo deck.

**Request:**
```json
{
  "name": "Novo Deck",
  "description": "Descrição do deck"
}
```

#### POST /decks/import
Importa flashcards via CSV.

**Request:**
```http
Content-Type: multipart/form-data
file: deck.csv
```

**Response (200 OK):**
```json
{
  "imported": 50,
  "errors": [],
  "deckId": "deck123"
}
```

### Flashcards

#### GET /decks/{deckId}/cards
Lista flashcards de um deck.

**Response (200 OK):**
```json
{
  "cards": [
    {
      "id": "card123",
      "word": "perseverança",
      "definition": "Qualidade de quem persevera",
      "example": "Sua perseverança o levou ao sucesso",
      "difficulty": 0.8,
      "nextReview": "2025-02-26T14:30:00Z"
    }
  ]
}
```

#### POST /cards/{cardId}/review
Registra uma revisão de flashcard.

**Request:**
```json
{
  "quality": 4,
  "timeSpent": 15
}
```

**Response (200 OK):**
```json
{
  "nextReview": "2025-02-28T14:30:00Z",
  "easeFactor": 2.5,
  "interval": 3
}
```

### IA e Suporte

#### POST /ai/generate-support
Gera frases de apoio para um flashcard.

**Request:**
```json
{
  "word": "perseverança",
  "definition": "Qualidade de quem persevera",
  "context": {
    "userLevel": "intermediário",
    "previousErrors": 2
  }
}
```

**Response (200 OK):**
```json
{
  "supportPhrases": [
    "A perseverança é fundamental para alcançar objetivos difíceis",
    "Grandes conquistas exigem perseverança diária",
    "Com perseverança, até as tarefas mais desafiadoras se tornam possíveis"
  ]
}
```

### Estatísticas

#### GET /users/me/stats
Retorna estatísticas do usuário.

**Response (200 OK):**
```json
{
  "totalCards": 150,
  "masteredCards": 75,
  "streakDays": 15,
  "averageAccuracy": 0.85,
  "timeSpent": 3600,
  "reviewsByDay": {
    "2025-02-24": 20,
    "2025-02-25": 25
  }
}
```

## Códigos de Erro

| Código | Descrição |
|--------|-----------|
| 400 | Requisição inválida |
| 401 | Não autorizado |
| 403 | Acesso negado |
| 404 | Recurso não encontrado |
| 429 | Muitas requisições |
| 500 | Erro interno do servidor |

## Rate Limiting

- 100 requisições por minuto por usuário
- 1000 requisições por hora por usuário
- Limites especiais para endpoints de IA:
  - 10 requisições por minuto
  - 100 requisições por hora

## Webhooks

### Eventos Disponíveis

1. **card.reviewed**
   - Disparado quando um flashcard é revisado
   ```json
   {
     "event": "card.reviewed",
     "data": {
       "cardId": "card123",
       "quality": 4,
       "nextReview": "2025-02-28T14:30:00Z"
     }
   }
   ```

2. **deck.imported**
   - Disparado quando um deck é importado com sucesso
   ```json
   {
     "event": "deck.imported",
     "data": {
       "deckId": "deck123",
       "cardsImported": 50
     }
   }
   ```

## Exemplos de Integração

### Curl

```bash
# Login
curl -X POST https://api.easyreading.app/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email": "usuario@exemplo.com", "password": "senha123"}'

# Listar decks
curl https://api.easyreading.app/v1/decks \
  -H "Authorization: Bearer seu_token"

# Revisar flashcard
curl -X POST https://api.easyreading.app/v1/cards/card123/review \
  -H "Authorization: Bearer seu_token" \
  -H "Content-Type: application/json" \
  -d '{"quality": 4, "timeSpent": 15}'
```

### JavaScript/TypeScript

```typescript
// Exemplo de cliente API
class EasyReadingAPI {
  private baseUrl = 'https://api.easyreading.app/v1';
  private token: string;

  constructor(token: string) {
    this.token = token;
  }

  private async request(endpoint: string, options: RequestInit = {}) {
    const response = await fetch(`${this.baseUrl}${endpoint}`, {
      ...options,
      headers: {
        'Authorization': `Bearer ${this.token}`,
        'Content-Type': 'application/json',
        ...options.headers,
      },
    });

    if (!response.ok) {
      throw new Error(`API Error: ${response.statusText}`);
    }

    return response.json();
  }

  async register(name: string, email: string, password: string) {
    return this.request('/auth/register', {
      method: 'POST',
      body: JSON.stringify({ name, email, password }),
    });
  }

  async getDecks() {
    return this.request('/decks');
  }

  async reviewCard(cardId: string, quality: number, timeSpent: number) {
    return this.request(`/cards/${cardId}/review`, {
      method: 'POST',
      body: JSON.stringify({ quality, timeSpent }),
    });
  }

  async generateSupportPhrases(word: string, definition: string, context?: {
    userLevel?: string;
    previousErrors?: number;
  }) {
    return this.request('/ai/generate-support', {
      method: 'POST',
      body: JSON.stringify({ word, definition, context }),
    });
  }
}
```

## Boas Práticas

1. **Cache**
   - Use cache para dados que não mudam frequentemente
   - Respeite os headers de cache retornados pela API

2. **Tratamento de Erros**
   - Sempre verifique o código de status da resposta
   - Implemente retry com backoff exponencial
   - Monitore erros e latência

3. **Segurança**
   - Nunca armazene tokens em localStorage
   - Use HTTPS para todas as requisições
   - Implemente refresh token

4. **Performance**
   - Use compressão gzip
   - Minimize o número de requisições
   - Implemente paginação quando necessário
