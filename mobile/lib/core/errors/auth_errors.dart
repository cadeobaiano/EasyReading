class AuthException implements Exception {
  final String message;
  final String code;

  AuthException({required this.message, required this.code});

  @override
  String toString() => 'AuthException: $message (Code: $code)';
}

class EmailAlreadyInUseException extends AuthException {
  EmailAlreadyInUseException()
      : super(
          message: 'Este e-mail já está em uso.',
          code: 'email-already-in-use',
        );
}

class WeakPasswordException extends AuthException {
  WeakPasswordException()
      : super(
          message: 'A senha é muito fraca. Use pelo menos 6 caracteres.',
          code: 'weak-password',
        );
}

class InvalidEmailException extends AuthException {
  InvalidEmailException()
      : super(
          message: 'O e-mail fornecido é inválido.',
          code: 'invalid-email',
        );
}

class UserNotFoundException extends AuthException {
  UserNotFoundException()
      : super(
          message: 'Usuário não encontrado.',
          code: 'user-not-found',
        );
}

class WrongPasswordException extends AuthException {
  WrongPasswordException()
      : super(
          message: 'Senha incorreta.',
          code: 'wrong-password',
        );
}

class UserDisabledException extends AuthException {
  UserDisabledException()
      : super(
          message: 'Esta conta foi desativada.',
          code: 'user-disabled',
        );
}

class NetworkException extends AuthException {
  NetworkException()
      : super(
          message: 'Erro de conexão. Verifique sua internet.',
          code: 'network-error',
        );
}

class UnknownException extends AuthException {
  UnknownException([String? message])
      : super(
          message: message ?? 'Ocorreu um erro desconhecido.',
          code: 'unknown',
        );
}
