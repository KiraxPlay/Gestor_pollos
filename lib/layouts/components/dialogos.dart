import 'package:flutter/material.dart';
import '../../models/lotes.dart';
import '../../services/lote_service.dart';

class DialogosGalpon {
  static Future<void> mostrarDialogoMuertos({
    required BuildContext context,
    required Lotes loteActual,
    required Function onMortalidadRegistrada,
  }) async {
    final cantidadController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: Colors.red[50],
        title: const Row(
          children: [
            Icon(Icons.warning_amber, color: Colors.red),
            SizedBox(width: 8),
            Text(
              'Registrar Mortalidad',
              style: TextStyle(color: Colors.red),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Cantidad actual de muertos: ${loteActual.cantidadMuertos}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: cantidadController,
              decoration: const InputDecoration(
                labelText: 'Cantidad de nuevos muertos',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.numbers),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final cantidad = int.tryParse(cantidadController.text);
              if (cantidad == null || cantidad <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Por favor ingrese una cantidad válida'),
                  ),
                );
                return;
              }

              try {
                await LoteService.actualizarCantidadMuertos(
                  loteActual.id!,
                  loteActual.cantidadMuertos + cantidad,
                );

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Mortalidad registrada satisfactoriamente'),
                    ),
                  );
                  onMortalidadRegistrada();
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error al registrar la mortalidad: $e'),
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Registrar'),
          ),
        ],
      ),
    );
  }
}