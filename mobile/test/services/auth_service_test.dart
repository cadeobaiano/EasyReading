import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import '../../lib/domain/services/auth_service.dart';
import '../../lib/domain/models/user_model.dart';

void main() {
  late MockFirebaseAuth mockFirebaseAuth;
  late AuthService authService;

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    authService = AuthService(firebaseAuth: mockFirebaseAuth);
  });

  group('AuthService', () {
    test('signInWithEmailAndPassword should return UserModel on success', () async {
      final email = 'test@example.com';
      final password = 'password123';

      final result = await authService.signInWithEmailAndPassword(email, password);

      expect(result, isA<UserModel>());
      expect(result.email, equals(email));
    });

    test('createUserWithEmailAndPassword should return UserModel on success', () async {
      final email = 'newuser@example.com';
      final password = 'newpassword123';

      final result = await authService.createUserWithEmailAndPassword(email, password);

      expect(result, isA<UserModel>());
      expect(result.email, equals(email));
    });

    test('signOut should complete successfully', () async {
      await expectLater(authService.signOut(), completes);
    });

    test('authStateChanges should emit user changes', () async {
      final stream = authService.authStateChanges;
      expect(stream, emits(isNull));
    });

    test('getCurrentUser should return null when not authenticated', () async {
      final user = await authService.getCurrentUser();
      expect(user, isNull);
    });

    test('sendPasswordResetEmail should complete successfully', () async {
      final email = 'test@example.com';
      await expectLater(
        authService.sendPasswordResetEmail(email),
        completes,
      );
    });

    test('updateProfile should update user data', () async {
      final displayName = 'New Name';
      await expectLater(
        authService.updateProfile(displayName: displayName),
        completes,
      );
    });
  });
}
