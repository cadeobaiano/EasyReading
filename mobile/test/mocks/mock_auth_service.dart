import 'package:mockito/mockito.dart';
import '../../lib/domain/services/auth_service.dart';
import '../../lib/domain/models/user_model.dart';

class MockAuthService extends Mock implements AuthService {
  @override
  Stream<UserModel?> get authStateChanges => Stream.value(null);

  @override
  Future<UserModel> signInWithEmailAndPassword(String email, String password) async {
    if (email == 'test@example.com' && password == 'password123') {
      return UserModel(
        id: 'test-user-id',
        email: email,
        displayName: 'Test User',
      );
    }
    throw Exception('Invalid credentials');
  }

  @override
  Future<UserModel> createUserWithEmailAndPassword(String email, String password) async {
    if (email.contains('@') && password.length >= 6) {
      return UserModel(
        id: 'new-user-id',
        email: email,
        displayName: email.split('@')[0],
      );
    }
    throw Exception('Invalid email or weak password');
  }

  @override
  Future<void> signOut() async {
    // Mock implementation
  }
}
