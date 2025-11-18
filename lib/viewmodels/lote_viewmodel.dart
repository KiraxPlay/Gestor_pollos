import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../services/db_service.dart';
import '../services/api_service.dart';
import '../models/lotes.dart';
import '../services/lote_service.dart';
import '../services/sync_service.dart';
import '../services/connectivity_service.dart';

class LoteViewModel extends ChangeNotifier {
  List<Lotes> _lotes = [];
  bool _isOnline = false;
  bool _isSyncing = false;
  String? _error;

  List<Lotes> get lotes => _lotes;
  bool get isOnline => _isOnline;
  bool get isSyncing => _isSyncing;
  String? get error => _error;

  LoteViewModel() {
    _initializeConnectivity();
    cargarLotes();
  }

  void _initializeConnectivity() {
    final connectivity = ConnectivityService();
    _isOnline = connectivity.isConnected;

    connectivity.onConnectivityChanged.listen((result) {
      _isOnline =
          result == ConnectivityResult.wifi ||
          result == ConnectivityResult.mobile;
      notifyListeners();

      if (_isOnline) {
        print('Conectividad recuperada, sincronizando...');
        syncPendingOperations();
      }
    });
  }

  Future<void> cargarLotes() async {
    try {
      _error = null;
      _lotes = await LoteService.obtenerLotes();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      print('Error cargando lotes: $e');
      notifyListeners();
    }
  }

  Future<void> agregarLote(Lotes lote) async {
    try {
      _error = null;
      await LoteService.insertarLote(lote);
      await cargarLotes();
    } catch (e) {
      _error = e.toString();
      print('Error agregando lote: $e');
      notifyListeners();
      rethrow;
    }
  }

  Future<Lotes?> obtenerLote(int id) async {
    try {
      _error = null;
      final lote = await LoteService.obtenerLotePorId(id);
      return lote;
    } catch (e) {
      _error = e.toString();
      print('Error obteniendo lote: $e');
      notifyListeners();
      return null;
    }
  }

  Future<void> eliminarLote(int id) async {
    try {
      _error = null;
      await LoteService.eliminarLote(id);
      await cargarLotes();
    } catch (e) {
      _error = e.toString();
      print('Error eliminando lote: $e');
      notifyListeners();
      rethrow;
    }
  }

  Future<void> actualizarMuertos(int id, int nuevosMuertos) async {
    try {
      _error = null;
      await LoteService.actualizarCantidadMuertos(id, nuevosMuertos);
      await cargarLotes();
    } catch (e) {
      _error = e.toString();
      print('Error actualizando muertos: $e');
      notifyListeners();
      rethrow;
    }
  }

  Future<void> actualizarLote(Lotes lote) async {
    try {
      _error = null;
      await LoteService.actualizarLote(lote);
      await cargarLotes();
    } catch (e) {
      _error = e.toString();
      print('Error actualizando lote: $e');
      notifyListeners();
      rethrow;
    }
  }

  Future<void> syncPendingOperations() async {
    if (_isSyncing) return;

    _isSyncing = true;
    notifyListeners();

    try {
      await SyncService.syncAllPendingOperations();
      await cargarLotes();
      _error = null;
    } catch (e) {
      _error = 'Error sincronizando: $e';
      print('Error en syncPendingOperations: $e');
    }

    _isSyncing = false;
    notifyListeners();
  }
}
