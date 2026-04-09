import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import '../models/lotes.dart';
import 'db_service.dart';
import 'connectivity_service.dart';
import 'sync_service.dart';
import 'api_service.dart';

class LoteService {
  static const String _tableName = 'Lotes';

  // 🔥 OBTENER LOTES
  static Future<List<Lotes>> obtenerLotes() async {
    final connectivity = ConnectivityService();

    // 🌐 WEB → SOLO API
    if (kIsWeb) {
      final datos = await ApiService.obtenerLotes();
      return List<Lotes>.from(datos.map((item) => Lotes.fromJson(item)));
    }

    // 📱 MOBILE → SQLite + Sync
    final db = await DBService.database;

    try {
      if (connectivity.isConnected) {
        final datos = await ApiService.obtenerLotes();
        final lotes = List<Lotes>.from(
          datos.map((item) => Lotes.fromJson(item)),
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
        return data.map((e) => Lotes.fromJson(e)).toList();
      }
    } catch (e) {
      final data = await db.query(_tableName);
      return data.map((e) => Lotes.fromJson(e)).toList();
    }
  }

  // 🔥 INSERTAR LOTE
  static Future<int> insertarLote(Lotes lote) async {
    final connectivity = ConnectivityService();

    // 🌐 WEB
    if (kIsWeb) {
      await ApiService.crearLote(lote.toJson());
      return 1;
    }

    final db = await DBService.database;

    if (connectivity.isConnected) {
      await ApiService.crearLote(lote.toJson());
    } else {
      await SyncService.queueOperation(
        operation: 'INSERT',
        tableName: 'lotes',
        data: lote.toJson(),
      );
    }

    return await db.insert(
      _tableName,
      lote.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // 🔥 ELIMINAR
  static Future<int> eliminarLote(int id) async {
    final connectivity = ConnectivityService();

    // 🌐 WEB
    if (kIsWeb) {
      await ApiService.eliminarLote(id);
      return 1;
    }

    final db = await DBService.database;

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
  }

  // 🔥 ACTUALIZAR
  static Future<int> actualizarLote(Lotes lote) async {
    final connectivity = ConnectivityService();

    // 🌐 WEB
    if (kIsWeb) {
      await ApiService.actualizarLote(lote.toJson());
      return 1;
    }

    final db = await DBService.database;

    await db.update(
      _tableName,
      lote.toJson(),
      where: 'id = ?',
      whereArgs: [lote.id],
    );

    if (connectivity.isConnected) {
      await ApiService.actualizarLote(lote.toJson());
    } else {
      await SyncService.queueOperation(
        operation: 'UPDATE',
        tableName: 'lotes',
        data: lote.toJson(),
      );
    }

    return 1;
  }

  // 🔥 ACTUALIZAR MUERTOS
  static Future<void> actualizarCantidadMuertos(
    int id,
    int nuevosMuertos,
  ) async {
    final connectivity = ConnectivityService();

    // 🌐 WEB
    if (kIsWeb) {
      await ApiService.registrarMortalidad({
        'lote_id': id,
        'cantidad_muerta': nuevosMuertos,
      });
      return;
    }

    final db = await DBService.database;

    await db.update(
      _tableName,
      {'cantidad_muertos': nuevosMuertos},
      where: 'id = ?',
      whereArgs: [id],
    );

    if (connectivity.isConnected) {
      await ApiService.registrarMortalidad({
        'lote_id': id,
        'cantidad_muerta': nuevosMuertos,
      });
    } else {
      await SyncService.queueOperation(
        operation: 'UPDATE_MORTALIDAD',
        tableName: 'lotes',
        data: {'lote_id': id, 'cantidad_muerta': nuevosMuertos},
      );
    }
  }

  static Future<Lotes> obtenerLotePorId(int id) async {
    final connectivity = ConnectivityService();

    // 🌐 WEB
    if (kIsWeb) {
      final data = await ApiService.detalleLote(id);

      if (data['lote'] != null) {
        final loteData = data['lote'];

        if (loteData is List && loteData.isNotEmpty) {
          return Lotes.fromJson(Map<String, dynamic>.from(loteData[0]));
        } else if (loteData is Map) {
          return Lotes.fromJson(Map<String, dynamic>.from(loteData));
        }
      }

      throw Exception('Lote no encontrado');
    }

    // 📱 MOBILE
    final db = await DBService.database;

    final local = await db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (local.isNotEmpty) {
      return Lotes.fromJson(local.first);
    }

    if (connectivity.isConnected) {
      final data = await ApiService.detalleLote(id);

      if (data['lote'] != null) {
        final loteData = data['lote'];

        Lotes lote;

        if (loteData is List && loteData.isNotEmpty) {
          lote = Lotes.fromJson(Map<String, dynamic>.from(loteData[0]));
        } else {
          lote = Lotes.fromJson(Map<String, dynamic>.from(loteData));
        }

        await db.insert(
          _tableName,
          lote.toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        return lote;
      }
    }

    throw Exception('Lote no encontrado');
  }

  static Future<void> registrarMortalidad(
    int loteId,
    int cantidadMuerta,
) async {
  final connectivity = ConnectivityService();

  // 🌐 WEB
  if (kIsWeb) {
    await ApiService.registrarMortalidad({
      'lote_id': loteId,
      'cantidad_muerta': cantidadMuerta,
    });
    return;
  }

  // 📱 MOBILE
  final db = await DBService.database;

  await db.execute(
    'UPDATE lotes SET cantidad_muertos = cantidad_muertos + ? WHERE id = ?',
    [cantidadMuerta, loteId],
  );

  if (connectivity.isConnected) {
    await ApiService.registrarMortalidad({
      'lote_id': loteId,
      'cantidad_muerta': cantidadMuerta,
    });
  } else {
    await SyncService.queueOperation(
      operation: 'UPDATE_MORTALIDAD',
      tableName: 'lotes',
      data: {
        'lote_id': loteId,
        'cantidad_muerta': cantidadMuerta,
      },
    );
  }
}
}
