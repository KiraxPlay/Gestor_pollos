import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
    // Ordenar registros por fecha
    final registrosOrdenados = List<RegistroHuevos>.from(registros)
      ..sort((a, b) => a.fecha.compareTo(b.fecha));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gráfica de Producción de Huevos'),
        backgroundColor: Colors.orange.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildResumen(),
            const SizedBox(height: 20),
            Expanded(
              child: _buildGraficaBarras(registrosOrdenados),
            ),
            _buildEstadisticas(registrosOrdenados),
          ],
        ),
      ),
    );
  }

  Widget _buildResumen() {
    final totalHuevos = registros.fold(0, (sum, registro) => sum + registro.cantidadHuevos);
    final promedio = registros.isEmpty ? 0 : totalHuevos / registros.length;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildMetrica('Total', '$totalHuevos', Icons.egg),
            _buildMetrica('Promedio', '${promedio.round()}/día', Icons.trending_up),
            _buildMetrica('Días', '${registros.length}', Icons.calendar_today),
          ],
        ),
      ),
    );
  }

  Widget _buildMetrica(String titulo, String valor, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.orange.shade700, size: 30),
        const SizedBox(height: 8),
        Text(titulo, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(valor, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildGraficaBarras(List<RegistroHuevos> registros) {
    if (registros.isEmpty) {
      return const Center(
        child: Text('No hay datos para mostrar', style: TextStyle(fontSize: 16)),
      );
    }

    final maxHuevos = registros.map((r) => r.cantidadHuevos).reduce((a, b) => a > b ? a : b);
    
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Producción Diaria de Huevos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: registros.length,
                itemBuilder: (context, index) {
                  final registro = registros[index];
                  final altura = (registro.cantidadHuevos / maxHuevos) * 150;
                  
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          registro.cantidadHuevos.toString(),
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: 30,
                          height: altura,
                          decoration: BoxDecoration(
                            color: _getColorPorCantidad(registro.cantidadHuevos, maxHuevos),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: 60,
                          child: Text(
                            DateFormat('dd/MM').format(DateTime.parse(registro.fecha)),
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 10),
                            maxLines: 2,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getColorPorCantidad(int cantidad, int max) {
    final porcentaje = cantidad / max;
    if (porcentaje > 0.7) return Colors.green.shade400;
    if (porcentaje > 0.4) return Colors.orange.shade400;
    return Colors.red.shade400;
  }

  Widget _buildEstadisticas(List<RegistroHuevos> registros) {
    if (registros.isEmpty) return const SizedBox();

    final cantidades = registros.map((r) => r.cantidadHuevos).toList();
    final maxHuevos = cantidades.reduce((a, b) => a > b ? a : b);
    final minHuevos = cantidades.reduce((a, b) => a < b ? a : b);
    final promedio = cantidades.reduce((a, b) => a + b) / cantidades.length;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Estadísticas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildEstadisticaItem('Máximo', '$maxHuevos', Icons.arrow_upward, Colors.green),
                _buildEstadisticaItem('Mínimo', '$minHuevos', Icons.arrow_downward, Colors.red),
                _buildEstadisticaItem('Promedio', '${promedio.round()}', Icons.bar_chart, Colors.blue),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEstadisticaItem(String titulo, String valor, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(titulo, style: const TextStyle(fontSize: 12)),
        Text(valor, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }
}