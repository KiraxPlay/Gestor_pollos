import 'package:flutter/material.dart';
import 'package:gestorgalpon_app/models/lotes.dart';
import 'package:gestorgalpon_app/models/registropesos.dart';
import 'package:gestorgalpon_app/services/registropeso_service.dart';
import 'package:intl/intl.dart';

 Future<void> mostrarDialogoRegistroPeso({
  required BuildContext context,
  required Lotes loteActual,
  required List<RegistroPeso> registrosPeso,
  required Function onPesoRegistrado,
  required Function(DateTime) calcularPesoTeorico,
}) async {
  final fechaController = TextEditingController(
    text: DateTime.now().toIso8601String().substring(0, 10),
  );
  final pesoController = TextEditingController();

  // Verificar si ya existe un registro para hoy
  final fechaHoy = DateTime.now().toIso8601String().substring(0, 10);
  final existeRegistroHoy = registrosPeso.any(
    (registro) => registro.fecha == fechaHoy,
  );

  if (existeRegistroHoy) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Ya existe un registro de peso para el día de hoy'),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  final ultimoRegistro = registrosPeso.isNotEmpty
      ? registrosPeso.reduce((a, b) => 
          DateTime.parse(a.fecha).isAfter(DateTime.parse(b.fecha)) ? a : b)
      : null;

  // Calcular peso teórico
  final fechaInicio = DateTime.parse(loteActual.fechaInicio);
  final pesoTeorico = calcularPesoTeorico(fechaInicio);

  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      backgroundColor: Colors.blue.shade50,
      title: Column(
        children: [
          Icon(Icons.monitor_weight, color: Colors.blue, size: 48),
          SizedBox(height: 8),
          Text(
            'Registrar Peso',
            style: TextStyle(
              color: Colors.blue.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (ultimoRegistro != null) ...[
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                children: [
                  Text(
                    'Último peso registrado:',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue.shade800,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '${ultimoRegistro.pesoPromedio} kg',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade900,
                    ),
                  ),
                  Text(
                    'Fecha: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(ultimoRegistro.fecha))}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue.shade800,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
          ],
          Text(
            'Peso teórico esperado:',
            style: TextStyle(fontSize: 16, color: Colors.blue.shade800),
          ),
          Text(
            '${pesoTeorico.toStringAsFixed(3)} kg',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade900,
            ),
          ),
          SizedBox(height: 16),
          TextField(
            controller: pesoController,
            decoration: InputDecoration(
              labelText: 'Nuevo peso (kg)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: Icon(Icons.scale, color: Colors.blue),
              filled: true,
              fillColor: Colors.white,
            ),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
          ),
          SizedBox(height: 8),
          Text(
            'Fecha: ${DateFormat('dd/MM/yyyy').format(DateTime.now())}',
            style: TextStyle(
              color: Colors.grey.shade600,
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
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Cancelar',
              style: TextStyle(
                color: Colors.grey.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () async {
            final peso = double.tryParse(pesoController.text);
            if (peso == null || peso <= 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Por favor ingrese un peso válido'),
                  backgroundColor: Colors.orange,
                ),
              );
              return;
            }

            try {
              final nuevo = RegistroPeso(
                lotesId: loteActual.id!,
                fecha: fechaController.text,
                pesoPromedio: peso,
                id: 0,
              );

              await RegistroPesoService.insertarPeso(nuevo);

              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.white),
                        SizedBox(width: 8),
                        Text('Peso registrado correctamente'),
                      ],
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
                onPesoRegistrado();
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.white),
                        SizedBox(width: 8),
                        Text('Error al registrar peso: $e'),
                      ],
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Guardar',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    ),
  );
}