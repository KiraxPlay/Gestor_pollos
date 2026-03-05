import 'package:flutter/material.dart';
import 'package:gestorgalpon_app/models/ponedoras/registrohuevos.dart';
import 'package:gestorgalpon_app/services/db_service.dart';
import 'package:gestorgalpon_app/services/connectivity_service.dart';
import 'package:gestorgalpon_app/viewmodels/ponedoras/ponedoras_viewmodel.dart';
import 'package:gestorgalpon_app/viewmodels/ponedoras/registrohuevos.dart';
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



  // Inicializar base de datos
  await DBService.database;

  // Inicializar conectividad
  await ConnectivityService().initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoteViewModel()..cargarLotes()),
        ChangeNotifierProvider(create: (_) => PonederasViewModel()..cargarPonedoras()),
        ChangeNotifierProvider(create: (_) => RegistroHuevosViewModel())
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
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
      home: const MenuImagen(),
    );
  }
}
