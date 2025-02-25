class UserProfile {
  final String id;
  final String name;
  final String email;
  final String? photoUrl;
  final UserPreferences preferences;
  final UserStatistics statistics;
  final DateTime createdAt;
  final DateTime lastActive;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
    required this.preferences,
    required this.statistics,
    required this.createdAt,
    required this.lastActive,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      photoUrl: json['photoUrl'] as String?,
      preferences: UserPreferences.fromJson(
        json['preferences'] as Map<String, dynamic>,
      ),
      statistics: UserStatistics.fromJson(
        json['statistics'] as Map<String, dynamic>,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastActive: DateTime.parse(json['lastActive'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'preferences': preferences.toJson(),
      'statistics': statistics.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'lastActive': lastActive.toIso8601String(),
    };
  }

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? photoUrl,
    UserPreferences? preferences,
    UserStatistics? statistics,
    DateTime? createdAt,
    DateTime? lastActive,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      preferences: preferences ?? this.preferences,
      statistics: statistics ?? this.statistics,
      createdAt: createdAt ?? this.createdAt,
      lastActive: lastActive ?? this.lastActive,
    );
  }
}

class UserPreferences {
  final bool isDarkMode;
  final bool enableNotifications;
  final bool enableSoundEffects;
  final NotificationSettings notificationSettings;
  final String preferredLanguage;

  const UserPreferences({
    this.isDarkMode = false,
    this.enableNotifications = true,
    this.enableSoundEffects = true,
    required this.notificationSettings,
    this.preferredLanguage = 'pt_BR',
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      isDarkMode: json['isDarkMode'] as bool? ?? false,
      enableNotifications: json['enableNotifications'] as bool? ?? true,
      enableSoundEffects: json['enableSoundEffects'] as bool? ?? true,
      notificationSettings: NotificationSettings.fromJson(
        json['notificationSettings'] as Map<String, dynamic>,
      ),
      preferredLanguage: json['preferredLanguage'] as String? ?? 'pt_BR',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isDarkMode': isDarkMode,
      'enableNotifications': enableNotifications,
      'enableSoundEffects': enableSoundEffects,
      'notificationSettings': notificationSettings.toJson(),
      'preferredLanguage': preferredLanguage,
    };
  }

  UserPreferences copyWith({
    bool? isDarkMode,
    bool? enableNotifications,
    bool? enableSoundEffects,
    NotificationSettings? notificationSettings,
    String? preferredLanguage,
  }) {
    return UserPreferences(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      enableNotifications: enableNotifications ?? this.enableNotifications,
      enableSoundEffects: enableSoundEffects ?? this.enableSoundEffects,
      notificationSettings: notificationSettings ?? this.notificationSettings,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
    );
  }
}

class NotificationSettings {
  final bool dailyReminder;
  final TimeOfDay reminderTime;
  final bool weeklyProgress;
  final bool achievementAlerts;

  const NotificationSettings({
    this.dailyReminder = true,
    required this.reminderTime,
    this.weeklyProgress = true,
    this.achievementAlerts = true,
  });

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    final timeString = json['reminderTime'] as String;
    final timeParts = timeString.split(':');
    
    return NotificationSettings(
      dailyReminder: json['dailyReminder'] as bool? ?? true,
      reminderTime: TimeOfDay(
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1]),
      ),
      weeklyProgress: json['weeklyProgress'] as bool? ?? true,
      achievementAlerts: json['achievementAlerts'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dailyReminder': dailyReminder,
      'reminderTime': '${reminderTime.hour}:${reminderTime.minute}',
      'weeklyProgress': weeklyProgress,
      'achievementAlerts': achievementAlerts,
    };
  }

  NotificationSettings copyWith({
    bool? dailyReminder,
    TimeOfDay? reminderTime,
    bool? weeklyProgress,
    bool? achievementAlerts,
  }) {
    return NotificationSettings(
      dailyReminder: dailyReminder ?? this.dailyReminder,
      reminderTime: reminderTime ?? this.reminderTime,
      weeklyProgress: weeklyProgress ?? this.weeklyProgress,
      achievementAlerts: achievementAlerts ?? this.achievementAlerts,
    );
  }
}

class UserStatistics {
  final int totalSessions;
  final int totalCards;
  final int masteredCards;
  final double averageAccuracy;
  final int streakDays;
  final int totalStudyTime;
  final List<DailyProgress> dailyProgress;
  final Map<String, int> difficultyDistribution;

  const UserStatistics({
    this.totalSessions = 0,
    this.totalCards = 0,
    this.masteredCards = 0,
    this.averageAccuracy = 0.0,
    this.streakDays = 0,
    this.totalStudyTime = 0,
    this.dailyProgress = const [],
    this.difficultyDistribution = const {},
  });

  factory UserStatistics.fromJson(Map<String, dynamic> json) {
    return UserStatistics(
      totalSessions: json['totalSessions'] as int? ?? 0,
      totalCards: json['totalCards'] as int? ?? 0,
      masteredCards: json['masteredCards'] as int? ?? 0,
      averageAccuracy: (json['averageAccuracy'] as num?)?.toDouble() ?? 0.0,
      streakDays: json['streakDays'] as int? ?? 0,
      totalStudyTime: json['totalStudyTime'] as int? ?? 0,
      dailyProgress: (json['dailyProgress'] as List<dynamic>?)
              ?.map((e) => DailyProgress.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      difficultyDistribution:
          Map<String, int>.from(json['difficultyDistribution'] as Map? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalSessions': totalSessions,
      'totalCards': totalCards,
      'masteredCards': masteredCards,
      'averageAccuracy': averageAccuracy,
      'streakDays': streakDays,
      'totalStudyTime': totalStudyTime,
      'dailyProgress': dailyProgress.map((e) => e.toJson()).toList(),
      'difficultyDistribution': difficultyDistribution,
    };
  }

  UserStatistics copyWith({
    int? totalSessions,
    int? totalCards,
    int? masteredCards,
    double? averageAccuracy,
    int? streakDays,
    int? totalStudyTime,
    List<DailyProgress>? dailyProgress,
    Map<String, int>? difficultyDistribution,
  }) {
    return UserStatistics(
      totalSessions: totalSessions ?? this.totalSessions,
      totalCards: totalCards ?? this.totalCards,
      masteredCards: masteredCards ?? this.masteredCards,
      averageAccuracy: averageAccuracy ?? this.averageAccuracy,
      streakDays: streakDays ?? this.streakDays,
      totalStudyTime: totalStudyTime ?? this.totalStudyTime,
      dailyProgress: dailyProgress ?? this.dailyProgress,
      difficultyDistribution:
          difficultyDistribution ?? this.difficultyDistribution,
    );
  }
}

class DailyProgress {
  final DateTime date;
  final int cardsStudied;
  final int correctAnswers;
  final int studyTime;

  const DailyProgress({
    required this.date,
    required this.cardsStudied,
    required this.correctAnswers,
    required this.studyTime,
  });

  factory DailyProgress.fromJson(Map<String, dynamic> json) {
    return DailyProgress(
      date: DateTime.parse(json['date'] as String),
      cardsStudied: json['cardsStudied'] as int,
      correctAnswers: json['correctAnswers'] as int,
      studyTime: json['studyTime'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'cardsStudied': cardsStudied,
      'correctAnswers': correctAnswers,
      'studyTime': studyTime,
    };
  }
}
