#!/bin/bash

# Instala a Firebase CLI globalmente
npm install -g firebase-tools

# Faz login no Firebase
firebase login

# Inicializa o projeto Firebase
firebase init

# Habilita os serviços necessários
firebase --project=easyreading enable-service firestore
firebase --project=easyreading enable-service storage
firebase --project=easyreading enable-service functions

# Deploy das Cloud Functions para backup
cd ../backup
firebase deploy --only functions:dailyBackup,functions:weeklyBackup

# Configura as regras do Cloud Storage para os backups
cat > storage.rules << EOL
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read: if request.auth != null && request.auth.token.admin == true;
      allow write: if false;
    }
  }
}
EOL

# Deploy das regras de storage
firebase deploy --only storage

echo "Firebase setup completed successfully!"
