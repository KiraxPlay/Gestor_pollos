import 'package:sqflite/sqflite.dart';
import '../../models/ponedoras/registrohuevos.dart';
import '../db_service.dart';
import '../connectivity_service.dart';
import '../sync_service.dart';
import '../ponedoras/api_service_ponedoras.dart';

class RegistroHuevosService {
  static const String _tableName = 'RegistroHuevos';

  static Future<List<RegistroHuevos>> obtenerRegistrosPorLote(int loteId) async {
    final db = await DBService.database;
    final connectivity = ConnectivityService();

    print('🔍 Obteniendo registros huevos para lote $loteId');

    try {
      if (await connectivity.isConnected) {
        print('📡 Conectado, pero usando datos locales por ahora');
        // Aquí podrías sincronizar datos del servidor si quieres
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
      print('❌ Error obteniendo registros: $e');
      return [];
    }
  }

  static Future<int> agregarRegistro(RegistroHuevos registro) async {
    final db = await DBService.database;
    final connectivity = ConnectivityService();

    print('➕ Agregando registro huevos para lote: ${registro.loteId}');

    try {
      if (await connectivity.isConnected) {
        print('📡 Enviando al backend...');
        try {
          await ApiServicePonedoras.agregarRegistroHuevos({
            'lote_id': registro.loteId,
            'fecha': registro.fecha,
            'cantidad_huevos': registro.cantidadHuevos,
          });
          print('✅ Enviado al backend exitosamente');
        } catch (e) {
          print('⚠️ Error enviando al backend: $e');
          // Continuar para guardar localmente
        }
      } else {
        print('📴 Sin conexión, solo guardando localmente');
      }

      // 📱 GUARDAR LOCALMENTE SIEMPRE
      final id = await db.insert(
        _tableName,
        registro.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      print('✅ Registrado localmente con ID: $id');

      // 🔄 ENCOLAR SI ESTÁ OFFLINE
      if (!(await connectivity.isConnected)) {
        await SyncService.queueOperation(
          operation: 'INSERT',
          tableName: 'RegistroHuevos',
          data: registro.toJson(),
        );
        print('✅ Operación encolada para sincronización');
      }

      return id;
    } catch (e) {
      print('❌ Error agregando registro: $e');
      rethrow;
    }
  }

  // 🗑️ MÉTODO PARA ELIMINAR REGISTRO
  static Future<void> eliminarRegistro(int id) async {
    final db = await DBService.database;
    final connectivity = ConnectivityService();

    print('🗑️ Eliminando registro huevos ID: $id');

    try {
      // Primero obtener el registro para tener los datos para sync
      final registro = await db.query(
        _tableName,
        where: 'id = ?',
        whereArgs: [id],
      );

      if (registro.isEmpty) {
        throw Exception('Registro no encontrado');
      }

      // Eliminar localmente
      await db.delete(
        _tableName,
        where: 'id = ?',
        whereArgs: [id],
      );

      print('✅ Eliminado localmente');

      if (await connectivity.isConnected) {
        print('📡 Intentando eliminar del backend...');
        try {
          // Necesitarías agregar este endpoint en tu ApiService
          // await ApiService.eliminarRegistroHuevos(id);
          print('⚠️ Eliminación en backend no implementada');
        } catch (e) {
          print('⚠️ Error eliminando en backend: $e');
        }
      } else {
        // Encolar eliminación para sync
        await SyncService.queueOperation(
          operation: 'DELETE',
          tableName: 'RegistroHuevos',
          data: {'id': id},
        );
        print('✅ Eliminación encolada para sincronización');
      }

    } catch (e) {
      print('❌ Error eliminando registro: $e');
      rethrow;
    }
  }

  // ✏️ MÉTODO PARA ACTUALIZAR REGISTRO
  static Future<void> actualizarRegistro(RegistroHuevos registro) async {
    final db = await DBService.database;
    final connectivity = ConnectivityService();

    print('✏️ Actualizando registro huevos ID: ${registro.id}');

    try {
      // Actualizar localmente
      await db.update(
        _tableName,
        registro.toJson(),
        where: 'id = ?',
        whereArgs: [registro.id],
      );

      print('✅ Actualizado localmente');

      if (await connectivity.isConnected) {
        print('📡 Intentando actualizar en backend...');
        try {
          // Necesitarías agregar este endpoint en tu ApiService
          // await ApiService.actualizarRegistroHuevos(registro.toJson());
          print('⚠️ Actualización en backend no implementada');
        } catch (e) {
          print('⚠️ Error actualizando en backend: $e');
        }
      } else {
        // Encolar actualización para sync
        await SyncService.queueOperation(
          operation: 'UPDATE',
          tableName: 'RegistroHuevos',
          data: registro.toJson(),
        );
        print('✅ Actualización encolada para sincronización');
      }

    } catch (e) {
      print('❌ Error actualizando registro: $e');
      rethrow;
    }
  }

  // 📊 MÉTODO PARA OBTENER REGISTRO POR ID
  static Future<RegistroHuevos?> obtenerRegistroPorId(int id) async {
    final db = await DBService.database;

    try {
      final data = await db.query(
        _tableName,
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );

      if (data.isNotEmpty) {
        return RegistroHuevos.fromJson(data.first);
      }
      return null;
    } catch (e) {
      print('❌ Error obteniendo registro por ID: $e');
      return null;
    }
  }

  // 📅 MÉTODO PARA VERIFICAR SI YA EXISTE REGISTRO EN UNA FECHA
  static Future<bool> existeRegistroEnFecha(int loteId, String fecha) async {
    final db = await DBService.database;

    try {
      final data = await db.query(
        _tableName,
        where: 'lote_id = ? AND fecha = ?',
        whereArgs: [loteId, fecha],
        limit: 1,
      );

      return data.isNotEmpty;
    } catch (e) {
      print('❌ Error verificando registro en fecha: $e');
      return false;
    }
  }

  // 📈 MÉTODO PARA OBTENER ESTADÍSTICAS
  static Future<Map<String, dynamic>> obtenerEstadisticas(int loteId) async {
    final db = await DBService.database;

    try {
      final registros = await obtenerRegistrosPorLote(loteId);
      
      if (registros.isEmpty) {
        return {
          'total': 0,
          'promedio': 0,
          'maximo': 0,
          'minimo': 0,
        };
      }

      final total = registros.fold(0, (sum, registro) => sum + registro.cantidadHuevos);
      final promedio = total / registros.length;
      final maximo = registros.map((r) => r.cantidadHuevos).reduce((a, b) => a > b ? a : b);
      final minimo = registros.map((r) => r.cantidadHuevos).reduce((a, b) => a < b ? a : b);

      return {
        'total': total,
        'promedio': promedio.round(),
        'maximo': maximo,
        'minimo': minimo,
        'dias_registrados': registros.length,
      };
    } catch (e) {
      print('❌ Error obteniendo estadísticas: $e');
      return {
        'total': 0,
        'promedio': 0,
        'maximo': 0,
        'minimo': 0,
        'dias_registrados': 0,
      };
    }
  }
}