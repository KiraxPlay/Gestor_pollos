import 'package:flutter/material.dart';
import '../../../models/ponedoras/ponedoras.dart';

class AgregarPonederasDialog extends StatefulWidget {
  final Function(Ponedoras) onAgregar;
  final int cantidadLotesExistentes; // ← AGREGAR ESTE PARÁMETRO

  const AgregarPonederasDialog({
    super.key, 
    required this.onAgregar,
    required this.cantidadLotesExistentes, // ← RECIBIR LA CANTIDAD
  });

  @override
  State<AgregarPonederasDialog> createState() => _AgregarPonederasDialogState();
}

class _AgregarPonederasDialogState extends State<AgregarPonederasDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _cantidadCtrl = TextEditingController();
  final _precioCtrl = TextEditingController();
  DateTime _fechaInicio = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Estableciendo el nombre automaticamente de ponedoras
    _nombreCtrl.text = 'Ponedoras ${widget.cantidadLotesExistentes + 1}';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.egg, color: Colors.orange),
          SizedBox(width: 8),
          Text('Agregar Ponedoras'),
        ],
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              //  CAMPO DE NOMBRE AUTOMÁTICO PERO EDITABLE
              TextFormField(
                controller: _nombreCtrl,
                decoration: const InputDecoration(
                  labelText: 'Ponedoras',
                  prefixIcon: Icon(Icons.badge),
                ),
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _cantidadCtrl,
                decoration: const InputDecoration(
                  labelText: 'Cantidad de gallinas',
                  prefixIcon: Icon(Icons.agriculture),
                ),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v!.isEmpty) return 'Requerido';
                  if (int.tryParse(v) == null) return 'Número inválido';
                  if (int.parse(v) <= 0) return 'Debe ser mayor a 0';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _precioCtrl,
                decoration: const InputDecoration(
                  labelText: 'Precio unitario (\$)',
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  if (v!.isEmpty) return 'Requerido';
                  if (double.tryParse(v) == null) return 'Número inválido';
                  if (double.parse(v) <= 0) return 'Debe ser mayor a 0';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // 🗓️ SELECTOR DE FECHA MEJORADO
              InkWell(
                onTap: _seleccionarFecha,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Fecha de inicio',
                    prefixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_fechaInicio.day}/${_fechaInicio.month}/${_fechaInicio.year}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const Icon(Icons.arrow_drop_down, color: Colors.grey),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              //  INFORMACIÓN ADICIONAL
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.orange.shade700, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'El nombre se genera automáticamente, pero puedes cambiarlo',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(
            foregroundColor: Colors.grey.shade700,
          ),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _agregarPonedora,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange.shade600,
            foregroundColor: Colors.white,
          ),
          child: const Text('Agregar Lote'),
        ),
      ],
    );
  }

  Future<void> _seleccionarFecha() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _fechaInicio,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() => _fechaInicio = date);
    }
  }

  void _agregarPonedora() {
    if (_formKey.currentState!.validate()) {
      final nuevaPonedora = Ponedoras(
        id: 0, // ← AGREGAR ID TEMPORAL
        nombre: _nombreCtrl.text.trim(),
        cantidadGallinas: int.parse(_cantidadCtrl.text),
        precioUnitario: double.parse(_precioCtrl.text),
        fechaInicio: _fechaInicio.toIso8601String().split('T')[0],
        cantidadMuerto: 0, // ← VALOR POR DEFECTO
        estado: 0, // ← VALOR POR DEFECTO
        edadSemanas: 0, // ← VALOR POR DEFECTO
      );

      widget.onAgregar(nuevaPonedora);
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _cantidadCtrl.dispose();
    _precioCtrl.dispose();
    super.dispose();
  }
}