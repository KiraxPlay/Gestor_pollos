import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../models/ponedoras/ponedoras.dart';
import '../../services/ponedoras/ponedoras_service.dart';
import '../../services/sync_service.dart';
import '../../services/connectivity_service.dart';

class PonederasViewModel extends ChangeNotifier {
  List<Ponedoras> _ponedoras = [];
  bool _isOnline = false;
  bool _isSyncing = false;
  String? _error;

  List<Ponedoras> get ponedoras => _ponedoras;
  bool get isOnline => _isOnline;
  bool get isSyncing => _isSyncing;
  String? get error => _error;

  PonederasViewModel() {
    _initializeConnectivity();
    cargarPonedoras();
  }

  void _initializeConnectivity() {
    final connectivity = ConnectivityService();
    _isOnline = connectivity.isConnected;

    connectivity.onConnectivityChanged.listen((result) {
      _isOnline = result == ConnectivityResult.wifi || result == ConnectivityResult.mobile;
      notifyListeners();

      if (_isOnline) {
        print('Conectividad recuperada, sincronizando ponedoras...');
        syncPendingOperations();
      }
    });
  }

  Future<void> cargarPonedoras() async {
    try {
      _error = null;
      _ponedoras = await PonederasService.obtenerPonedoras();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      print('Error cargando ponedoras: $e');
      notifyListeners();
    }
  }

  Future<void> agregarPonedora(Ponedoras ponedora) async {
    try {
      _error = null;
      await PonederasService.insertarPonedora(ponedora);
      await cargarPonedoras();
    } catch (e) {
      _error = e.toString();
      print('Error agregando ponedora: $e');
      notifyListeners();
      rethrow;
    }
  }

  Future<Ponedoras?> obtenerPonedora(int id) async {
    try {
      _error = null;
      final ponedora = await PonederasService.obtenerPonederaPorId(id);
      return ponedora;
    } catch (e) {
      _error = e.toString();
      print('Error obteniendo ponedora: $e');
      notifyListeners();
      return null;
    }
  }

  Future<void> eliminarPonedora(int id) async {
    try {
      _error = null;
      await PonederasService.eliminarPonedora(id);
      await cargarPonedoras();
    } catch (e) {
      _error = e.toString();
      print('Error eliminando ponedora: $e');
      notifyListeners();
      rethrow;
    }
  }

  Future<void> actualizarPonedora(Ponedoras ponedora) async {
    try {
      _error = null;
      await PonederasService.actualizarPonedora(ponedora);
      await cargarPonedoras();
    } catch (e) {
      _error = e.toString();
      print('Error actualizando ponedora: $e');
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
      await cargarPonedoras();
      _error = null;
    } catch (e) {
      _error = 'Error sincronizando: $e';
      print('Error en syncPendingOperations: $e');
    }

    _isSyncing = false;
    notifyListeners();
  }
}