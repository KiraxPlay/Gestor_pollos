import 'package:sqflite/sqflite.dart';
import '../models/lotes.dart';
import 'db_service.dart';
import 'connectivity_service.dart';
import 'sync_service.dart';
import 'api_service.dart';
import 'dart:convert';

class LoteService {
  static const String _tableName = 'Lotes';

  static Future<List<Lotes>> obtenerLotes() async {
    final connectivity = ConnectivityService();
    final db = await DBService.database;

    try {
      if (connectivity.isConnected) {
        final datosBackend = await ApiService.obtenerLotes();
        final lotes = List<Lotes>.from(
          datosBackend.map((item) => Lotes.fromJson(item)),
        );

        for (var lote in lotes) {
          await db.insert(
            _tableName,
            lote.toJson(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }

        return lotes;
      } else {
        final data = await db.query(_tableName);
        return List<Lotes>.from(data.map((item) => Lotes.fromJson(item)));
      }
    } catch (e) {
      final data = await db.query(_tableName);
      return List<Lotes>.from(data.map((item) => Lotes.fromJson(item)));
    }
  }

  static Future<int> insertarLote(Lotes lote) async {
    final db = await DBService.database;
    final connectivity = ConnectivityService();

    try {
      if (connectivity.isConnected) {
        final response = await ApiService.crearLote(lote.toJson());
        // backend devuelve {"success": True, "lote": [ {...} ] }
        if (response is Map<String, dynamic> && response['lote'] != null) {
          final loteResp = response['lote'];
          Map<String, dynamic> loteMap;
          if (loteResp is List && loteResp.isNotEmpty) {
            loteMap = Map<String, dynamic>.from(loteResp[0]);
          } else if (loteResp is Map) {
            loteMap = Map<String, dynamic>.from(loteResp);
          } else {
            loteMap = {};
          }

          if (loteMap.isNotEmpty) {
            final nuevoLote = Lotes.fromJson(loteMap);
            return await db.insert(
              _tableName,
              nuevoLote.toJson(),
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          }
        }

        // Fallback: si backend respondió pero sin lote estructurado, insertar local con posible id retornado
        if (response is Map<String, dynamic> && response['id'] != null) {
          final loteConId = lote.copyWith(
            id: int.tryParse(response['id'].toString()),
          );
          return await db.insert(
            _tableName,
            loteConId.toJson(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }

        // Si no se puede parsear, insertar local y encolar
        final id = await db.insert(
          _tableName,
          lote.toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        await SyncService.queueOperation(
          operation: 'INSERT',
          tableName: 'lotes',
          data: lote.toJson(),
        );
        return id;
      } else {
        final id = await db.insert(
          _tableName,
          lote.toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        await SyncService.queueOperation(
          operation: 'INSERT',
          tableName: 'lotes',
          data: lote.toJson(),
        );
        return id;
      }
    } catch (e) {
      final id = await db.insert(
        _tableName,
        lote.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      await SyncService.queueOperation(
        operation: 'INSERT',
        tableName: 'lotes',
        data: lote.toJson(),
      );
      return id;
    }
  }

  static Future<Lotes> obtenerLotePorId(int id) async {
    final db = await DBService.database;
    final connectivity = ConnectivityService();

    try {
      // 📱 PRIMERO intentar obtener de BD local
      final listaLocal = await db.query(
        _tableName,
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );

      if (listaLocal.isNotEmpty) {
        final loteLocal = Lotes.fromJson(listaLocal.first);
        print(
          '✅ Lote obtenido de BD local - Muertos: ${loteLocal.cantidadMuertos}',
        );

        // Si hay conexión, sincronizar en segundo plano
        if (await connectivity.isConnected) {
          _sincronizarLoteEnSegundoPlano(id);
        }

        return loteLocal;
      }

      // Si no existe localmente y hay conexión, obtener del servidor
      if (await connectivity.isConnected) {
        final data = await ApiService.detalleLote(id);
        if (data is Map<String, dynamic> && data['lote'] != null) {
          final loteList = data['lote'];
          Lotes lote;

          if (loteList is List && loteList.isNotEmpty) {
            lote = Lotes.fromJson(Map<String, dynamic>.from(loteList[0]));
          } else if (loteList is Map) {
            lote = Lotes.fromJson(Map<String, dynamic>.from(loteList));
          } else {
            throw Exception('Formato de lote inválido');
          }

          // Guardar en BD local
          await db.insert(
            _tableName,
            lote.toJson(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );

          return lote;
        }
        throw Exception('Respuesta inválida del backend para detalleLote');
      }

      throw Exception('Lote no encontrado localmente con id $id');
    } catch (e) {
      print('❌ Error en obtenerLotePorId: $e');
      rethrow;
    }
  }

  // Sincronización en segundo plano
  static Future<void> _sincronizarLoteEnSegundoPlano(int id) async {
    try {
      final data = await ApiService.detalleLote(id);
      if (data is Map<String, dynamic> && data['lote'] != null) {
        final loteList = data['lote'];
        Lotes lote;

        if (loteList is List && loteList.isNotEmpty) {
          lote = Lotes.fromJson(Map<String, dynamic>.from(loteList[0]));
        } else if (loteList is Map) {
          lote = Lotes.fromJson(Map<String, dynamic>.from(loteList));
        } else {
          return;
        }

        final db = await DBService.database;
        await db.insert(
          _tableName,
          lote.toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        print('✅ Lote sincronizado en segundo plano');
      }
    } catch (e) {
      print('⚠️ Error en sincronización en segundo plano: $e');
    }
  }

  static Future<int> actualizarLote(Lotes lote) async {
    final db = await DBService.database;
    final connectivity = ConnectivityService();

    try {
      final rows = await db.update(
        _tableName,
        lote.toJson(),
        where: 'id = ?',
        whereArgs: [lote.id],
      );
      await SyncService.queueOperation(
        operation: 'UPDATE',
        tableName: 'lotes',
        data: lote.toJson(),
      );
      if (connectivity.isConnected)
        await SyncService.syncAllPendingOperations();
      return rows;
    } catch (e) {
      await db.update(
        _tableName,
        lote.toJson(),
        where: 'id = ?',
        whereArgs: [lote.id],
      );
      await SyncService.queueOperation(
        operation: 'UPDATE',
        tableName: 'lotes',
        data: lote.toJson(),
      );
      rethrow;
    }
  }

  static Future<int> eliminarLote(int id) async {
    final db = await DBService.database;
    final connectivity = ConnectivityService();

    try {
      if (connectivity.isConnected) {
        await ApiService.eliminarLote(id);
      } else {
        await SyncService.queueOperation(
          operation: 'DELETE',
          tableName: 'lotes',
          data: {'id': id},
        );
      }
      return await db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      return await db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
    }
  }

  static Future<void> actualizarCantidadMuertos(
    int id,
    int nuevosMuertos,
  ) async {
    final db = await DBService.database;
    final connectivity = ConnectivityService();

    try {
      await db.update(
        _tableName,
        {'cantidad_muertos': nuevosMuertos},
        where: 'id = ?',
        whereArgs: [id],
      );
      await SyncService.queueOperation(
        operation: 'UPDATE',
        tableName: 'lotes',
        data: {'id': id, 'cantidad_muertos': nuevosMuertos},
      );
      if (connectivity.isConnected)
        await SyncService.syncAllPendingOperations();
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> registrarMortalidad(
    int loteId,
    int cantidadMuerta,
  ) async {
    final connectivity = ConnectivityService();
    final db = await DBService.database;

    try {
      // 📱 PRIMERO: Actualizar SIEMPRE localmente
      await db.execute(
        'UPDATE lotes SET cantidad_muertos = cantidad_muertos + ? WHERE id = ?',
        [cantidadMuerta, loteId],
      );

      print('✅ Mortalidad actualizada localmente');

      if (await connectivity.isConnected) {
        // ✅ ONLINE: Enviar al servidor también
        try {
          await ApiService.registrarMortalidad({
            'lote_id': loteId,
            'cantidad_muerta': cantidadMuerta,
          });
          print('✅ Mortalidad enviada al servidor');
        } catch (e) {
          // Si falla el servidor, ya tenemos el dato local
          print('⚠️ Falló envío al servidor, pero se guardó localmente: $e');

          // Encolar para reintentar después
          await SyncService.queueOperation(
            operation: 'UPDATE_MORTALIDAD',
            tableName: 'lotes',
            data: {'lote_id': loteId, 'cantidad_muerta': cantidadMuerta},
          );
        }
      } else {
        // 📴 OFFLINE: Solo encolar
        await SyncService.queueOperation(
          operation: 'UPDATE_MORTALIDAD',
          tableName: 'lotes',
          data: {'lote_id': loteId, 'cantidad_muerta': cantidadMuerta},
        );
        print('✅ Mortalidad guardada localmente (offline)');
      }
    } catch (e) {
      print('❌ Error en registrarMortalidad: $e');
      rethrow;
    }
  }

  static Future<void> _guardarMortalidadLocal(
    int loteId,
    int cantidadMuerta,
  ) async {
    final db = await DBService.database;

    // 1. Actualizar localmente
    await db.execute(
      'UPDATE lotes SET cantidad_muertos = cantidad_muertos + ? WHERE id = ?',
      [cantidadMuerta, loteId],
    );

    // 2. Encolar para sincronización posterior
    await SyncService.queueOperation(
      operation: 'UPDATE_MORTALIDAD',
      tableName: 'lotes',
      data: {'lote_id': loteId, 'cantidad_muerta': cantidadMuerta},
    );
  }
}
