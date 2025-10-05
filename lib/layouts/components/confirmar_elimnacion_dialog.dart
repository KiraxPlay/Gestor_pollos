import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/lote_viewmodel.dart';
import '../../models/lotes.dart';

class ConfirmarEliminacionDialog extends StatelessWidget {
  final Lotes lote;

  const ConfirmarEliminacionDialog({
    Key? key,
    required this.lote,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      backgroundColor: Colors.red.shade50,
      title: Column(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: Colors.red.shade700,
            size: 48,
          ),
          const SizedBox(height: 8),
          Text(
            'Confirmar eliminación',
            style: TextStyle(
              color: Colors.red.shade800,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '¿Está seguro de eliminar el',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.red.shade800,
            ),
          ),
          Text(
            '"${lote.nombre}"?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.red.shade900,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Esta acción no se puede deshacer',
            style: TextStyle(
              fontSize: 14,
              color: Colors.red.shade700,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(
            backgroundColor: Colors.grey.shade200,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            child: Text(
              'Cancelar',
              style: TextStyle(
                color: Colors.grey.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        TextButton(
          onPressed: () => _eliminarLote(context),
          style: TextButton.styleFrom(
            backgroundColor: Colors.red.shade400,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.delete, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  'Eliminar',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _eliminarLote(BuildContext context) async {
    try {
      await Provider.of<LoteViewModel>(
        context,
        listen: false,
      ).eliminarLote(lote.id!);

      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
                Text(
                  'Lote eliminado correctamente',
                  style: TextStyle(
                    color: Colors.green.shade200,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(
                  Icons.error_outline,
                  color: Colors.white,
                ),
                SizedBox(width: 8),
                Text(
                  'Error al eliminar lote',
                ),
              ],
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}