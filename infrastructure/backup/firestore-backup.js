const { initializeApp } = require('firebase-admin/app');
const { getFirestore } = require('firebase-admin/firestore');
const { Storage } = require('@google-cloud/storage');

// Inicializa o Firebase Admin
initializeApp();

const firestore = getFirestore();
const storage = new Storage();

// Nome do bucket onde os backups serão armazenados
const BACKUP_BUCKET = 'easyreading-backups';

// Função para gerar o nome do backup baseado na data
function getBackupName(type) {
  const date = new Date();
  const year = date.getFullYear();
  const month = String(date.getMonth() + 1).padStart(2, '0');
  const day = String(date.getDate()).padStart(2, '0');
  return `firestore-${type}-${year}${month}${day}`;
}

// Função principal para realizar o backup
async function performBackup(type) {
  try {
    const backupName = getBackupName(type);
    const bucket = storage.bucket(BACKUP_BUCKET);

    // Verifica se o bucket existe, se não, cria
    const [exists] = await bucket.exists();
    if (!exists) {
      await bucket.create();
      console.log(`Bucket ${BACKUP_BUCKET} created`);
    }

    // Realiza o backup
    const collection = firestore.collection('_all_');
    await collection.exportDocuments({
      bucket: BACKUP_BUCKET,
      prefix: backupName
    });

    console.log(`Backup ${backupName} completed successfully`);

    // Configuração de retenção (mantém backups por 30 dias)
    const [files] = await bucket.getFiles({
      prefix: `firestore-${type}`
    });

    const thirtyDaysAgo = new Date();
    thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);

    for (const file of files) {
      const fileCreationDate = new Date(file.metadata.timeCreated);
      if (fileCreationDate < thirtyDaysAgo) {
        await file.delete();
        console.log(`Deleted old backup: ${file.name}`);
      }
    }

  } catch (error) {
    console.error('Error performing backup:', error);
    throw error;
  }
}

// Exporta as funções para uso com Cloud Functions
exports.dailyBackup = async (context) => {
  await performBackup('daily');
};

exports.weeklyBackup = async (context) => {
  await performBackup('weekly');
};
