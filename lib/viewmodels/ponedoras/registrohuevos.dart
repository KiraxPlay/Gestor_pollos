import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../models/ponedoras/registrohuevos.dart';
import '../../services/ponedoras/registrohuevos.dart';
import '../../services/sync_service.dart';
import '../../services/connectivity_service.dart';

class RegistroHuevosViewModel extends ChangeNotifier {
  List<RegistroHuevos> _registros = [];
  bool _isOnline = false;
  bool _isSyncing = false;
  String? _error;
  int? _loteIdActual;

  List<RegistroHuevos> get registros => _registros;
  bool get isOnline => _isOnline;
  bool get isSyncing => _isSyncing;
  String? get error => _error;
  int? get loteIdActual => _loteIdActual;

  RegistroHuevosViewModel() {
    _initializeConnectivity();
  }

  void _initializeConnectivity() {
    final connectivity = ConnectivityService();
    _isOnline = connectivity.isConnected;

    connectivity.onConnectivityChanged.listen((result) {
      _isOnline = result == ConnectivityResult.wifi || result == ConnectivityResult.mobile;
      notifyListeners();

      if (_isOnline) {
        print('Conectividad recuperada, sincronizando registros de huevos...');
        syncPendingOperations();
      }
    });
  }

  Future<void> cargarRegistrosPorLote(int loteId) async {
    try {
      _error = null;
      _loteIdActual = loteId;
      _registros = await RegistroHuevosService.obtenerRegistrosPorLote(loteId);
      notifyListeners();
      print('✅ Cargados ${_registros.length} registros de huevos para lote $loteId');
    } catch (e) {
      _error = e.toString();
      print('❌ Error cargando registros: $e');
      notifyListeners();
    }
  }

  Future<void> agregarRegistro(RegistroHuevos registro) async {
    try {
      _error = null;
      print('🔍 Agregando registro de huevos...');
      await RegistroHuevosService.agregarRegistro(registro);
      
      if (_loteIdActual != null) {
        await cargarRegistrosPorLote(_loteIdActual!);
      }
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      print('❌ Error agregando registro: $e');
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
      if (_loteIdActual != null) {
        await cargarRegistrosPorLote(_loteIdActual!);
      }
      _error = null;
    } catch (e) {
      _error = 'Error sincronizando: $e';
      print('❌ Error en syncPendingOperations: $e');
    }

    _isSyncing = false;
    notifyListeners();
  }

  int get totalHuevos {
    return _registros.fold(0, (sum, registro) => sum + registro.cantidadHuevos);
  }

  int get promedioDiario {
    if (_registros.isEmpty) return 0;
    return (totalHuevos / _registros.length).ceil();
  }
}