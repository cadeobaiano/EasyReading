#!/bin/bash

# Configurações
PROJECT_ID="easyreading-prod"
APP_NAME="EasyReading"

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "🚀 Iniciando deploy do $APP_NAME"

# Verifica ambiente
echo "🔍 Verificando ambiente..."
if [ ! -f "pubspec.yaml" ]; then
    echo "${RED}Erro: pubspec.yaml não encontrado. Execute este script da raiz do projeto.${NC}"
    exit 1
fi

# Atualiza dependências
echo "📦 Atualizando dependências..."
flutter pub get

# Executa testes
echo "🧪 Executando testes..."
flutter test
if [ $? -ne 0 ]; then
    echo "${RED}❌ Falha nos testes. Corriga os erros antes de continuar.${NC}"
    exit 1
fi

# Build para Android
echo "📱 Gerando APK de release..."
flutter build apk --release
if [ $? -ne 0 ]; then
    echo "${RED}❌ Falha no build Android.${NC}"
    exit 1
fi

# Build para iOS (se estiver no macOS)
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "🍎 Gerando build iOS..."
    flutter build ios --release
    if [ $? -ne 0 ]; then
        echo "${RED}❌ Falha no build iOS.${NC}"
        exit 1
    fi
fi

# Deploy do app web para Firebase Hosting
echo "🌐 Realizando build web..."
flutter build web --release
if [ $? -ne 0 ]; then
    echo "${RED}❌ Falha no build web.${NC}"
    exit 1
fi

# Deploy para Firebase Hosting
echo "🚀 Realizando deploy para Firebase Hosting..."
firebase deploy --only hosting

# Deploy das Cloud Functions
echo "☁️ Realizando deploy das Cloud Functions..."
cd functions
npm install
firebase deploy --only functions

# Verificações pós-deploy
echo "✅ Verificando serviços após deploy..."

# Verifica Firestore
echo "📊 Verificando Firestore..."
firebase firestore:indexes > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "${YELLOW}⚠️ Aviso: Verifique os índices do Firestore${NC}"
fi

# Verifica regras de segurança
echo "🔒 Verificando regras de segurança..."
firebase deploy --only firestore:rules

# Verifica Functions
echo "⚡ Verificando Cloud Functions..."
firebase functions:log --limit=1 > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "${YELLOW}⚠️ Aviso: Verifique os logs das Cloud Functions${NC}"
fi

echo "${GREEN}✅ Deploy concluído com sucesso!${NC}"
echo "
📝 Próximos passos:
1. Verifique o console do Firebase para monitoramento
2. Configure os alertas no Firebase Console
3. Monitore os logs das Cloud Functions
4. Verifique as métricas de performance
5. Faça um teste de produção
"
