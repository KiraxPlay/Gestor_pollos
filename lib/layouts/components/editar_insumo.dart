import 'package:flutter/material.dart';
import '../../models/insumos.dart';
import '../../models/tipo_insumo.dart';
import '../../services/insumo_service.dart';

Future<void> mostrarDialogoEditarInsumo({
  required BuildContext context,
  required Insumos insumo,
  required Function onInsumoActualizado,
}) async {
  final nombreController = TextEditingController(text: insumo.nombre);
  final cantidadController = TextEditingController(
    text: insumo.cantidad.toString(),
  );
  final precioController = TextEditingController(
    text: insumo.precio.toString(),
  );

  TipoInsumo tipoSeleccionado = insumo.tipo;
  String unidadSeleccionada = insumo.unidad;

  if (!getUnidadesPorTipo(tipoSeleccionado).contains(unidadSeleccionada)) {
    unidadSeleccionada = getUnidadesPorTipo(tipoSeleccionado).first;
  }

  await showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: Colors.yellow.shade100,
        title: Row(
          children: const [
            Icon(Icons.edit, color: Colors.blue),
            SizedBox(width: 8),
            Text('Editar Insumo'),
          ],
        ),
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
                    child: Text(tipoInsumoToString(tipo)),
                  );
                }).toList(),
                onChanged: (TipoInsumo? newValue) {
                  if (newValue != null) {
                    setState(() {
                      tipoSeleccionado = newValue;
                      unidadSeleccionada = getUnidadesPorTipo(newValue).first;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: unidadSeleccionada,
                decoration: const InputDecoration(
                  labelText: 'Unidad',
                  border: OutlineInputBorder(),
                ),
                items: getUnidadesPorTipo(tipoSeleccionado).map((String unidad) {
                  return DropdownMenuItem(
                    value: unidad,
                    child: Text(unidad),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      unidadSeleccionada = newValue;
                    });
                  }
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
            style: TextButton.styleFrom(
              backgroundColor: Colors.grey.shade200,
            ),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final cantidad = int.tryParse(cantidadController.text);
                final precio = double.tryParse(precioController.text);

                if (nombreController.text.isEmpty || cantidad == null || precio == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Por favor complete todos los campos correctamente'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }

                final insumoActualizado = Insumos(
                  id: insumo.id,
                  nombre: nombreController.text,
                  tipo: tipoSeleccionado,
                  unidad: unidadSeleccionada,
                  cantidad: cantidad,
                  precio: precio,
                  lotesId: insumo.lotesId,
                  fecha: insumo.fecha,
                );

                await InsumosService.actualizarInsumo(insumoActualizado);
                
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.white),
                          SizedBox(width: 8),
                          Text('Insumo actualizado correctamente'),
                        ],
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
                
                onInsumoActualizado();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error al actualizar insumo: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Actualizar'),
          ),
        ],
      ),
    ),
  );
}