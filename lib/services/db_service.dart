import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:synchronized/synchronized.dart';

class DBService {
  static Database? _database;
  static final _lock = Lock();

  static Future<Database> get database async {
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
      version: 4,
      onCreate: _createTables,
      onUpgrade: _upgradeTables,
    );
  }

  static Future<void> _createTables(Database db, int version) async {
    print('🔧 Creando tablas (versión $version)...');

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
    print(' Tabla lotes creada');

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
    print(' Tabla RegistroPeso creada');

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
    print(' Tabla Insumos creada');

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
    print(' Tabla Ponedoras creada');

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
    print(' Tabla RegistroHuevos creada');

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
    print(' Tabla InsumosPonedoras creada');

    // Tabla RegistroPesoPonedora
    await db.execute('''
      CREATE TABLE IF NOT EXISTS RegistroPesoPonedora (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        lotes_id INTEGER,
        fecha TEXT,
        peso_promedio REAL,
        FOREIGN KEY(lotes_id) REFERENCES Ponedoras(id)
      )
    ''');
    print(' Tabla RegistroPesoPonedora creada');

    // Tabla SyncQueue (para operaciones pendientes)
    await db.execute('''
      CREATE TABLE IF NOT EXISTS sync_queue (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        operation TEXT NOT NULL,
        table_name TEXT NOT NULL,
        data TEXT NOT NULL,
        timestamp INTEGER NOT NULL,
        created_at TEXT,
        synced INTEGER DEFAULT 0
      )
    ''');
    print(' Tabla sync_queue creada');

    print(' Todas las tablas creadas exitosamente');
  }

  static Future<void> _upgradeTables(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    print(' Actualizando base de datos de v$oldVersion a v$newVersion...');

    // Upgrade de v1 a v2
    if (oldVersion < 2) {
      try {
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
        print(' Tabla Ponedoras creada (v2)');

        await db.execute('''
          CREATE TABLE IF NOT EXISTS RegistroHuevos (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            lote_id INTEGER,
            fecha TEXT,
            cantidad_huevos INTEGER,
            FOREIGN KEY(lote_id) REFERENCES Ponedoras(id)
          )
        ''');
        print(' Tabla RegistroHuevos creada (v2)');
      } catch (e) {
        print(' Error en upgrade v2: $e');
      }
    }

    // Upgrade de v2 a v3
    if (oldVersion < 3) {
      try {
        // Verificar si sync_queue existe
        final tables = await db.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table' AND name='sync_queue'",
        );

        if (tables.isNotEmpty) {
          // Verificar columnas existentes
          final columns = await db.rawQuery("PRAGMA table_info(sync_queue)");
          final columnNames = columns.map((col) => col['name'].toString()).toList();

          if (!columnNames.contains('synced')) {
            await db.execute('ALTER TABLE sync_queue ADD COLUMN synced INTEGER DEFAULT 0');
            print(' Columna synced agregada a sync_queue (v3)');
          }

          if (!columnNames.contains('created_at')) {
            await db.execute('ALTER TABLE sync_queue ADD COLUMN created_at TEXT');
            print(' Columna created_at agregada a sync_queue (v3)');
          }
        }
      } catch (e) {
        print('⚠️ Error en upgrade v3: $e');
      }
    }

    // Upgrade de v3 a v4
    if (oldVersion < 4) {
      try {
        // Crear tabla InsumosPonedoras si no existe
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
        print(' Tabla InsumosPonedoras creada (v4)');

        // Crear tabla RegistroPesoPonedora si no existe
        await db.execute('''
          CREATE TABLE IF NOT EXISTS RegistroPesoPonedora (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            lotes_id INTEGER,
            fecha TEXT,
            peso_promedio REAL,
            FOREIGN KEY(lotes_id) REFERENCES Ponedoras(id)
          )
        ''');
        print(' Tabla RegistroPesoPonedora creada (v4)');

        // Verificar que sync_queue tiene todas las columnas
        final columns = await db.rawQuery("PRAGMA table_info(sync_queue)");
        final columnNames = columns.map((col) => col['name'].toString()).toList();

        if (!columnNames.contains('synced')) {
          await db.execute('ALTER TABLE sync_queue ADD COLUMN synced INTEGER DEFAULT 0');
          print(' Columna synced agregada (v4)');
        }
      } catch (e) {
        print(' Error en upgrade v4: $e');
      }
    }

    print('Base de datos actualizada exitosamente a v$newVersion');
  }



  // Método para obtener información de debug
  static Future<void> printDatabaseInfo() async {
    final db = await database;
    final tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table'",
    );

    print('\n TABLAS EN LA BASE DE DATOS:');
    for (var table in tables) {
      final tableName = table['name'];
      final columns = await db.rawQuery("PRAGMA table_info($tableName)");
      print('\n   $tableName:');
      for (var col in columns) {
        print('     - ${col['name']}: ${col['type']}');
      }
    }
  }
}