const admin = require('firebase-admin');
const serviceAccount = require('../service-account.json');

async function diagnoseFirebase() {
  try {
    console.log('1. Verificando arquivo service-account.json...');
    console.log(JSON.stringify(serviceAccount, null, 2));

    console.log('\n2. Inicializando Firebase Admin...');
    admin.initializeApp({
      credential: admin.credential.cert(serviceAccount)
    });

    const db = admin.firestore();
    console.log('✓ Firebase Admin inicializado com sucesso');

    console.log('\n3. Testando conexão com Firestore...');
    const testDoc = await db.collection('_test').add({
      timestamp: admin.firestore.FieldValue.serverTimestamp()
    });
    console.log('✓ Documento de teste criado:', testDoc.id);

    await testDoc.delete();
    console.log('✓ Documento de teste removido');

    console.log('\n4. Listando coleções existentes...');
    const collections = await db.listCollections();
    console.log('Coleções encontradas:');
    for (const collection of collections) {
      console.log(`- ${collection.id}`);
    }

    console.log('\n✓ Diagnóstico concluído com sucesso!');
  } catch (error) {
    console.error('\n✗ Erro durante o diagnóstico:', error);
    console.error('Stack:', error.stack);
  } finally {
    process.exit(0);
  }
}

diagnoseFirebase();
