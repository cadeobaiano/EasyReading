import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

class UserModel extends Equatable {
  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final DateTime? lastSignInTime;
  final DateTime creationTime;

  const UserModel({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.lastSignInTime,
    required this.creationTime,
  });

  /// Cria um UserModel a partir de um User do Firebase
  factory UserModel.fromFirebaseUser(firebase_auth.User user) {
    return UserModel(
      id: user.uid,
      email: user.email!,
      displayName: user.displayName,
      photoUrl: user.photoURL,
      lastSignInTime: user.metadata.lastSignInTime,
      creationTime: user.metadata.creationTime ?? DateTime.now(),
    );
  }

  /// Cria uma cópia do UserModel com alguns campos atualizados
  UserModel copyWith({
    String? displayName,
    String? photoUrl,
    DateTime? lastSignInTime,
  }) {
    return UserModel(
      id: id,
      email: email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      lastSignInTime: lastSignInTime ?? this.lastSignInTime,
      creationTime: creationTime,
    );
  }

  @override
  List<Object?> get props => [id, email, displayName, photoUrl, lastSignInTime, creationTime];
}
