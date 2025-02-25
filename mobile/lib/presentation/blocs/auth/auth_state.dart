import 'package:equatable/equatable.dart';
import '../../../domain/models/user_model.dart';

enum AuthStatus { initial, authenticated, unauthenticated }

class AuthState extends Equatable {
  final AuthStatus status;
  final UserModel? user;
  final String? error;

  const AuthState._({
    this.status = AuthStatus.initial,
    this.user,
    this.error,
  });

  const AuthState.initial() : this._();

  const AuthState.authenticated(UserModel user)
      : this._(status: AuthStatus.authenticated, user: user);

  const AuthState.unauthenticated([String? error])
      : this._(status: AuthStatus.unauthenticated, error: error);

  @override
  List<Object?> get props => [status, user, error];
}
