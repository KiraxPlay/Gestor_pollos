import 'package:flutter/material.dart';
import '../../../models/ponedoras/ponedoras.dart';

class AgregarPonederasDialog extends StatefulWidget {
  final Function(Ponedoras) onAgregar;

  const AgregarPonederasDialog({super.key, required this.onAgregar});

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
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Agregar Ponedora'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nombreCtrl,
                decoration: const InputDecoration(labelText: 'Nombre del lote'),
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _cantidadCtrl,
                decoration: const InputDecoration(labelText: 'Cantidad de gallinas'),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _precioCtrl,
                decoration: const InputDecoration(labelText: 'Precio unitario'),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _fechaInicio,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    setState(() => _fechaInicio = date);
                  }
                },
                child: Text('Fecha: ${_fechaInicio.toLocal()}'.split(' ')[0]),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              widget.onAgregar(
                Ponedoras(
                  nombre: _nombreCtrl.text,
                  cantidadGallinas: int.parse(_cantidadCtrl.text),
                  precioUnitario: double.parse(_precioCtrl.text),
                  fechaInicio: _fechaInicio.toString().split(' ')[0],
                ),
              );
              Navigator.pop(context);
            }
          },
          child: const Text('Agregar'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _cantidadCtrl.dispose();
    _precioCtrl.dispose();
    super.dispose();
  }
}