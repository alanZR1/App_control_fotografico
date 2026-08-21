import 'user_session.dart';

class LoginResult {
  const LoginResult({required this.success, this.message, this.session});

  final bool success;
  final String? message;
  final UserSession? session;
}

abstract interface class AuthService {
  Future<LoginResult> login({required String email, required String password});
}
