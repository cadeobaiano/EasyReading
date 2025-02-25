import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/deck_model.dart';
import '../../domain/repositories/base_repository.dart';

class DeckRepository extends BaseRepository<DeckModel> {
  DeckRepository(FirebaseFirestore firestore) : super(firestore, 'decks');

  @override
  Future<DeckModel> create(DeckModel model) async {
    final docRef = await _firestore.collection(collection).add(model.toJson());
    final doc = await docRef.get();
    return DeckModel.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>, null);
  }

  @override
  Future<DeckModel?> read(String id) async {
    final doc = await _firestore.collection(collection).doc(id).get();
    if (!doc.exists) return null;
    return DeckModel.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>, null);
  }

  @override
  Future<void> update(DeckModel model) async {
    await _firestore.collection(collection).doc(model.id).update(model.toJson());
  }

  @override
  Future<void> delete(String id) async {
    await _firestore.collection(collection).doc(id).delete();
  }

  @override
  Stream<DeckModel?> watchDocument(String id) {
    return _firestore.collection(collection).doc(id).snapshots().map(
          (doc) => doc.exists
              ? DeckModel.fromFirestore(
                  doc as DocumentSnapshot<Map<String, dynamic>>, null)
              : null,
        );
  }

  @override
  Stream<List<DeckModel>> watchCollection([
    Query? Function(Query query)? queryBuilder,
  ]) {
    Query query = _firestore.collection(collection);
    if (queryBuilder != null) {
      query = queryBuilder(query) ?? query;
    }
    return query.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => DeckModel.fromFirestore(
            doc as DocumentSnapshot<Map<String, dynamic>>, null))
        .toList());
  }

  /// Busca decks públicos
  Stream<List<DeckModel>> watchPublicDecks() {
    return watchCollection(
      (query) => query.where('visibility', isEqualTo: 'public'),
    );
  }

  /// Busca decks de um usuário específico
  Stream<List<DeckModel>> watchUserDecks(String userId) {
    return watchCollection(
      (query) => query.where('userId', isEqualTo: userId),
    );
  }

  /// Busca decks onde o usuário é colaborador
  Stream<List<DeckModel>> watchCollaboratorDecks(String userId) {
    return watchCollection(
      (query) => query.where('collaborators', arrayContains: userId),
    );
  }

  /// Atualiza as estatísticas de um deck
  Future<void> updateStats(String deckId, DeckStats stats) async {
    await _firestore
        .collection(collection)
        .doc(deckId)
        .update({'stats': stats.toJson()});
  }
}
