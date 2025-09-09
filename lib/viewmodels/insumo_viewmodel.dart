import 'package:flutter/material.dart';
import '../models/insumos.dart';
import '../services/insumo_service.dart';

class InsumoViewModel extends ChangeNotifier {
  List<Insumos> _insumos = [];

  List<Insumos> get insumos => _insumos;

  Future<void> cargarInsumos(int loteId) async {
    _insumos = await InsumosService.obtenerInsumosPorLote(loteId);
    notifyListeners();
  }

  Future<void> agregarInsumo(Insumos insumo) async {
    await InsumosService.insertarInsumo(insumo);
    await cargarInsumos(insumo.lotesId);
  }

  Future<void> eliminarInsumo(int id) async {
    try {
      await InsumosService.eliminarInsumo(id);
      await cargarInsumos(_insumos.first.lotesId); // Assuming all insumos have the same loteId
      notifyListeners();
    } catch (e) {
      print('Error en ViewModel al eliminar insumo: $e');
      rethrow;
    }
  }
}