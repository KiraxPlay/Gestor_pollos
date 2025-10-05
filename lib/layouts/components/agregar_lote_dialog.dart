import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/lotes.dart';
import '../../viewmodels/lote_viewmodel.dart';
import 'package:provider/provider.dart';

class AgregarLoteDialog extends StatefulWidget {
  final LoteViewModel loteVM;

  const AgregarLoteDialog({
    Key? key,
    required this.loteVM,
  }) : super(key: key);

  @override
  State<AgregarLoteDialog> createState() => _AgregarLoteDialogState();
}

class _AgregarLoteDialogState extends State<AgregarLoteDialog> {
  String cantidadPollosStr = '';
  String precioUnitarioStr = '';
  final fechaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fechaController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  @override
  void dispose() {
    fechaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.yellow.shade100,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      title: Column(
        children: [
          Image.asset(
            'assets/images/saved.png',
            height: 80,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 8),
          const Text(
            'Agregar Nuevo Lote',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              enabled: false,
              decoration: InputDecoration(
                labelText: 'Nombre del Lote',
                hintText: 'Lote ${widget.loteVM.lotes.length + 1}',
              ),
            ),
            const SizedBox(height: 12),
            _buildCantidadPollosField(),
            const SizedBox(height: 12),
            _buildFechaField(),
            const SizedBox(height: 12),
            _buildPrecioUnitarioField(),
            const SizedBox(height: 12),
            _buildDisabledFields(),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(
            foregroundColor: Colors.red.shade600,
          ),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () => _guardarLote(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green.shade600,
            foregroundColor: Colors.white,
          ),
          child: const Text('Guardar'),
        ),
      ],
    );
  }

  Widget _buildCantidadPollosField() {
    return TextField(
      decoration: const InputDecoration(
        labelText: 'Cantidad de Pollos',
        hintText: 'Ingrese la cantidad',
        prefixIcon: Icon(Icons.numbers),
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
      onChanged: (value) => cantidadPollosStr = value,
    );
  }

  Widget _buildFechaField() {
    return InkWell(
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime.now().add(const Duration(days: 1)),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  primary: Colors.yellow.shade700,
                  onPrimary: Colors.white,
                  surface: Colors.yellow.shade50,
                ),
                dialogBackgroundColor: Colors.yellow.shade50,
              ),
              child: child!,
            );
          },
        );

        if (picked != null) {
          setState(() {
            fechaController.text = DateFormat('yyyy-MM-dd').format(picked);
          });
        }
      },
      child: AbsorbPointer(
        child: TextField(
          controller: fechaController,
          decoration: const InputDecoration(
            labelText: 'Fecha de Inicio',
            hintText: 'Seleccione la fecha',
            prefixIcon: Icon(Icons.calendar_today),
            border: OutlineInputBorder(),
            suffixIcon: Icon(Icons.arrow_drop_down),
          ),
        ),
      ),
    );
  }

  Widget _buildPrecioUnitarioField() {
    return TextField(
      decoration: const InputDecoration(
        labelText: 'Precio Unitario',
        hintText: 'Ingrese el precio unitario',
        prefixIcon: Icon(Icons.attach_money),
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
      onChanged: (value) => precioUnitarioStr = value,
    );
  }

  Widget _buildDisabledFields() {
    return Column(
      children: const [
        TextField(
          enabled: false,
          decoration: InputDecoration(
            labelText: 'Cantidad de Muertos',
            hintText: '0',
          ),
        ),
        SizedBox(height: 12),
        TextField(
          enabled: false,
          decoration: InputDecoration(
            labelText: 'Estado',
            hintText: 'Desactivado',
          ),
        ),
      ],
    );
  }

  Future<void> _guardarLote(BuildContext context) async {
    final cantidadPollos = int.tryParse(cantidadPollosStr);
    final precioUnitario = double.tryParse(precioUnitarioStr);

    if (cantidadPollos == null || cantidadPollos <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingrese una cantidad válida de pollos')),
      );
      return;
    }

    if (precioUnitario == null || precioUnitario <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingrese un precio válido')),
      );
      return;
    }

    try {
      await widget.loteVM.agregarLote(
        Lotes(
          nombre: 'Lote ${widget.loteVM.lotes.length + 1}',
          cantidadPollos: cantidadPollos,
          precioUnitario: precioUnitario,
          fechaInicio: fechaController.text,
          cantidadMuertos: 0,
        ),
      );

      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 2),
            content: Row(
              children: const [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  'Lote creado exitosamente',
                  style: TextStyle(
                    color: Colors.white,
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }
}