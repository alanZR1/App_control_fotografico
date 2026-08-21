import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_imagenes/core/network/api_client.dart';
import 'package:mobile_imagenes/features/auth/data/api_auth_service.dart';
import 'package:mobile_imagenes/features/auth/domain/user_session.dart';

void main() {
  test('convierte la respuesta del backend en una sesión móvil', () async {
    final client = _FakeClient({
      'idUsuario': 8,
      'nombre': 'Juan Pérez',
      'correo': 'juan@example.com',
      'idObra': 214,
      'idRol': 2,
      'rol': 'Supervisor',
    });

    final result = await ApiAuthService(client)
        .login(email: 'juan@example.com', password: '123456');

    expect(result.success, isTrue);
    expect(result.session?.role, UserRole.supervisor);
    expect(result.session?.workId, 214);
    expect(client.lastPath, '/api/auth/login');
    expect(client.lastBody?['correo'], 'juan@example.com');
  });

  test('presenta al usuario el mensaje de error del backend', () async {
    final result = await ApiAuthService(
      _FakeClient.error(
        const ApiException('Correo o contraseña incorrectos.', statusCode: 401),
      ),
    ).login(email: 'nadie@example.com', password: 'incorrecta');

    expect(result.success, isFalse);
    expect(result.message, 'Correo o contraseña incorrectos.');
  });
}

class _FakeClient implements JsonApiClient {
  _FakeClient(this.response) : error = null;
  _FakeClient.error(this.error) : response = null;

  final Map<String, dynamic>? response;
  final ApiException? error;
  String? lastPath;
  Map<String, Object?>? lastBody;

  @override
  set bearerToken(String? value) {}

  @override
  Future<Map<String, dynamic>> postJson(
    String path,
    Map<String, Object?> body,
  ) async {
    lastPath = path;
    lastBody = body;
    if (error != null) throw error!;
    return response!;
  }
}
