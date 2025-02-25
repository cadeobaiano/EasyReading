# EasyReading Backend

Backend para o aplicativo de flashcards EasyReading, construído com NestJS.

## Pré-requisitos

1. Node.js (v16 ou superior)
   - Baixe e instale o Node.js de [nodejs.org](https://nodejs.org/)
   - Isso instalará também o npm (Node Package Manager)

2. Yarn (opcional, mas recomendado)
   - Após instalar o Node.js, execute:
   ```bash
   npm install -g yarn
   ```

## Configuração do Ambiente

1. Instale as dependências:
   ```bash
   npm install
   # ou
   yarn install
   ```

2. Configure as variáveis de ambiente:
   - Crie um arquivo `.env` na raiz do projeto
   - Adicione as seguintes variáveis:
   ```env
   OPENAI_API_KEY=sua_chave_api_aqui
   FIREBASE_PROJECT_ID=seu_projeto_id
   FIREBASE_PRIVATE_KEY=sua_chave_privada
   FIREBASE_CLIENT_EMAIL=seu_email_cliente
   JWT_SECRET=seu_segredo_jwt
   ```

## Desenvolvimento

1. Inicie o servidor em modo de desenvolvimento:
   ```bash
   npm run start:dev
   # ou
   yarn start:dev
   ```

2. Execute os testes:
   ```bash
   # Todos os testes
   npm test
   # ou
   yarn test

   # Cobertura de testes
   npm run test:cov
   # ou
   yarn test:cov

   # Modo watch
   npm run test:watch
   # ou
   yarn test:watch
   ```

## Estrutura do Projeto

```
src/
├── ai/                # Serviço de IA (OpenAI)
├── decks/            # Gerenciamento de decks
├── spaced-repetition/# Sistema de repetição espaçada
└── users/            # Gerenciamento de usuários
```

## Principais Funcionalidades

1. **Sistema de Repetição Espaçada**
   - Implementação do algoritmo SM2
   - Rastreamento de progresso do usuário
   - Cálculo de intervalos de revisão

2. **Integração com IA**
   - Geração de frases de apoio
   - Dicas de aprendizado personalizadas
   - Adaptação baseada no desempenho

3. **Gerenciamento de Decks**
   - Importação via CSV
   - Validação de dados
   - Organização por tags

4. **Autenticação e Autorização**
   - Integração com Firebase
   - JWT para sessões
   - Controle de acesso baseado em roles

## Testes

O projeto inclui testes unitários abrangentes para todos os módulos principais:

- Serviço de IA (`ai.service.spec.ts`)
- Validação de CSV (`csv-validator.service.spec.ts`)
- Sistema de Repetição Espaçada (`spaced-repetition.service.spec.ts`)

## Contribuição

1. Faça um fork do projeto
2. Crie uma branch para sua feature (`git checkout -b feature/nova-feature`)
3. Commit suas mudanças (`git commit -m 'Adiciona nova feature'`)
4. Push para a branch (`git push origin feature/nova-feature`)
5. Abra um Pull Request
