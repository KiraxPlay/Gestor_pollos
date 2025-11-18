import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:synchronized/synchronized.dart'; // ← AGREGAR ESTE IMPORT
// import 'package:gestorgalpon_app/models/ponedoras/ponedoras.dart';
// import 'package:gestorgalpon_app/models/ponedoras/registrohuevos.dart';

class DBService {
  static Database? _database;
  static final _lock = Lock(); // ← AGREGAR ESTE LOCK

  static Future<Database> get database async {
    // Usar lock para evitar acceso concurrente
    return await _lock.synchronized(() async {
      if (_database != null) return _database!;
      _database = await _initDatabase();
      return _database!;
    });
  }

  static Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'gestorgalpon.db');

    return await openDatabase(
      path,
      version: 3,
      onCreate: _createTables,
      onUpgrade: _upgradeTables,
    );
  }

  static Future<void> _createTables(Database db, int version) async {
    // Tabla Lotes (engorde)
    await db.execute('''
      CREATE TABLE IF NOT EXISTS lotes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT,
        cantidad_pollos INTEGER,
        precio_unitario REAL,
        fecha_inicio TEXT,
        cantidad_muertos INTEGER DEFAULT 0,
        estado INTEGER DEFAULT 0
      )
    ''');

    // Tabla RegistroPeso
    await db.execute('''
      CREATE TABLE IF NOT EXISTS RegistroPeso (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        lote_id INTEGER,
        fecha TEXT,
        peso_promedio REAL,
        FOREIGN KEY(lote_id) REFERENCES lotes(id)
      )
    ''');

    // Tabla Insumos
    await db.execute('''
      CREATE TABLE IF NOT EXISTS Insumos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        lotes_id INTEGER,
        nombre TEXT,
        cantidad INTEGER,
        unidad TEXT,
        precio REAL,
        tipo TEXT,
        fecha TEXT,
        FOREIGN KEY(lotes_id) REFERENCES lotes(id)
      )
    ''');

    // Tabla Ponedoras
    await db.execute('''
      CREATE TABLE IF NOT EXISTS Ponedoras (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT,
        cantidad_gallinas INTEGER,
        precio_unitario REAL,
        fecha_inicio TEXT,
        cantidad_muerto INTEGER DEFAULT 0,
        estado INTEGER DEFAULT 0,
        edad_semanas INTEGER DEFAULT 0,
        muertos_semanales INTEGER DEFAULT 0
      )
    ''');

    // Tabla RegistroHuevos
    await db.execute('''
      CREATE TABLE IF NOT EXISTS RegistroHuevos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        lote_id INTEGER,
        fecha TEXT,
        cantidad_huevos INTEGER,
        FOREIGN KEY(lote_id) REFERENCES Ponedoras(id)
      )
    ''');

    // Tabla InsumosPonedoras
    await db.execute('''
      CREATE TABLE IF NOT EXISTS InsumosPonedoras (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        lotes_id INTEGER,
        nombre TEXT,
        cantidad INTEGER,
        unidad TEXT,
        precio REAL,
        tipo TEXT,
        fecha TEXT,
        FOREIGN KEY(lotes_id) REFERENCES Ponedoras(id)
      )
    ''');

    // Tabla SyncQueue (para operaciones pendientes) - CORREGIDA
    await db.execute('''
    CREATE TABLE IF NOT EXISTS sync_queue (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      operation TEXT,
      table_name TEXT,
      data TEXT,
      timestamp INTEGER,
      created_at TEXT  -- ← AGREGAR ESTA COLUMNA
    )
  ''');

    print('✅ Tablas creadas exitosamente');
  }

  static Future<void> _upgradeTables(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 3) {
      // Agregar tabla Ponedoras si no existe
      await db.execute('''
        CREATE TABLE IF NOT EXISTS Ponedoras (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          nombre TEXT,
          cantidad_gallinas INTEGER,
          precio_unitario REAL,
          fecha_inicio TEXT,
          cantidad_muerto INTEGER DEFAULT 0,
          estado INTEGER DEFAULT 0,
          edad_semanas INTEGER DEFAULT 0,
          muertos_semanales INTEGER DEFAULT 0
        )
      ''');

      // Agregar tabla InsumosPonedoras si no existe
      await db.execute('''
      CREATE TABLE IF NOT EXISTS InsumosPonedoras (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        lotes_id INTEGER,
        nombre TEXT,
        cantidad INTEGER,
        unidad TEXT,
        precio REAL,
        tipo TEXT,
        fecha TEXT,
        FOREIGN KEY(lotes_id) REFERENCES Ponedoras(id)
      )
    ''');

      // Agregar tabla RegistroHuevos si no existe
      await db.execute('''
        CREATE TABLE IF NOT EXISTS RegistroHuevos (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          lotes_id INTEGER,
          fecha TEXT,
          cantidad_huevos INTEGER,
          FOREIGN KEY(lote_id) REFERENCES Ponedoras(id)
        )
      ''');

      try {
        await db.execute('ALTER TABLE sync_queue ADD COLUMN created_at TEXT');
        print('✅ Columna created_at agregada a sync_queue');
      } catch (e) {
        print('ℹ️ La columna created_at ya existe en sync_queue: $e');
      }

      print('✅ Tablas actualizadas exitosamente');
    }
  }
}
