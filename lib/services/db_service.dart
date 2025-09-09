import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
// import 'package:gestorgalpon_app/models/ponedoras/ponedoras.dart';
// import 'package:gestorgalpon_app/models/ponedoras/registrohuevos.dart';


class DBService {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;

    try {
      String dbPath;
      if (kIsWeb) {
        dbPath = 'bdGalpon.db';
      } else if (Platform.isAndroid || Platform.isIOS) {
        // Para dispositivos móviles
        dbPath = join(await getDatabasesPath(), 'bdGalpon.db');
      } else {
        // Para desktop
        dbPath = join('.', 'bdGalpon.db');
      }

      print('Intentando abrir base de datos en: $dbPath');

      _database = await openDatabase(
        dbPath,
        version: 4,
        onCreate: _createTables,
        onOpen: (db) {
          print('Base de datos abierta exitosamente');
        },
        
        onUpgrade: (db  , oldVersion , newVersion) async {
          if(oldVersion < 4) {
            // await db.execute('ALTER TABLE Lotes ADD COLUMN precio_unitario REAL DEFAULT 0.0');
            await db.execute('ALTER TABLE Lotes ADD COLUMN estado INTEGER DEFAULT 0');// Aquí puedes manejar actualizaciones de la base de datos si es necesario
            print('Actualizando base de datos de versión $oldVersion a $newVersion');
          }
        }
      );

      return _database!;
    } catch (e) {
      print('Error al abrir la base de datos: $e');
      rethrow;
    }
  }

  static Future<void> _createTables(Database db, int version) async {
    try {
      await db.transaction((txn) async {
        // Crear tabla Lotes
        await txn.execute('''
          CREATE TABLE IF NOT EXISTS Lotes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nombre TEXT NOT NULL,
            cantidad_pollos INTEGER NOT NULL,
            precio_unitario REAL DEFAULT 0.0,
            fecha_inicio TEXT ,
            cantidad_muertos INTEGER DEFAULT 0,
            estado INTEGER DEFAULT 0 
          )
        ''');

        // Crear tabla Insumo
        await txn.execute('''
          CREATE TABLE IF NOT EXISTS Insumos (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            lotes_id INTEGER NOT NULL,
            nombre TEXT NOT NULL,
            cantidad INTEGER NOT NULL,
            unidad TEXT NOT NULL,
            precio REAL NOT NULL,
            tipo TEXT NOT NULL,
            fecha TEXT NOT NULL,
            FOREIGN KEY (lotes_id) REFERENCES Lotes(id) ON DELETE CASCADE
          )
        ''');

        // Crear tabla RegistroPeso
        await txn.execute('''
          CREATE TABLE IF NOT EXISTS RegistroPeso (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            lotes_id INTEGER NOT NULL,
            fecha TEXT NOT NULL,
            peso_promedio REAL NOT NULL,
            FOREIGN KEY (lotes_id) REFERENCES Lotes(id) ON DELETE CASCADE
          )
        ''');
        // Crear tabla LotePonedoras para futuro de version 2.0.0
        // await txn.execute('''
        //   CREATE TABLE IF NOT EXISTS LotePonedoras (
        //     id INTEGER PRIMARY KEY AUTOINCREMENT,
        //     nombre TEXT NOT NULL,
        //     cantidad INTEGER NOT NULL,
        //     fecha_inicio TEXT NOT NULL,
        //     fecha_fin TEXT NOT NULL,
        //     estado TEXT NOT NULL
        //   )
        // ''');
        // // Crear tabla Huevos
        // await txn.execute('''
        //   CREATE TABLE IF NOT EXISTS Huevos (
        //     id INTEGER PRIMARY KEY AUTOINCREMENT,
        //     lote_ponedoras_id INTEGER NOT NULL,
        //     cantidad INTEGER NOT NULL,
        //     fecha TEXT NOT NULL,
        //     huevos_recogidos INTEGER DEFAULT 0,
        //     huevos_rotos INTEGER DEFAULT 0,
        //     FOREIGN KEY (lote_ponedoras_id) REFERENCES LotePonedoras(id) ON DELETE CASCADE
        //   )
        // ''');
      });
      print('Tablas creadas exitosamente');
    } catch (e) {
      print('Error al crear las tablas: $e');
      rethrow;
    }
  }
}