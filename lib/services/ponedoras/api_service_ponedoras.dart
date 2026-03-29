import 'dart:convert';
import '../api_client.dart'; // para el api_client para manejar el token automaticamente

class ApiServicePonedoras {
  static const String baseUrl =
      'https://backend-gestor-pollos.onrender.com/api/ponedoras';

  static const String obtenerPonedorasEndpoint = '$baseUrl/lotesPonedoras/';
  static const String crearPonedoraEndpoint = '$baseUrl/crearLotePonedora/';
  static const String agregarRegistroHuevoEndpoint = '$baseUrl/registroHuevos/';

  // ──────────────────────────────────────────────
  //  LOTES PONEDORAS
  // ──────────────────────────────────────────────

  static Future<List<dynamic>> obtenerPonedoras() async {
    print('📤 Obteniendo ponedoras');
    final res = await ApiClient.get(obtenerPonedorasEndpoint);
    print('📥 Respuesta obtenerPonedoras (${res.statusCode}): ${res.body}');

    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      if (data is Map<String, dynamic> && data['lotes'] != null) {
        return data['lotes'];
      }
      return data;
    }
    throw Exception('Error obtenerPonedoras: ${res.statusCode} ${res.body}');
  }

  static Future<dynamic> crearPonedora(Map<String, dynamic> payload) async {
    print('📤 Creando ponedora: $payload');
    final res = await ApiClient.post(crearPonedoraEndpoint, payload);
    print('📥 Respuesta crearPonedora (${res.statusCode}): ${res.body}');

    if (res.statusCode == 200 || res.statusCode == 201)
      return json.decode(res.body);
    throw Exception('Error crearPonedora: ${res.statusCode} ${res.body}');
  }

  static Future<Map<String, dynamic>> detallePonedora(int id) async {
    print('📤 Obteniendo detalle ponedora ID: $id');
    final res =
        await ApiClient.get('$baseUrl/detalleLotePonedora/$id/');
    print('📥 Respuesta detallePonedora (${res.statusCode}): ${res.body}');

    if (res.statusCode == 200)
      return Map<String, dynamic>.from(json.decode(res.body));
    throw Exception('Error detallePonedora: ${res.statusCode} ${res.body}');
  }

  static Future<Map<String, dynamic>> eliminarPonedora(int id) async {
    print('📤 Eliminando ponedora ID: $id');
    final res =
        await ApiClient.delete('$baseUrl/eliminarLotePonedora/$id/');
    print('📥 Respuesta eliminarPonedora (${res.statusCode}): ${res.body}');

    if (res.statusCode == 200) {
      final responseData = json.decode(res.body);
      if (responseData['success'] == true) {
        print('✅ Lote eliminado correctamente');
        return {
          'success': true,
          'message':
              responseData['message'] ?? 'Lote eliminado correctamente',
          'lote_eliminado': responseData['lote_eliminado'] ?? id,
        };
      }
      throw Exception(responseData['error'] ?? 'Error al eliminar lote');
    } else if (res.statusCode == 404) {
      throw Exception('Lote no encontrado');
    }
    throw Exception('Error del servidor: ${res.statusCode}');
  }

  // ──────────────────────────────────────────────
  //  REGISTRO HUEVOS
  // ──────────────────────────────────────────────

  static Future<dynamic> agregarRegistroHuevos(
      Map<String, dynamic> payload) async {
    print('📤 Agregando registro huevos: $payload');
    final res =
        await ApiClient.post(agregarRegistroHuevoEndpoint, payload);
    print(
        '📥 Respuesta agregarRegistroHuevos (${res.statusCode}): ${res.body}');

    if (res.statusCode == 200 || res.statusCode == 201)
      return json.decode(res.body);
    throw Exception(
        'Error agregarRegistroHuevos: ${res.statusCode} ${res.body}');
  }

  // ──────────────────────────────────────────────
  //  REGISTRO PESO PONEDORA
  // ──────────────────────────────────────────────

  static Future<dynamic> agregarRegistroPesoPonedora(
      Map<String, dynamic> payload) async {
    print('📤 Agregando registro peso ponedora: $payload');
    final res =
        await ApiClient.post('$baseUrl/registroPesoPonedora/', payload);
    print(
        '📥 Respuesta agregarRegistroPeso (${res.statusCode}): ${res.body}');

    if (res.statusCode == 200 || res.statusCode == 201)
      return json.decode(res.body);
    throw Exception(
        'Error agregarRegistroPeso: ${res.statusCode} ${res.body}');
  }

  // ──────────────────────────────────────────────
  //  GANANCIAS
  // ──────────────────────────────────────────────

  static Future<Map<String, dynamic>> obtenerResumenGanancias(
      int loteId) async {
    print('📤 Obteniendo resumen ganancias lote: $loteId');
    final res =
        await ApiClient.get('$baseUrl/resumenGanancias/$loteId/');
    print(
        '📥 Respuesta resumenGanancias (${res.statusCode}): ${res.body}');

    if (res.statusCode == 200)
      return Map<String, dynamic>.from(json.decode(res.body));
    throw Exception(
        'Error resumenGanancias: ${res.statusCode} ${res.body}');
  }

  // ──────────────────────────────────────────────
  //  INSUMOS PONEDORAS
  // ──────────────────────────────────────────────

  static Future<dynamic> agregarInsumoPonedora(
      Map<String, dynamic> data) async {
    print('📤 Agregando insumo ponedora: $data');
    final res = await ApiClient.post('$baseUrl/agregarInsumo/', data);
    print('📥 Respuesta agregarInsumo (${res.statusCode}): ${res.body}');

    if (res.statusCode == 200) {
      final result = json.decode(res.body);
      if (result['success'] == true) return result;
      throw Exception(result['error'] ?? 'Error al agregar insumo');
    }
    throw Exception('Error del servidor: ${res.statusCode}');
  }

  static Future<dynamic> eliminarInsumoPonedora(int insumoId) async {
    print('📤 Eliminando insumo ponedora ID: $insumoId');
    final res = await ApiClient.delete(
        '$baseUrl/eliminarInsumoPonedora/$insumoId/');
    print(
        '📥 Respuesta eliminarInsumo (${res.statusCode}): ${res.body}');

    if (res.statusCode == 200) {
      final result = json.decode(res.body);
      if (result['success'] == true) return result;
      throw Exception(result['error'] ?? 'Error al eliminar insumo');
    }
    throw Exception('Error del servidor: ${res.statusCode}');
  }
}