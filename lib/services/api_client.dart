import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'auth_service.dart';

/// Wrapper sobre http que inyecta el JWT en cada petición
/// y reintenta una vez si recibe 401 (token expirado).
class ApiClient {
  static Future<http.Response> get(String url) async {
    return _withRetry(() async {
      print('🔍 [API GET] URL: $url');
      final headers = await AuthService.authHeaders();
      print('📋 [API GET] Headers: $headers');
      final response = await http.get(Uri.parse(url), headers: headers);
      final bodyPreview = response.body.isNotEmpty 
        ? response.body.substring(0, min(response.body.length, 200))
        : '[empty]';
      print('✅ [API GET] Status: ${response.statusCode}, Body: $bodyPreview');
      return response;
    });
  }

  static Future<http.Response> post(
    String url,
    Map<String, dynamic> body,
  ) async {
    return _withRetry(() async {
      print('🔍 [API POST] URL: $url');
      print('📦 [API POST] Body: $body');
      final headers = await AuthService.authHeaders();
      print('📋 [API POST] Headers: $headers');
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: json.encode(body),
      );
      final bodyPreview = response.body.isNotEmpty 
        ? response.body.substring(0, min(response.body.length, 200))
        : '[empty]';
      print('✅ [API POST] Status: ${response.statusCode}, Body: $bodyPreview');
      return response;
    });
  }

  static Future<http.Response> put(
    String url,
    Map<String, dynamic> body,
  ) async {
    return _withRetry(() async {
      print('🔍 [API PUT] URL: $url');
      print('📦 [API PUT] Body: $body');
      final headers = await AuthService.authHeaders();
      print('📋 [API PUT] Headers: $headers');
      final response = await http.put(
        Uri.parse(url),
        headers: headers,
        body: json.encode(body),
      );
      final bodyPreview = response.body.isNotEmpty 
        ? response.body.substring(0, min(response.body.length, 200))
        : '[empty]';
      print('✅ [API PUT] Status: ${response.statusCode}, Body: $bodyPreview');
      return response;
    });
  }

  static Future<http.Response> delete(
    String url, {
    Map<String, dynamic>? body,
  }) async {
    return _withRetry(() async {
      print('🔍 [API DELETE] URL: $url');
      if (body != null) print('📦 [API DELETE] Body: $body');
      final headers = await AuthService.authHeaders();
      print('📋 [API DELETE] Headers: $headers');
      final response = await http.delete(
        Uri.parse(url),
        headers: headers,
        body: body != null ? json.encode(body) : null,
      );
      final bodyPreview = response.body.isNotEmpty 
        ? response.body.substring(0, min(response.body.length, 200))
        : '[empty]';
      print('✅ [API DELETE] Status: ${response.statusCode}, Body: $bodyPreview');
      return response;
    });
  }

  // ──────────────────────────────────────────────
  // Reintenta automáticamente si el servidor devuelve 401
  // ──────────────────────────────────────────────
  static Future<http.Response> _withRetry(
    Future<http.Response> Function() request,
  ) async {
    try {
      var res = await request();

      if (res.statusCode == 401) {
        print('⚠️ [API] Token expirado (401), intentando refrescar...');
        // Intentar refrescar el token
        final newToken = await AuthService.refreshAccessToken();
        if (newToken != null) {
          print('✅ [API] Token refrescado, reintentando petición...');
          // Reintentar con el nuevo token
          res = await request();
        } else {
          print('❌ [API] No se pudo refrescar el token');
          throw Exception('Sesión expirada. Por favor inicia sesión nuevamente.');
        }
      }

      return res;
    } catch (e) {
      print('❌ [API ERROR] $e');
      rethrow;
    }
  }
}