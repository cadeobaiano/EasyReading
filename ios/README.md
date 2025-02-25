# Configuração do Firebase para iOS

Para configurar o Firebase no iOS, siga estes passos quando estiver pronto para adicionar suporte iOS:

1. Execute o comando para criar o app iOS no Firebase:
```bash
firebase apps:create IOS --bundle-id "com.easyreading.app"
```

2. Depois de criar o app, baixe o arquivo de configuração:
```bash
firebase apps:sdkconfig IOS [APP_ID]
```
Substitua [APP_ID] pelo ID do app iOS gerado no passo 1.

3. O arquivo `GoogleService-Info.plist` será gerado. Coloque-o neste diretório (`ios/`).

4. No Xcode:
   - Arraste o arquivo `GoogleService-Info.plist` para o seu projeto
   - Certifique-se de que "Copy items if needed" está marcado
   - Adicione o arquivo ao target principal do seu app

5. Configure o CocoaPods no seu projeto iOS:
```bash
cd ios
pod init
```

6. Adicione as dependências do Firebase no seu `Podfile`:
```ruby
pod 'Firebase/Core'
pod 'Firebase/Auth'
pod 'Firebase/Firestore'
```

7. Instale as dependências:
```bash
pod install
```

8. Abra o arquivo `.xcworkspace` gerado pelo CocoaPods para continuar o desenvolvimento.

**Nota**: Mantenha o arquivo `GoogleService-Info.plist` seguro e nunca o compartilhe publicamente, pois ele contém chaves de API sensíveis.
