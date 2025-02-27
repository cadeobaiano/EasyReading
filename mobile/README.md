# EasyReading Mobile

EasyReading é um aplicativo de flashcards com integração de IA, projetado para otimizar o processo de aprendizado através da repetição espaçada e conteúdo personalizado.

## Visão Geral

O aplicativo EasyReading utiliza o algoritmo SM2 para implementar um sistema de repetição espaçada, otimizando o processo de memorização. A integração com IA via OpenAI permite gerar conteúdo personalizado e dicas de estudo adaptadas ao progresso do usuário.

## Stack Tecnológico

### Frontend Mobile
- **Framework**: Flutter 3.29.0
- **Linguagem**: Dart 3.7.0
- **Gerenciamento de Estado**: BLoC
- **Navegação**: GoRouter
- **Arquitetura**: Clean Architecture

### Backend
- **Framework**: NestJS com TypeScript
- **Banco de Dados**: Firebase Firestore
- **Autenticação**: Firebase Authentication
- **Análise**: Firebase Analytics
- **Monitoramento de Erros**: Firebase Crashlytics
- **Notificações**: Firebase Cloud Messaging

### Integrações Externas
- **OpenAI API**: Para geração de conteúdo personalizado
- **Firebase**: Para sincronização em tempo real e gerenciamento de usuários

## Requisitos

- Flutter 3.29.0+
- Dart 3.7.0+
- Android SDK (para desenvolvimento Android)
- Xcode (para desenvolvimento iOS)
- Firebase CLI (para configuração do Firebase)

## Configuração

### 1. Clonar o Repositório
```bash
git clone https://github.com/seu-usuario/easyreading.git
cd easyreading/mobile
```

### 2. Instalar Dependências
```bash
flutter pub get
```

### 3. Configurar Firebase
1. Crie um projeto no [Firebase Console](https://console.firebase.google.com/)
2. Adicione aplicativos Android e iOS
3. Baixe os arquivos de configuração:
   - Android: `google-services.json` (coloque em `android/app/`)
   - iOS: `GoogleService-Info.plist` (coloque em `ios/Runner/`)

### 4. Configurar Variáveis de Ambiente
1. Crie arquivos de ambiente baseados no template:
   ```bash
   cp env.template.txt .env.development
   cp env.template.txt .env.staging
   cp env.template.txt .env.production
   ```
2. Edite os arquivos com suas configurações específicas

### 5. (Android) Gerar Keystore para Release
Execute o script para criar o keystore:
```bash
cd mobile
./scripts/create_keystore.ps1
```

## Desenvolvimento

### Executar em Modo Debug
```bash
# Desenvolvimento
flutter run --dart-define=ENV=development

# Staging
flutter run --dart-define=ENV=staging

# Produção
flutter run --dart-define=ENV=production
```

### Análise Estática
```bash
flutter analyze
```

### Testes
```bash
flutter test
```

## Build

### Android

#### Build de Debug
```bash
flutter build apk --debug
```

#### Build de Release
```bash
flutter build apk --release
```

#### Build de AppBundle para Google Play
```bash
flutter build appbundle --release
```

#### Análise de Build
```bash
./scripts/analyze_build.ps1
```

### iOS (a ser implementado)

## Otimizações de Build Android

O aplicativo implementa várias otimizações para o build Android:

- **MultiDex**: Suporte para aplicativos com grande número de métodos
- **ProGuard**: Regras de ofuscação para proteger o código e reduzir o tamanho do APK
- **Shrinking de Recursos**: Remoção de recursos não utilizados
- **Configuração de Assinatura Segura**: Usando variáveis de ambiente para armazenar informações sensíveis
- **Firebase Integration**: Configuração otimizada para serviços Firebase

## CI/CD

O projeto utiliza GitHub Actions para automatizar o processo de build, teste e distribuição:

- **Lint & Análise**: Verificação da qualidade do código
- **Testes**: Execução de testes unitários e de widget
- **Build**: Compilação do aplicativo para Android (e iOS no futuro)
- **Deploy**: Distribuição do aplicativo para testes ou produção

Veja a documentação completa de CI/CD em `/docs/ci_cd_setup.md`.

## Estrutura do Projeto

O projeto segue a arquitetura Clean Architecture com a seguinte estrutura:

```
lib/
├── core/           # Componentes centrais e utilitários
├── data/           # Camada de dados (repositórios, fontes de dados)
├── domain/         # Camada de domínio (entidades, casos de uso)
├── presentation/   # Camada de apresentação (UI, BLoC)
└── main.dart       # Ponto de entrada do aplicativo
```

## Documentação

A documentação detalhada está disponível em `/docs`:

- `/docs/firebase_implementation.md`: Implementação dos serviços Firebase
- `/docs/ci_cd_setup.md`: Configuração de CI/CD
- `/android/README.md`: Configuração específica para Android

## Contribuição

1. Crie um fork do projeto
2. Crie uma branch para sua feature (`git checkout -b feature/nova-feature`)
3. Faça commit das alterações (`git commit -am 'Adiciona nova feature'`)
4. Faça push para a branch (`git push origin feature/nova-feature`)
5. Crie um Pull Request

## Licença

[Adicionar informações de licença]

## Contato

[Adicionar informações de contato]
