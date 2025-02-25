import 'package:cloud_firestore/cloud_firestore.dart';
import 'base_model.dart';

class FlashcardModel implements BaseModel {
  @override
  final String id;
  final String deckId;
  final String front;
  final String back;
  final List<String> tags;
  final SM2Data sm2Data;
  final DateTime createdAt;
  final DateTime updatedAt;

  FlashcardModel({
    required this.id,
    required this.deckId,
    required this.front,
    required this.back,
    List<String>? tags,
    SM2Data? sm2Data,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : tags = tags ?? [],
        sm2Data = sm2Data ?? SM2Data(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  @override
  Map<String, dynamic> toJson() {
    return {
      'deckId': deckId,
      'front': front,
      'back': back,
      'tags': tags,
      'sm2Data': sm2Data.toJson(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  @override
  FlashcardModel fromJson(Map<String, dynamic> json) {
    return FlashcardModel(
      id: json['id'] as String,
      deckId: json['deckId'] as String,
      front: json['front'] as String,
      back: json['back'] as String,
      tags: List<String>.from(json['tags'] ?? []),
      sm2Data: SM2Data.fromJson(json['sm2Data'] as Map<String, dynamic>),
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
    );
  }

  factory FlashcardModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data()!;
    return FlashcardModel(
      id: snapshot.id,
      deckId: data['deckId'] as String,
      front: data['front'] as String,
      back: data['back'] as String,
      tags: List<String>.from(data['tags'] ?? []),
      sm2Data: SM2Data.fromJson(data['sm2Data'] as Map<String, dynamic>),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }
}

class SM2Data {
  final int repetitions;
  final double easeFactor;
  final int interval;
  final DateTime? nextReview;
  final double? lastGrade;

  SM2Data({
    this.repetitions = 0,
    this.easeFactor = 2.5,
    this.interval = 0,
    this.nextReview,
    this.lastGrade,
  });

  Map<String, dynamic> toJson() {
    return {
      'repetitions': repetitions,
      'easeFactor': easeFactor,
      'interval': interval,
      'nextReview': nextReview != null ? Timestamp.fromDate(nextReview!) : null,
      'lastGrade': lastGrade,
    };
  }

  factory SM2Data.fromJson(Map<String, dynamic> json) {
    return SM2Data(
      repetitions: json['repetitions'] as int? ?? 0,
      easeFactor: (json['easeFactor'] as num?)?.toDouble() ?? 2.5,
      interval: json['interval'] as int? ?? 0,
      nextReview: json['nextReview'] != null
          ? (json['nextReview'] as Timestamp).toDate()
          : null,
      lastGrade: (json['lastGrade'] as num?)?.toDouble(),
    );
  }
}
