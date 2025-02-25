import 'package:cloud_firestore/cloud_firestore.dart';
import 'base_model.dart';

class ReviewModel implements BaseModel {
  @override
  final String id;
  final String userId;
  final String flashcardId;
  final String deckId;
  final double grade;
  final int timeSpentMs;
  final DateTime timestamp;

  ReviewModel({
    required this.id,
    required this.userId,
    required this.flashcardId,
    required this.deckId,
    required this.grade,
    required this.timeSpentMs,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  @override
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'flashcardId': flashcardId,
      'deckId': deckId,
      'grade': grade,
      'timeSpentMs': timeSpentMs,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  @override
  ReviewModel fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      flashcardId: json['flashcardId'] as String,
      deckId: json['deckId'] as String,
      grade: (json['grade'] as num).toDouble(),
      timeSpentMs: json['timeSpentMs'] as int,
      timestamp: (json['timestamp'] as Timestamp).toDate(),
    );
  }

  factory ReviewModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data()!;
    return ReviewModel(
      id: snapshot.id,
      userId: data['userId'] as String,
      flashcardId: data['flashcardId'] as String,
      deckId: data['deckId'] as String,
      grade: (data['grade'] as num).toDouble(),
      timeSpentMs: data['timeSpentMs'] as int,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }
}
