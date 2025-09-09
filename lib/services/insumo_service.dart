import 'package:sqflite/sqflite.dart';
import '../models/insumos.dart';
import 'db_service.dart';

class InsumosService {
  static Future<int> insertarInsumo(Insumos insumo) async {
    try {
      final db = await DBService.database;
      final id = await db.insert(
        'Insumos',
        insumo.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return id;
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<Insumos>> obtenerInsumos() async {
    try {
      final db = await DBService.database;
      final List<Map<String, dynamic>> maps = await db.query('Insumos');
      return List.generate(maps.length, (i) => Insumos.fromMap(maps[i]));
    } catch (e) {
      return [];
    }
  }

  static Future<List<Insumos>> obtenerInsumosPorLote(int loteId) async {
    try {
      final db = await DBService.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'Insumos',
        where: 'lotes_id = ?',
        whereArgs: [loteId],
      );
      return List.generate(maps.length, (i) => Insumos.fromMap(maps[i]));
    } catch (e) {
      return [];
    }
  }

  static Future<void> eliminarInsumo(int id) async {
    try {
      final db = await DBService.database;
      final result = await db.delete(
        'Insumos',
        where: 'id = ?',
        whereArgs: [id],
      );
      print('Insumo eliminado. Filas afectadas: $result');
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> actualizarInsumo(Insumos insumo) async {
    try {
      final db = await DBService.database;
      final result = await db.update(
        'Insumos',
        insumo.toMap(),
        where: 'id = ?',
        whereArgs: [insumo.id],
      );
      print('Insumo actualizado. Filas afectadas: $result');
    } catch (e) {
      rethrow;
    }
  }
}