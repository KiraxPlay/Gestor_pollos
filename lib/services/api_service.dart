import 'dart:convert';
import 'api_client.dart';

class ApiService {
  static const String baseUrl = 'https://backend-gestor-pollos.onrender.com/api';

  // 🔹 LISTAR LOTES
  static Future<List<Map<String, dynamic>>> obtenerLotes() async {
    final res = await ApiClient.get('$baseUrl/lotes/');
    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      return List<Map<String, dynamic>>.from(data);
    }
    throw Exception('Error obtenerLotes: ${res.statusCode} ${res.body}');
  }

  // 🔹 CREAR LOTE
  static Future<Map<String, dynamic>> crearLote(
      Map<String, dynamic> payload) async {
    final res = await ApiClient.post('$baseUrl/crearLote/', payload);
    if (res.statusCode == 200 || res.statusCode == 201) {
      return Map<String, dynamic>.from(json.decode(res.body));
    }
    throw Exception('Error crearLote: ${res.statusCode} ${res.body}');
  }

  // 🔹 DETALLE LOTE (NO SE TOCA)
  static Future<Map<String, dynamic>> detalleLote(int loteId) async {
    final res = await ApiClient.get('$baseUrl/detalleLote/$loteId/');
    if (res.statusCode == 200) {
      return Map<String, dynamic>.from(json.decode(res.body));
    }
    throw Exception('Error detalleLote: ${res.statusCode} ${res.body}');
  }

  // 🔹 ACTUALIZAR LOTE (AGREGADO, NO ROMPE NADA)
  static Future<Map<String, dynamic>> actualizarLote(
      Map<String, dynamic> payload) async {
    final res = await ApiClient.put('$baseUrl/actualizarLote/', payload);
    if (res.statusCode == 200 || res.statusCode == 201) {
      return Map<String, dynamic>.from(json.decode(res.body));
    }
    throw Exception('Error actualizarLote: ${res.statusCode} ${res.body}');
  }

  // 🔹 REGISTRAR PESO (SE MANTIENE)
  static Future<Map<String, dynamic>> registrarPeso(
      Map<String, dynamic> data) async {
    final res = await ApiClient.post('$baseUrl/registrarPeso/', data);
    if (res.statusCode == 200 || res.statusCode == 201) {
      final responseData = json.decode(res.body);
      if (responseData['success'] == true) return responseData;
      throw Exception(responseData['error'] ?? 'Error del servidor');
    }
    throw Exception('Error HTTP: ${res.statusCode} ${res.body}');
  }

  // 🔹 REGISTRAR MORTALIDAD
  static Future<void> registrarMortalidad(
      Map<String, dynamic> payload) async {
    final res =
        await ApiClient.put('$baseUrl/registrarMortalidad/', payload);
    if (res.statusCode == 200 || res.statusCode == 201) return;
    throw Exception(
        'Error registrarMortalidad: ${res.statusCode} ${res.body}');
  }

  // 🔹 ELIMINAR LOTE
  static Future<void> eliminarLote(int loteId) async {
    final res = await ApiClient.delete('$baseUrl/eliminarLote/$loteId/');
    if (res.statusCode == 200 || res.statusCode == 204) return;
    throw Exception('Error eliminarLote: ${res.statusCode} ${res.body}');
  }

  // 🔹 INSUMOS
  static Future<Map<String, dynamic>> crearInsumo(
      Map<String, dynamic> payload) async {
    final res = await ApiClient.post('$baseUrl/agregarInsumo/', payload);
    if (res.statusCode == 200 || res.statusCode == 201) {
      return Map<String, dynamic>.from(json.decode(res.body));
    }
    throw Exception('Error crearInsumo: ${res.statusCode} ${res.body}');
  }

  static Future<void> eliminarInsumo(int insumoId, int loteId) async {
    final res = await ApiClient.delete(
      '$baseUrl/eliminarInsumo/$insumoId/',
      body: {'lote_id': loteId},
    );
    if (res.statusCode == 200 || res.statusCode == 204) return;
    throw Exception(
        'Error eliminarInsumo: ${res.statusCode} ${res.body}');
  }

  // 🔹 HISTORIAL MORTALIDAD
  static Future<Map<String, dynamic>> historialMortalidad(
      int loteId) async {
    final res =
        await ApiClient.get('$baseUrl/historialMortalidad/$loteId/');
    if (res.statusCode == 200) {
      return Map<String, dynamic>.from(json.decode(res.body));
    }
    throw Exception(
        'Error historialMortalidad: ${res.statusCode} ${res.body}');
  }
}