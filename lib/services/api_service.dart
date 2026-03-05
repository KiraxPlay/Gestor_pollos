import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  // URL conectado a render
  static const String baseUrl = 'https://backend-gestor-pollos.onrender.com/api';
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
    
    print('Respuesta registrarPeso (${res.statusCode}): ${res.body}');
    
    if (res.statusCode == 200 || res.statusCode == 201) {
      final responseData = json.decode(res.body);
      
      //  Verificar success del backend
      if (responseData['success'] == true) {
        return responseData;
      } else {
        throw Exception(responseData['error'] ?? 'Error del servidor');
      }
    } else {
      throw Exception('Error HTTP: ${res.statusCode} ${res.body}');
    }
  } catch (e) {
    print(' Error en registrarPeso: $e');
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
}


