import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/registropesos.dart';

class PesoGrafica extends StatelessWidget {
  final List<RegistroPeso> registros;
  final String fechaInicio;
  final double Function(DateTime fecha) pesoTeorico;

  const PesoGrafica({
    Key? key, 
    required this.registros,
    required this.fechaInicio,
    required this.pesoTeorico,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final registrosOrdenados = [...registros]..sort((a, b) => a.fecha.compareTo(b.fecha));

    // Calcular máximo entre peso real y teórico
    double maxY = 0;
    for (var registro in registrosOrdenados) {
      final pesoReal = registro.pesoPromedio;
      final pesoTeorico = this.pesoTeorico(DateTime.parse(registro.fecha));
      maxY = [maxY, pesoReal, pesoTeorico].reduce((curr, next) => curr > next ? curr : next);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gráfica de Peso', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Evolución del Peso',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Container(
              height: 400,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    horizontalInterval: 0.5,
                    verticalInterval: 1,
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 && value.toInt() < registrosOrdenados.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                DateFormat('dd/MM').format(DateTime.parse(registrosOrdenados[value.toInt()].fecha)),
                                style: const TextStyle(fontSize: 12),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 0.5,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toStringAsFixed(1)} kg',
                            style: const TextStyle(fontSize: 12),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  minX: 0,
                  maxX: registrosOrdenados.length.toDouble() - 1,
                  minY: 0,
                  maxY: maxY + 0.5,
                  lineBarsData: [
                    // Línea de peso real
                    LineChartBarData(
                      spots: List.generate(
                        registrosOrdenados.length,
                        (index) => FlSpot(
                          index.toDouble(),
                          registrosOrdenados[index].pesoPromedio,
                        ),
                      ),
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.blue.withOpacity(0.2),
                      ),
                    ),
                    // Línea de peso teórico
                    LineChartBarData(
                      spots: List.generate(
                        registrosOrdenados.length,
                        (index) => FlSpot(
                          index.toDouble(),
                          pesoTeorico(DateTime.parse(registrosOrdenados[index].fecha)),
                        ),
                      ),
                      isCurved: true,
                      color: Colors.orange,
                      barWidth: 2,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: false),
                      dashArray: [5, 5],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Información:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text('Peso real (kg)'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        width: 24,
                        height: 2,
                        decoration: const BoxDecoration(color: Colors.orange),
                      ),
                      const SizedBox(width: 8),
                      const Text('Peso teórico (kg)'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Último peso real: ${registrosOrdenados.last.pesoPromedio.toStringAsFixed(3)} kg',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  Text(
                    'Último peso teórico: ${pesoTeorico(DateTime.parse(registrosOrdenados.last.fecha)).toStringAsFixed(3)} kg',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  Text(
                    'Fecha: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(registrosOrdenados.last.fecha))}',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Diferencia con el teórico: ${(registrosOrdenados.last.pesoPromedio - pesoTeorico(DateTime.parse(registrosOrdenados.last.fecha))).toStringAsFixed(3)} kg',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}