import 'package:flutter/material.dart';
import 'package:gestorgalpon_app/models/ponedoras/ponedoras.dart';
import 'package:gestorgalpon_app/services/ponedoras/ponedoras_service.dart';
import 'package:intl/intl.dart';
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
      builder:
          (context) => AlertDialog(
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
                  if (cantidadController.text.isNotEmpty) {
                    final nuevosMuertos = int.parse(cantidadController.text);

                    // Validar que no sea negativo
                    if (nuevosMuertos < 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('La cantidad no puede ser negativa'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    try {
                      // ✅ ESTO ESTÁ CORRECTO - tu método SÍ existe
                      await LoteService.registrarMortalidad(
                        loteActual.id!,
                        nuevosMuertos,
                      );

                      // Recargar datos
                      onMortalidadRegistrada();
                      Navigator.pop(context);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('$nuevosMuertos muertos registrados'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Ingrese una cantidad válida'),
                        backgroundColor: Colors.red,
                      ),
                    );
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

  static Future<void> mostrarDialogoMuertosPonedoras({
    required BuildContext context,
    required Ponedoras ponedoraActual,
    required Function onMortalidadRegistrada,
  }) async {
    final cantidadCtrl = TextEditingController();
    DateTime fechaSeleccionada = DateTime.now();

    await showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            backgroundColor: Colors.yellow.shade100,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: Column(
              children: [
                const Icon(Icons.heart_broken, size: 48, color: Colors.red),
                const SizedBox(height: 8),
                const Text(
                  'Registrar Mortalidad',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  ponedoraActual.nombre,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Gallinas vivas: ${ponedoraActual.cantidadGallinas - ponedoraActual.cantidadMuerto}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: cantidadCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Cantidad de gallinas muertas',
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
                          labelText: 'Fecha de mortalidad',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.calendar_today),
                          suffixIcon: const Icon(Icons.arrow_drop_down),
                          hintText: DateFormat(
                            'dd/MM/yyyy',
                          ).format(fechaSeleccionada),
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
                    final cantidadMuertas = int.tryParse(cantidadCtrl.text);

                    if (cantidadMuertas == null || cantidadMuertas <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Ingrese una cantidad válida'),
                        ),
                      );
                      return;
                    }

                    // Validar que no exceda las gallinas vivas
                    final gallinasVivas =
                        ponedoraActual.cantidadGallinas -
                        ponedoraActual.cantidadMuerto;
                    if (cantidadMuertas > gallinasVivas) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'No puede haber más muertas ($cantidadMuertas) que gallinas vivas ($gallinasVivas)',
                          ),
                        ),
                      );
                      return;
                    }

                    try {
                      // Actualizar la ponedora con la nueva mortalidad
                      final nuevaPonedora = ponedoraActual.copyWith(
                        cantidadMuerto:
                            ponedoraActual.cantidadMuerto + cantidadMuertas,
                      );

                      await PonederasService.actualizarPonedora(nuevaPonedora);

                      onMortalidadRegistrada();
                      Navigator.pop(ctx);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '$cantidadMuertas gallinas muertas registradas',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('Error: $e')));
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Ingrese la cantidad de gallinas muertas',
                        ),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text(
                  'Registrar',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }
}
