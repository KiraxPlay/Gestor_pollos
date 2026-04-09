import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/ponedoras/ponedoras.dart';

class AgregarPonederasDialog extends StatefulWidget {
  final Function(Ponedoras) onAgregar;
  final int cantidadLotesExistentes;

  const AgregarPonederasDialog({
    super.key, 
    required this.onAgregar,
    required this.cantidadLotesExistentes,
  });

  @override
  State<AgregarPonederasDialog> createState() => _AgregarPonederasDialogState();
}

class _AgregarPonederasDialogState extends State<AgregarPonederasDialog> {
  final _cantidadCtrl = TextEditingController();
  final _precioCtrl = TextEditingController();
  String fechaInicio = '';

  @override
  void initState() {
    super.initState();
    fechaInicio = DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  @override
  void dispose() {
    _cantidadCtrl.dispose();
    _precioCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.orange.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Column(
        children: [
          Image.asset(
            'assets/images/saved.png',
            height: 80,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 8),
          const Text(
            'Agregar Nuevo Lote de Ponedoras',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                hintText: 'Ponedoras ${widget.cantidadLotesExistentes + 1}',
              ),
            ),
            const SizedBox(height: 12),
            _buildCantidadGallinasField(),
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
          style: TextButton.styleFrom(foregroundColor: Colors.red.shade600),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () => _guardarPonedora(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange.shade600,
            foregroundColor: Colors.white,
          ),
          child: const Text('Guardar'),
        ),
      ],
    );
  }

  Widget _buildCantidadGallinasField() {
    return TextField(
      controller: _cantidadCtrl,
      decoration: const InputDecoration(
        labelText: 'Cantidad de Gallinas',
        hintText: 'Ingrese la cantidad',
        prefixIcon: Icon(Icons.agriculture),
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
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
                  primary: Colors.orange.shade600,
                  onPrimary: Colors.white,
                  surface: Colors.orange.shade50,
                ),
                dialogBackgroundColor: Colors.orange.shade50,
              ),
              child: child!,
            );
          },
        );

        if (picked != null) {
          setState(() {
            fechaInicio = DateFormat('yyyy-MM-dd').format(picked);
          });
        }
      },
      child: AbsorbPointer(
        child: TextField(
          controller: TextEditingController(text: fechaInicio),
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
      controller: _precioCtrl,
      decoration: const InputDecoration(
        labelText: 'Precio Unitario',
        hintText: 'Ingrese el precio unitario',
        prefixIcon: Icon(Icons.attach_money),
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
    );
  }

  Widget _buildDisabledFields() {
    return Column(
      children: [
        const TextField(
          enabled: false,
          decoration: InputDecoration(
            labelText: 'Cantidad de Muertos',
            hintText: '0',
          ),
        ),
        const SizedBox(height: 12),
        const TextField(
          enabled: false,
          decoration: InputDecoration(
            labelText: 'Estado',
            hintText: 'Desactivado',
          ),
        ),
        const SizedBox(height: 12),
        // INFORMACIÓN ADICIONAL
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.yellow.shade100,
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
                  style: TextStyle(fontSize: 12, color: Colors.orange.shade800),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _guardarPonedora(BuildContext context) async {
    final cantidad = int.tryParse(_cantidadCtrl.text);
    final precio = double.tryParse(_precioCtrl.text);

    if (cantidad == null || cantidad <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingrese una cantidad válida de gallinas')),
      );
      return;
    }

    if (precio == null || precio <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingrese un precio válido')),
      );
      return;
    }

    try {
      final nuevaPonedora = Ponedoras(
        nombre: 'Ponedoras ${widget.cantidadLotesExistentes + 1}',
        cantidadGallinas: cantidad,
        precioUnitario: precio,
        fechaInicio: fechaInicio,
        cantidadMuerto: 0,
        estado: 0,
        edadSemanas: 0,
        muertosSemanales: 0,
      );

      print('🔘 [Dialog] Ejecutando callback onAgregar() con: ${nuevaPonedora.nombre}');
      widget.onAgregar(nuevaPonedora);
      print('✅ [Dialog] Callback completado');

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
                  'Lote de ponedoras creado exitosamente',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.orange.shade600,
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
