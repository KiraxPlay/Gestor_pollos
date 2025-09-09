import 'package:flutter/material.dart';
import 'package:gestorgalpon_app/models/insumos.dart';
import 'package:gestorgalpon_app/models/lotes.dart';
import 'package:gestorgalpon_app/models/tipo_insumo.dart';
import 'package:gestorgalpon_app/services/insumo_service.dart';
import 'package:gestorgalpon_app/services/lote_service.dart';


Future<void> mostrarDialogoInsumo({
  required BuildContext context,
  required Lotes loteActual,
  required Function onInsumoRegistrado,
}) async {
  final nombreController = TextEditingController();
  final cantidadController = TextEditingController();
  final precioController = TextEditingController();

  TipoInsumo tipoSeleccionado = TipoInsumo.alimento;
  String unidadSeleccionada = getUnidadesPorTipo(TipoInsumo.alimento).first;

  final Map<TipoInsumo, List<String>> unidadesPorTipo = {
    TipoInsumo.alimento: ['kg', 'bulto', 'gramos'],
    TipoInsumo.medicamento: ['ml', 'cc', 'dosis'],
    TipoInsumo.vacuna: ['dosis', 'frasco'],
    TipoInsumo.vitamina: ['ml', 'sobre', 'cc'],
    TipoInsumo.desinfectante: ['ml', 'litro'],
    TipoInsumo.otro: ['unidad', 'kg', 'litro', 'ml'],
  };

  await showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: Colors.yellow.shade100,
        title: const Text('Agregar Insumo'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<TipoInsumo>(
                value: tipoSeleccionado,
                decoration: const InputDecoration(
                  labelText: 'Tipo de Insumo',
                  border: OutlineInputBorder(),
                ),
                items: TipoInsumo.values.map((tipo) {
                  return DropdownMenuItem(
                    value: tipo,
                    child: Text(tipo.toString().split('.').last),
                  );
                }).toList(),
                onChanged: (TipoInsumo? newValue) {
                  setState(() {
                    tipoSeleccionado = newValue!;
                    unidadSeleccionada = unidadesPorTipo[tipoSeleccionado]!.first;
                  });
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: unidadSeleccionada,
                decoration: const InputDecoration(
                  labelText: 'Unidad',
                  border: OutlineInputBorder(),
                ),
                items: unidadesPorTipo[tipoSeleccionado]!.map((String unidad) {
                  return DropdownMenuItem(
                    value: unidad,
                    child: Text(unidad),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    unidadSeleccionada = newValue!;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: cantidadController,
                decoration: const InputDecoration(
                  labelText: 'Cantidad',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: precioController,
                decoration: const InputDecoration(
                  labelText: 'Precio',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              try {
                final cantidad = int.tryParse(cantidadController.text);
                final precio = double.tryParse(precioController.text);

                if (nombreController.text.isEmpty || cantidad == null || precio == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Por favor complete todos los campos correctamente'),
                    ),
                  );
                  return;
                }

                Navigator.pop(context);

                final nuevo = Insumos(
                  nombre: nombreController.text,
                  tipo: tipoSeleccionado,
                  unidad: unidadSeleccionada,
                  cantidad: cantidad,
                  precio: precio,
                  lotesId: loteActual.id!,
                  fecha: DateTime.now().toIso8601String().substring(0, 10),
                );

                await InsumosService.insertarInsumo(nuevo);
                
                if (loteActual.estado == 0) {
                  final loteActualizado = loteActual.copyWith(estado: 1);
                  await LoteService.actualizarLote(loteActualizado);
                }

                onInsumoRegistrado();

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: Colors.green,
                      content: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            'Insumo agregado correctamente',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error al agregar insumo: $e'),
                    ),
                  );
                }
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    ),
  );
}