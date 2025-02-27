# Configuração CI/CD para o EasyReading Mobile

Este documento descreve a configuração de Integração Contínua (CI) e Entrega Contínua (CD) para o aplicativo EasyReading. A configuração utiliza GitHub Actions para automatizar o processo de build, teste e distribuição do aplicativo.

## Visão Geral do Fluxo CI/CD

```
[Commit/PR] → [Lint & Análise] → [Testes] → [Build] → [Deploy]
```

1. **Lint & Análise**: Verificação da qualidade do código
2. **Testes**: Execução de testes unitários e de widget
3. **Build**: Compilação do aplicativo para Android e iOS
4. **Deploy**: Distribuição do aplicativo para lojas ou testers

## Configuração do GitHub Actions

### Workflows Disponíveis

1. **Android Build**: Constrói e testa a versão Android do aplicativo
2. **iOS Build**: Constrói e testa a versão iOS do aplicativo (a ser implementado)
3. **Release**: Prepara e distribui uma nova versão do aplicativo (a ser implementado)

### Workflow Android Build

O workflow de build para Android está configurado em `.github/workflows/android-build.yml`. Este workflow é executado em pushes para a branch principal e pull requests.

#### Principais características:

- Utiliza o cache do Gradle para builds mais rápidos
- Executa análise estática do código
- Executa testes unitários e de widget
- Constrói APK e AppBundle
- Armazena os artefatos de build

## Configuração de Secrets

Os seguintes secrets precisam ser configurados no GitHub para o funcionamento adequado do CI/CD:

### Secrets para Android

- `KEYSTORE_BASE64`: Conteúdo do keystore em formato base64
- `KEYSTORE_PASSWORD`: Senha do keystore
- `KEY_PASSWORD`: Senha da chave
- `KEY_ALIAS`: Alias da chave
- `FIREBASE_CONFIG`: Conteúdo do arquivo `google-services.json` em formato base64

### Secrets para iOS (a serem implementados)

- `IOS_SIGNING_CERTIFICATE_BASE64`: Certificado de assinatura em formato base64
- `IOS_SIGNING_CERTIFICATE_PASSWORD`: Senha do certificado
- `IOS_PROVISIONING_PROFILE_BASE64`: Perfil de provisionamento em formato base64
- `IOS_TEAM_ID`: ID da equipe Apple Developer
- `APPLE_ID`: ID da conta Apple Developer
- `APPLE_APP_SPECIFIC_PASSWORD`: Senha específica para aplicativo

## Como Configurar os Secrets

### Preparando o Keystore para Android

1. Gere o keystore usando o script `scripts/create_keystore.ps1` ou manualmente
2. Codifique o keystore em base64:

   ```powershell
   # PowerShell
   $keystorePath = "android/app/keystore/easyreading-release.keystore"
   [System.Convert]::ToBase64String([System.IO.File]::ReadAllBytes($keystorePath)) | Set-Clipboard
   ```

3. Cole o valor como um secret no GitHub

### Preparando o google-services.json

1. Obtenha o arquivo `google-services.json` do Firebase Console
2. Codifique o arquivo em base64:

   ```powershell
   # PowerShell
   $firebaseConfigPath = "android/app/google-services.json"
   [System.Convert]::ToBase64String([System.IO.File]::ReadAllBytes($firebaseConfigPath)) | Set-Clipboard
   ```

3. Cole o valor como um secret no GitHub

## Ambientes de Desenvolvimento

O aplicativo suporta diferentes ambientes de desenvolvimento. Cada ambiente tem sua própria configuração, incluindo URLs de API, configurações do Firebase e comportamentos específicos.

### Ambientes Disponíveis

1. **Development**: Para desenvolvimento local
2. **Staging**: Para testes em um ambiente que imita a produção
3. **Production**: Ambiente de produção para usuários finais

### Configuração de Ambiente

A configuração de ambiente é feita através de arquivos `.env` específicos para cada ambiente:

- `.env.development`
- `.env.staging`
- `.env.production`

Esses arquivos devem ser criados localmente e não são versionados no Git. Um arquivo `.env.template` é fornecido como referência.

#### Exemplo de arquivo .env:

```
# API Configuration
API_BASE_URL=https://api.easyreading.app
API_TIMEOUT=30000

# Feature Flags
ENABLE_ANALYTICS=true
ENABLE_CRASHLYTICS=true
ENABLE_AI_FEATURES=true

# OpenAI Configuration
OPENAI_API_KEY=your_api_key_here
```

### Switching de Ambiente

Para trocar entre ambientes durante o desenvolvimento:

```bash
# Para desenvolvimento
flutter run --dart-define=ENV=development

# Para staging
flutter run --dart-define=ENV=staging

# Para produção
flutter run --dart-define=ENV=production
```

No CI/CD, o ambiente é definido através de variáveis de ambiente:

```yaml
jobs:
  build:
    steps:
      - name: Build for staging
        run: flutter build apk --dart-define=ENV=staging
```

## Fluxo de Trabalho para Releases

### Versionamento

O versionamento segue o padrão Semantic Versioning (SemVer):

```
MAJOR.MINOR.PATCH+BUILD_NUMBER
```

- **MAJOR**: Alterações incompatíveis com versões anteriores
- **MINOR**: Adição de funcionalidades compatíveis com versões anteriores
- **PATCH**: Correções de bugs
- **BUILD_NUMBER**: Número incremental para cada build

A versão é definida no arquivo `pubspec.yaml`:

```yaml
version: 1.0.0+1
```

### Processo de Release

1. Atualizar a versão no `pubspec.yaml`
2. Criar uma tag no Git com a versão
3. O workflow de release será acionado automaticamente
4. Os artifacts serão publicados nas lojas ou disponibilizados para download

#### Comando para criar tag:

```bash
git tag -a v1.0.0 -m "Versão 1.0.0"
git push origin v1.0.0
```

## Distribuição de Builds

### Distribuição para Testes

Para testes internos e beta testing, o aplicativo pode ser distribuído através do Firebase App Distribution.

O workflow de CI/CD pode ser configurado para enviar automaticamente as builds para o Firebase App Distribution:

```yaml
- name: Upload to Firebase App Distribution
  uses: wzieba/Firebase-Distribution-Github-Action@v1
  with:
    appId: ${{ secrets.FIREBASE_APP_ID }}
    token: ${{ secrets.FIREBASE_TOKEN }}
    groups: testers
    file: build/app/outputs/flutter-apk/app-release.apk
    releaseNotes: |
      Alterações nesta versão:
      - Nova funcionalidade X
      - Correção do bug Y
```

### Publicação nas Lojas

Para publicação nas lojas de aplicativos, o processo pode ser automatizado usando ferramentas como:

- **Google Play Store**: Usando a Google Play Developer API
- **Apple App Store**: Usando fastlane e App Store Connect API

Esses processos serão implementados em fases futuras do projeto.

## Monitoramento e Alertas

### Crashlytics

O Firebase Crashlytics é usado para monitorar crashes e erros em tempo real. A integração já está configurada no código do aplicativo.

### Alertas de Build

O GitHub Actions pode ser configurado para enviar notificações em caso de falha no processo de build:

```yaml
- name: Send Slack notification on failure
  if: failure()
  uses: rtCamp/action-slack-notify@v2
  env:
    SLACK_WEBHOOK: ${{ secrets.SLACK_WEBHOOK }}
    SLACK_CHANNEL: build-alerts
    SLACK_COLOR: danger
    SLACK_TITLE: Build Failed
    SLACK_MESSAGE: 'Build failed for ${{ github.repository }}@${{ github.ref }}'
```

## Solução de Problemas

### Falhas de Build no CI

Se o build falhar no CI, verifique:

1. O log completo do GitHub Actions para identificar o erro
2. Se todos os secrets necessários estão configurados
3. Se o código compila localmente
4. Se todos os testes passam localmente

### Problemas de Assinatura

Se houver problemas com a assinatura do APK:

1. Verifique se o keystore está corretamente codificado em base64
2. Confirme se as senhas e alias estão corretos
3. Teste o processo de assinatura localmente

### Problemas com Firebase

Se houver problemas com a integração do Firebase:

1. Verifique se o arquivo `google-services.json` está correto
2. Confirme se o projeto no Firebase Console está configurado corretamente
3. Teste a conexão com o Firebase localmente

## Recursos Adicionais

- [Documentação do GitHub Actions](https://docs.github.com/en/actions)
- [Documentação do Flutter para CI/CD](https://flutter.dev/docs/deployment/cd)
- [Firebase App Distribution](https://firebase.google.com/docs/app-distribution)
- [Google Play Developer API](https://developers.google.com/android-publisher)
- [App Store Connect API](https://developer.apple.com/app-store-connect/api/)
