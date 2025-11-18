import 'package:flutter/material.dart';
import 'package:gestorgalpon_app/views/ponedoras/detalle_ponedora.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/ponedoras/ponedoras_viewmodel.dart';
import '../../models/ponedoras/ponedoras.dart';
import '../../layouts/components/ponedoras/agregar_ponedoras_dialog.dart';

class VistaPonedoras extends StatelessWidget {
  const VistaPonedoras({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PonederasViewModel(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Ponedoras',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          centerTitle: true,
        ),
        body: Consumer<PonederasViewModel>(
          builder: (context, ponedeVM, _) {
            if (ponedeVM.ponedoras.isEmpty) {
              return const Center(
                child: Image(
                  image: AssetImage('assets/images/ponedoras2.png'),
                ),
              );
            }

            return ListView.builder(
              itemCount: ponedeVM.ponedoras.length,
              itemBuilder: (context, index) {
                final ponedora = ponedeVM.ponedoras[index];
                return ListTile(
                  title: Text(
                    ponedora.nombre,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Colors.black87,
                    ),
                  ),
                  subtitle: Text(
                    '🐔 Gallinas: ${ponedora.cantidadGallinas}\n'
                    '📅 Fecha de inicio: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(ponedora.fechaInicio))}\n'
                    '💰 Precio unitario: \$${ponedora.precioUnitario.toStringAsFixed(2)} c/u\n'
                    '💵 Precio total: \$${(ponedora.cantidadGallinas * ponedora.precioUnitario).toStringAsFixed(2)}\n'
                    '🥚 Edad: ${ponedora.edadSemanas} semanas\n'
                    'Estado: ${ponedora.estado == 0 ? '🔴 Inactivo' : '🟢 Activo'}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  onLongPress: () {
                    if (ponedora.estado == 1) {
                      // Alerta de lote activo
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            backgroundColor: Colors.red.shade50,
                            title: Column(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: Colors.red,
                                  size: 48,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'No se puede eliminar',
                                  style: TextStyle(
                                    color: Colors.red.shade700,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Este lote de ponedoras está activo y no puede ser eliminado.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.red.shade700,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Para eliminar el lote, primero debe estar inactivo.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.red.shade400,
                                  ),
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.red.shade100,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  child: Text(
                                    'Entendido',
                                    style: TextStyle(
                                      color: Colors.red.shade700,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    } else {
                      // Alerta de confirmación de eliminación - VERSIÓN CORREGIDA
                      showDialog(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          backgroundColor: Colors.red.shade50,
                          title: Column(
                            children: [
                              Icon(
                                Icons.warning_amber,
                                color: Colors.orange,
                                size: 48,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Confirmar Eliminación',
                                style: TextStyle(
                                  color: Colors.red.shade700,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '¿Estás seguro de eliminar el lote "${ponedora.nombre}"?',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.red.shade700,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Esta acción no se puede deshacer.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.red.shade400,
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
                            TextButton(
                              onPressed: () {
                                ponedeVM.eliminarPonedora(ponedora.id!);
                                Navigator.pop(context);
                              },
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.red.shade100,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                child: Text(
                                  'Eliminar',
                                  style: TextStyle(
                                    color: Colors.red.shade700,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                  // OnTap para ver detalle
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetallePonedora(loteId: ponedora.id!),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: Colors.yellow.shade200,
          elevation: 4,
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) => AgregarPonederasDialog(
                onAgregar: (ponedora) {
                  Provider.of<PonederasViewModel>(
                    context,
                    listen: false,
                  ).agregarPonedora(ponedora);
                },
              ),
            );
          },
          icon: const Icon(
            Icons.add,
            size: 30,
            color: Colors.black,
            shadows: [
              BoxShadow(
                color: Colors.black87,
                blurRadius: 4,
                offset: Offset(1, 1),
              ),
            ],
          ),
          label: const Text(
            'Agregar',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          color: Colors.yellow.shade300,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.info_outline, color: Colors.black54, size: 18),
              SizedBox(width: 8),
              const Text(
                'Versión 1.1.0',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}