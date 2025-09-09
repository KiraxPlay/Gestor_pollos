import 'package:sqflite/sqflite.dart';
import '../models/lotes.dart';
import 'db_service.dart';

class LoteService {
  static Future<int> insertarLote(Lotes lote) async {
    try {
      final db = await DBService.database;      
      final id = await db.insert(
        'Lotes', 
        lote.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      
      return id;
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<Lotes>> obtenerLotes() async {
    try {
      final db = await DBService.database;
      final List<Map<String, dynamic>> maps = await db.query('Lotes');
      return List.generate(maps.length, (i) => Lotes.fromMap(maps[i]));
    } catch (e) {
      return [];
    }
  }

static Future<Lotes> obtenerLotePorId(int id) async {
  final db = await DBService.database;
  final List<Map<String, dynamic>> maps = await db.query(
    'Lotes',
    where: 'id = ?',
    whereArgs: [id],
  );
  
  if (maps.isEmpty) {
    throw Exception('Lote no encontrado');
  }
  
  return Lotes.fromMap(maps.first);
}

  static Future<void> eliminarLote(int id) async {
  try {
    final db = await DBService.database;

    final lote = await obtenerLotePorId(id);

    if(lote.estado == 1) {
      throw Exception('No se puede eliminar un lote con insumos activos');
    }
    
    await db.transaction((txn) async {
      // Primero eliminamos los registros relacionados debido a la clave foránea
      await txn.delete('Insumos', where: 'lotes_id = ?', whereArgs: [id]);
      await txn.delete('RegistroPeso', where: 'lotes_id = ?', whereArgs: [id]);
      
      
      // Finalmente eliminamos el lote
      final result = await txn.delete(
        'Lotes',
        where: 'id = ?',
        whereArgs: [id],
      );
      
      print('Lote eliminado. Filas afectadas: $result');
    });
  } catch (e) {
    rethrow;
  }
}

  static Future<void> actualizarLote(Lotes lote) async {
    try {
      final db = await DBService.database;
      await db.update(
        'Lotes',
        lote.toMap(),
        where: 'id = ?',
        whereArgs: [lote.id],
      );
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> actualizarEstadoLote(int id, String estado) async {
    try {
      final db = await DBService.database;
      await db.update(
        'Lotes',
        {'estado': estado},
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> actualizarCantidadMuertos(int id, int cantidadMuertos) async {
    try {
      final db = await DBService.database;
      await db.update(
        'Lotes',
        {'cantidad_muertos': cantidadMuertos},
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      rethrow;
    }
  }


}