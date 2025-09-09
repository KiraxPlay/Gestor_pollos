import 'tipo_insumo.dart';

class Insumos {
  final int? id;
  final int lotesId;          // ← clave foránea
  final String nombre;       // ej: "Comida inicial"
  final int cantidad;        // ej: 50
  final String unidad;       // ej: "kg", "bolsas", etc.
  final double precio;       // total
  final TipoInsumo tipo;      // ej: "Alimento", "Medicamento", etc.
  final String fecha;        // yyyy-MM-dd

  Insumos({
    this.id,
    required this.lotesId,
    required this.nombre,
    required this.cantidad,
    required this.unidad,
    required this.precio,
    required this.tipo,
    required this.fecha,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'lotes_id': lotesId,
      'nombre': nombre,
      'cantidad': cantidad,
      'unidad': unidad,
      'precio': precio,
      'tipo' : tipoInsumoToString(tipo),
      'fecha': fecha,
    };
  }

  factory Insumos.fromMap(Map<String, dynamic> map) {
    try {
      return Insumos(
        id: map['id'],
        lotesId: map['lotes_id'] ?? 0,
        nombre: map['nombre'] ?? '',
        cantidad: (map['cantidad'] ?? 0) is String 
            ? int.tryParse(map['cantidad']) ?? 0 
            : map['cantidad'] ?? 0,
        unidad: map['unidad'] ?? '',
        precio: (map['precio'] ?? 0.0) is String 
            ? double.tryParse(map['precio']) ?? 0.0 
            : (map['precio'] ?? 0.0).toDouble(),
        tipo: tipoInsumoFromString(map['tipo']),
        fecha: map['fecha'] ?? DateTime.now().toIso8601String().substring(0, 10),
      );
    } catch (e) {
      print('Error al convertir mapa a Insumo: $e');
      print('Mapa recibido: $map');
      // Retornamos un insumo con valores por defecto en caso de error
      return Insumos(
        lotesId: 0,
        nombre: 'Error de conversión',
        cantidad: 0,
        unidad: '',
        precio: 0.0,
        tipo: TipoInsumo.otro,
        fecha: DateTime.now().toIso8601String().substring(0, 10),
      );
    }
  }

  // Método para crear una copia del insumo con cambios
  Insumos copyWith({
    int? id,
    int? lotesId, 
    String? nombre,
    int? cantidad,
    String? unidad,
    double? precio,
    TipoInsumo? tipo,
    String? fecha,
  }) {
    return Insumos(
      id: id ?? this.id,
      lotesId: lotesId ?? this.lotesId,
      nombre: nombre ?? this.nombre,
      cantidad: cantidad ?? this.cantidad,
      unidad: unidad ?? this.unidad,
      precio: precio ?? this.precio,
      tipo: tipo ?? this.tipo,
      fecha: fecha ?? this.fecha,
    );
  }
}