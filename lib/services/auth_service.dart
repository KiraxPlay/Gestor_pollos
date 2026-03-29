import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AuthService {
  static const String baseUrl = 'https://backend-gestor-pollos.onrender.com/api/auth';

  static const String _tokenKey = 'access_token';
  static const String _refreshKey = 'refresh_token';

  // ──────────────────────────────────────────────
  //  REGISTRO
  // ──────────────────────────────────────────────
  static Future<Map<String, dynamic>> register({
    required String username,
    required String password,
    required String email,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/register/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': username,
        'password': password,
        'email': email,
      }),
    );

    final data = json.decode(res.body);

    if (res.statusCode == 201) {
      return {'success': true, ...data};
    }

    // Django devuelve errores como { "username": ["..."], "email": ["..."] }
    final errorMsg = _parseErrors(data);
    throw Exception(errorMsg);
  }

  // ──────────────────────────────────────────────
  //  LOGIN  →  guarda los tokens automáticamente
  // ──────────────────────────────────────────────
  static Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/login/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'username': username, 'password': password}),
    );

    final data = json.decode(res.body);

    if (res.statusCode == 200) {
      // SimpleJWT devuelve { "access": "...", "refresh": "..." }
      await _saveTokens(
        accessToken: data['access'],
        refreshToken: data['refresh'],
      );
      return {'success': true, ...data};
    }

    throw Exception(data['detail'] ?? 'Credenciales incorrectas');
  }

  // ──────────────────────────────────────────────
  //  REFRESH del access token
  // ──────────────────────────────────────────────
  static Future<String?> refreshAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    final refresh = prefs.getString(_refreshKey);

    if (refresh == null) return null;

    final res = await http.post(
      Uri.parse('$baseUrl/refresh/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'refresh': refresh}),
    );

    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      final newAccess = data['access'] as String;
      await prefs.setString(_tokenKey, newAccess);
      return newAccess;
    }

    // Refresh expirado → cerrar sesión
    await logout();
    return null;
  }

  // ──────────────────────────────────────────────
  //  LOGOUT
  // ──────────────────────────────────────────────
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_refreshKey);
  }

  // ──────────────────────────────────────────────
  //  HELPERS
  // ──────────────────────────────────────────────

  /// Devuelve el access token guardado (o null si no hay sesión)
  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  /// True si hay un token guardado (sesión activa)
  static Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null;
  }

  /// Headers listos para usar en cualquier petición autenticada.
  /// Refresca automáticamente si el token expiró.
  static Future<Map<String, String>> authHeaders() async {
    String? token = await getAccessToken();
    if (token == null) throw Exception('No hay sesión activa');

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  /// Guarda access y refresh en SharedPreferences
  static Future<void> _saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, accessToken);
    await prefs.setString(_refreshKey, refreshToken);
  }

  /// Convierte errores de Django REST en un String legible
  static String _parseErrors(Map<String, dynamic> data) {
    final buffer = StringBuffer();
    data.forEach((key, value) {
      if (value is List) {
        buffer.writeln('$key: ${value.join(', ')}');
      } else {
        buffer.writeln('$key: $value');
      }
    });
    return buffer.toString().trim();
  }
}