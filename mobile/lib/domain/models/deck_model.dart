import 'package:cloud_firestore/cloud_firestore.dart';
import 'base_model.dart';

class DeckModel implements BaseModel {
  @override
  final String id;
  final String userId;
  final String title;
  final String description;
  final String visibility; // 'public' ou 'private'
  final List<String> collaborators;
  final DeckStats stats;
  final DateTime createdAt;
  final DateTime updatedAt;

  DeckModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.visibility,
    List<String>? collaborators,
    DeckStats? stats,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : collaborators = collaborators ?? [],
        stats = stats ?? DeckStats(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  @override
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'title': title,
      'description': description,
      'visibility': visibility,
      'collaborators': collaborators,
      'stats': stats.toJson(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  @override
  DeckModel fromJson(Map<String, dynamic> json) {
    return DeckModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      visibility: json['visibility'] as String,
      collaborators: List<String>.from(json['collaborators'] ?? []),
      stats: DeckStats.fromJson(json['stats'] as Map<String, dynamic>),
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
    );
  }

  factory DeckModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data()!;
    return DeckModel(
      id: snapshot.id,
      userId: data['userId'] as String,
      title: data['title'] as String,
      description: data['description'] as String,
      visibility: data['visibility'] as String,
      collaborators: List<String>.from(data['collaborators'] ?? []),
      stats: DeckStats.fromJson(data['stats'] as Map<String, dynamic>),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }
}

class DeckStats {
  final int totalCards;
  final int mastered;
  final int learning;
  final int needsReview;

  DeckStats({
    this.totalCards = 0,
    this.mastered = 0,
    this.learning = 0,
    this.needsReview = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'totalCards': totalCards,
      'mastered': mastered,
      'learning': learning,
      'needsReview': needsReview,
    };
  }

  factory DeckStats.fromJson(Map<String, dynamic> json) {
    return DeckStats(
      totalCards: json['totalCards'] as int? ?? 0,
      mastered: json['mastered'] as int? ?? 0,
      learning: json['learning'] as int? ?? 0,
      needsReview: json['needsReview'] as int? ?? 0,
    );
  }
}
