import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/review_model.dart';
import '../../domain/repositories/base_repository.dart';

class ReviewRepository extends BaseRepository<ReviewModel> {
  ReviewRepository(FirebaseFirestore firestore) : super(firestore, 'reviews');

  @override
  Future<ReviewModel> create(ReviewModel model) async {
    final docRef = await _firestore.collection(collection).add(model.toJson());
    final doc = await docRef.get();
    return ReviewModel.fromFirestore(
        doc as DocumentSnapshot<Map<String, dynamic>>, null);
  }

  @override
  Future<ReviewModel?> read(String id) async {
    final doc = await _firestore.collection(collection).doc(id).get();
    if (!doc.exists) return null;
    return ReviewModel.fromFirestore(
        doc as DocumentSnapshot<Map<String, dynamic>>, null);
  }

  @override
  Future<void> update(ReviewModel model) async {
    await _firestore.collection(collection).doc(model.id).update(model.toJson());
  }

  @override
  Future<void> delete(String id) async {
    await _firestore.collection(collection).doc(id).delete();
  }

  @override
  Stream<ReviewModel?> watchDocument(String id) {
    return _firestore.collection(collection).doc(id).snapshots().map(
          (doc) => doc.exists
              ? ReviewModel.fromFirestore(
                  doc as DocumentSnapshot<Map<String, dynamic>>, null)
              : null,
        );
  }

  @override
  Stream<List<ReviewModel>> watchCollection([
    Query? Function(Query query)? queryBuilder,
  ]) {
    Query query = _firestore.collection(collection);
    if (queryBuilder != null) {
      query = queryBuilder(query) ?? query;
    }
    return query.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => ReviewModel.fromFirestore(
            doc as DocumentSnapshot<Map<String, dynamic>>, null))
        .toList());
  }

  /// Busca reviews de um usuário específico
  Stream<List<ReviewModel>> watchUserReviews(String userId) {
    return watchCollection(
      (query) => query
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true),
    );
  }

  /// Busca reviews de um deck específico
  Stream<List<ReviewModel>> watchDeckReviews(String deckId) {
    return watchCollection(
      (query) => query
          .where('deckId', isEqualTo: deckId)
          .orderBy('timestamp', descending: true),
    );
  }

  /// Busca reviews de um flashcard específico
  Stream<List<ReviewModel>> watchFlashcardReviews(String flashcardId) {
    return watchCollection(
      (query) => query
          .where('flashcardId', isEqualTo: flashcardId)
          .orderBy('timestamp', descending: true),
    );
  }

  /// Calcula estatísticas de revisão para um deck
  Future<Map<String, dynamic>> getDeckReviewStats(String deckId) async {
    final reviews = await _firestore
        .collection(collection)
        .where('deckId', isEqualTo: deckId)
        .get();

    var totalReviews = 0;
    var totalGrade = 0.0;
    var totalTimeSpent = 0;

    for (var doc in reviews.docs) {
      final review = ReviewModel.fromFirestore(
          doc as DocumentSnapshot<Map<String, dynamic>>, null);
      totalReviews++;
      totalGrade += review.grade;
      totalTimeSpent += review.timeSpentMs;
    }

    return {
      'totalReviews': totalReviews,
      'averageGrade': totalReviews > 0 ? totalGrade / totalReviews : 0.0,
      'averageTimeSpent':
          totalReviews > 0 ? totalTimeSpent / totalReviews : 0.0,
    };
  }
}
