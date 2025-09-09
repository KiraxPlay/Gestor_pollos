import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../viewmodels/lote_viewmodel.dart';
import '../models/lotes.dart';
import 'lotesTable.dart'; // Asegúrate de importar la vista de detalle

class VistaLotes extends StatelessWidget {
  const VistaLotes({super.key});

  @override
  Widget build(BuildContext context) {
    final loteVM = Provider.of<LoteViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'SmartGalpon',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body:
          loteVM.lotes.isEmpty
              ? const Center(
                child: Image(
                  image: AssetImage('assets/images/carga_lotes.png'),
                ),
              )
              : ListView.builder(
                itemCount: loteVM.lotes.length,
                itemBuilder: (context, index) {
                  final lote = loteVM.lotes[index];
                  return ListTile(
                    title: Text(
                      lote.nombre,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Colors.black87,
                      ),
                    ),
                    subtitle: Text(
                      '🐔 pollos: ${lote.cantidadPollos} \n'
                      '📅 Fecha de inicio: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(lote.fechaInicio))}\n'
                      '💰 Precio unitario:\$${lote.precioUnitario.toStringAsFixed(2)} c/u\n'
                      '💵 Precio total: \$${(lote.cantidadPollos * lote.precioUnitario).toStringAsFixed(2)}\n'
                      'Estado: ${lote.estado == 0 ? '🔴 Inactivo' : '🟢 Activo'}\n',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
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
                          builder: (BuildContext context) {
                            return AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              backgroundColor: Colors.red.shade50,
                              title: Column(
                                children: [
                                  Icon(
                                    Icons.warning_amber_rounded,
                                    color: Colors.red.shade700,
                                    size: 48,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Confirmar eliminación',
                                    style: TextStyle(
                                      color: Colors.red.shade800,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '¿Está seguro de eliminar el',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.red.shade800,
                                    ),
                                  ),
                                  Text(
                                    '"${lote.nombre}"?',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red.shade900,
                                    ),
                                  ),
                                  SizedBox(height: 12),
                                  Text(
                                    'Esta acción no se puede deshacer',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.red.shade700,
                                      fontStyle: FontStyle.italic,
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
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
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
                                  onPressed: () async {
                                    try {
                                      await Provider.of<LoteViewModel>(
                                        context,
                                        listen: false,
                                      ).eliminarLote(lote.id!);

                                      if (context.mounted) {
                                        Navigator.pop(context);
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Row(
                                              children: [
                                                Icon(
                                                  Icons.check_circle,
                                                  color: Colors.white,
                                                ),
                                                SizedBox(width: 8),
                                                Text(
                                                  'Lote eliminado correctamente',
                                                  style: TextStyle(
                                                    color:
                                                        Colors.green.shade200,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      if (context.mounted) {
                                        Navigator.pop(context);
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Row(
                                              children: [
                                                Icon(
                                                  Icons.error_outline,
                                                  color: Colors.white,
                                                ),
                                                SizedBox(width: 8),
                                                Text(
                                                  'Error al eliminar lote: $e',
                                                ),
                                              ],
                                            ),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    }
                                  },
                                  style: TextButton.styleFrom(
                                    backgroundColor: Colors.red.shade400,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.delete, color: Colors.white),
                                        SizedBox(width: 8),
                                        Text(
                                          'Eliminar',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      }
                    },

                    //Onpresss de eliminar lote
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LotesTable(lote: lote),
                        ),
                      );
                    },
                  );
                },
              ),

      floatingActionButton: FloatingActionButton.extended(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: Colors.yellow.shade200,
        elevation: 4, // Controla el tamaño de la sombra
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              String cantidadPollosStr = '';
              String precioUnitarioStr = '';
              final fechaController = TextEditingController(
                text: DateFormat('yyyy-MM-dd').format(DateTime.now()),
              );

              return StatefulBuilder(
                builder: (context, setState) {
                  return AlertDialog(
                    backgroundColor: Colors.yellow.shade100,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    title: Column(
                      children: [
                        // Imagen añadida aquí
                        Image.asset(
                          'assets/images/saved.png', // Cambia por tu ruta de imagen
                          height: 80,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Agregar Nuevo Lote',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    content: SingleChildScrollView(
                      // Para contenido desplazable si es necesario
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            enabled: false,
                            decoration: InputDecoration(
                              labelText: 'Nombre del Lote',
                              hintText: 'Lote ${loteVM.lotes.length + 1}',
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            decoration: const InputDecoration(
                              labelText: 'Cantidad de Pollos',
                              hintText: 'Ingrese la cantidad',
                              prefixIcon: Icon(Icons.numbers),
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) => cantidadPollosStr = value,
                          ),
                          const SizedBox(height: 12),
                          InkWell(
                            onTap: () async {
                              final DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2020),
                                lastDate: DateTime.now().add(
                                  const Duration(days: 1),
                                ),
                                builder: (context, child) {
                                  return Theme(
                                    data: Theme.of(context).copyWith(
                                      colorScheme: ColorScheme.light(
                                        primary: Colors.yellow.shade700,
                                        onPrimary: Colors.white,
                                        surface: Colors.yellow.shade50,
                                      ),
                                      dialogBackgroundColor:
                                          Colors.yellow.shade50,
                                    ),
                                    child: child!,
                                  );
                                },
                              );

                              if (picked != null) {
                                setState(() {
                                  fechaController.text = DateFormat(
                                    'yyyy-MM-dd',
                                  ).format(picked);
                                });
                              }
                            },
                            child: AbsorbPointer(
                              child: TextField(
                                controller: fechaController,
                                decoration: const InputDecoration(
                                  labelText: 'Fecha de Inicio',
                                  hintText: 'Seleccione la fecha',
                                  prefixIcon: Icon(Icons.calendar_today),
                                  border: OutlineInputBorder(),
                                  suffixIcon: Icon(Icons.arrow_drop_down),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            decoration: const InputDecoration(
                              labelText: 'Precio Unitario',
                              hintText: 'Ingrese el precio unitario',
                              prefixIcon: Icon(Icons.attach_money),
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) => precioUnitarioStr = value,
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            enabled: false,
                            decoration: const InputDecoration(
                              labelText: 'Cantidad de Muertos',
                              hintText: '0',
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            enabled: false,
                            decoration: const InputDecoration(
                              labelText: 'Estado',
                              hintText: 'Desactivado',
                            ),
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red.shade600,
                        ),
                        child: const Text('Cancelar'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          final cantidadPollos = int.tryParse(
                            cantidadPollosStr,
                          );
                          final precioUnitario = double.tryParse(
                            precioUnitarioStr,
                          );

                          if (cantidadPollos == null || cantidadPollos <= 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Ingrese una cantidad válida de pollos',
                                ),
                              ),
                            );
                            return;
                          }

                          if (precioUnitario == null || precioUnitario <= 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Ingrese un precio  válido'),
                              ),
                            );
                            return;
                          }

                          try {
                            await loteVM.agregarLote(
                              Lotes(
                                nombre: 'Lote ${loteVM.lotes.length + 1}',
                                cantidadPollos: cantidadPollos,
                                precioUnitario: precioUnitario,
                                fechaInicio: DateFormat('yyyy-MM-dd').format(
                                  DateTime.now(),
                                ), // Formato: 2023-12-31,
                                cantidadMuertos: 0,
                              ),
                            );

                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  duration: Duration(seconds: 2),
                                  content: Row(
                                    children: const [
                                      Icon(
                                        Icons.check_circle,
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Lote creado exitosamente',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error: ${e.toString()}'),
                                ),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Guardar'),
                      ),
                    ],
                  );
                },
              );
            },
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
