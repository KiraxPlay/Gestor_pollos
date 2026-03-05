import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiServicePonedoras{
  //URL conectado a render
    static const String baseUrl = 'https://backend-gestor-pollos.onrender.com/api/ponedoras';
    //para pruebas en local
    //static const String baseUrl = 'http://192.168.20.45:8000/api/ponedoras';
    
    //constantes para mejor manejo de los endpoints

    // endpoint encargado de en listar los lotes de ponedoras
    static const String obtenerPonedorasEndpoint = '$baseUrl/lotesPonedoras/';

    // endpoint encargado de crear un nuevo lote de ponedoras
    static const String crearPonedoraEndpoint = '$baseUrl/crearLotePonedora/';

    static const String agregarRegistroHuevoEnpoint = '$baseUrl/registroHuevos/';
    // ==================== PONEDORAS ====================

  static Future<List<dynamic>> obtenerPonedoras() async {
    print('📤 Obteniendo ponedoras');
    final res = await http.get(
      Uri.parse(obtenerPonedorasEndpoint),
      headers: {'Content-Type': 'application/json'},
    );
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
    final res = await http.post(
      Uri.parse(crearPonedoraEndpoint),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(payload),
    );
    print('📥 Respuesta crearPonedora (${res.statusCode}): ${res.body}');
    if (res.statusCode == 200 || res.statusCode == 201)
      return json.decode(res.body);
    throw Exception('Error crearPonedora: ${res.statusCode} ${res.body}');
  }

  static Future<Map<String, dynamic>> detallePonedora(int id) async {
    print('📤 Obteniendo detalle ponedora ID: $id');
    final res = await http.get(
      Uri.parse('$baseUrl/detalleLotePonedora/$id/'),
      headers: {'Content-Type': 'application/json'},
    );
    print('📥 Respuesta detallePonedora (${res.statusCode}): ${res.body}');
    if (res.statusCode == 200)
      return Map<String, dynamic>.from(json.decode(res.body));
    throw Exception('Error detallePonedora: ${res.statusCode} ${res.body}');
  }

static Future<Map<String, dynamic>> eliminarPonedora(int id) async {
  print('📤 Eliminando ponedora ID: $id');
  
  try {
    final res = await http.delete(
      Uri.parse('$baseUrl/eliminarLotePonedora/$id/'),
      headers: {'Content-Type': 'application/json'},
    );
    
    print('📥 Respuesta eliminarPonedora (${res.statusCode}): ${res.body}');
    
    if (res.statusCode == 200) {
      // Parsear la respuesta JSON
      final responseData = json.decode(res.body);
      
      if (responseData['success'] == true) {
        print('✅ Lote eliminado correctamente');
        return {
          'success': true,
          'message': responseData['message'] ?? 'Lote eliminado correctamente',
          'lote_eliminado': responseData['lote_eliminado'] ?? id
        };
      } else {
        throw Exception(responseData['error'] ?? 'Error al eliminar lote');
      }
    } else if (res.statusCode == 404) {
      throw Exception('Lote no encontrado');
    } else {
      throw Exception('Error del servidor: ${res.statusCode}');
    }
  } catch (e) {
    print(' Error en eliminarPonedora: $e');
    rethrow;
  }
}

  static Future<dynamic> agregarRegistroHuevos(
    Map<String, dynamic> payload,
  ) async {
    print(' Agregando registro huevos: $payload');
    final res = await http.post(
      Uri.parse(agregarRegistroHuevoEnpoint),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(payload),
    );
    print(
      'Respuesta agregarRegistroHuevos (${res.statusCode}): ${res.body}',
    );
    if (res.statusCode == 200 || res.statusCode == 201)
      return json.decode(res.body);
    throw Exception(
      'Error agregarRegistroHuevos: ${res.statusCode} ${res.body}',
    );
  }

  static Future<dynamic> agregarRegistroPesoPonedora(
    Map<String, dynamic> payload,
  ) async {
    print(' Agregando registro peso ponedora: $payload');
    final res = await http.post(
      Uri.parse('$baseUrl/registroPesoPonedora/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(payload),
    );
    print('Respuesta agregarRegistroPeso (${res.statusCode}): ${res.body}');
    if (res.statusCode == 200 || res.statusCode == 201)
      return json.decode(res.body);
    throw Exception('Error agregarRegistroPeso: ${res.statusCode} ${res.body}');
  }

  static Future<Map<String, dynamic>> obtenerResumenGanancias(
    int loteId,
  ) async {
    print('Obteniendo resumen ganancias lote: $loteId');
    final res = await http.get(
      Uri.parse('$baseUrl/resumenGanancias/$loteId/'),
      headers: {'Content-Type': 'application/json'},
    );
    print('Respuesta resumenGanancias (${res.statusCode}): ${res.body}');
    if (res.statusCode == 200)
      return Map<String, dynamic>.from(json.decode(res.body));
    throw Exception('Error resumenGanancias: ${res.statusCode} ${res.body}');
  }

  
// Agregar insumo para ponedoras
  static Future<dynamic> agregarInsumoPonedora(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/agregarInsumo/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        if (result['success'] == true) {
          return result;
        } else {
          throw Exception(result['error'] ?? 'Error al agregar insumo');
        }
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      print(' Error en agregarInsumoPonedora: $e');
      rethrow;
    }
  }

static Future<dynamic> eliminarInsumoPonedora(int insumoId) async {
  try {
    final response = await http.delete(
      Uri.parse('$baseUrl/eliminarInsumoPonedora/$insumoId/'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['success'] == true) {
        return result;
      } else {
        throw Exception(result['error'] ?? 'Error al eliminar insumo');
      }
    } else {
      throw Exception('Error del servidor: ${response.statusCode}');
    }
  } catch (e) {
    print('Error en eliminarInsumoPonedora: $e');
    rethrow;
  }
}
}