import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  //para poder probar desde el celular se pone la url de tu PC ya sea la de Ipv4 Wifi o Ipv4 Ethernet
  static const String baseUrl = 'http://192.168.x.x:8000/api';
  
  // ==================== ENGORDE ====================

  // LISTAR LOTES
  static Future<List<dynamic>> obtenerLotes() async {
    final res = await http.get(
      Uri.parse('$baseUrl/lotes/'),
      headers: {'Content-Type': 'application/json'},
    );
    if (res.statusCode == 200) return json.decode(res.body);
    throw Exception('Error obtenerLotes: ${res.statusCode} ${res.body}');
  }

  // CREAR LOTE (espera { "cantidad_pollos", "precio_unitario", "fecha_inicio" })
  static Future<dynamic> crearLote(Map<String, dynamic> payload) async {
    final res = await http.post(
      Uri.parse('$baseUrl/crearLote/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(payload),
    );
    if (res.statusCode == 200 || res.statusCode == 201)
      return json.decode(res.body);
    throw Exception('Error crearLote: ${res.statusCode} ${res.body}');
  }

  // DETALLE LOTE (devuelve { "lote": ..., "insumos": ..., "registro_peso": ... })
  static Future<Map<String, dynamic>> detalleLote(int loteId) async {
    final res = await http.get(
      Uri.parse('$baseUrl/detalleLote/$loteId/'),
      headers: {'Content-Type': 'application/json'},
    );
    if (res.statusCode == 200)
      return Map<String, dynamic>.from(json.decode(res.body));
    throw Exception('Error detalleLote: ${res.statusCode} ${res.body}');
  }

  // OBTENER EDAD (endpoint detalleLote/<id>/edad/)
  static Future<Map<String, dynamic>> obtenerEdadLote(int loteId) async {
    final res = await http.get(
      Uri.parse('$baseUrl/detalleLote/$loteId/edad/'),
      headers: {'Content-Type': 'application/json'},
    );
    if (res.statusCode == 200)
      return Map<String, dynamic>.from(json.decode(res.body));
    throw Exception('Error obtenerEdadLote: ${res.statusCode} ${res.body}');
  }

  // AGREGAR INSUMO (POST a /agregarInsumo/)
  static Future<dynamic> crearInsumo(Map<String, dynamic> payload) async {
    final res = await http.post(
      Uri.parse('$baseUrl/agregarInsumo/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(payload),
    );
    if (res.statusCode == 200 || res.statusCode == 201)
      return json.decode(res.body);
    throw Exception('Error crearInsumo: ${res.statusCode} ${res.body}');
  }

  // ELIMINAR INSUMO (DELETE a /eliminarInsumo/<insumo_id>/ con body { "lote_id": ... })
  static Future<void> eliminarInsumo(int insumoId, int loteId) async {
    final res = await http.delete(
      Uri.parse('$baseUrl/eliminarInsumo/$insumoId/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'lote_id': loteId}),
    );
    if (res.statusCode == 200 || res.statusCode == 204) return;
    throw Exception('Error eliminarInsumo: ${res.statusCode} ${res.body}');
  }

// En ApiService - para ENGORDE
static Future<dynamic> registrarPeso(Map<String, dynamic> data) async {
  print('📤 Registrando peso ENGORDE: $data');
  
  try {
    final res = await http.post(
      Uri.parse('$baseUrl/registrarPeso/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
    
    print('📥 Respuesta registrarPeso (${res.statusCode}): ${res.body}');
    
    if (res.statusCode == 200 || res.statusCode == 201) {
      final responseData = json.decode(res.body);
      
      // ✅ Verificar success del backend
      if (responseData['success'] == true) {
        return responseData;
      } else {
        throw Exception(responseData['error'] ?? 'Error del servidor');
      }
    } else {
      throw Exception('Error HTTP: ${res.statusCode} ${res.body}');
    }
  } catch (e) {
    print('❌ Error en registrarPeso: $e');
    rethrow;
  }
}

  // HISTORIAL MORTALIDAD (GET /historialMortalidad/<lote_id>/)
  static Future<Map<String, dynamic>> historialMortalidad(int loteId) async {
    final res = await http.get(
      Uri.parse('$baseUrl/historialMortalidad/$loteId/'),
      headers: {'Content-Type': 'application/json'},
    );
    if (res.statusCode == 200)
      return Map<String, dynamic>.from(json.decode(res.body));
    throw Exception('Error historialMortalidad: ${res.statusCode} ${res.body}');
  }

  // REGISTRAR MORTALIDAD (PUT a /registrarMortalidad/ con { "lote_id", "cantidad_muerta" })
  static Future<dynamic> registrarMortalidad(
    Map<String, dynamic> payload,
  ) async {
    final res = await http.put(
      Uri.parse('$baseUrl/registrarMortalidad/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(payload),
    );
    if (res.statusCode == 200 || res.statusCode == 201)
      return json.decode(res.body);
    throw Exception('Error registrarMortalidad: ${res.statusCode} ${res.body}');
  }

  // ELIMINAR LOTE (DELETE a /eliminarLote/<lote_id>/)
  static Future<void> eliminarLote(int loteId) async {
    final url = Uri.parse('$baseUrl/eliminarLote/$loteId/');

    final res = await http.delete(
      url,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    );

    if (res.statusCode == 200 || res.statusCode == 204) {
      return;
    } else {
      throw Exception('Error eliminarLote: ${res.statusCode} - ${res.body}');
    }
  }

  // ==================== PONEDORAS ====================

  static Future<List<dynamic>> obtenerPonedoras() async {
    print('📤 Obteniendo ponedoras');
    final res = await http.get(
      Uri.parse('$baseUrl/ponedoras/lotesPonedoras/'),
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
      Uri.parse('$baseUrl/ponedoras/crearLotePonedora/'),
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
      Uri.parse('$baseUrl/ponedoras/detalleLotePonedora/$id/'),
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
      Uri.parse('$baseUrl/ponedoras/eliminarLotePonedora/$id/'),
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
    print('❌ Error en eliminarPonedora: $e');
    rethrow;
  }
}

  static Future<dynamic> agregarRegistroHuevos(
    Map<String, dynamic> payload,
  ) async {
    print('📤 Agregando registro huevos: $payload');
    final res = await http.post(
      Uri.parse('$baseUrl/ponedoras/registroHuevos/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(payload),
    );
    print(
      '📥 Respuesta agregarRegistroHuevos (${res.statusCode}): ${res.body}',
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
    print('📤 Agregando registro peso ponedora: $payload');
    final res = await http.post(
      Uri.parse('$baseUrl/ponedoras/registroPesoPonedora/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(payload),
    );
    print('📥 Respuesta agregarRegistroPeso (${res.statusCode}): ${res.body}');
    if (res.statusCode == 200 || res.statusCode == 201)
      return json.decode(res.body);
    throw Exception('Error agregarRegistroPeso: ${res.statusCode} ${res.body}');
  }

  static Future<Map<String, dynamic>> obtenerResumenGanancias(
    int loteId,
  ) async {
    print('📤 Obteniendo resumen ganancias lote: $loteId');
    final res = await http.get(
      Uri.parse('$baseUrl/ponedoras/resumenGanancias/$loteId/'),
      headers: {'Content-Type': 'application/json'},
    );
    print('📥 Respuesta resumenGanancias (${res.statusCode}): ${res.body}');
    if (res.statusCode == 200)
      return Map<String, dynamic>.from(json.decode(res.body));
    throw Exception('Error resumenGanancias: ${res.statusCode} ${res.body}');
  }

  
/// 🧪 Agregar insumo para ponedoras
  static Future<dynamic> agregarInsumoPonedora(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/ponedoras/agregarInsumo/'),
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
      print('❌ Error en agregarInsumoPonedora: $e');
      rethrow;
    }
  }

  // En services/api_service.dart, agrega:
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
    print('❌ Error en eliminarInsumoPonedora: $e');
    rethrow;
  }
}

}


