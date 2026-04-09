import 'package:flutter/material.dart';
import 'package:gestorgalpon_app/layouts/components/confirmar_elimnacion_dialog.dart';
import 'package:gestorgalpon_app/layouts/components/agregar_lote_dialog.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../viewmodels/lote_viewmodel.dart';
import 'lotesTable.dart'; // Asegúrate de importar la vista de detalle

class VistaLotes extends StatelessWidget {
  const VistaLotes({super.key});

  @override
  Widget build(BuildContext context) {
    final loteVM = Provider.of<LoteViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Pollos de Engorde',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body:
          loteVM.isLoading
              ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Cargando pollos de engorde...'),
                  ],
                ),
              )
              : loteVM.error != null && loteVM.lotes.isEmpty
                  ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red.shade700,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error al cargar lotes',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.red.shade700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            loteVM.error!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.red.shade600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () => loteVM.cargarLotes(),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Reintentar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange.shade700,
                          ),
                        ),
                      ],
                    ),
                  )
                  : loteVM.lotes.isEmpty
                      ? const Center(
                        child: Image(
                          image: AssetImage('assets/images/carga_lotes.png'),
                        ),
                      )
                      : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 1,
                          childAspectRatio: 1.5,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                        ),
                        itemCount: loteVM.lotes.length,
                        itemBuilder: (context, index) {
                          final lote = loteVM.lotes[index];
                          return Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => LotesTable(lote: lote),
                                  ),
                                );
                              },
                              onLongPress: () {
                                if (lote.estado == 1) {
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
                                              'Este lote está activo y no puede ser eliminado.',
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
                                  // Alerta de confirmación de eliminación
                                  showDialog(
                                    context: context,
                                    builder:
                                        (BuildContext context) =>
                                            ConfirmarEliminacionDialog(lote: lote),
                                  );
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      lote.nombre,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '🐔 pollos: ${lote.cantidadPollos} \n'
                                      '📅 Fecha de inicio: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(lote.fechaInicio))}\n'
                                      '💰 Precio unitario:\$${lote.precioUnitario.toStringAsFixed(2)} c/u\n'
                                      '💵 Precio total: \$${(lote.cantidadPollos * lote.precioUnitario).toStringAsFixed(2)}\n'
                                      'Estado: ${lote.estado == 0 ? '🔴 Inactivo' : '🟢 Activo'}\n',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
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
            builder:
                (BuildContext context) => AgregarLoteDialog(loteVM: loteVM),
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
    );
  }
}
