import '../../../core/network/api_client.dart';
import '../domain/auth_service.dart';
import '../domain/user_session.dart';

class ApiAuthService implements AuthService {
  const ApiAuthService(this.client);
  final JsonApiClient client;

  @override
  Future<LoginResult> login({
    required String email,
    required String password,
  }) async {
    try {
      final json = await client.postJson('/api/auth/login', {
        'correo': email.trim(),
        'password': password,
      });
      final role = _parseRole(json['rol'], json['idRol']);
      final userId = _asInt(json['idUsuario']);
      final name = json['nombre'] as String?;
      final serverEmail = json['correo'] as String?;
      if (role == null ||
          userId == null ||
          name == null ||
          serverEmail == null) {
        return const LoginResult(
          success: false,
          message: 'El servidor devolvió una sesión incompleta.',
        );
      }
      final token = json['token'] as String?;
      client.bearerToken = token;
      return LoginResult(
        success: true,
        session: UserSession(
          userId: userId,
          name: name,
          email: serverEmail,
          role: role,
          workId: _asInt(json['idObra']),
          token: token,
        ),
      );
    } on ApiException catch (error) {
      return LoginResult(success: false, message: error.message);
    } catch (_) {
      return const LoginResult(
        success: false,
        message: 'No fue posible procesar la respuesta de inicio de sesión.',
      );
    }
  }

  int? _asInt(Object? value) => switch (value) {
    int number => number,
    num number => number.toInt(),
    String text => int.tryParse(text),
    _ => null,
  };

  UserRole? _parseRole(Object? value, Object? idValue) {
    final normalized = (value as String? ?? '')
        .trim()
        .toLowerCase()
        .replaceAll(RegExp('[áä]'), 'a')
        .replaceAll(RegExp('[éë]'), 'e')
        .replaceAll(RegExp('[íï]'), 'i')
        .replaceAll(RegExp('[óö]'), 'o')
        .replaceAll(RegExp('[úü]'), 'u');
    if (normalized.contains('contrat')) return UserRole.contractor;
    if (normalized.contains('supervis')) return UserRole.supervisor;
    if (normalized.contains('benefici')) return UserRole.beneficiary;
    if (normalized.contains('ejecut')) return UserRole.executive;
    return switch (_asInt(idValue)) {
      1 => UserRole.contractor,
      2 => UserRole.supervisor,
      3 => UserRole.beneficiary,
      4 => UserRole.executive,
      _ => null,
    };
  }
}
