import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:gestorgalpon_app/services/reporte_service.dart';
import 'package:gestorgalpon_app/views/reportes/widgets_reporte.dart';

class ReporteEngordeScreen extends StatefulWidget {
  final int loteId;
  final String nombreLote;

  const ReporteEngordeScreen({
    super.key,
    required this.loteId,
    required this.nombreLote,
  });

  @override
  State<ReporteEngordeScreen> createState() => _ReporteEngordeScreenState();
}

class _ReporteEngordeScreenState extends State<ReporteEngordeScreen> {
  Map<String, dynamic> _resumen  = {};
  List<dynamic>        _insumos  = [];
  List<dynamic>        _mortalidad = [];
  bool _cargando   = true;
  bool _exportando = false;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() => _cargando = true);
    try {
      final results = await Future.wait([
        ReporteService.getResumenEngorde(widget.loteId),
        ReporteService.getInsumosEngorde(widget.loteId),
        ReporteService.getMortalidad(widget.loteId),
      ]);
      setState(() {
        _resumen    = results[0] as Map<String, dynamic>;
        _insumos    = results[1] as List;
        _mortalidad = results[2] as List;
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
                    KPIRow(items: [
                      KPIItem('Pollos',
                          _resumen['cantidad_pollos']?.toString() ?? '—',
                          Colors.orange),
                      KPIItem('Ganancia',
                          '\$${_resumen['ganancia_total'] ?? 0}',
                          Colors.green),
                      KPIItem('Costos',
                          '\$${_resumen['costos_totales'] ?? 0}',
                          Colors.red),
                    ]),
                    const SizedBox(height: 20),

                    SeccionTabla(
                      titulo: '💀 Mortalidad',
                      encabezados: const ['Fecha', 'Muertes'],
                      filas: _mortalidad.map((r) => [
                        r['fecha']?.toString() ?? '',
                        r['cantidad_muerta']?.toString() ?? '',
                      ]).toList(),
                      colorHeader: Colors.red.shade700,
                    ),
                    const SizedBox(height: 16),

                    SeccionTabla(
                      titulo: '🧪 Insumos por tipo',
                      encabezados: const ['Tipo', 'Costo total', 'Registros'],
                      filas: _insumos.map((r) => [
                        r['tipo']?.toString() ?? '',
                        '\$${double.tryParse(r['costo_total'].toString())?.toStringAsFixed(2) ?? '0.00'}',
                        r['registros']?.toString() ?? '',
                      ]).toList(),
                      colorHeader: Colors.yellow.shade800,
                    ),
                    const SizedBox(height: 24),

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