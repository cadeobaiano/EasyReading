import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/word_stats.dart';

class WordPortalService {
  final FirebaseFirestore _firestore;

  WordPortalService({required FirebaseFirestore firestore})
      : _firestore = firestore;

  Stream<List<WordStats>> getWordStats({
    required String userId,
    String? searchQuery,
    double? minAccuracy,
    double? maxAccuracy,
    String? deckId,
    List<String>? tags,
    String? sortBy,
    bool descending = true,
  }) {
    Query query = _firestore
        .collection('flashcards')
        .where('userId', isEqualTo: userId)
        .where('totalReviews', isGreaterThan: 0);

    if (deckId != null) {
      query = query.where('deckId', isEqualTo: deckId);
    }

    if (tags != null && tags.isNotEmpty) {
      query = query.where('tags', arrayContainsAny: tags);
    }

    // Ordenação
    switch (sortBy) {
      case 'accuracy':
        query = query.orderBy('accuracy', descending: descending);
        break;
      case 'lastReview':
        query = query.orderBy('lastReview', descending: descending);
        break;
      case 'nextReview':
        query = query.orderBy('nextReviewDue', descending: descending);
        break;
      default:
        query = query.orderBy('word', descending: descending);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => WordStats.fromJson(doc.data() as Map<String, dynamic>))
          .where((stats) {
            // Filtros que não podem ser aplicados no Firestore
            bool matchesSearch = searchQuery?.isEmpty ?? true ||
                stats.word.toLowerCase().contains(searchQuery!.toLowerCase()) ||
                stats.translation.toLowerCase().contains(searchQuery.toLowerCase());

            bool matchesAccuracy = (minAccuracy == null ||
                    stats.accuracy >= minAccuracy) &&
                (maxAccuracy == null || stats.accuracy <= maxAccuracy);

            return matchesSearch && matchesAccuracy;
          })
          .toList();
    });
  }

  Future<Map<String, int>> getAccuracyDistribution(String userId) async {
    final snapshot = await _firestore
        .collection('flashcards')
        .where('userId', isEqualTo: userId)
        .where('totalReviews', isGreaterThan: 0)
        .get();

    Map<String, int> distribution = {
      '0-20': 0,
      '21-40': 0,
      '41-60': 0,
      '61-80': 0,
      '81-100': 0,
    };

    for (var doc in snapshot.docs) {
      double accuracy = doc.data()['accuracy'] ?? 0.0;
      if (accuracy <= 20) {
        distribution['0-20'] = (distribution['0-20'] ?? 0) + 1;
      } else if (accuracy <= 40) {
        distribution['21-40'] = (distribution['21-40'] ?? 0) + 1;
      } else if (accuracy <= 60) {
        distribution['41-60'] = (distribution['41-60'] ?? 0) + 1;
      } else if (accuracy <= 80) {
        distribution['61-80'] = (distribution['61-80'] ?? 0) + 1;
      } else {
        distribution['81-100'] = (distribution['81-100'] ?? 0) + 1;
      }
    }

    return distribution;
  }

  Future<List<String>> getAllTags(String userId) async {
    final snapshot = await _firestore
        .collection('flashcards')
        .where('userId', isEqualTo: userId)
        .get();

    Set<String> tags = {};
    for (var doc in snapshot.docs) {
      List<String> cardTags = List<String>.from(doc.data()['tags'] ?? []);
      tags.addAll(cardTags);
    }

    return tags.toList()..sort();
  }
}
