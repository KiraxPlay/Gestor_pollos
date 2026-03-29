import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:gestorgalpon_app/services/reporte_service.dart';
import 'package:gestorgalpon_app/views/reportes/widgets_reporte.dart';

class ReportePonedoraScreen extends StatefulWidget {
  final int loteId;
  final String nombreLote;

  const ReportePonedoraScreen({
    super.key,
    required this.loteId,
    required this.nombreLote,
  });

  @override
  State<ReportePonedoraScreen> createState() => _ReportePonedoraScreenState();
}

class _ReportePonedoraScreenState extends State<ReportePonedoraScreen> {
  Map<String, dynamic> _resumen   = {};
  List<dynamic>        _mortalidad = [];
  List<dynamic>        _huevos    = [];
  List<dynamic>        _insumos   = [];
  bool _cargando    = true;
  bool _exportando  = false;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() => _cargando = true);
    try {
      final results = await Future.wait([
        ReporteService.getResumenPonedora(widget.loteId),
        ReporteService.getMortalidad(widget.loteId),
        ReporteService.getHuevos(widget.loteId),
        ReporteService.getInsumosPonedora(widget.loteId),
      ]);
      setState(() {
        _resumen    = results[0] as Map<String, dynamic>;
        _mortalidad = results[1] as List;
        _huevos     = results[2] as List;
        _insumos    = results[3] as List;
        _cargando   = false;
      });
    } catch (e) {
      setState(() => _cargando = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error cargando reporte: $e')),
        );
      }
    }
  }

  Future<void> _exportar(String tipo) async {
    setState(() => _exportando = true);
    try {
      final file = await ReporteService.descargarArchivo(widget.loteId, tipo);
      await OpenFilex.open(file.path);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error exportando: $e')),
        );
      }
    } finally {
      setState(() => _exportando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reporte — ${widget.nombreLote}'),
        actions: [
          if (_exportando)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20, height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else ...[
            IconButton(
              icon: const Icon(Icons.picture_as_pdf, color: Colors.red),
              tooltip: 'Exportar PDF',
              onPressed: () => _exportar('pdf'),
            ),
            IconButton(
              icon: const Icon(Icons.table_chart, color: Colors.green),
              tooltip: 'Exportar Excel',
              onPressed: () => _exportar('excel'),
            ),
          ],
        ],
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _cargarDatos,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // KPIs
                    KPIRow(items: [
                      KPIItem('Gallinas',
                          _resumen['cantidad_gallinas']?.toString() ?? '—',
                          Colors.orange),
                      KPIItem('Total huevos',
                          _resumen['total_huevos']?.toString() ?? '—',
                          Colors.amber),
                      KPIItem('Ganancia',
                          '\$${_resumen['ganancia_total'] ?? 0}',
                          Colors.green),
                    ]),
                    const SizedBox(height: 8),
                    KPIRow(items: [
                      KPIItem('Ingresos',
                          '\$${_resumen['ingresos_totales'] ?? 0}',
                          Colors.blue),
                      KPIItem('Costos',
                          '\$${_resumen['costos_totales'] ?? 0}',
                          Colors.red),
                    ]),
                    const SizedBox(height: 20),

                    // Tabla mortalidad
                    SeccionTabla(
                      titulo: '💀 Mortalidad',
                      encabezados: const ['Fecha', 'Muertes', 'Acumulado'],
                      filas: _mortalidad.map((r) => [
                        r['fecha']?.toString() ?? '',
                        r['cantidad_muerta']?.toString() ?? '',
                        r['acumulado']?.toString() ?? '',
                      ]).toList(),
                      colorHeader: Colors.red.shade700,
                    ),
                    const SizedBox(height: 16),

                    // Tabla huevos
                    SeccionTabla(
                      titulo: '🥚 Producción de huevos',
                      encabezados: const ['Fecha', 'Huevos'],
                      filas: _huevos.map((r) => [
                        r['fecha']?.toString() ?? '',
                        r['cantidad_huevos']?.toString() ?? '',
                      ]).toList(),
                      colorHeader: Colors.orange.shade700,
                    ),
                    const SizedBox(height: 16),

                    // Tabla insumos
                    SeccionTabla(
                      titulo: '🧪 Insumos por tipo',
                      encabezados: const ['Tipo', 'Costo total', 'Registros'],
                      filas: _insumos.map((r) => [
                        r['tipo']?.toString() ?? '',
                        '\$${double.tryParse(r['costo_total'].toString())?.toStringAsFixed(2) ?? '0.00'}',
                        r['registros']?.toString() ?? '',
                      ]).toList(),
                      colorHeader: Colors.green.shade700,
                    ),
                    const SizedBox(height: 24),

                    // Botones exportar
                    Row(children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.picture_as_pdf),
                          label: const Text('Exportar PDF'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade700,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: _exportando ? null : () => _exportar('pdf'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.table_chart),
                          label: const Text('Exportar Excel'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade700,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: _exportando ? null : () => _exportar('excel'),
                        ),
                      ),
                    ]),
                  ],
                ),
              ),
            ),
    );
  }
}