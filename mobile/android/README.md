# EasyReading - Configuração Android

## Visão Geral

Este documento descreve a configuração da plataforma Android para o aplicativo EasyReading, um aplicativo de flashcards com integração de IA. O aplicativo é desenvolvido usando Flutter para proporcionar uma experiência de usuário nativa em dispositivos Android e iOS.

## Configuração de Build

### Requisitos

- Flutter 3.29.0+
- Dart 3.7.0+
- Java 11+
- Android SDK
- Gradle 8.2.2+

### Estrutura de Diretórios

```
android/
├── app/
│   ├── build.gradle                 # Configurações específicas do aplicativo
│   ├── google-services.json         # Configuração do Firebase (não versionado)
│   ├── google-services.json.template # Template para configuração do Firebase
│   ├── proguard-rules.pro           # Regras de ofuscação para builds de release
│   ├── keystore/                    # Diretório para armazenar keystores (não versionado)
│   └── src/
│       └── main/
│           ├── AndroidManifest.xml  # Manifesto Android
│           └── kotlin/              # Código Kotlin específico da plataforma
├── build.gradle                     # Configurações globais do Android
└── gradle.properties                # Propriedades do Gradle
```

## Firebase

O aplicativo utiliza o Firebase para autenticação, armazenamento de dados em tempo real e notificações push.

### Configuração do Firebase

1. Crie um projeto no [Firebase Console](https://console.firebase.google.com/)
2. Adicione um aplicativo Android com o pacote `com.easyreading.app`
3. Baixe o arquivo `google-services.json` e coloque-o no diretório `android/app/`
4. Adicione também a configuração para iOS se necessário

## MultiDex

O aplicativo utiliza MultiDex para suportar um grande número de métodos. A configuração está incorporada no arquivo `build.gradle` do aplicativo.

## Keystore para Release

### Criação do Keystore

Use o script `scripts/create_keystore.ps1` para criar um keystore para assinatura de builds de release:

```powershell
cd mobile
./scripts/create_keystore.ps1
```

O script irá:
1. Criar um diretório `keystore` em `android/app/` se não existir
2. Gerar um novo keystore com as informações fornecidas
3. Criar um arquivo `.env.local` com as referências (mas sem senhas)
4. Exibir instruções para configurar o CI/CD

### Configuração Manual do Keystore

Alternativamente, você pode criar o keystore manualmente:

```bash
keytool -genkey -v -keystore android/app/keystore/easyreading-release.keystore -alias easyreading-key -keyalg RSA -keysize 2048 -validity 10000
```

## Variáveis de Ambiente

As seguintes variáveis de ambiente são usadas para configuração segura:

- `KEYSTORE_PASSWORD`: Senha do keystore para assinatura de release
- `KEY_PASSWORD`: Senha da chave para assinatura de release
- `KEY_ALIAS`: Alias da chave para assinatura de release
- `KEYSTORE_PATH`: Caminho para o arquivo keystore

## Processo de Build

### Debug

```bash
flutter build apk --debug
```

### Release

```bash
flutter build apk --release
```

Para build de produção com análise de tamanho:

```bash
flutter build apk --release --analyze-size
```

### AppBundle (Google Play)

```bash
flutter build appbundle --release
```

## Análise de Build

Use o script `scripts/analyze_build.ps1` para analisar o tamanho do build e realizar verificações pré-release:

```powershell
cd mobile
./scripts/analyze_build.ps1
```

## CI/CD

O projeto inclui uma configuração para GitHub Actions em `.github/workflows/android-build.yml`. Para ativar:

1. Configure os secrets no repositório GitHub:
   - `KEYSTORE_BASE64`: Conteúdo do keystore codificado em base64
   - `KEYSTORE_PASSWORD`: Senha do keystore
   - `KEY_PASSWORD`: Senha da chave
   - `KEY_ALIAS`: Alias da chave
   - `FIREBASE_CONFIG`: Conteúdo do arquivo `google-services.json` codificado em base64

2. Ative o workflow no repositório GitHub

## ProGuard

O projeto utiliza ProGuard para ofuscação e redução de tamanho do APK em builds de release. As regras estão definidas em `android/app/proguard-rules.pro`.

## Próximos Passos

1. Substituir `google-services.json.template` com credenciais reais do projeto Firebase
2. Gerar um keystore de produção usando o script fornecido
3. Configurar pipeline CI/CD com os secrets necessários
4. Testar a implementação do MultiDex
5. Verificar a integração com os serviços do Firebase

## Solução de Problemas

### Erro de MultiDex

Se você encontrar erros relacionados ao MultiDex durante o desenvolvimento, verifique:

1. Se a aplicação está estendendo `MultiDexApplication`
2. Se a dependência do MultiDex está corretamente adicionada no `build.gradle`
3. Se o `minSdkVersion` está configurado adequadamente

### Erro de Assinatura

Se você encontrar erros de assinatura em builds de release:

1. Verifique se o keystore existe no caminho especificado
2. Confirme se as senhas do keystore e da chave estão corretas
3. Verifique se o alias da chave está correto

## Contato

Para questões relacionadas à configuração do Android, entre em contato com a equipe de desenvolvimento.
