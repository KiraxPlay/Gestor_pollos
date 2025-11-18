import 'package:sqflite/sqflite.dart';
import '../../models/ponedoras/ponedoras.dart';
import '../db_service.dart';
import '../connectivity_service.dart';
import '../sync_service.dart';
import '../api_service.dart';

class PonederasService {
  static const String _tableName = 'Ponedoras';

  static Future<List<Ponedoras>> obtenerPonedoras() async {
    final connectivity = ConnectivityService();
    final db = await DBService.database;

    print('🔍 Obteniendo ponedoras - Conectado: ${connectivity.isConnected}');

    try {
      if (connectivity.isConnected) {
        print('📡 Intentando obtener ponedoras del backend...');
        final datosBackend = await ApiService.obtenerPonedoras();
        print('✅ Backend devolvió: $datosBackend');
        
        final ponedoras = List<Ponedoras>.from(
          datosBackend.map((item) => Ponedoras.fromJson(item)),
        );

        // Guardar en SQLite local
        for (var ponedora in ponedoras) {
          await db.insert(_tableName, ponedora.toJson(),
              conflictAlgorithm: ConflictAlgorithm.replace);
        }

        print('💾 Guardadas ${ponedoras.length} ponedoras en SQLite');
        return ponedoras;
      } else {
        print('📴 Sin conexión, obteniendo del SQLite local...');
        final data = await db.query(_tableName);
        final ponedoras = List<Ponedoras>.from(data.map((item) => Ponedoras.fromJson(item)));
        print('✅ Obtenidas ${ponedoras.length} ponedoras del local');
        return ponedoras;
      }
    } catch (e) {
      print('❌ Error obteniendo ponedoras del backend: $e');
      print('📴 Intentando recuperar del SQLite local...');
      final data = await db.query(_tableName);
      final ponedoras = List<Ponedoras>.from(data.map((item) => Ponedoras.fromJson(item)));
      print('✅ Obtenidas ${ponedoras.length} ponedoras del local (fallback)');
      return ponedoras;
    }
  }

  static Future<int> insertarPonedora(Ponedoras ponedora) async {
    final db = await DBService.database;
    final connectivity = ConnectivityService();

    print('🔍 Insertando ponedora: ${ponedora.nombre}');
    print('🔌 ¿Conectado? ${connectivity.isConnected}');

    try {
      if (connectivity.isConnected) {
        print('📡 Intentando crear ponedora en backend...');
        final response = await ApiService.crearPonedora(ponedora.toJson());
        print('✅ Respuesta backend: $response');
        
        if (response is Map<String, dynamic> && response['lote_id'] != null) {
          final id = response['lote_id'];
          final ponederaConId = ponedora.copyWith(id: id);
          print('💾 Guardando en SQLite con ID: $id');
          return await db.insert(_tableName, ponederaConId.toJson(),
              conflictAlgorithm: ConflictAlgorithm.replace);
        }

        final id = await db.insert(_tableName, ponedora.toJson(),
            conflictAlgorithm: ConflictAlgorithm.replace);
        await SyncService.queueOperation(
            operation: 'INSERT', tableName: 'ponedoras', data: ponedora.toJson());
        print('⚠️ Guardado localmente (sin ID del backend)');
        return id;
      } else {
        print('📴 Sin conexión, guardando localmente...');
        final id = await db.insert(_tableName, ponedora.toJson(),
            conflictAlgorithm: ConflictAlgorithm.replace);
        await SyncService.queueOperation(
            operation: 'INSERT', tableName: 'ponedoras', data: ponedora.toJson());
        print('✅ Guardado localmente con ID: $id');
        return id;
      }
    } catch (e) {
      print('❌ Error: $e');
      final id = await db.insert(_tableName, ponedora.toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace);
      await SyncService.queueOperation(
          operation: 'INSERT', tableName: 'ponedoras', data: ponedora.toJson());
      return id;
    }
  }

  static Future<Ponedoras> obtenerPonederaPorId(int id) async {
    final db = await DBService.database;
    final connectivity = ConnectivityService();

    print('🔍 Obteniendo ponedora ID: $id - Conectado: ${connectivity.isConnected}');

    try {
      if (connectivity.isConnected) {
        print('📡 Intentando obtener del backend...');
        final data = await ApiService.detallePonedora(id);
        print('✅ Backend devolvió: $data');
        
        if (data is Map<String, dynamic> && data['lote'] != null) {
          final loteData = data['lote'];
          Map<String, dynamic> ponederaMap;
          
          if (loteData is List && loteData.isNotEmpty) {
            ponederaMap = Map<String, dynamic>.from(loteData[0]);
          } else if (loteData is Map) {
            ponederaMap = Map<String, dynamic>.from(loteData);
          } else {
            ponederaMap = {};
          }

          if (ponederaMap.isNotEmpty) {
            final ponedora = Ponedoras.fromJson(ponederaMap);
            print('💾 Guardando en SQLite: ${ponedora.nombre}');
            await db.insert(_tableName, ponedora.toJson(),
                conflictAlgorithm: ConflictAlgorithm.replace);
            return ponedora;
          }
        }
        throw Exception('Respuesta inválida del backend');
      } else {
        print('📴 Sin conexión, obteniendo del local...');
        final lista = await db.query(_tableName, where: 'id = ?', whereArgs: [id], limit: 1);
        if (lista.isNotEmpty) {
          final ponedora = Ponedoras.fromJson(lista.first);
          print('✅ Obtenida del local: ${ponedora.nombre}');
          return ponedora;
        }
        throw Exception('Ponedora no encontrada localmente');
      }
    } catch (e) {
      print('❌ Error: $e');
      print('📴 Intentando recuperar del local...');
      final lista = await db.query(_tableName, where: 'id = ?', whereArgs: [id], limit: 1);
      if (lista.isNotEmpty) {
        final ponedora = Ponedoras.fromJson(lista.first);
        print('✅ Obtenida del local (fallback): ${ponedora.nombre}');
        return ponedora;
      }
      rethrow;
    }
  }

  static Future<int> actualizarPonedora(Ponedoras ponedora) async {
    final db = await DBService.database;
    final connectivity = ConnectivityService();

    print('🔍 Actualizando ponedora: ${ponedora.nombre}');

    try {
      final rows = await db.update(_tableName, ponedora.toJson(),
          where: 'id = ?', whereArgs: [ponedora.id]);
      
      await SyncService.queueOperation(
          operation: 'UPDATE', tableName: 'ponedoras', data: ponedora.toJson());
      
      if (connectivity.isConnected) {
        print('📡 Sincronizando cambios...');
        await SyncService.syncAllPendingOperations();
      }
      
      print('✅ Actualizada: ${ponedora.nombre}');
      return rows;
    } catch (e) {
      print('❌ Error: $e');
      await db.update(_tableName, ponedora.toJson(),
          where: 'id = ?', whereArgs: [ponedora.id]);
      await SyncService.queueOperation(
          operation: 'UPDATE', tableName: 'ponedoras', data: ponedora.toJson());
      rethrow;
    }
  }

  static Future<int> eliminarPonedora(int id) async {
    final db = await DBService.database;
    final connectivity = ConnectivityService();

    print('🔍 Eliminando ponedora ID: $id');

    try {
      if (connectivity.isConnected) {
        print('📡 Intentando eliminar del backend...');
        await ApiService.eliminarPonedora(id);
        print('✅ Eliminada del backend');
      } else {
        print('📴 Sin conexión, encolando eliminación...');
        await SyncService.queueOperation(
            operation: 'DELETE', tableName: 'ponedoras', data: {'id': id});
      }
      
      final rows = await db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
      print('✅ Eliminada del local');
      return rows;
    } catch (e) {
      print('❌ Error: $e');
      return await db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
    }
  }
}