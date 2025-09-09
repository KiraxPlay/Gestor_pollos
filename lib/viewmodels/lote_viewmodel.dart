import 'package:flutter/material.dart';
import 'package:gestorgalpon_app/services/db_service.dart';
import '../models/lotes.dart';
import '../services/lote_service.dart';

class LoteViewModel extends ChangeNotifier {
  List<Lotes> _lotes = [];

  List<Lotes> get lotes => _lotes;

  Future<void> cargarLotes() async {
    _lotes = await LoteService.obtenerLotes();
    notifyListeners();
  }



  Future<void> agregarLote(Lotes lote) async {
    await LoteService.insertarLote(lote);
    await cargarLotes();
  }

  Future<void> eliminarLote(int id) async {
    try {
      await LoteService.eliminarLote(id);
      await cargarLotes();
      notifyListeners();
    } catch (e) {
      print('Error en ViewModel al eliminar lote: $e');
      rethrow;
    }
  }

  Future<void> actualizarLoteLocal(Lotes loteActualizado) async {
    final index = _lotes.indexWhere((l) => l.id == loteActualizado.id);
    if (index != -1) {
      _lotes[index] = loteActualizado;
      notifyListeners();
    }
  }

  Future<void> actualizarMuertos(int id, int nuevosMuertos) async {
    try {
      // 1. Actualiza en SQLite
      await LoteService.actualizarCantidadMuertos(id, nuevosMuertos);

      // 2. Actualiza en memoria
      final index = _lotes.indexWhere((l) => l.id == id);
      if (index != -1) {
        _lotes[index] = _lotes[index].copyWith(cantidadMuertos: nuevosMuertos);
        notifyListeners(); // Notifica a los widgets
      }

      // Opcional: Recargar desde DB para garantizar consistencia
      await cargarLotes();
    } catch (e) {
      debugPrint('Error actualizando muertos: $e');
      rethrow;
    }
  }
}
