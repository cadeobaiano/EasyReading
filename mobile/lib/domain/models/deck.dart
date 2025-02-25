class Deck {
  final String id;
  final String title;
  final String description;
  final int cardCount;
  final bool isFeatured;
  final DateTime createdAt;
  final DateTime? lastUpdated;
  final String? imageUrl;
  final Map<String, dynamic>? metadata;

  const Deck({
    required this.id,
    required this.title,
    required this.description,
    required this.cardCount,
    this.isFeatured = false,
    required this.createdAt,
    this.lastUpdated,
    this.imageUrl,
    this.metadata,
  });

  factory Deck.fromJson(Map<String, dynamic> json) {
    return Deck(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      cardCount: json['cardCount'] as int,
      isFeatured: json['isFeatured'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'] as String)
          : null,
      imageUrl: json['imageUrl'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'cardCount': cardCount,
      'isFeatured': isFeatured,
      'createdAt': createdAt.toIso8601String(),
      'lastUpdated': lastUpdated?.toIso8601String(),
      'imageUrl': imageUrl,
      'metadata': metadata,
    };
  }

  Deck copyWith({
    String? id,
    String? title,
    String? description,
    int? cardCount,
    bool? isFeatured,
    DateTime? createdAt,
    DateTime? lastUpdated,
    String? imageUrl,
    Map<String, dynamic>? metadata,
  }) {
    return Deck(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      cardCount: cardCount ?? this.cardCount,
      isFeatured: isFeatured ?? this.isFeatured,
      createdAt: createdAt ?? this.createdAt,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      imageUrl: imageUrl ?? this.imageUrl,
      metadata: metadata ?? this.metadata,
    );
  }
}
