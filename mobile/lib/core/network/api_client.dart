import 'dart:async';
import 'dart:convert';
import 'dart:io';

class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});
  final String message;
  final int? statusCode;
}

abstract interface class JsonApiClient {
  set bearerToken(String? value);
  Future<Map<String, dynamic>> postJson(String path, Map<String, Object?> body);
}

class ApiClient implements JsonApiClient {
  ApiClient({
    required this.baseUrl,
    HttpClient? httpClient,
    this.timeout = const Duration(seconds: 12),
  }) : _httpClient = httpClient ?? HttpClient();

  final String baseUrl;
  final HttpClient _httpClient;
  final Duration timeout;
  @override
  String? bearerToken;

  @override
  Future<Map<String, dynamic>> postJson(
    String path,
    Map<String, Object?> body,
  ) async {
    try {
      final request = await _httpClient
          .postUrl(Uri.parse('$baseUrl$path'))
          .timeout(timeout);
      request.headers.contentType = ContentType.json;
      request.headers.set(HttpHeaders.acceptHeader, ContentType.json.mimeType);
      final token = bearerToken;
      if (token != null && token.isNotEmpty) {
        request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
      }
      request.write(jsonEncode(body));
      final response = await request.close().timeout(timeout);
      final responseText = await utf8.decoder.bind(response).join();
      final decoded = responseText.isEmpty ? null : jsonDecode(responseText);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiException(
          _errorMessage(decoded) ?? 'El servidor respondió con un error.',
          statusCode: response.statusCode,
        );
      }
      if (decoded is! Map<String, dynamic>) {
        throw const ApiException('La respuesta del servidor no es válida.');
      }
      return decoded;
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw const ApiException('El servidor tardó demasiado en responder.');
    } on SocketException {
      throw const ApiException(
        'No fue posible conectar con el servidor. Verifica que el backend esté encendido.',
      );
    } on FormatException {
      throw const ApiException('El servidor devolvió una respuesta ilegible.');
    }
  }

  String? _errorMessage(Object? decoded) {
    if (decoded is Map<String, dynamic>) {
      for (final key in ['message', 'error', 'detalle']) {
        final value = decoded[key];
        if (value is String && value.trim().isNotEmpty) return value;
      }
    }
    if (decoded is String && decoded.trim().isNotEmpty) return decoded;
    return null;
  }
}
