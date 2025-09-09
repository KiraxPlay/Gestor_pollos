import 'package:flutter/material.dart';
import 'package:gestorgalpon_app/licencia_home.dart';
import 'package:gestorgalpon_app/services/db_service.dart';
import 'package:gestorgalpon_app/services/licencia/guardarLiscencia.dart';
import 'package:gestorgalpon_app/views/Home.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'viewmodels/lote_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configuración para Desktop
  if (!kIsWeb && !(Platform.isAndroid || Platform.isIOS)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  await DBService.database;

  runApp(
    ChangeNotifierProvider(
      create: (_) => LoteViewModel()..cargarLotes(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Función que verifica la licencia
  Future<bool> verificarLicencia() async {
    try {
      final licencia = await LicenciaService.obtenerLicencia();
      final deviceId = await LicenciaService.getDeviceId();

      if (licencia == null || deviceId == null) {
        return false;
      }

      final esValida = licencia.esValida(deviceId);

      if (!esValida) {
        await LicenciaService.borrarLicencia();
      }

      return esValida;
    } catch (e) {
      print('Error verificando licencia: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: verificarLicencia(),
      builder: (context, snapshot) {
        // Mientras se verifica
        if (snapshot.connectionState != ConnectionState.done) {
          return const MaterialApp(
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }

        final licenciaValida = snapshot.data ?? false;

        return MaterialApp(
          title: 'SmartGalpon',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.yellow),
            useMaterial3: true,
            cardTheme: const CardTheme(elevation: 4, margin: EdgeInsets.all(8)),
            appBarTheme: AppBarTheme(
              elevation: 0,
              centerTitle: true,
              backgroundColor: Colors.yellow.shade300,
              foregroundColor: Colors.black,
            ),
          ),
          home:
              licenciaValida
                  ? const MenuImagen()
                  : const LicenciaInvalidaScreen(),
          //valida que si licenciaValida es true mostrara el home , si no mandara a la pantalla de licencia invalida
        );
      },
    );
  }
}
