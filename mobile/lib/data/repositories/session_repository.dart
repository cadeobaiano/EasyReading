import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/session_model.dart';
import '../../domain/repositories/base_repository.dart';

class SessionRepository extends BaseRepository<SessionModel> {
  SessionRepository(FirebaseFirestore firestore) : super(firestore, 'sessions');

  @override
  Future<SessionModel> create(SessionModel model) async {
    final docRef = await _firestore.collection(collection).add(model.toJson());
    final doc = await docRef.get();
    return SessionModel.fromFirestore(
        doc as DocumentSnapshot<Map<String, dynamic>>, null);
  }

  @override
  Future<SessionModel?> read(String id) async {
    final doc = await _firestore.collection(collection).doc(id).get();
    if (!doc.exists) return null;
    return SessionModel.fromFirestore(
        doc as DocumentSnapshot<Map<String, dynamic>>, null);
  }

  @override
  Future<void> update(SessionModel model) async {
    await _firestore.collection(collection).doc(model.id).update(model.toJson());
  }

  @override
  Future<void> delete(String id) async {
    await _firestore.collection(collection).doc(id).delete();
  }

  @override
  Stream<SessionModel?> watchDocument(String id) {
    return _firestore.collection(collection).doc(id).snapshots().map(
          (doc) => doc.exists
              ? SessionModel.fromFirestore(
                  doc as DocumentSnapshot<Map<String, dynamic>>, null)
              : null,
        );
  }

  @override
  Stream<List<SessionModel>> watchCollection([
    Query? Function(Query query)? queryBuilder,
  ]) {
    Query query = _firestore.collection(collection);
    if (queryBuilder != null) {
      query = queryBuilder(query) ?? query;
    }
    return query.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => SessionModel.fromFirestore(
            doc as DocumentSnapshot<Map<String, dynamic>>, null))
        .toList());
  }

  /// Busca sessões de um usuário específico
  Stream<List<SessionModel>> watchUserSessions(String userId) {
    return watchCollection(
      (query) => query
          .where('userId', isEqualTo: userId)
          .orderBy('startTime', descending: true),
    );
  }

  /// Busca sessões ativas de um usuário
  Stream<List<SessionModel>> watchActiveUserSessions(String userId) {
    return watchCollection(
      (query) => query
          .where('userId', isEqualTo: userId)
          .where('endTime', isNull: true),
    );
  }

  /// Finaliza uma sessão
  Future<void> endSession(String sessionId, SessionStats stats) async {
    await _firestore.collection(collection).doc(sessionId).update({
      'endTime': Timestamp.now(),
      'stats': stats.toJson(),
    });
  }

  /// Atualiza as estatísticas de uma sessão
  Future<void> updateSessionStats(String sessionId, SessionStats stats) async {
    await _firestore
        .collection(collection)
        .doc(sessionId)
        .update({'stats': stats.toJson()});
  }

  /// Calcula estatísticas gerais de sessões para um usuário
  Future<Map<String, dynamic>> getUserSessionStats(String userId) async {
    final sessions = await _firestore
        .collection(collection)
        .where('userId', isEqualTo: userId)
        .where('endTime', isNull: false)
        .get();

    var totalSessions = 0;
    var totalCardsReviewed = 0;
    var totalCorrectAnswers = 0;
    var totalTimeSpent = 0.0;

    for (var doc in sessions.docs) {
      final session = SessionModel.fromFirestore(
          doc as DocumentSnapshot<Map<String, dynamic>>, null);
      totalSessions++;
      totalCardsReviewed += session.stats.cardsReviewed;
      totalCorrectAnswers += session.stats.correctAnswers;
      
      if (session.endTime != null) {
        totalTimeSpent += session.endTime!
            .difference(session.startTime)
            .inMinutes
            .toDouble();
      }
    }

    return {
      'totalSessions': totalSessions,
      'totalCardsReviewed': totalCardsReviewed,
      'averageAccuracy': totalCardsReviewed > 0
          ? (totalCorrectAnswers / totalCardsReviewed) * 100
          : 0.0,
      'averageSessionDuration':
          totalSessions > 0 ? totalTimeSpent / totalSessions : 0.0,
    };
  }
}
