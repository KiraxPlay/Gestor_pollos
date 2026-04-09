import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;

// Import condicional correcto: stub en móvil, real en web
import 'download_stub.dart'
    if (dart.library.html) 'download_web.dart';

class ReporteService {
  static const String _base =
      'https://backend-gestor-pollos.onrender.com/api/reportes/detalleLote';

  // ── Ponedoras ─────────────────────────────────────────────
  static Future<Map<String, dynamic>> getResumenPonedora(int loteId) async {
    final res = await http.get(Uri.parse('$_base/$loteId/resumen/'));
    if (res.statusCode == 200) {
      final lista = jsonDecode(res.body) as List;
      return lista.isNotEmpty ? lista[0] : {};
    }
    throw Exception('Error ${res.statusCode} al obtener resumen ponedora');
  }

  static Future<List<dynamic>> getMortalidad(int loteId) async {
    final res = await http.get(Uri.parse('$_base/$loteId/mortalidad/'));
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Error ${res.statusCode} al obtener mortalidad');
  }

  static Future<List<dynamic>> getHuevos(int loteId) async {
    final res = await http.get(Uri.parse('$_base/$loteId/huevos/'));
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Error ${res.statusCode} al obtener huevos');
  }

  static Future<List<dynamic>> getInsumosPonedora(int loteId) async {
    final res = await http.get(Uri.parse('$_base/$loteId/insumos/'));
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Error ${res.statusCode} al obtener insumos ponedora');
  }

  // ── Engorde ───────────────────────────────────────────────
  static Future<Map<String, dynamic>> getResumenEngorde(int loteId) async {
    final res = await http.get(Uri.parse('$_base/$loteId/resumen/'));
    if (res.statusCode == 200) {
      final lista = jsonDecode(res.body) as List;
      return lista.isNotEmpty ? lista[0] : {};
    }
    throw Exception('Error ${res.statusCode} al obtener resumen engorde');
  }

  static Future<List<dynamic>> getInsumosEngorde(int loteId) async {
    final res = await http.get(Uri.parse('$_base/$loteId/insumos/'));
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Error ${res.statusCode} al obtener insumos engorde');
  }

  // ── Exportación ───────────────────────────────────────────
  static Future<File?> descargarArchivo(int loteId, String tipo) async {
    final res = await http.get(
      Uri.parse('$_base/$loteId/exportar/$tipo/'),
    );
    if (res.statusCode != 200) {
      throw Exception('Error ${res.statusCode} al descargar $tipo');
    }

    final ext = tipo == 'pdf' ? 'pdf' : 'xlsx';
    final fileName = 'reporte_lote_$loteId.$ext';

    // En web: usar dart:html para disparar la descarga
    if (kIsWeb) {
      await downloadFileWeb(res.bodyBytes, fileName);
      print('✓ Descarga iniciada en web: $fileName');
      return null; // En web no hay File real
    }

    // En Android/iOS: guardar en el directorio de documentos
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(res.bodyBytes);
    print('✓ Archivo guardado: ${file.path}');
    return file;
  }
}
