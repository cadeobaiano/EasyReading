import 'package:cloud_firestore/cloud_firestore.dart';
import '../../flashcard/models/flashcard.dart';

class DifficultCardsService {
  final FirebaseFirestore _firestore;

  DifficultCardsService({required FirebaseFirestore firestore})
      : _firestore = firestore;

  Future<List<Flashcard>> getDifficultCards(String userId) async {
    final now = DateTime.now();
    
    // Busca cards que:
    // 1. Têm grade baixo (difícil)
    // 2. Estão com revisão atrasada
    // 3. Foram marcados como difíceis recentemente
    final querySnapshot = await _firestore
        .collection('flashcards')
        .where('userId', isEqualTo: userId)
        .where('sm2Data.nextReview', isLessThan: now)
        .orderBy('sm2Data.nextReview')
        .get();

    final cards = querySnapshot.docs
        .map((doc) => Flashcard.fromJson(doc.data()))
        .where((card) {
          final sm2Data = card.sm2Data;
          return sm2Data.grade <= 2 || // Cards com nota baixa
                 sm2Data.nextReview.isBefore(now) || // Cards atrasados
                 sm2Data.consecutiveCorrect < 2; // Cards com poucos acertos consecutivos
        })
        .toList();

    // Ordena por prioridade de revisão
    cards.sort((a, b) {
      // Prioriza cards mais atrasados e com notas mais baixas
      final aScore = _calculateReviewPriority(a);
      final bScore = _calculateReviewPriority(b);
      return bScore.compareTo(aScore);
    });

    return cards;
  }

  double _calculateReviewPriority(Flashcard card) {
    final now = DateTime.now();
    final daysOverdue = now.difference(card.sm2Data.nextReview).inDays;
    final gradeWeight = (5 - card.sm2Data.grade) * 2; // Notas mais baixas têm mais peso
    final streakWeight = (5 - card.sm2Data.consecutiveCorrect); // Menos acertos, mais peso
    
    return daysOverdue + gradeWeight + streakWeight;
  }

  Future<void> updateDifficultCardStats(
    String userId,
    String cardId,
    bool wasCorrect,
  ) async {
    final cardRef = _firestore.collection('flashcards').doc(cardId);
    
    if (wasCorrect) {
      await cardRef.update({
        'sm2Data.consecutiveCorrect': FieldValue.increment(1),
        'sm2Data.lastCorrectDate': FieldValue.serverTimestamp(),
      });
    } else {
      await cardRef.update({
        'sm2Data.consecutiveCorrect': 0,
        'sm2Data.grade': 1, // Reseta para difícil
        'difficultHistory': FieldValue.arrayUnion([
          {
            'date': FieldValue.serverTimestamp(),
            'reason': 'incorrect_review'
          }
        ]),
      });
    }
  }
}
