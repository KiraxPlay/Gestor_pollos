import 'package:flutter/material.dart';
import '../models/registro_peso.dart';
import '../services/registropeso_service.dart';
import '../services/sync_service.dart';
import '../services/connectivity_service.dart';

class RegistroPesoViewModel extends ChangeNotifier {
  List<RegistroPeso> _registrosPeso = [];

  List<RegistroPeso> get registrosPeso => _registrosPeso;

  Future<void> cargarRegistrosPeso(int loteId) async {
    _registrosPeso = await RegistroPesoService.obtenerPesos(loteId);
    notifyListeners();
  }

  Future<void> agregarRegistroPeso(RegistroPeso registro) async {
    await RegistroPesoService.insertarPeso(registro);
    await cargarRegistrosPeso(registro.lotesId);
    
    // 🔄 Intentar sincronizar después de agregar
    await _sincronizarSiEstaDisponible();
  }

  Future<void> eliminarRegistroPeso(int id) async {
    try {
      await RegistroPesoService.eliminarPeso(id);
      await cargarRegistrosPeso(_registrosPeso.first.lotesId); // Assuming all registros have the same loteId
      notifyListeners();
      
      // 🔄 Intentar sincronizar después de eliminar
      await _sincronizarSiEstaDisponible();
    } catch (e) {
      print('Error en ViewModel al eliminar registro de peso: $e');
      rethrow;
    }
  }

  Future <void> actualizarRegistroPeso(RegistroPeso registro) async {
    try {
      await RegistroPesoService.actualizarPeso(registro);
      await cargarRegistrosPeso(registro.lotesId);
      notifyListeners();
      
      // 🔄 Intentar sincronizar después de actualizar
      await _sincronizarSiEstaDisponible();
    } catch (e) {
      print('Error en ViewModel al actualizar registro de peso: $e');
      rethrow;
    }
  }

  /// 🔄 Método auxiliar para sincronizar si hay conexión disponible
  Future<void> _sincronizarSiEstaDisponible() async {
    try {
      final connectivity = ConnectivityService();
      final hasConnection = await connectivity.checkConnection();
      if (hasConnection) {
        print('🔄 Sincronizando registros de peso pendientes...');
        await SyncService.syncAllPendingOperations();
      }
    } catch (e) {
      print('⚠️ Error intentando sincronizar: $e');
      // No lanzar error, solo registrar
    }
  }
}