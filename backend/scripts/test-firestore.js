const admin = require('firebase-admin');
const serviceAccount = require('../service-account.json');

// Inicializa o Firebase Admin
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

// Testa a criação de um documento
async function testFirestore() {
  try {
    // Criar um documento de teste
    const testRef = await db.collection('test').add({
      message: 'Test successful',
      timestamp: admin.firestore.FieldValue.serverTimestamp()
    });
    
    console.log('Test document created:', testRef.id);
    
    // Ler o documento
    const doc = await testRef.get();
    console.log('Document data:', doc.data());
    
    // Deletar o documento
    await testRef.delete();
    console.log('Test document deleted');
    
    return true;
  } catch (error) {
    console.error('Error:', error);
    return false;
  }
}

testFirestore().then(success => {
  if (success) {
    console.log('All tests passed!');
  } else {
    console.log('Tests failed!');
  }
  process.exit(0);
});
