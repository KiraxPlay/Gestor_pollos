// views/ponedoras/huevos_grafica.dart
import 'package:flutter/material.dart';
import '../../models/ponedoras/registrohuevos.dart';

class HuevosGrafica extends StatelessWidget {
  final List<RegistroHuevos> registros;
  final String fechaInicio;

  const HuevosGrafica({
    super.key,
    required this.registros,
    required this.fechaInicio,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gráfica de Producción de Huevos')),
      body: const Center(
        child: Text('Gráfica de producción de huevos - Por implementar'),
      ),
    );
  }
}