const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

// Monitoramento de erros de autenticação
exports.monitorAuthErrors = functions.analytics.event('login_error').onLog((event) => {
  const errorCount = event.data.errorCount || 1;
  
  if (errorCount > 10) {
    return admin.messaging().sendToTopic('monitoring', {
      notification: {
        title: 'Alto número de erros de login',
        body: `Detectados ${errorCount} erros de login nos últimos 5 minutos`
      }
    });
  }
});

// Monitoramento de performance
exports.monitorAppPerformance = functions.analytics.event('app_start').onLog(async (event) => {
  const startupTime = event.data.startup_time;
  
  if (startupTime > 5000) { // mais de 5 segundos
    return admin.messaging().sendToTopic('monitoring', {
      notification: {
        title: 'Performance Degradada',
        body: `Tempo de inicialização do app: ${startupTime}ms`
      }
    });
  }
});

// Monitoramento de uso do Firestore
exports.monitorFirestoreUsage = functions.firestore
  .document('{collection}/{document}')
  .onWrite(async (change, context) => {
    const stats = await admin.firestore().collection('stats').doc('usage').get();
    const currentUsage = stats.data()?.documentCount || 0;
    
    if (currentUsage > 1000000) { // mais de 1 milhão de documentos
      return admin.messaging().sendToTopic('monitoring', {
        notification: {
          title: 'Alto uso do Firestore',
          body: `Número total de documentos: ${currentUsage}`
        }
      });
    }
});

// Monitoramento de erros críticos
exports.monitorCriticalErrors = functions.crashlytics.issue().onNew(async (issue) => {
  if (issue.velocity > 10) { // mais de 10 ocorrências
    return admin.messaging().sendToTopic('monitoring', {
      notification: {
        title: 'Erro Crítico Detectado',
        body: `${issue.title} - ${issue.velocity} ocorrências`
      }
    });
  }
});

// Monitoramento de sessões de estudo
exports.monitorStudySessions = functions.firestore
  .document('sessions/{sessionId}')
  .onCreate(async (snap, context) => {
    const sessions = await admin.firestore()
      .collection('sessions')
      .where('startTime', '>', Date.now() - 3600000) // última hora
      .get();
    
    if (sessions.size > 1000) { // mais de 1000 sessões por hora
      return admin.messaging().sendToTopic('monitoring', {
        notification: {
          title: 'Alto número de sessões',
          body: `${sessions.size} sessões na última hora`
        }
      });
    }
});
