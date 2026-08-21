import '../domain/auth_service.dart';
import '../domain/user_session.dart';

class MockAuthService implements AuthService {
  static const demoEmail = 'supervisor@demo.com';
  static const demoPassword = '123456';

  static const _users = <String, UserSession>{
    'contratista@demo.com': UserSession(
      userId: 1,
      name: 'Carlos Hernández',
      email: 'contratista@demo.com',
      role: UserRole.contractor,
    ),
    'supervisor@demo.com': UserSession(
      userId: 2,
      name: 'Juan Pérez',
      email: 'supervisor@demo.com',
      role: UserRole.supervisor,
    ),
    'beneficiario@demo.com': UserSession(
      userId: 3,
      name: 'María López',
      email: 'beneficiario@demo.com',
      role: UserRole.beneficiary,
    ),
    'ejecutivo@demo.com': UserSession(
      userId: 4,
      name: 'Laura Martínez',
      email: 'ejecutivo@demo.com',
      role: UserRole.executive,
    ),
  };

  @override
  Future<LoginResult> login({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));

    final session = _users[email.trim().toLowerCase()];
    if (session != null && password == demoPassword) {
      return LoginResult(success: true, session: session);
    }

    return const LoginResult(
      success: false,
      message: 'El correo o la contraseña son incorrectos.',
    );
  }
}
