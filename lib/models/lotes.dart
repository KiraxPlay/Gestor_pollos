class Lotes {
  final int? id;
  final String nombre;
  final int cantidadPollos;
  final double precioUnitario;
  final String fechaInicio;
  final int cantidadMuertos;
  final int estado; // 0: activo, 1: inactivo, etc.

  Lotes({
    this.id,
    required this.nombre,
    required this.cantidadPollos,
    required this.precioUnitario,
    required this.fechaInicio,
    required this.cantidadMuertos,
    this.estado = 0,
  });

  Lotes copyWith({
    int? id,
    String? nombre,
    int? cantidadPollos,
    double? precioUnitario,
    String? fechaInicio,
    int? cantidadMuertos,
    int? estado,
  }) {
    return Lotes(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      cantidadPollos: cantidadPollos ?? this.cantidadPollos,
      precioUnitario: precioUnitario ?? this.precioUnitario,
      fechaInicio: fechaInicio ?? this.fechaInicio,
      cantidadMuertos: cantidadMuertos ?? this.cantidadMuertos,
      estado: estado ?? this.estado,
    );
  }
  
  // Para guardar en la bd / enviar al API
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'nombre': nombre,
      'cantidad_pollos': cantidadPollos,
      'precio_unitario': precioUnitario,
      'fecha_inicio': fechaInicio,
      'cantidad_muertos': cantidadMuertos,
      'estado': estado,
    };

    if (id != null) map['id'] = id;
    return map;
  }

  // Para compatibilidad con API y SQLite
  Map<String, dynamic> toJson() => toMap();

  // Para recuperar de la bd / respuesta API (más tolerante a tipos)
  factory Lotes.fromMap(Map<String, dynamic> map) {
    int parseInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      return int.tryParse(v.toString()) ?? 0;
    }

    double parseDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is double) return v;
      if (v is int) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0.0;
    }

    return Lotes(
      id: map['id'] is int ? map['id'] : (map['id'] != null ? int.tryParse(map['id'].toString()) : null),
      nombre: (map['nombre'] ?? '').toString(),
      cantidadPollos: parseInt(map['cantidad_pollos'] ?? map['cantidadPollos'] ?? 0),
      precioUnitario: parseDouble(map['precio_unitario'] ?? map['precioUnitario'] ?? map['precio'] ?? 0),
      fechaInicio: (map['fecha_inicio'] ?? map['fechaInicio'] ?? '').toString(),
      cantidadMuertos: parseInt(map['cantidad_muertos'] ?? map['cantidadMuertos'] ?? 0),
      estado: parseInt(map['estado'] ?? 0),
    );
  }

  // Alias usado por el resto del código (lote_service espera fromJson)
  factory Lotes.fromJson(Map<String, dynamic> json) => Lotes.fromMap(json);
}