import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math';
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildResumen(),
            const SizedBox(height: 20),
            Container(
              height: 300,
              child: _buildGraficaBarras(registrosOrdenados),
            ),
            const SizedBox(height: 20),
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
    
    // Calcular desviación estándar
    final varianza = cantidades.fold<double>(0, (sum, val) => sum + pow((val - promedio), 2).toDouble()) / cantidades.length;
    final desviacionEstandar = sqrt(varianza);
    
    // Calcular mediana
    final cantidadesOrdenadas = List<int>.from(cantidades)..sort();
    final mediana = cantidadesOrdenadas.length.isOdd
        ? cantidadesOrdenadas[cantidadesOrdenadas.length ~/ 2].toDouble()
        : (cantidadesOrdenadas[cantidadesOrdenadas.length ~/ 2 - 1] + cantidadesOrdenadas[cantidadesOrdenadas.length ~/ 2]) / 2;
    
    // Últimos 7 días
    final ultimosDias = cantidades.length >= 7 ? cantidades.sublist(cantidades.length - 7) : cantidades;
    final promedioUltimos7 = ultimosDias.fold<int>(0, (sum, val) => sum + val) / ultimosDias.length;
    
    // Primer y último valor
    final primerHuevo = registros.first.cantidadHuevos;
    final ultimoHuevo = registros.last.cantidadHuevos;
    
    // Tasa de cambio
    final tasaCambio = registros.length > 1 ? (ultimoHuevo - primerHuevo).toDouble() / (registros.length - 1) : 0.0;
    
    // Eficiencia (promedio respecto al máximo)
    final eficiencia = (promedio / maxHuevos) * 100;
    
    // Total de huevos
    final totalHuevos = cantidades.fold<int>(0, (sum, val) => sum + val);
    
    // Tendencia (comparar últimos 7 con primeros 7)
    final primosDias = cantidades.length >= 7 ? cantidades.sublist(0, 7) : cantidades;
    final promedioPrimeros7 = primosDias.fold<int>(0, (sum, val) => sum + val) / primosDias.length;
    final tendencia = promedioUltimos7 - promedioPrimeros7;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Estadísticas Detalladas',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              
              // Fila 1: Producción básica
              _buildStatRow([
                _buildStatCol('Máximo', '$maxHuevos', Icons.arrow_upward, Colors.green),
                _buildStatCol('Mínimo', '$minHuevos', Icons.arrow_downward, Colors.red),
                _buildStatCol('Promedio', '${promedio.round()}', Icons.bar_chart, Colors.blue),
              ]),
              const SizedBox(height: 12),
              
              // Fila 2: Tendencias
              _buildStatRow([
                _buildStatCol('Mediana', '${mediana.round()}', Icons.straighten, Colors.purple),
                _buildStatCol('Desv. Est.', '${desviacionEstandar.toStringAsFixed(1)}', Icons.trending_down, Colors.orange),
                _buildStatCol('Total', '$totalHuevos', Icons.add, Colors.teal),
              ]),
              const SizedBox(height: 12),
              
              // Fila 3: Últimos días y tendencias
              _buildStatRow([
                _buildStatCol('Últimos 7 días', '${promedioUltimos7.round()}/día', Icons.calendar_today, Colors.indigo),
                _buildStatCol('Tasa de cambio', '${tasaCambio.toStringAsFixed(1)}/día', Icons.trending_up, 
                  tasaCambio >= 0 ? Colors.green.shade600 : Colors.red.shade600),
                _buildStatCol('Eficiencia', '${eficiencia.toStringAsFixed(1)}%', Icons.percent, Colors.amber),
              ]),
              const SizedBox(height: 12),
              
              // Fila 4: Detalles adicionales
              _buildStatRow([
                _buildStatCol('Primer día', '$primerHuevo', Icons.play_circle, Colors.blue.shade300),
                _buildStatCol('Último día', '$ultimoHuevo', Icons.stop_circle, Colors.red.shade300),
                _buildStatCol('Cambio total', '${ultimoHuevo - primerHuevo}', Icons.compare_arrows, 
                  (ultimoHuevo - primerHuevo) >= 0 ? Colors.green.shade600 : Colors.red.shade600),
              ]),
              const SizedBox(height: 12),
              
              // Fila 5: Tendencia general
              _buildStatRow([
                _buildStatCol('Tendencia 7d', '${tendencia.toStringAsFixed(1)}', Icons.trending_up_outlined,
                  tendencia >= 0 ? Colors.green.shade600 : Colors.red.shade600),
                _buildStatCol('Días registrados', '${registros.length}', Icons.history, Colors.grey.shade700),
                _buildStatCol('Coef. Variación', '${((desviacionEstandar / promedio * 100).isFinite ? (desviacionEstandar / promedio * 100).toStringAsFixed(1) : '0.0')}%', 
                  Icons.analytics, Colors.blue.shade600),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(List<Widget> items) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: items,
    );
  }

  Widget _buildStatCol(String titulo, String valor, IconData icon, Color color) {
    return Flexible(
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(titulo, style: const TextStyle(fontSize: 11, color: Colors.grey), textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Text(valor, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}