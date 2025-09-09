import 'package:flutter/material.dart';
import '../models/registropesos.dart';
import '../services/registropeso_service.dart';

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
  }

  Future<void> eliminarRegistroPeso(int id) async {
    try {
      await RegistroPesoService.eliminarPeso(id);
      await cargarRegistrosPeso(_registrosPeso.first.lotesId); // Assuming all registros have the same loteId
      notifyListeners();
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
    } catch (e) {
      print('Error en ViewModel al actualizar registro de peso: $e');
      rethrow;
    }
  }
}