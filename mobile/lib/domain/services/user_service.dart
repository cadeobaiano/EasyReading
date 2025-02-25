import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easy_reading/domain/models/user_profile.dart';

class UserService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  UserService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  Future<UserProfile> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Usuário não autenticado');

    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (!doc.exists) {
      // Criar perfil padrão se não existir
      final defaultProfile = UserProfile(
        id: user.uid,
        name: user.displayName ?? 'Usuário',
        email: user.email!,
        photoUrl: user.photoURL,
        preferences: UserPreferences(
          notificationSettings: NotificationSettings(
            reminderTime: const TimeOfDay(hour: 20, minute: 0),
          ),
        ),
        statistics: const UserStatistics(),
        createdAt: DateTime.now(),
        lastActive: DateTime.now(),
      );
      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(defaultProfile.toJson());
      return defaultProfile;
    }

    return UserProfile.fromJson({
      'id': doc.id,
      ...doc.data()!,
    });
  }

  Future<void> updateProfile(UserProfile profile) async {
    await _firestore.collection('users').doc(profile.id).update(profile.toJson());
  }

  Future<void> updatePreferences(String userId, UserPreferences preferences) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .update({'preferences': preferences.toJson()});
  }

  Future<void> updateStatistics(String userId, UserStatistics statistics) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .update({'statistics': statistics.toJson()});
  }

  Future<void> recordDailyProgress(String userId, DailyProgress progress) async {
    final userRef = _firestore.collection('users').doc(userId);
    
    await _firestore.runTransaction((transaction) async {
      final doc = await transaction.get(userRef);
      final currentStats =
          UserStatistics.fromJson(doc.data()!['statistics'] as Map<String, dynamic>);

      final updatedProgress = List<DailyProgress>.from(currentStats.dailyProgress)
        ..add(progress);

      // Manter apenas os últimos 30 dias
      if (updatedProgress.length > 30) {
        updatedProgress.removeAt(0);
      }

      final updatedStats = currentStats.copyWith(
        totalSessions: currentStats.totalSessions + 1,
        totalCards: currentStats.totalCards + progress.cardsStudied,
        averageAccuracy: (currentStats.averageAccuracy *
                    currentStats.totalSessions +
                (progress.correctAnswers / progress.cardsStudied)) /
            (currentStats.totalSessions + 1),
        totalStudyTime: currentStats.totalStudyTime + progress.studyTime,
        dailyProgress: updatedProgress,
      );

      transaction.update(
        userRef,
        {
          'statistics': updatedStats.toJson(),
          'lastActive': DateTime.now().toIso8601String(),
        },
      );
    });
  }

  Stream<UserProfile> userProfileStream() {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Usuário não autenticado');

    return _firestore.collection('users').doc(user.uid).snapshots().map(
          (doc) => UserProfile.fromJson({
            'id': doc.id,
            ...doc.data()!,
          }),
        );
  }
}
