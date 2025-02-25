import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'firebase_options.dart';

class FirebaseConfig {
  static final Logger _logger = Logger();
  static FirebaseAnalytics? analytics;
  static FirebaseAnalyticsObserver? analyticsObserver;

  /// Inicializa o Firebase e seus serviços
  static Future<void> initializeFirebase() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      _logger.i('Firebase inicializado com sucesso');

      // Inicializa o Analytics
      analytics = FirebaseAnalytics.instance;
      analyticsObserver = FirebaseAnalyticsObserver(analytics: analytics!);
      _logger.i('Firebase Analytics configurado');

      // Log de inicialização bem-sucedida
      await analytics?.logEvent(
        name: 'app_initialized',
        parameters: {
          'timestamp': DateTime.now().toIso8601String(),
          'platform': defaultTargetPlatform.toString(),
        },
      );
    } catch (e, stackTrace) {
      _logger.e('Erro ao inicializar o Firebase', e, stackTrace);
      // Em modo debug, propaga o erro para facilitar o desenvolvimento
      if (kDebugMode) {
        rethrow;
      }
    }
  }

  /// Retorna a instância do Analytics
  static FirebaseAnalytics? getAnalytics() => analytics;

  /// Retorna o observer do Analytics para navegação
  static FirebaseAnalyticsObserver? getAnalyticsObserver() => analyticsObserver;
}
