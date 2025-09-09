import 'package:sqflite/sqflite.dart';
import '../models/registropesos.dart';
import 'db_service.dart';

class RegistroPesoService{
  static Future<int> insertarPeso(RegistroPeso registropesos) async {
    try{
      final db = await DBService.database;
      final id = await db.insert(
        'RegistroPeso',registropesos.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      return id;

    } catch (e){
      rethrow;
    }
  }

  static Future<List<RegistroPeso>> obtenerPesos(int loteId) async {
    try {
      final db = await DBService.database;
      final List<Map<String, dynamic>> maps = await db.query('RegistroPeso');
      return List.generate(maps.length, (i) => RegistroPeso.fromMap(maps[i]));
    } catch (e) {
      return [];
    }
  }
  static Future<List<RegistroPeso>> getRegistrosByLoteId(int loteId) async {
    try {
      final db = await DBService.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'RegistroPeso',
        where: 'lotes_id = ?',
        whereArgs: [loteId],
      );
      return List.generate(maps.length, (i) => RegistroPeso.fromMap(maps[i]));
    } catch (e) {
      return [];
    }
  }

  static Future<void> eliminarPeso(int id) async {
    try {
      final db = await DBService.database;
      final result = await db.delete(
        'RegistroPeso',
        where: 'id = ?',
        whereArgs: [id],
      );
      
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> actualizarPeso(RegistroPeso registropesos) async {
    try {
      final db = await DBService.database;
      final result = await db.update(
        'RegistroPeso',
        registropesos.toMap(),
        where: 'id = ?',
        whereArgs: [registropesos.id],
      );
      print('Registro de peso actualizado. Filas afectadas: $result');
    } catch (e) {
      rethrow;
    }
  }

}