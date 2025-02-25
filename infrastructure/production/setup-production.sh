#!/bin/bash

# Configurações
PROJECT_ID="easyreading-prod"
REGION="southamerica-east1"
APP_NAME="EasyReading"

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

echo "🚀 Iniciando setup do ambiente de produção para $APP_NAME"

# Verifica se o Firebase CLI está instalado
if ! command -v firebase &> /dev/null; then
    echo "${RED}Firebase CLI não encontrado. Instalando...${NC}"
    npm install -g firebase-tools
fi

# Login no Firebase
echo "📱 Realizando login no Firebase..."
firebase login

# Configura o projeto Firebase
echo "⚙️ Configurando projeto Firebase..."
firebase use $PROJECT_ID

# Habilita os serviços necessários
echo "🔧 Habilitando serviços do Firebase..."
firebase --project=$PROJECT_ID enable-service firestore
firebase --project=$PROJECT_ID enable-service hosting
firebase --project=$PROJECT_ID enable-service storage
firebase --project=$PROJECT_ID enable-service performance
firebase --project=$PROJECT_ID enable-service crashlytics

# Configura regras do Firestore
echo "🔒 Configurando regras de segurança do Firestore..."
cat > firestore.rules << EOL
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Função auxiliar para verificar autenticação
    function isAuthenticated() {
      return request.auth != null;
    }
    
    // Função para verificar se o usuário é dono do documento
    function isOwner(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }
    
    // Função para verificar se o usuário é colaborador
    function isCollaborator(collaborators) {
      return isAuthenticated() && request.auth.uid in collaborators;
    }

    // Regras para coleção de usuários
    match /users/{userId} {
      allow read: if isAuthenticated();
      allow write: if isOwner(userId);
    }

    // Regras para coleção de decks
    match /decks/{deckId} {
      allow read: if resource.data.visibility == 'public' || 
                    isOwner(resource.data.userId) || 
                    isCollaborator(resource.data.collaborators);
      allow create: if isAuthenticated();
      allow update, delete: if isOwner(resource.data.userId) || 
                             isCollaborator(resource.data.collaborators);
    }

    // Regras para coleção de flashcards
    match /flashcards/{cardId} {
      allow read: if get(resource.data.deckRef).data.visibility == 'public' || 
                    isOwner(get(resource.data.deckRef).data.userId) || 
                    isCollaborator(get(resource.data.deckRef).data.collaborators);
      allow write: if isOwner(get(resource.data.deckRef).data.userId) || 
                    isCollaborator(get(resource.data.deckRef).data.collaborators);
    }

    // Regras para coleção de reviews
    match /reviews/{reviewId} {
      allow read: if isOwner(resource.data.userId);
      allow create: if isAuthenticated();
      allow update, delete: if isOwner(resource.data.userId);
    }

    // Regras para coleção de sessions
    match /sessions/{sessionId} {
      allow read, write: if isOwner(resource.data.userId);
    }
  }
}
EOL

# Configura regras do Storage
echo "🔒 Configurando regras do Storage..."
cat > storage.rules << EOL
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /users/{userId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId;
    }
    
    match /decks/{deckId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
    
    match /backups/{allPaths=**} {
      allow read: if false;
      allow write: if false;
    }
  }
}
EOL

# Deploy das regras
echo "📤 Realizando deploy das regras..."
firebase deploy --only firestore:rules
firebase deploy --only storage:rules

# Configura índices do Firestore
echo "📑 Configurando índices do Firestore..."
cat > firestore.indexes.json << EOL
{
  "indexes": [
    {
      "collectionGroup": "decks",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "visibility", "order": "ASCENDING" },
        { "fieldPath": "createdAt", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "flashcards",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "deckId", "order": "ASCENDING" },
        { "fieldPath": "sm2Data.nextReview", "order": "ASCENDING" }
      ]
    },
    {
      "collectionGroup": "reviews",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "userId", "order": "ASCENDING" },
        { "fieldPath": "timestamp", "order": "DESCENDING" }
      ]
    }
  ]
}
EOL

# Deploy dos índices
firebase deploy --only firestore:indexes

echo "${GREEN}✅ Setup do ambiente de produção concluído com sucesso!${NC}"
