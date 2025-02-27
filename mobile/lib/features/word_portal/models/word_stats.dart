class WordStats {
  final String wordId;
  final String word;
  final String translation;
  final String deckId;
  final String deckName;
  final DateTime lastReview;
  final int totalReviews;
  final int correctReviews;
  final double accuracy;
  final int currentGrade;
  final DateTime nextReviewDue;
  final List<String> tags;

  WordStats({
    required this.wordId,
    required this.word,
    required this.translation,
    required this.deckId,
    required this.deckName,
    required this.lastReview,
    required this.totalReviews,
    required this.correctReviews,
    required this.accuracy,
    required this.currentGrade,
    required this.nextReviewDue,
    required this.tags,
  });

  factory WordStats.fromJson(Map<String, dynamic> json) {
    return WordStats(
      wordId: json['wordId'],
      word: json['word'],
      translation: json['translation'],
      deckId: json['deckId'],
      deckName: json['deckName'],
      lastReview: DateTime.parse(json['lastReview']),
      totalReviews: json['totalReviews'],
      correctReviews: json['correctReviews'],
      accuracy: json['accuracy'].toDouble(),
      currentGrade: json['currentGrade'],
      nextReviewDue: DateTime.parse(json['nextReviewDue']),
      tags: List<String>.from(json['tags']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'wordId': wordId,
      'word': word,
      'translation': translation,
      'deckId': deckId,
      'deckName': deckName,
      'lastReview': lastReview.toIso8601String(),
      'totalReviews': totalReviews,
      'correctReviews': correctReviews,
      'accuracy': accuracy,
      'currentGrade': currentGrade,
      'nextReviewDue': nextReviewDue.toIso8601String(),
      'tags': tags,
    };
  }
}
