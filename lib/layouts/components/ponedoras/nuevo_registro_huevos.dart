// layouts/components/ponedoras/nuevo_registro_huevos.dart
import 'package:flutter/material.dart';
import 'package:gestorgalpon_app/models/ponedoras/registrohuevos.dart';
import 'package:gestorgalpon_app/services/ponedoras/registrohuevos.dart';
import 'package:intl/intl.dart';
import '../../../models/ponedoras/ponedoras.dart';

Future<void> mostrarDialogoRegistroHuevos({
  required BuildContext context,
  required Ponedoras ponedoraActual,
  required Function onHuevosRegistrados,
}) async {
  final cantidadCtrl = TextEditingController();
  DateTime fechaSeleccionada = DateTime.now();

  await showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: Colors.yellow.shade100,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Column(
        children: [
          const Icon(Icons.egg, size: 48, color: Colors.orange),
          const SizedBox(height: 8),
          const Text(
            'Agregar Registro de Huevos',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: cantidadCtrl,
              decoration: const InputDecoration(
                labelText: 'Cantidad de huevos',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.numbers),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: fechaSeleccionada,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  fechaSeleccionada = date;
                }
              },
              child: AbsorbPointer(
                child: TextField(
                  enabled: false,
                  decoration: InputDecoration(
                    labelText: 'Fecha',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.calendar_today),
                    suffixIcon: const Icon(Icons.arrow_drop_down),
                    hintText: DateFormat('dd/MM/yyyy').format(fechaSeleccionada),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (cantidadCtrl.text.isNotEmpty) {
              try {
                await RegistroHuevosService.agregarRegistro(
                  RegistroHuevos(
                    loteId: ponedoraActual.id!,
                    fecha: DateFormat('yyyy-MM-dd').format(fechaSeleccionada),
                    cantidadHuevos: int.parse(cantidadCtrl.text),
                  ),
                );
                
                onHuevosRegistrados();
                Navigator.pop(ctx);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '${cantidadCtrl.text} huevos registrados exitosamente',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          child: const Text('Guardar', style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
}