import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/errors/auth_errors.dart';
import '../../../data/services/auth_service.dart';
import '../../../domain/models/user_model.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;
  StreamSubscription<UserModel?>? _authStateSubscription;

  AuthBloc({required AuthService authService})
      : _authService = authService,
        super(const AuthState.initial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<SignUpRequested>(_onSignUpRequested);
    on<SignInRequested>(_onSignInRequested);
    on<SignOutRequested>(_onSignOutRequested);
    on<ResetPasswordRequested>(_onResetPasswordRequested);
    on<UpdateProfileRequested>(_onUpdateProfileRequested);

    // Inicia a escuta das mudanças de estado de autenticação
    _authStateSubscription = _authService.authStateChanges.listen(
      (UserModel? user) {
        if (user != null) {
          add(AuthCheckRequested());
        } else {
          emit(const AuthState.unauthenticated());
        }
      },
    );
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    final user = _authService.currentUser;
    if (user != null) {
      emit(AuthState.authenticated(user));
    } else {
      emit(const AuthState.unauthenticated());
    }
  }

  Future<void> _onSignUpRequested(
    SignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final user = await _authService.signUp(
        email: event.email,
        password: event.password,
        displayName: event.displayName,
      );
      emit(AuthState.authenticated(user));
    } on AuthException catch (e) {
      emit(AuthState.unauthenticated(e.message));
    }
  }

  Future<void> _onSignInRequested(
    SignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final user = await _authService.signIn(
        email: event.email,
        password: event.password,
      );
      emit(AuthState.authenticated(user));
    } on AuthException catch (e) {
      emit(AuthState.unauthenticated(e.message));
    }
  }

  Future<void> _onSignOutRequested(
    SignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _authService.signOut();
      emit(const AuthState.unauthenticated());
    } on AuthException catch (e) {
      emit(AuthState.unauthenticated(e.message));
    }
  }

  Future<void> _onResetPasswordRequested(
    ResetPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _authService.sendPasswordResetEmail(event.email);
    } on AuthException catch (e) {
      emit(AuthState.unauthenticated(e.message));
    }
  }

  Future<void> _onUpdateProfileRequested(
    UpdateProfileRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final user = await _authService.updateProfile(
        displayName: event.displayName,
        photoUrl: event.photoUrl,
      );
      emit(AuthState.authenticated(user));
    } on AuthException catch (e) {
      emit(AuthState.unauthenticated(e.message));
    }
  }

  @override
  Future<void> close() {
    _authStateSubscription?.cancel();
    return super.close();
  }
}
