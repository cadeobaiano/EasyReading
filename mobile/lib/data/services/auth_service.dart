import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:logger/logger.dart';
import '../../core/errors/auth_errors.dart';
import '../../domain/models/user_model.dart';

class AuthService {
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final Logger _logger;

  AuthService({
    firebase_auth.FirebaseAuth? firebaseAuth,
    Logger? logger,
  })  : _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance,
        _logger = logger ?? Logger();

  /// Stream que emite o estado atual da autenticação
  Stream<UserModel?> get authStateChanges => _firebaseAuth.authStateChanges().map(
        (firebase_auth.User? user) =>
            user != null ? UserModel.fromFirebaseUser(user) : null,
      );

  /// Retorna o usuário atual, se houver
  UserModel? get currentUser {
    final user = _firebaseAuth.currentUser;
    return user != null ? UserModel.fromFirebaseUser(user) : null;
  }

  /// Registra um novo usuário com e-mail e senha
  Future<UserModel> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (displayName != null) {
        await userCredential.user?.updateDisplayName(displayName);
      }

      final user = userCredential.user;
      if (user == null) throw UnknownException('Falha ao criar usuário');

      _logger.i('Usuário registrado com sucesso: ${user.email}');
      return UserModel.fromFirebaseUser(user);
    } on firebase_auth.FirebaseAuthException catch (e, stackTrace) {
      _logger.e('Erro no registro', e, stackTrace);
      switch (e.code) {
        case 'email-already-in-use':
          throw EmailAlreadyInUseException();
        case 'invalid-email':
          throw InvalidEmailException();
        case 'weak-password':
          throw WeakPasswordException();
        case 'network-request-failed':
          throw NetworkException();
        default:
          throw UnknownException(e.message);
      }
    } catch (e, stackTrace) {
      _logger.e('Erro desconhecido no registro', e, stackTrace);
      throw UnknownException();
    }
  }

  /// Faz login com e-mail e senha
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) throw UnknownException('Falha ao fazer login');

      _logger.i('Usuário logado com sucesso: ${user.email}');
      return UserModel.fromFirebaseUser(user);
    } on firebase_auth.FirebaseAuthException catch (e, stackTrace) {
      _logger.e('Erro no login', e, stackTrace);
      switch (e.code) {
        case 'user-not-found':
          throw UserNotFoundException();
        case 'wrong-password':
          throw WrongPasswordException();
        case 'invalid-email':
          throw InvalidEmailException();
        case 'user-disabled':
          throw UserDisabledException();
        case 'network-request-failed':
          throw NetworkException();
        default:
          throw UnknownException(e.message);
      }
    } catch (e, stackTrace) {
      _logger.e('Erro desconhecido no login', e, stackTrace);
      throw UnknownException();
    }
  }

  /// Faz logout do usuário atual
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
      _logger.i('Usuário deslogado com sucesso');
    } catch (e, stackTrace) {
      _logger.e('Erro ao fazer logout', e, stackTrace);
      throw UnknownException();
    }
  }

  /// Envia e-mail de redefinição de senha
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      _logger.i('E-mail de redefinição enviado para: $email');
    } on firebase_auth.FirebaseAuthException catch (e, stackTrace) {
      _logger.e('Erro ao enviar e-mail de redefinição', e, stackTrace);
      switch (e.code) {
        case 'user-not-found':
          throw UserNotFoundException();
        case 'invalid-email':
          throw InvalidEmailException();
        case 'network-request-failed':
          throw NetworkException();
        default:
          throw UnknownException(e.message);
      }
    } catch (e, stackTrace) {
      _logger.e('Erro desconhecido ao enviar e-mail de redefinição', e, stackTrace);
      throw UnknownException();
    }
  }

  /// Atualiza o perfil do usuário
  Future<UserModel> updateProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) throw UnknownException('Usuário não está logado');

      await user.updateDisplayName(displayName);
      if (photoUrl != null) {
        await user.updatePhotoURL(photoUrl);
      }

      _logger.i('Perfil atualizado com sucesso');
      return UserModel.fromFirebaseUser(user);
    } catch (e, stackTrace) {
      _logger.e('Erro ao atualizar perfil', e, stackTrace);
      throw UnknownException();
    }
  }
}
