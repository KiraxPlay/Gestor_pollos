// services/ponedoras/insumos_ponedoras_service.dart
import 'package:gestorgalpon_app/views/ponedoras/insumos_ponedoras.dart';
import 'package:sqflite/sqflite.dart';
import '../db_service.dart';
import '../connectivity_service.dart';
import '../sync_service.dart';
import '../api_service.dart';

class InsumosPonedorasService {
  static const String _tableName = 'InsumosPonedoras';

  static Future<List<InsumoPonedora>> obtenerInsumosPorLote(int loteId) async {
    final db = await DBService.database;
    final connectivity = ConnectivityService();

    print('🔍 Obteniendo insumos para lote ponedora $loteId');

    try {
      // Sincronizar si hay conexión
      if (connectivity.isConnected) {
        await SyncService.syncAllPendingOperations();
      }

      final data = await db.query(
        _tableName,
        where: 'lotes_id = ?',
        whereArgs: [loteId],
        orderBy: 'fecha DESC',
      );

      return List<InsumoPonedora>.from(
        data.map((item) => InsumoPonedora.fromJson(item)),
      );
    } catch (e) {
      print('❌ Error obteniendo insumos: $e');
      rethrow;
    }
  }

  static Future<int> agregarInsumo(InsumoPonedora insumo) async {
    final db = await DBService.database;
    final connectivity = ConnectivityService();

    print('🔍 Agregando insumo para lote ponedora: ${insumo.lotesId}');

    try {
      // PRIMERO guardar localmente
      final id = await db.insert(
        _tableName,
        insumo.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      print('✅ Insumo guardado localmente con ID: $id');

      // LUEGO intentar enviar al servidor o encolar
      if (connectivity.isConnected) {
        print('📡 Intentando enviar al backend...');
        try {
          await ApiService.agregarInsumoPonedora({
            'lotes_id': insumo.lotesId,
            'nombre': insumo.nombre,
            'cantidad': insumo.cantidad,
            'unidad': insumo.unidad,
            'precio': insumo.precio,
            'tipo': insumo.tipo,
            'fecha': insumo.fecha,
          });
          print('✅ Insumo enviado al backend');
        } catch (e) {
          print('⚠️ Falló envío directo, encolando...: $e');
          await SyncService.queueOperation(
            operation: 'INSERT',
            tableName: _tableName,
            data: insumo.toJson(),
          );
        }
      } else {
        print('📴 Sin conexión, encolando...');
        await SyncService.queueOperation(
          operation: 'INSERT',
          tableName: _tableName,
          data: insumo.toJson(),
        );
      }

      return id;
    } catch (e) {
      print('❌ Error agregando insumo: $e');
      rethrow;
    }
  }
}