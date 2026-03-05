// services/sync_service.dart
import 'package:gestorgalpon_app/services/ponedoras/api_service_ponedoras.dart';
import 'package:sqflite/sqflite.dart';
import '../models/lotes.dart';
import 'api_service.dart';
import 'db_service.dart';
import 'connectivity_service.dart';
import 'dart:convert';

class SyncService {
  static const String _syncTableName = 'sync_queue';

  static Future<void> initializeSyncTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $_syncTableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        operation TEXT NOT NULL,
        table_name TEXT NOT NULL,
        data TEXT NOT NULL,
        created_at TEXT NOT NULL,
        synced INTEGER DEFAULT 0
      )
    ''');
  }

  /// Guarda una operación para sincronizar después - CON CONTROL DE CONCURRENCIA
  static Future<void> queueOperation({
    required String operation,
    required String tableName,
    required Map<String, dynamic> data,
  }) async {
    try {
      final db = await DBService.database;

      await db.insert(_syncTableName, {
        'operation': operation,
        'table_name': tableName,
        'data': jsonEncode(data),
        'created_at': DateTime.now().toIso8601String(),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'synced': 0,
      });

      print('✅ Operación encolada: $operation en $tableName');
    } catch (e) {
      print('❌ Error encolando operación: $e');

      // FALLBACK: Intentar sin created_at si falla
      try {
        final db = await DBService.database;
        await db.insert(_syncTableName, {
          'operation': operation,
          'table_name': tableName,
          'data': jsonEncode(data),
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          'synced': 0,
        });
        print('✅ Operación encolada (fallback)');
      } catch (e2) {
        print('❌ Error crítico encolando operación: $e2');
        rethrow;
      }
    }
  }

  /// Obtiene operaciones pendientes de sincronizar - CON CONTROL DE CONCURRENCIA
  static Future<List<Map<String, dynamic>>> getPendingOperations() async {
    try {
      final db = await DBService.database; // Esto ya usa el lock
      return await db.query(
        _syncTableName,
        where: 'synced = ?',
        whereArgs: [0],
        orderBy: 'id ASC',
      );
    } catch (e) {
      print(' Error obteniendo operaciones pendientes: $e');
      return [];
    }
  }

  /// Marca una operación como sincronizada - CON CONTROL DE CONCURRENCIA
  static Future<void> markAsSynced(int id) async {
    try {
      final db = await DBService.database; // Esto ya usa el lock
      await db.update(
        _syncTableName,
        {'synced': 1},
        where: 'id = ?',
        whereArgs: [id],
      );
      print(' Operación marcada como sincronizada: $id');
    } catch (e) {
      print(' Error marcando operación como sincronizada: $e');
      rethrow;
    }
  }

  /// Sincroniza todas las operaciones pendientes - MEJORADO Y ORGANIZADO
  static Future<void> syncAllPendingOperations() async {
    try {
      final connectivity = ConnectivityService();

      if (!connectivity.isConnected) {
        print(' No hay conexión. Sincronización pospuesta.');
        return;
      }

      print(' Iniciando sincronización de operaciones pendientes');
      final pendingOps = await getPendingOperations();

      if (pendingOps.isEmpty) {
        print(' No hay operaciones pendientes de sincronizar');
        return;
      }

      print(' Operaciones pendientes: ${pendingOps.length}');

      for (var op in pendingOps) {
        try {
          final operation = op['operation'];
          final tableName = op['table_name'];
          final data = jsonDecode(op['data']);
          final opId = op['id'];

          print(' Sincronizando: $operation en $tableName');

          bool success = await _procesarOperacion(operation, tableName, data);

          if (success) {
            await markAsSynced(opId);
            print('Operación sincronizada: $operation en $tableName');
          } else {
            print(' Operación no procesada: $operation en $tableName');
          }
        } catch (e) {
          print(' Error sincronizando operación $op: $e');
          // NO marcar como sincronizada para reintentar después
        }
      }

      print(' Sincronización completada');
    } catch (e) {
      print(' Error general en syncAllPendingOperations: $e');
    }
  }

  /// Procesa una operación específica según la tabla
  static Future<bool> _procesarOperacion(
    String operation,
    String tableName,
    Map<String, dynamic> data,
  ) async {
    try {
      //  SISTEMA DE ENGORDE
      if (tableName == 'lotes') {
        return await _procesarEngorde(operation, data);
      }
      //  REGISTROS DE PESO
      else if (tableName == 'registro_peso') {
        return await _procesarRegistroPeso(operation, data);
      }
      //  SISTEMA DE PONEDORAS
      else if (tableName == 'Ponedoras') {
        return await _procesarPonedoras(operation, data);
      }
      //  REGISTROS DE HUEVOS
      else if (tableName == 'RegistroHuevos') {
        return await _procesarRegistroHuevos(operation, data);
      }
      //  INSUMOS DE PONEDORAS
      else if (tableName == 'Insumos') {
        return await _procesarInsumosPonedoras(operation, data);
      }

      print(' Tabla no reconocida: $tableName');
      return false;
    } catch (e) {
      print(' Error procesando operación: $e');
      return false;
    }
  }

  /// 🐓 Procesa operaciones del sistema de engorde
  static Future<bool> _procesarEngorde(
    String operation,
    Map<String, dynamic> data,
  ) async {
    try {
      if (operation == 'INSERT') {
        await ApiService.crearLote(data);
        return true;
      } else if (operation == 'DELETE') {
        if (data['id'] != null) {
          await ApiService.eliminarLote(data['id']);
          return true;
        }
      } else if (operation == 'UPDATE_MORTALIDAD') {
        //  Manejar actualización de mortalidad
        await ApiService.registrarMortalidad({
          'lote_id': data['id'],
          'cantidad_muerta': data['cantidad_muerta_agregada'],
        });
        return true;
      }

      return false;
    } catch (e) {
      print(' Error en procesarEngorde: $e');
      return false;
    }
  }

  /// ⚖️ Procesa operaciones de registros de peso
  static Future<bool> _procesarRegistroPeso(
    String operation,
    Map<String, dynamic> data,
  ) async {
    try {
      if (operation == 'INSERT') {
        // Asegurar que los nombres de campo coincidan con tu API Django
        final datosCorregidos = {
          'lotes_id': data['lotes_id'] ?? data['lotesId'],
          'fecha': data['fecha'],
          'peso_promedio': data['peso_promedio'] ?? data['pesoPromedio'],
        };
        await ApiService.registrarPeso(datosCorregidos);
        return true;
      } else if (operation == 'UPDATE') {
        // Manejar actualización de registros de peso
        final datosCorregidos = {
          'id': data['id'],
          'lotes_id': data['lotes_id'] ?? data['lotesId'],
          'fecha': data['fecha'],
          'peso_promedio': data['peso_promedio'] ?? data['pesoPromedio'],
        };
        await ApiService.registrarPeso(datosCorregidos);
        return true;
      } else if (operation == 'DELETE') {
        // Manejar eliminación de registros de peso
        if (data['id'] != null) {
          // Si tu API no tiene endpoint para eliminar pesos,
          // descomentar la siguiente línea:
          // await ApiService.eliminarRegistroPeso(data['id']);
          print('⚠️ Eliminación de registro de peso: ${data['id']}');
          return true;
        }
      }
      return false;
    } catch (e) {
      print('❌ Error en procesarRegistroPeso: $e');
      return false;
    }
  }

  ///  Procesa operaciones del sistema de ponedoras
  static Future<bool> _procesarPonedoras(
    String operation,
    Map<String, dynamic> data,
  ) async {
    try {
      if (operation == 'INSERT') {
        await ApiServicePonedoras.crearPonedora(data);
        return true;
      } else if (operation == 'DELETE') {
        if (data['id'] != null) {
          await ApiServicePonedoras.eliminarPonedora(data['id']);
          return true;
        }
      }
      return false;
    } catch (e) {
      print('❌ Error en procesarPonedoras: $e');
      return false;
    }
  }

  ///  Procesa operaciones de registros de huevos
  static Future<bool> _procesarRegistroHuevos(
    String operation,
    Map<String, dynamic> data,
  ) async {
    try {
      if (operation == 'INSERT') {
        // Asegurar que los nombres de campo coincidan con tu API Django
        final datosCorregidos = {
          'lote_id': data['loteId'] ?? data['lote_id'],
          'fecha': data['fecha'],
          'cantidad_huevos': data['cantidadHuevos'] ?? data['cantidad_huevos'],
        };
        await ApiServicePonedoras.agregarRegistroHuevos(datosCorregidos);
        return true;
      }
      // Agregar UPDATE y DELETE si es necesario
      return false;
    } catch (e) {
      print('❌ Error en procesarRegistroHuevos: $e');
      return false;
    }
  }

  /// 🧪 Procesa operaciones de insumos (si los necesitas)
  // En services/sync_service.dart, actualiza _procesarInsumosPonedoras:
  static Future<bool> _procesarInsumosPonedoras(
    String operation,
    Map<String, dynamic> data,
  ) async {
    try {
      if (operation == 'INSERT') {
        final datosCorregidos = {
          'lotes_id': data['lotesId'] ?? data['lotes_id'],
          'nombre': data['nombre'],
          'cantidad': data['cantidad'],
          'unidad': data['unidad'],
          'precio': data['precio'],
          'tipo': data['tipo'],
          'fecha': data['fecha'],
        };
        await ApiServicePonedoras.agregarInsumoPonedora(datosCorregidos);
        return true;
      } else if (operation == 'DELETE') {
        //  Manejar eliminación de insumos
        if (data['id'] != null) {
          await ApiServicePonedoras.eliminarInsumoPonedora(data['id']);
          return true;
        }
      }
      return false;
    } catch (e) {
      print(' Error en procesarInsumosPonedoras: $e');
      return false;
    }
  }
}
