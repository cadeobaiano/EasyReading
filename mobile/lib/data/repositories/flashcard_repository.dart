import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/flashcard_model.dart';
import '../../domain/repositories/base_repository.dart';

class FlashcardRepository extends BaseRepository<FlashcardModel> {
  FlashcardRepository(FirebaseFirestore firestore) : super(firestore, 'flashcards');

  @override
  Future<FlashcardModel> create(FlashcardModel model) async {
    final docRef = await _firestore.collection(collection).add(model.toJson());
    final doc = await docRef.get();
    return FlashcardModel.fromFirestore(
        doc as DocumentSnapshot<Map<String, dynamic>>, null);
  }

  @override
  Future<FlashcardModel?> read(String id) async {
    final doc = await _firestore.collection(collection).doc(id).get();
    if (!doc.exists) return null;
    return FlashcardModel.fromFirestore(
        doc as DocumentSnapshot<Map<String, dynamic>>, null);
  }

  @override
  Future<void> update(FlashcardModel model) async {
    await _firestore.collection(collection).doc(model.id).update(model.toJson());
  }

  @override
  Future<void> delete(String id) async {
    await _firestore.collection(collection).doc(id).delete();
  }

  @override
  Stream<FlashcardModel?> watchDocument(String id) {
    return _firestore.collection(collection).doc(id).snapshots().map(
          (doc) => doc.exists
              ? FlashcardModel.fromFirestore(
                  doc as DocumentSnapshot<Map<String, dynamic>>, null)
              : null,
        );
  }

  @override
  Stream<List<FlashcardModel>> watchCollection([
    Query? Function(Query query)? queryBuilder,
  ]) {
    Query query = _firestore.collection(collection);
    if (queryBuilder != null) {
      query = queryBuilder(query) ?? query;
    }
    return query.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => FlashcardModel.fromFirestore(
            doc as DocumentSnapshot<Map<String, dynamic>>, null))
        .toList());
  }

  /// Busca flashcards de um deck específico
  Stream<List<FlashcardModel>> watchDeckFlashcards(String deckId) {
    return watchCollection(
      (query) => query.where('deckId', isEqualTo: deckId),
    );
  }

  /// Busca flashcards que precisam de revisão
  Stream<List<FlashcardModel>> watchDueFlashcards(String deckId) {
    return watchCollection(
      (query) => query
          .where('deckId', isEqualTo: deckId)
          .where('sm2Data.nextReview', isLessThanOrEqualTo: Timestamp.now())
          .orderBy('sm2Data.nextReview', descending: false),
    );
  }

  /// Atualiza os dados SM2 de um flashcard
  Future<void> updateSM2Data(String flashcardId, SM2Data sm2Data) async {
    await _firestore
        .collection(collection)
        .doc(flashcardId)
        .update({'sm2Data': sm2Data.toJson()});
  }

  /// Cria múltiplos flashcards em lote
  Future<List<FlashcardModel>> createBatch(List<FlashcardModel> flashcards) async {
    final batch = _firestore.batch();
    final createdFlashcards = <FlashcardModel>[];

    for (var flashcard in flashcards) {
      final docRef = _firestore.collection(collection).doc();
      batch.set(docRef, flashcard.toJson());
      createdFlashcards.add(FlashcardModel(
        id: docRef.id,
        deckId: flashcard.deckId,
        front: flashcard.front,
        back: flashcard.back,
        tags: flashcard.tags,
        sm2Data: flashcard.sm2Data,
      ));
    }

    await batch.commit();
    return createdFlashcards;
  }
}
