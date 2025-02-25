import 'package:cloud_firestore/cloud_firestore.dart';
import 'base_model.dart';

class SessionModel implements BaseModel {
  @override
  final String id;
  final String userId;
  final String deckId;
  final DateTime startTime;
  final DateTime? endTime;
  final SessionStats stats;

  SessionModel({
    required this.id,
    required this.userId,
    required this.deckId,
    DateTime? startTime,
    this.endTime,
    SessionStats? stats,
  })  : startTime = startTime ?? DateTime.now(),
        stats = stats ?? SessionStats();

  @override
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'deckId': deckId,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': endTime != null ? Timestamp.fromDate(endTime!) : null,
      'stats': stats.toJson(),
    };
  }

  @override
  SessionModel fromJson(Map<String, dynamic> json) {
    return SessionModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      deckId: json['deckId'] as String,
      startTime: (json['startTime'] as Timestamp).toDate(),
      endTime: json['endTime'] != null
          ? (json['endTime'] as Timestamp).toDate()
          : null,
      stats: SessionStats.fromJson(json['stats'] as Map<String, dynamic>),
    );
  }

  factory SessionModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data()!;
    return SessionModel(
      id: snapshot.id,
      userId: data['userId'] as String,
      deckId: data['deckId'] as String,
      startTime: (data['startTime'] as Timestamp).toDate(),
      endTime: data['endTime'] != null
          ? (data['endTime'] as Timestamp).toDate()
          : null,
      stats: SessionStats.fromJson(data['stats'] as Map<String, dynamic>),
    );
  }
}

class SessionStats {
  final int cardsReviewed;
  final int correctAnswers;
  final int wrongAnswers;
  final double averageTimePerCard;

  SessionStats({
    this.cardsReviewed = 0,
    this.correctAnswers = 0,
    this.wrongAnswers = 0,
    this.averageTimePerCard = 0.0,
  });

  Map<String, dynamic> toJson() {
    return {
      'cardsReviewed': cardsReviewed,
      'correctAnswers': correctAnswers,
      'wrongAnswers': wrongAnswers,
      'averageTimePerCard': averageTimePerCard,
    };
  }

  factory SessionStats.fromJson(Map<String, dynamic> json) {
    return SessionStats(
      cardsReviewed: json['cardsReviewed'] as int? ?? 0,
      correctAnswers: json['correctAnswers'] as int? ?? 0,
      wrongAnswers: json['wrongAnswers'] as int? ?? 0,
      averageTimePerCard: (json['averageTimePerCard'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
