import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/registro_peso.dart';
import '../services/registropeso_service.dart';

class PesoGrafica extends StatefulWidget {
  final List<RegistroPeso> registros;
  final String fechaInicio;
  final double Function(DateTime fecha) pesoTeorico;
  final int loteId;

  const PesoGrafica({
    Key? key, 
    required this.registros,
    required this.fechaInicio,
    required this.pesoTeorico,
    this.loteId = 0,
  }) : super(key: key);

  @override
  State<PesoGrafica> createState() => _PesoGraficaState();
}

class _PesoGraficaState extends State<PesoGrafica> {
  late List<RegistroPeso> registrosActualizados;

  @override
  void initState() {
    super.initState();
    registrosActualizados = widget.registros;
    _cargarRegistros();
  }

  Future<void> _cargarRegistros() async {
    if (widget.loteId > 0) {
      final registros = await RegistroPesoService.obtenerPesos(widget.loteId);
      if (mounted) {
        setState(() {
          registrosActualizados = registros;
        });
      }
    }
  }

  // Obtener fechas únicas ordenadas
  List<String> _obtenerFechasUnicas(List<RegistroPeso> registros) {
    final fechasSet = <String>{};
    for (var registro in registros) {
      fechasSet.add(registro.fecha);
    }
    final fechas = fechasSet.toList();
    fechas.sort();
    return fechas;
  }

  // Agrupar registros por fecha para calcular promedios
  Map<String, List<RegistroPeso>> _agruparPorFecha(List<RegistroPeso> registros) {
    final agrupados = <String, List<RegistroPeso>>{};
    for (var registro in registros) {
      if (!agrupados.containsKey(registro.fecha)) {
        agrupados[registro.fecha] = [];
      }
      agrupados[registro.fecha]!.add(registro);
    }
    return agrupados;
  }

  @override
  Widget build(BuildContext context) {
    // Usar registros actualizados
    final registros = registrosActualizados.isNotEmpty ? registrosActualizados : widget.registros;
    
    // 🆕 VALIDAR SI NO HAY REGISTROS
    if (registros.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Gráfica de Peso', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.blue.shade700,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.show_chart, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'No hay registros de peso',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              SizedBox(height: 8),
              Text(
                'Agrega registros de peso para ver la gráfica',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    // Obtener fechas únicas y agrupar registros por fecha
    final fechasUnicas = _obtenerFechasUnicas(registros);
    final registrosPorFecha = _agruparPorFecha(registros);
    
    // Crear lista ordenada de registros con pesos promediados por día
    final registrosPromediados = fechasUnicas.map((fecha) {
      final registrosDia = registrosPorFecha[fecha]!;
      final pesoPromedio = registrosDia.fold<double>(0, (sum, r) => sum + r.pesoPromedio) / registrosDia.length;
      final primero = registrosDia.first;
      return RegistroPeso(
        id: primero.id,
        lotesId: primero.lotesId,
        fecha: fecha,
        pesoPromedio: pesoPromedio,
      );
    }).toList();

    // Calcular máximo entre peso real y teórico de forma más robusta
    double maxY = 0;
    if (registrosPromediados.isNotEmpty) {
      for (var registro in registrosPromediados) {
        final pesoReal = registro.pesoPromedio;
        final fechaRegistro = DateTime.parse(registro.fecha);
        final pesoTeoricoValor = widget.pesoTeorico(fechaRegistro);
        maxY = [maxY, pesoReal, pesoTeoricoValor].reduce((curr, next) => curr > next ? curr : next);
      }
      maxY = (maxY * 1.1).ceilToDouble(); // Agregar 10% de margen
    }

    // Calcular estadísticas completas
    final pesos = registrosPromediados.map((r) => r.pesoPromedio).toList();
    final ultimoPesoReal = registrosPromediados.last.pesoPromedio;
    final primerPesoReal = registrosPromediados.first.pesoPromedio;
    final pesoMax = pesos.reduce((a, b) => a > b ? a : b);
    final pesoMin = pesos.reduce((a, b) => a < b ? a : b);
    final pesoPromedio = pesos.fold<double>(0, (sum, p) => sum + p) / pesos.length;
    
    // Ganancia total y velocidad de crecimiento
    final gananciaTotalPeso = ultimoPesoReal - primerPesoReal;
    final diasTranscurridos = registrosPromediados.length;
    final velocidadCrecimiento = diasTranscurridos > 1 ? gananciaTotalPeso / diasTranscurridos : 0;
    
    // Últimas estadísticas teóricas
    final ultimoPesoTeorico = widget.pesoTeorico(DateTime.parse(registrosPromediados.last.fecha));
    final primerPesoTeorico = widget.pesoTeorico(DateTime.parse(registrosPromediados.first.fecha));
    final diferencia = ultimoPesoReal - ultimoPesoTeorico;
    final porcentajeDiferencia = ultimoPesoTeorico > 0 ? (diferencia / ultimoPesoTeorico * 100) : 0;
    
    // Desviaciones mejores y peores
    double mejorDesviacion = double.negativeInfinity;
    double peorDesviacion = double.infinity;
    for (var registro in registrosPromediados) {
      final fechaReg = DateTime.parse(registro.fecha);
      final pesoTeoVal = widget.pesoTeorico(fechaReg);
      final desv = ((registro.pesoPromedio - pesoTeoVal) / pesoTeoVal * 100);
      if (desv > mejorDesviacion) mejorDesviacion = desv;
      if (desv < peorDesviacion) peorDesviacion = desv;
    }
    
    // Eficiencia de engorde
    final eficienciaEngorde = ultimoPesoTeorico > 0 ? (ultimoPesoReal / ultimoPesoTeorico) * 100 : 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gráfica de Peso', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue.shade700,
        elevation: 0,
      ),
      body: SingleChildScrollView( // ← CAMBIO PRINCIPAL: Usar SingleChildScrollView
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Título
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: const Text(
                'Evolución del Peso del Lote',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            
            // Gráfica 
            Container(
              height: 400, // ← ALTURA FIJA en lugar de Expanded
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    horizontalInterval: maxY > 5 ? 1 : 0.5,
                    verticalInterval: registrosPromediados.length > 10 ? (registrosPromediados.length / 5).ceilToDouble() : 1,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey.shade300,
                        strokeWidth: 1,
                      );
                    },
                    getDrawingVerticalLine: (value) {
                      return FlLine(
                        color: Colors.grey.shade300,
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: registrosPromediados.length > 10 ? (registrosPromediados.length / 5).ceilToDouble() : 1,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 && value.toInt() < registrosPromediados.length) {
                            final fecha = DateTime.parse(registrosPromediados[value.toInt()].fecha);
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                DateFormat('dd/MM').format(fecha),
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
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
                        interval: maxY > 5 ? 1 : 0.5,
                        reservedSize: 45,
                        getTitlesWidget: (value, meta) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Text(
                              '${value.toStringAsFixed(value == value.roundToDouble() ? 0 : 1)} kg',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(
                      color: Colors.grey.shade400,
                      width: 1,
                    ),
                  ),
                  minX: 0,
                  maxX: registrosPromediados.length > 1 ? registrosPromediados.length.toDouble() - 1 : 1,
                  minY: 0,
                  maxY: maxY,
                  lineBarsData: [
                    // Línea de peso real
                    LineChartBarData(
                      spots: List.generate(
                        registrosPromediados.length,
                        (index) => FlSpot(
                          index.toDouble(),
                          registrosPromediados[index].pesoPromedio,
                        ),
                      ),
                      isCurved: true,
                      color: Colors.blue.shade700,
                      barWidth: 4,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: Colors.blue.shade700,
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.blue.shade700.withOpacity(0.3),
                            Colors.blue.shade100.withOpacity(0.1),
                          ],
                        ),
                      ),
                      gradient: LinearGradient(
                        colors: [
                          Colors.blue.shade700,
                          Colors.blue.shade400,
                        ],
                      ),
                    ),
                    // Línea de peso teórico
                    LineChartBarData(
                      spots: List.generate(
                        registrosPromediados.length,
                        (index) => FlSpot(
                          index.toDouble(),
                          widget.pesoTeorico(DateTime.parse(registrosPromediados[index].fecha)),
                        ),
                      ),
                      isCurved: true,
                      color: Colors.orange.shade600,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      dashArray: [5, 5],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Información y estadísticas - QUITAR Expanded
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Leyenda
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLeyendaItem(Colors.blue.shade700, 'Peso Real'),
                      const SizedBox(width: 20),
                      _buildLeyendaItem(Colors.orange.shade600, 'Peso Teórico'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Línea divisoria
                  Divider(color: Colors.grey.shade300, height: 1),
                  const SizedBox(height: 16),
                  
                  // Estadísticas
                  _buildStatItem(
                    'Último peso real:', 
                    '${ultimoPesoReal.toStringAsFixed(2)} kg',
                    Icons.scale,
                    Colors.blue.shade700,
                  ),
                  _buildStatItem(
                    'Primer peso real:', 
                    '${primerPesoReal.toStringAsFixed(2)} kg',
                    Icons.trending_up,
                    Colors.blue.shade400,
                  ),
                  _buildStatItem(
                    'Ganancia de peso:', 
                    '${gananciaTotalPeso.toStringAsFixed(2)} kg',
                    Icons.trending_up,
                    gananciaTotalPeso >= 0 ? Colors.green.shade600 : Colors.red.shade600,
                  ),
                  _buildStatItem(
                    'Velocidad de crecimiento:', 
                    '${velocidadCrecimiento.toStringAsFixed(3)} kg/día',
                    Icons.speed,
                    Colors.blue.shade600,
                  ),
                  _buildStatItem(
                    'Peso mínimo:', 
                    '${pesoMin.toStringAsFixed(2)} kg',
                    Icons.arrow_downward,
                    Colors.orange.shade600,
                  ),
                  _buildStatItem(
                    'Peso máximo:', 
                    '${pesoMax.toStringAsFixed(2)} kg',
                    Icons.arrow_upward,
                    Colors.green.shade600,
                  ),
                  _buildStatItem(
                    'Peso promedio:', 
                    '${pesoPromedio.toStringAsFixed(2)} kg',
                    Icons.bar_chart,
                    Colors.blue.shade600,
                  ),
                  _buildStatItem(
                    'Último peso teórico:', 
                    '${ultimoPesoTeorico.toStringAsFixed(2)} kg',
                    Icons.timeline,
                    Colors.orange.shade600,
                  ),
                  _buildStatItem(
                    'Diferencia (actual):', 
                    '${diferencia.toStringAsFixed(2)} kg',
                    Icons.compare_arrows,
                    diferencia >= 0 ? Colors.green.shade600 : Colors.red.shade600,
                  ),
                  _buildStatItem(
                    'Desviación actual:', 
                    '${porcentajeDiferencia.toStringAsFixed(1)}%',
                    Icons.percent,
                    porcentajeDiferencia.abs() > 10 ? Colors.red.shade600 : Colors.green.shade600,
                  ),
                  _buildStatItem(
                    'Mejor desviación:', 
                    '${mejorDesviacion.toStringAsFixed(1)}%',
                    Icons.trending_up,
                    Colors.green.shade600,
                  ),
                  _buildStatItem(
                    'Peor desviación:', 
                    '${peorDesviacion.toStringAsFixed(1)}%',
                    Icons.trending_down,
                    Colors.red.shade600,
                  ),
                  _buildStatItem(
                    'Eficiencia de engorde:', 
                    '${eficienciaEngorde.toStringAsFixed(1)}%',
                    Icons.check_circle,
                    eficienciaEngorde >= 100 ? Colors.green.shade600 : Colors.orange.shade600,
                  ),
                  _buildStatItem(
                    'Días de registro:', 
                    '$diasTranscurridos días',
                    Icons.calendar_today,
                    Colors.grey.shade700,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20), // ← ESPACIO EXTRA PARA SCROLL
          ],
        ),
      ),
    );
  }

  // Método para construir items de leyenda
  Widget _buildLeyendaItem(Color color, String texto) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          texto, 
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // Método para construir items de estadísticas
  Widget _buildStatItem(String titulo, String valor, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              titulo,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Text(
            valor,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}