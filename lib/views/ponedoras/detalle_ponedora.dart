import 'package:flutter/material.dart';
import 'package:gestorgalpon_app/layouts/components/dialogos.dart';
import 'package:gestorgalpon_app/layouts/components/ponedoras/nuevo_insumo_ponedoras.dart';
import 'package:gestorgalpon_app/layouts/components/ponedoras/nuevo_registro_huevos.dart';
import 'package:gestorgalpon_app/services/ponedoras/insumos_ponedoras_service.dart';
import 'package:gestorgalpon_app/services/ponedoras/registrohuevos.dart';
import 'package:gestorgalpon_app/views/ponedoras/huevos_grafica.dart';
import 'package:gestorgalpon_app/models/ponedoras/insumos_ponedoras.dart';
import 'package:gestorgalpon_app/services/db_service.dart';
import 'package:gestorgalpon_app/services/sync_service.dart';
import 'package:gestorgalpon_app/views/reportes/reporte_engorde_screen.dart';
import 'package:gestorgalpon_app/views/reportes/reporte_ponedora_screen.dart';
import 'package:intl/intl.dart';
import '../../models/ponedoras/ponedoras.dart';
import '../../models/ponedoras/registrohuevos.dart';
import '../../services/ponedoras/ponedoras_service.dart';

class DetallePonedora extends StatefulWidget {
  final int loteId;

  const DetallePonedora({super.key, required this.loteId});

  @override
  State<DetallePonedora> createState() => _DetallePonedoraState();
}

class _DetallePonedoraState extends State<DetallePonedora> {
  List<RegistroHuevos> registrosHuevos = [];
  List<InsumoPonedora> insumos = [];
  late Ponedoras ponedoraActual;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  // Iconos para tipos de insumo
  IconData _getIconForTipo(String tipo) {
    switch (tipo) {
      case 'Alimento':
        return Icons.restaurant;
      case 'Medicamento':
        return Icons.medical_services;
      case 'Vacuna':
        return Icons.vaccines;
      case 'Vitamina':
        return Icons.local_pharmacy;
      case 'Desinfectante':
        return Icons.cleaning_services;
      case 'Otro':
      default:
        return Icons.category;
    }
  }

  // 🎨 COLORES para tipos de insumo - AGREGA ESTA FUNCIÓN
  Color _getColorForTipo(String tipo) {
    switch (tipo) {
      case 'Alimento':
        return Colors.orange.shade700;
      case 'Medicamento':
        return Colors.red.shade700;
      case 'Vacuna':
        return Colors.blue.shade700;
      case 'Vitamina':
        return Colors.purple.shade700;
      case 'Desinfectante':
        return Colors.teal.shade700;
      case 'Otro':
      default:
        return Colors.grey.shade700;
    }
  }

  Future<void> _eliminarInsumo(InsumoPonedora insumo) async {
    try {
      await InsumosPonedorasService.eliminarInsumoPonedora(insumo.id!);
      _cargarDatos(); // Recarga los datos después de eliminar
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al eliminar insumo: $e')));
    }
  }

  // Función para confirmar eliminación de insumo
  Future<void> _confirmarEliminarInsumo(InsumoPonedora insumo) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            backgroundColor: Colors.red.shade50,
            title: const Text('Confirmar eliminación'),
            content: Text(
              '¿Está seguro que desea eliminar el insumo ${insumo.nombre}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Eliminar'),
              ),
            ],
          ),
    );

    if (confirmar == true) {
      await _eliminarInsumo(insumo);
    }
  }

  // Función para cargar los datos de la ponedora y registros de huevos
  Future<void> _cargarDatos() async {
    setState(() => _isLoading = true);
    try {
      final cargadosRegistros =
          await RegistroHuevosService.obtenerRegistrosPorLote(widget.loteId);
      final cargadosInsumos =
          await InsumosPonedorasService.obtenerInsumosPorLote(widget.loteId);
      final ponedoraActualizada = await PonederasService.obtenerPonederaPorId(
        widget.loteId,
      );

      setState(() {
        registrosHuevos = cargadosRegistros;
        insumos = cargadosInsumos;
        ponedoraActual = ponedoraActualizada;
        _isLoading = false;
      });
    } catch (e) {
      print('Error cargando datos: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error cargando datos: $e')));
      }
    }
  }

  // Función para agregar insumo
  Future<void> _agregarInsumo() async {
    await mostrarDialogoInsumoPonedoras(
      context: context,
      ponedoraActual: ponedoraActual,
      onInsumoRegistrado: _cargarDatos,
    );
  }

  // Función para agregar registro de huevos
  Future<void> _agregarRegistroHuevos() async {
    await mostrarDialogoRegistroHuevos(
      context: context,
      ponedoraActual: ponedoraActual,
      onHuevosRegistrados: _cargarDatos,
    );
  }

  // Función para eliminar registro de huevos
  Future<void> _eliminarRegistro(RegistroHuevos registro) async {
    await RegistroHuevosService.eliminarRegistro(registro.id!);
    _cargarDatos();
  }

  // Función para confirmar eliminación
  Future<void> _confirmarEliminarRegistro(RegistroHuevos registro) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            backgroundColor: Colors.yellow.shade100,
            title: const Text('Confirmar eliminación'),
            content: Text(
              '¿Está seguro que desea eliminar el registro del ${registro.fecha}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Eliminar'),
              ),
            ],
          ),
    );

    if (confirmar == true) {
      try {
        await _eliminarRegistro(registro);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Registro del ${registro.fecha} eliminado satisfactoriamente',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al eliminar registro: $e')),
          );
        }
      }
    }
  }

  // Calcular producción promedio diaria
  double get _produccionPromedio {
    if (registrosHuevos.isEmpty) return 0;
    final totalHuevos = registrosHuevos.fold(
      0,
      (sum, registro) => sum + registro.cantidadHuevos,
    );
    return totalHuevos / registrosHuevos.length;
  }

  // Calcular porcentaje de producción
  double get _porcentajeProduccion {
    if (ponedoraActual.cantidadGallinas == 0) return 0;
    final totalHuevos = registrosHuevos.fold(
      0,
      (sum, registro) => sum + registro.cantidadHuevos,
    );
    final promedioDiario =
        registrosHuevos.isNotEmpty ? totalHuevos / registrosHuevos.length : 0;
    return (promedioDiario / ponedoraActual.cantidadGallinas) * 100;
  }

  @override
  Widget build(BuildContext context) {
    // 🔄 Mostrar loading si los datos aún no han cargado
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Cargando...')),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Cargando datos de la ponedora...'),
            ],
          ),
        ),
      );
    }

    final totalHuevos = registrosHuevos.fold(
      0,
      (sum, registro) => sum + registro.cantidadHuevos,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Detalle de ${ponedoraActual.nombre}',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        actions:
            _isLoading
                ? []
                : [
                  IconButton(
                    icon: const Icon(Icons.bar_chart),
                    tooltip: 'Ver reporte',
                    onPressed:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => ReportePonedoraScreen(
                                  loteId:
                                      ponedoraActual.id!, // campo de Ponedoras
                                  nombreLote:
                                      ponedoraActual
                                          .nombre, // campo de Ponedoras
                                ),
                          ),
                        ),
                  ),
                ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔄 WIDGET DE ESTADO DE SINCRONIZACIÓN
            _buildSyncStatusWidget(),
            const SizedBox(height: 16),

            // INFORMACIÓN DEL LOTE
            Text(
              '🐔 ${ponedoraActual.nombre}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              '🥚 Gallinas: ${ponedoraActual.cantidadGallinas}',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            Text(
              '📅 Fecha de inicio: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(ponedoraActual.fechaInicio))}',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),

            // ESTADÍSTICAS DE PRODUCCIÓN
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.yellow.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.yellow.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      const Text(
                        'Total Huevos',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '$totalHuevos',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const Text(
                        'Promedio/Día',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        _produccionPromedio.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const Text(
                        'Eficiencia',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${_porcentajeProduccion.toStringAsFixed(1)}%',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 🆕 SECCIÓN DE INSUMOS - AGREGA ESTO
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '🧪 Insumos:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _agregarInsumo,
                ),
              ],
            ),

            Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Column(
                children: [
                  if (insumos.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'No hay insumos registrados',
                        style: TextStyle(
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  else
                    ...insumos
                        .map(
                          (insumo) => Card(
                            margin: const EdgeInsets.all(8),
                            child: ListTile(
                              leading: Icon(
                                _getIconForTipo(insumo.tipo),
                                color: Colors.green.shade800,
                              ),
                              title: Text(
                                insumo.nombre,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${insumo.cantidad} ${insumo.unidad}'),
                                  Text(
                                    'Precio: \$${insumo.precio.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    'Fecha: ${insumo.fecha}',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    'Tipo: ${insumo.tipo}',
                                    style: TextStyle(
                                      color: _getColorForTipo(insumo.tipo),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Colors.blue,
                                    ),
                                    onPressed: () {
                                      // TODO: Editar insumo
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed:
                                        () => _confirmarEliminarInsumo(insumo),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                        .toList(),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // REGISTROS DE HUEVOS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '🥚 Registros de Huevos:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _agregarRegistroHuevos,
                ),
              ],
            ),

            Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Column(
                children: [
                  if (registrosHuevos.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Image(
                        image: AssetImage('assets/images/no_huevos.png'),
                        height: 150, // Aumenta la altura
                        width: 150, // Opcional: define un ancho
                        fit:
                            BoxFit
                                .contain, // Asegura que la imagen se ajuste correctamente
                      ),
                    )
                  else
                    ...registrosHuevos
                        .map(
                          (registro) => Card(
                            margin: const EdgeInsets.all(8),
                            child: ListTile(
                              leading: Icon(
                                Icons.egg,
                                color: Colors.orange.shade800,
                              ),
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${registro.cantidadHuevos} huevos',
                                          style: TextStyle(
                                            color: Colors.orange.shade900,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          DateFormat('dd/MM/yyyy').format(
                                            DateTime.parse(registro.fecha),
                                          ),
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              subtitle: Row(
                                children: [
                                  Icon(
                                    Icons.trending_up,
                                    color: Colors.green.shade800,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      'Eficiencia: ${((registro.cantidadHuevos / ponedoraActual.cantidadGallinas) * 100).toStringAsFixed(1)}%',
                                      style: TextStyle(
                                        color: Colors.green.shade800,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.show_chart,
                                      color: Colors.purple,
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) => HuevosGrafica(
                                                registros: registrosHuevos,
                                                fechaInicio:
                                                    ponedoraActual.fechaInicio,
                                              ),
                                        ),
                                      );
                                    },
                                    tooltip: 'Ver gráfica',
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed:
                                        () => _confirmarEliminarRegistro(
                                          registro,
                                        ),
                                    tooltip: 'Eliminar registro',
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                        .toList(),
                ],
              ),
            ),

            const Divider(height: 32),

            // INFORMACIÓN FINANCIERA
            Text(
              '💰 Información de Precios:',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              '💵 Precio unitario: \$${ponedoraActual.precioUnitario.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            Text(
              '🏷️ Precio total gallinas: \$${(ponedoraActual.cantidadGallinas * ponedoraActual.precioUnitario).toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              '🥚 Valor producción estimada: \$${(totalHuevos * 0.25).toStringAsFixed(2)}', // Asumiendo $0.25 por huevo
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: Colors.green,
              ),
            ),

            const Divider(height: 32),

            // INFORMACIÓN DEL LOTE
            Text(
              '📊 Información del Lote:',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              '⏱️ Edad del lote: ${ponedoraActual.edadSemanas} semanas',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            TextButton.icon(
              onPressed: _mostrarDialogoMuertos,
              icon: const Icon(Icons.heart_broken, color: Colors.red),
              label: Text(
                '💀 Muertos: ${ponedoraActual.cantidadMuerto}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Text(
              '🐔 Gallinas vivas: ${ponedoraActual.cantidadGallinas - ponedoraActual.cantidadMuerto}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 16),
            Text(
              '📈 Total de registros: ${registrosHuevos.length}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 16),
            Text(
              '📅 Días en producción: ${DateTime.now().difference(DateTime.parse(ponedoraActual.fechaInicio)).inDays} días',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _mostrarDialogoMuertos() async {
    await DialogosGalpon.mostrarDialogoMuertosPonedoras(
      context: context,
      ponedoraActual: ponedoraActual,
      onMortalidadRegistrada: _cargarDatos,
    );
  }

  /// 🔄 Widget para mostrar el estado de sincronización
  Widget _buildSyncStatusWidget() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _obtenerOperacionesPendientes(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }

        final operacionesPendientes = snapshot.data ?? [];

        if (operacionesPendientes.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.shade300),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green.shade700),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '✅ Sincronización completada',
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.orange.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.sync, color: Colors.orange.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '⏳ ${operacionesPendientes.length} operación(es) pendiente(s)',
                      style: TextStyle(
                        color: Colors.orange.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ..._buildOperacionesList(operacionesPendientes),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _sincronizarAhora,
                  icon: const Icon(Icons.cloud_upload),
                  label: const Text('Sincronizar ahora'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade700,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 📋 Construir lista de operaciones pendientes
  List<Widget> _buildOperacionesList(List<Map<String, dynamic>> operaciones) {
    final Map<String, int> contadores = {};

    for (var op in operaciones) {
      final key = '${op['operation']} - ${op['table_name']}';
      contadores[key] = (contadores[key] ?? 0) + 1;
    }

    return contadores.entries.map((entry) {
      final [operation, tableName] = entry.key.split(' - ');
      final count = entry.value;
      final icon = _getIconForOperation(operation);
      final color = _getColorForOperation(operation);

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Text(
              '$operation en $tableName ($count)',
              style: TextStyle(
                fontSize: 13,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  /// 🎨 Obtener icono según operación
  IconData _getIconForOperation(String operation) {
    switch (operation) {
      case 'INSERT':
        return Icons.add_circle;
      case 'UPDATE':
        return Icons.edit;
      case 'DELETE':
        return Icons.delete;
      default:
        return Icons.sync;
    }
  }

  /// 🎨 Obtener color según operación
  Color _getColorForOperation(String operation) {
    switch (operation) {
      case 'INSERT':
        return Colors.blue.shade700;
      case 'UPDATE':
        return Colors.amber.shade700;
      case 'DELETE':
        return Colors.red.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  /// 📡 Obtener operaciones pendientes de sincronizar
  Future<List<Map<String, dynamic>>> _obtenerOperacionesPendientes() async {
    try {
      final db = await DBService.database;
      return await db.query(
        'sync_queue',
        where: 'synced = ?',
        whereArgs: [0],
        orderBy: 'id ASC',
      );
    } catch (e) {
      print('Error obteniendo operaciones pendientes: $e');
      return [];
    }
  }

  /// 🔄 Sincronizar operaciones pendientes
  Future<void> _sincronizarAhora() async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🔄 Sincronizando operaciones...'),
          duration: Duration(seconds: 2),
        ),
      );

      await SyncService.syncAllPendingOperations();

      // Recargar datos después de sincronizar
      await _cargarDatos();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Sincronización completada'),
            duration: Duration(seconds: 2),
          ),
        );
      }

      // Forzar rebuild para actualizar el widget de estado
      setState(() {});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error en sincronización: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}
