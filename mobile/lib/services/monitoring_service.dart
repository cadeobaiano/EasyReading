import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/foundation.dart';

class MonitoringService {
  final FirebaseAnalytics _analytics;
  final FirebaseCrashlytics _crashlytics;
  final FirebasePerformance _performance;

  MonitoringService()
      : _analytics = FirebaseAnalytics.instance,
        _crashlytics = FirebaseCrashlytics.instance,
        _performance = FirebasePerformance.instance;

  Future<void> initialize() async {
    // Configura Crashlytics
    await _crashlytics.setCrashlyticsCollectionEnabled(!kDebugMode);
    FlutterError.onError = _crashlytics.recordFlutterError;

    // Configura Performance Monitoring
    await _performance.setPerformanceCollectionEnabled(!kDebugMode);

    // Configura Analytics
    await _analytics.setAnalyticsCollectionEnabled(!kDebugMode);
  }

  // Analytics Events
  Future<void> logScreenView(String screenName) async {
    await _analytics.logScreenView(screenName: screenName);
  }

  Future<void> logDeckCreated(String deckId, String deckName) async {
    await _analytics.logEvent(
      name: 'deck_created',
      parameters: {
        'deck_id': deckId,
        'deck_name': deckName,
      },
    );
  }

  Future<void> logStudySessionStarted(String deckId, int cardCount) async {
    await _analytics.logEvent(
      name: 'study_session_started',
      parameters: {
        'deck_id': deckId,
        'card_count': cardCount,
      },
    );
  }

  Future<void> logStudySessionCompleted(
      String deckId, int timeSpentMs, int cardsReviewed) async {
    await _analytics.logEvent(
      name: 'study_session_completed',
      parameters: {
        'deck_id': deckId,
        'time_spent_ms': timeSpentMs,
        'cards_reviewed': cardsReviewed,
      },
    );
  }

  // Performance Monitoring
  Trace startTrace(String name) {
    return _performance.newTrace(name);
  }

  HttpMetric startHttpMetric(String url, String httpMethod) {
    return _performance.newHttpMetric(url, httpMethod);
  }

  // Error Reporting
  Future<void> recordError(dynamic error, StackTrace stack) async {
    await _crashlytics.recordError(error, stack);
  }

  Future<void> log(String message) async {
    await _crashlytics.log(message);
  }

  Future<void> setUserIdentifier(String userId) async {
    await _crashlytics.setUserIdentifier(userId);
    await _analytics.setUserId(id: userId);
  }

  // Custom Performance Monitoring
  Future<void> measureDeckLoadTime(String deckId, int timeMs) async {
    final metric = _performance.newTrace('deck_load_time');
    await metric.start();
    metric.putAttribute('deck_id', deckId);
    metric.putMetric('time_ms', timeMs);
    await metric.stop();
  }

  Future<void> measureCardReviewTime(String cardId, int timeMs) async {
    final metric = _performance.newTrace('card_review_time');
    await metric.start();
    metric.putAttribute('card_id', cardId);
    metric.putMetric('time_ms', timeMs);
    await metric.stop();
  }
}
