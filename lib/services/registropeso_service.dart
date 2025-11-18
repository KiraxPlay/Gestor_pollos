import 'package:sqflite/sqflite.dart';
import '../models/registropesos.dart';
import 'db_service.dart';
import 'connectivity_service.dart';
import 'sync_service.dart';
import 'api_service.dart';

class RegistroPesoService {
  static const String _tableName = 'RegistroPeso';

  static Future<int> insertarPeso(RegistroPeso registroPeso) async {
    final db = await DBService.database;
    final connectivity = ConnectivityService();

    try {
      if (await connectivity.isConnected) {
        // ✅ ONLINE: Enviar al servidor - usar toJson() para API
        try {
          await ApiService.registrarPeso(
            registroPeso.toJson(),
          ); // ← toJson() para API
          print('✅ Peso de engorde enviado al servidor');
        } catch (e) {
          print('⚠️ Falló envío al servidor, guardando local: $e');
        }
      }

      // 📱 Guardar localmente - usar toMap() para BD local
      final id = await db.insert(
        _tableName,
        registroPeso.toMap(), // ← toMap() para BD local
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // 🔄 Encolar para sincronización si está offline
      if (!(await connectivity.isConnected)) {
        await SyncService.queueOperation(
          operation: 'INSERT',
          tableName: 'registro_peso',
          data: registroPeso.toJson(), // ← toJson() para sync
        );
      }

      return id;
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<RegistroPeso>> obtenerPesos(int loteId) async {
    try {
      final db = await DBService.database;
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: 'lote_id = ?', // ← lote_id (sin 's') para BD local
        whereArgs: [loteId],
        orderBy: 'fecha DESC',
      );
      return List.generate(maps.length, (i) => RegistroPeso.fromMap(maps[i]));
    } catch (e) {
      print('❌ Error obteniendo pesos: $e');
      return [];
    }
  }

  static Future<List<RegistroPeso>> getRegistrosByLoteId(int loteId) async {
    return await obtenerPesos(loteId);
  }

  static Future<List<RegistroPeso>> obtenerTodosLosPesos() async {
    try {
      final db = await DBService.database;
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        orderBy: 'fecha DESC',
      );
      return List.generate(maps.length, (i) => RegistroPeso.fromMap(maps[i]));
    } catch (e) {
      print('❌ Error obteniendo todos los pesos: $e');
      return [];
    }
  }

  static Future<void> eliminarPeso(int id) async {
    try {
      final db = await DBService.database;
      final connectivity = ConnectivityService();

      // Eliminar localmente
      await db.delete(_tableName, where: 'id = ?', whereArgs: [id]);

      // Encolar eliminación si está offline
      if (!(await connectivity.isConnected)) {
        await SyncService.queueOperation(
          operation: 'DELETE',
          tableName: 'registro_peso',
          data: {'id': id},
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> actualizarPeso(RegistroPeso registroPeso) async {
    try {
      final db = await DBService.database;
      final connectivity = ConnectivityService();

      // Actualizar localmente
      await db.update(
        _tableName,
        registroPeso.toMap(),
        where: 'id = ?',
        whereArgs: [registroPeso.id],
      );

      // Encolar actualización si está offline
      if (!(await connectivity.isConnected)) {
        await SyncService.queueOperation(
          operation: 'UPDATE',
          tableName: 'registro_peso',
          data: registroPeso.toMap(),
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  // Método para sincronizar pendientes
  static Future<void> sincronizarPesosPendientes() async {
    final connectivity = ConnectivityService();
    if (await connectivity.isConnected) {
      await SyncService.syncAllPendingOperations();
    }
  }
}
