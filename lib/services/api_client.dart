import 'package:http/http.dart' as http;
import 'dart:convert';
import 'auth_service.dart';

/// Wrapper sobre http que inyecta el JWT en cada petición
/// y reintenta una vez si recibe 401 (token expirado).
class ApiClient {
  static Future<http.Response> get(String url) async {
    return _withRetry(() async {
      final headers = await AuthService.authHeaders();
      return http.get(Uri.parse(url), headers: headers);
    });
  }

  static Future<http.Response> post(
    String url,
    Map<String, dynamic> body,
  ) async {
    return _withRetry(() async {
      final headers = await AuthService.authHeaders();
      return http.post(
        Uri.parse(url),
        headers: headers,
        body: json.encode(body),
      );
    });
  }

  static Future<http.Response> put(
    String url,
    Map<String, dynamic> body,
  ) async {
    return _withRetry(() async {
      final headers = await AuthService.authHeaders();
      return http.put(
        Uri.parse(url),
        headers: headers,
        body: json.encode(body),
      );
    });
  }

  static Future<http.Response> delete(
    String url, {
    Map<String, dynamic>? body,
  }) async {
    return _withRetry(() async {
      final headers = await AuthService.authHeaders();
      return http.delete(
        Uri.parse(url),
        headers: headers,
        body: body != null ? json.encode(body) : null,
      );
    });
  }

  // ──────────────────────────────────────────────
  // Reintenta automáticamente si el servidor devuelve 401
  // ──────────────────────────────────────────────
  static Future<http.Response> _withRetry(
    Future<http.Response> Function() request,
  ) async {
    var res = await request();

    if (res.statusCode == 401) {
      // Intentar refrescar el token
      final newToken = await AuthService.refreshAccessToken();
      if (newToken != null) {
        // Reintentar con el nuevo token
        res = await request();
      } else {
        throw Exception('Sesión expirada. Por favor inicia sesión nuevamente.');
      }
    }

    return res;
  }
}