// layouts/components/ponedoras/nuevo_insumo_ponedoras.dart
import 'package:flutter/material.dart';
import 'package:gestorgalpon_app/views/ponedoras/insumos_ponedoras.dart';
import 'package:intl/intl.dart';
import '../../../models/ponedoras/ponedoras.dart';
import '../../../services/ponedoras/insumos_ponedoras_service.dart';

Future<void> mostrarDialogoInsumoPonedoras({
  required BuildContext context,
  required Ponedoras ponedoraActual,
  required Function onInsumoRegistrado,
}) async {
  final nombreCtrl = TextEditingController();
  final cantidadCtrl = TextEditingController();
  final unidadCtrl = TextEditingController();
  final precioCtrl = TextEditingController();
  
  String tipoSeleccionado = 'Alimento';
  DateTime fechaSeleccionada = DateTime.now();
  
  final List<String> tiposInsumo = [
    'Alimento',
    'Medicamento', 
    'Vacuna',
    'Vitamina',
    'Desinfectante',
    'Otro'
  ];

  await showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          backgroundColor: Colors.green.shade50,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Column(
            children: [
              const Icon(Icons.medical_services, size: 48, color: Colors.green),
              const SizedBox(height: 8),
              const Text(
                'Agregar Insumo',
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
                TextField(
                  controller: nombreCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del insumo',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.medical_services),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: cantidadCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Cantidad',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.numbers),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: unidadCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Unidad',
                          border: OutlineInputBorder(),
                          hintText: 'kg, ml, etc.',
                          prefixIcon: Icon(Icons.scale),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: precioCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Precio',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: tipoSeleccionado,
                  decoration: const InputDecoration(
                    labelText: 'Tipo de insumo',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.category),
                  ),
                  items: tiposInsumo.map((String tipo) {
                    return DropdownMenuItem<String>(
                      value: tipo,
                      child: Text(tipo),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        tipoSeleccionado = newValue;
                      });
                    }
                  },
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: fechaSeleccionada,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: ColorScheme.light(
                              primary: Colors.green.shade700,
                              onPrimary: Colors.white,
                              surface: Colors.green.shade50,
                            ),
                            dialogBackgroundColor: Colors.green.shade50,
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (date != null) {
                      setState(() {
                        fechaSeleccionada = date;
                      });
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
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
                backgroundColor: Colors.red.shade50,
              ),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Validaciones
                if (nombreCtrl.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Ingrese el nombre del insumo')),
                  );
                  return;
                }

                if (cantidadCtrl.text.isEmpty || int.tryParse(cantidadCtrl.text) == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Ingrese una cantidad válida')),
                  );
                  return;
                }

                if (unidadCtrl.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Ingrese la unidad')),
                  );
                  return;
                }

                if (precioCtrl.text.isEmpty || double.tryParse(precioCtrl.text) == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Ingrese un precio válido')),
                  );
                  return;
                }

                try {
                  await InsumosPonedorasService.agregarInsumo(
                    InsumoPonedora(
                      lotesId: ponedoraActual.id!,
                      nombre: nombreCtrl.text,
                      cantidad: int.parse(cantidadCtrl.text),
                      unidad: unidadCtrl.text,
                      precio: double.parse(precioCtrl.text),
                      tipo: tipoSeleccionado,
                      fecha: DateFormat('yyyy-MM-dd').format(fechaSeleccionada),
                    ),
                  );
                  
                  onInsumoRegistrado();
                  Navigator.pop(ctx);
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Insumo "${nombreCtrl.text}" agregado exitosamente',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      backgroundColor: Colors.green,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error al agregar insumo: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                foregroundColor: Colors.white,
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text('Guardar Insumo'),
              ),
            ),
          ],
        );
      },
    ),
  );
}