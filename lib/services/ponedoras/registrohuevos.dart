import 'package:sqflite/sqflite.dart';
import '../../models/ponedoras/registrohuevos.dart';
import '../db_service.dart';
import '../connectivity_service.dart';
import '../sync_service.dart';
import '../api_service.dart';

class RegistroHuevosService {
  static const String _tableName = 'RegistroHuevos';

  static Future<List<RegistroHuevos>> obtenerRegistrosPorLote(int loteId) async {
    final db = await DBService.database;
    final connectivity = ConnectivityService();

    print('🔍 Obteniendo registros huevos para lote $loteId - Conectado: ${connectivity.isConnected}');

    try {
      if (connectivity.isConnected) {
        print('📡 Obteniendo del backend...');
        // Nota: Este endpoint deberías agregarlo en Django si no existe
        // Por ahora usamos el dato local
      }

      final data = await db.query(
        _tableName,
        where: 'lote_id = ?',
        whereArgs: [loteId],
        orderBy: 'fecha DESC',
      );

      final registros = List<RegistroHuevos>.from(
        data.map((item) => RegistroHuevos.fromJson(item)),
      );

      print('✅ Obtenidos ${registros.length} registros del local');
      return registros;
    } catch (e) {
      print('❌ Error: $e');
      final data = await db.query(
        _tableName,
        where: 'lote_id = ?',
        whereArgs: [loteId],
        orderBy: 'fecha DESC',
      );
      return List<RegistroHuevos>.from(
        data.map((item) => RegistroHuevos.fromJson(item)),
      );
    }
  }

  static Future<int> agregarRegistro(RegistroHuevos registro) async {
    final db = await DBService.database;
    final connectivity = ConnectivityService();

    print('🔍 Agregando registro huevos para lote: ${registro.loteId}');
    print('🔌 ¿Conectado? ${connectivity.isConnected}');

    try {
      if (connectivity.isConnected) {
        print('📡 Enviando al backend...');
        final response = await ApiService.agregarRegistroHuevos({
          'lote_id': registro.loteId,
          'fecha': registro.fecha,
          'cantidad_huevos': registro.cantidadHuevos,
        });
        print('✅ Respuesta backend: $response');
      } else {
        print('📴 Sin conexión, encolando...');
        await SyncService.queueOperation(
          operation: 'INSERT',
          tableName: 'registro_huevos',
          data: registro.toJson(),
        );
      }

      final id = await db.insert(
        _tableName,
        registro.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      print('✅ Registrado localmente con ID: $id');
      return id;
    } catch (e) {
      print('❌ Error: $e');
      final id = await db.insert(_tableName, registro.toJson());
      await SyncService.queueOperation(
        operation: 'INSERT',
        tableName: 'registro_huevos',
        data: registro.toJson(),
      );
      return id;
    }
  }

  static Future<void> eliminarRegistro(int id) async {
    final db = await DBService.database;
    final connectivity = ConnectivityService();

    print('🔍 Eliminando registro ID: $id');

    try {
      if (connectivity.isConnected) {
        print('📡 Intentando eliminar del backend...');
        // Agregar endpoint en Django si es necesario
      }

      await db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
      print('✅ Eliminado del local');
    } catch (e) {
      print('❌ Error: $e');
      rethrow;
    }
  }
}