import 'package:flutter/material.dart';
import 'package:gestorgalpon_app/layouts/components/dialogos.dart';
import 'package:gestorgalpon_app/layouts/components/editar_insumo.dart';
import 'package:gestorgalpon_app/layouts/components/nuevo_insumo.dart';
import 'package:gestorgalpon_app/layouts/components/registro_peso.dart';
import 'package:gestorgalpon_app/views/pesoGrafica.dart';
import 'package:intl/intl.dart';
import 'package:gestorgalpon_app/models/tipo_insumo.dart';
import 'package:gestorgalpon_app/services/lote_service.dart';
// import 'package:provider/provider.dart';
import '../models/lotes.dart';
import '../models/insumos.dart';
import '../models/registropesos.dart';
import '../services/insumo_service.dart';
import '../services/registropeso_service.dart';

class LotesTable extends StatefulWidget {
  final Lotes lote;

  const LotesTable({super.key, required this.lote});

  @override
  State<LotesTable> createState() => _LotesTableState();
}

class _LotesTableState extends State<LotesTable> {
  List<Insumos> insumos = [];
  List<RegistroPeso> registrosPeso = [];
  late Lotes loteActual;

  @override
  void initState() {
    super.initState();
    loteActual = widget.lote;
    _cargarDatos();
  }

  //Funcion para cargar los datos de insumos y registros de peso
  Future<void> _cargarDatos() async {
    final cargadosInsumos = await InsumosService.obtenerInsumosPorLote(
      widget.lote.id!,
    );
    final cargadosRegistros = await RegistroPesoService.getRegistrosByLoteId(
      widget.lote.id!,
    );
    final loteActualizado = await LoteService.obtenerLotePorId(widget.lote.id!);
    // Actualizar el estado del lote actual con los datos cargados
    setState(() {
      insumos = cargadosInsumos;
      registrosPeso = cargadosRegistros;
      loteActual = loteActualizado;
    });
  }

  // inicio funcion _agregarInsumo
  Future<void> _agregarInsumo() async {
    await mostrarDialogoInsumo(
      context: context,
      loteActual: loteActual,
      onInsumoRegistrado: _cargarDatos,
    );
  }
  //fin funcion _agregarInsumo

  //comienzo funcion _agregarRegistroPeso
  Future<void> _agregarRegistroPeso() async {
    await mostrarDialogoRegistroPeso(
      context: context,
      loteActual: loteActual,
      registrosPeso: registrosPeso,
      onPesoRegistrado: _cargarDatos,
      calcularPesoTeorico: calcularPesoTeorico,
    );
  }
  //fin funcion _agregarRegistroPeso

  Future<void> _eliminarInsumo(Insumos insumo) async {
    await InsumosService.eliminarInsumo(insumo.id!);

    // Verificar si quedan insumos
    final insumosRestantes = await InsumosService.obtenerInsumosPorLote(
      loteActual.id!,
    );
    if (insumosRestantes.isEmpty) {
      // Si no quedan insumos, cambiar estado a inactivo (0)
      final loteActualizado = loteActual.copyWith(estado: 0);
      await LoteService.actualizarLote(loteActualizado);
    }

    await _cargarDatos();
  }

  Future<void> _eliminarRegistro(RegistroPeso registro) async {
    await RegistroPesoService.eliminarPeso(registro.id!);
    _cargarDatos();
  }

  IconData _getIconForTipo(TipoInsumo tipo) {
    switch (tipo) {
      case TipoInsumo.alimento:
        return Icons.restaurant;
      case TipoInsumo.medicamento:
        return Icons.medical_services;
      case TipoInsumo.vacuna:
        return Icons.vaccines;
      case TipoInsumo.vitamina:
        return Icons.local_pharmacy;
      case TipoInsumo.desinfectante:
        return Icons.cleaning_services;
      case TipoInsumo.otro:
      default:
        return Icons.category;
    }
  }

  //inicio funcion _editarInsumo

  Future<void> _editarInsumo(Insumos insumo) async {
    await mostrarDialogoEditarInsumo(
      context: context,
      insumo: insumo,
      onInsumoActualizado: _cargarDatos,
    );
  }
  //fin funcion _editarInsumo

  Future<void> _confirmarEliminarInsumo(Insumos insumo) async {
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
              '¿Está seguro que desea eliminar el insumo "${insumo.nombre}"?',
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
        await _eliminarInsumo(insumo);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                ' el Insumo "${insumo.nombre}" eliminado satisfactoriamente',
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
            SnackBar(content: Text('Error al eliminar insumo: $e')),
          );
        }
      }
    }
  }

  //funcion para calcular el peso teorico
  double calcularPesoTeorico(DateTime fechaInicio) {
    final dias = DateTime.now().difference(fechaInicio).inDays;
    //Parametros
    const pesoInicial = 40.0; // Peso inicial en gramos
    const crecimientoDiario = 20.0; // Crecimiento diario en gramos

    final peso = pesoInicial + (dias * crecimientoDiario);
    return peso.clamp(0, 4000) / 1000;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Detalle de ${widget.lote.nombre}',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '📦 ${widget.lote.nombre}',
              style: const TextStyle(fontSize: 18),
            ),
            Text(
              '🐥 Pollitos: ${widget.lote.cantidadPollos}',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            Text(
              '📅 Fecha de inicio: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(widget.lote.fechaInicio))} ',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '📋 Insumos:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _agregarInsumo,
                ),
              ],
            ),
            ...insumos
                .map(
                  (Insumos insumo) => Card(
                    // Especificamos el tipo explícitamente
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 8,
                    ),
                    child: ListTile(
                      leading: Icon(
                        _getIconForTipo(insumo.tipo),
                        color: Colors.yellow.shade900,
                      ),
                      title: Text(
                        insumo.nombre,
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${insumo.cantidad} ${insumo.unidad}'),
                          Text(
                            'Precio: \$${insumo.precio.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            'Fecha: ${insumo.fecha}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _editarInsumo(insumo),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _confirmarEliminarInsumo(insumo),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                .toList(), // No olvides convertir el map a lista

            const Divider(height: 32),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '⚖️ Registros de Peso:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _agregarRegistroPeso,
                ),
              ],
            ),

            Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                children: [
                  if (registrosPeso.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'No hay registros de peso',
                        style: TextStyle(
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  else
                    ...registrosPeso
                        .map(
                          (peso) => Card(
                            margin: const EdgeInsets.all(8),
                            child: ListTile(
                              title: Row(
                                children: [
                                  Icon(
                                    Icons.monitor_weight,
                                    color: Colors.blue.shade900,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${peso.pesoPromedio.toStringAsFixed(3)} kg',
                                          style: TextStyle(
                                            color: Colors.blue.shade900,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          DateFormat(
                                            'dd/MM/yyyy',
                                          ).format(DateTime.parse(peso.fecha)),
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
                                    Icons.analytics,
                                    color: Colors.orange.shade800,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      'P.Teorico: ${calcularPesoTeorico(DateTime.parse(peso.fecha)).toStringAsFixed(3)} kg',
                                      style: TextStyle(
                                        color: Colors.orange.shade800,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      overflow: TextOverflow.ellipsis,
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
                                      color: Colors.green,
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) => PesoGrafica(
                                                registros: registrosPeso,
                                                fechaInicio:
                                                    widget.lote.fechaInicio,
                                                pesoTeorico:
                                                    calcularPesoTeorico
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
                                    onPressed: () => _eliminarRegistro(peso),
                                    tooltip: 'Eliminar registro',
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ).toList(),
                ],
              ),
            ),

            const Divider(height: 32),
            Text(
              'Información de precio de los pollos: ',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              '💰 Precio unitario: \$${widget.lote.precioUnitario.toStringAsFixed(2)}',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            Text(
              '💵 Precio total: \$${(widget.lote.cantidadPollos * widget.lote.precioUnitario).toStringAsFixed(2)}',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),

            const Divider(height: 32),
            Text(
              '⏱️ Edad del lote: ${DateTime.now().difference(DateTime.parse(widget.lote.fechaInicio)).inDays} días',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            TextButton.icon(
              onPressed: _mostrarDialogoMuertos,
              icon: const Icon(Icons.add_circle_outline, color: Colors.red),
              label: Text(
                '💀 Muertos: ${loteActual.cantidadMuertos}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Text(
              '📝 Cantidad Actual de Pollos: ${loteActual.cantidadPollos - loteActual.cantidadMuertos}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 16),
            Text(
              '📊 Total de insumos en este lote : ${insumos.length}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 16),
            Text(
              '📈 Total precio de insumos: \$${insumos.fold(0, (total, insumo) => total + (insumo.precio.toInt() * insumo.cantidad)).toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _mostrarDialogoMuertos() async {
    await DialogosGalpon.mostrarDialogoMuertos(
      context: context,
      loteActual: loteActual,
      onMortalidadRegistrada: _cargarDatos,
    );
  }
}
