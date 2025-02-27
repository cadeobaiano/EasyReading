import 'package:cloud_firestore/cloud_firestore.dart';

class StudySession {
  final String id;
  final String userId;
  final String deckId;
  final DateTime startTime;
  DateTime? endTime;
  int cardsReviewed;
  int correctAnswers;
  List<String> difficultWords;
  Map<String, int> cardDifficulties;
  int earnedPoints;
  List<String> achievementsUnlocked;

  StudySession({
    required this.id,
    required this.userId,
    required this.deckId,
    required this.startTime,
    this.endTime,
    this.cardsReviewed = 0,
    this.correctAnswers = 0,
    this.difficultWords = const [],
    this.cardDifficulties = const {},
    this.earnedPoints = 0,
    this.achievementsUnlocked = const [],
  });

  double get accuracy => cardsReviewed > 0 
    ? (correctAnswers / cardsReviewed) * 100 
    : 0;

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'deckId': deckId,
    'startTime': startTime.toIso8601String(),
    'endTime': endTime?.toIso8601String(),
    'cardsReviewed': cardsReviewed,
    'correctAnswers': correctAnswers,
    'difficultWords': difficultWords,
    'cardDifficulties': cardDifficulties,
    'earnedPoints': earnedPoints,
    'achievementsUnlocked': achievementsUnlocked,
  };

  factory StudySession.fromJson(Map<String, dynamic> json) => StudySession(
    id: json['id'],
    userId: json['userId'],
    deckId: json['deckId'],
    startTime: DateTime.parse(json['startTime']),
    endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
    cardsReviewed: json['cardsReviewed'],
    correctAnswers: json['correctAnswers'],
    difficultWords: List<String>.from(json['difficultWords']),
    cardDifficulties: Map<String, int>.from(json['cardDifficulties']),
    earnedPoints: json['earnedPoints'],
    achievementsUnlocked: List<String>.from(json['achievementsUnlocked']),
  );
}
