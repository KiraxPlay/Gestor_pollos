class Ponedoras {
  final int? id;
  final String nombre;
  final int cantidadGallinas;
  final double precioUnitario;
  final String fechaInicio;
  final int cantidadMuerto;
  final int estado;
  final int edadSemanas;
  final int muertosSemanales;

  Ponedoras({
    this.id,
    required this.nombre,
    required this.cantidadGallinas,
    required this.precioUnitario,
    required this.fechaInicio,
    this.cantidadMuerto = 0,
    this.estado = 0,
    this.edadSemanas = 0,
    this.muertosSemanales = 0,
  });

  Ponedoras copyWith({
    int? id,
    String? nombre,
    int? cantidadGallinas,
    double? precioUnitario,
    String? fechaInicio,
    int? cantidadMuerto,
    int? estado,
    int? edadSemanas,
    int? muertosSemanales,
  }) {
    return Ponedoras(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      cantidadGallinas: cantidadGallinas ?? this.cantidadGallinas,
      precioUnitario: precioUnitario ?? this.precioUnitario,
      fechaInicio: fechaInicio ?? this.fechaInicio,
      cantidadMuerto: cantidadMuerto ?? this.cantidadMuerto,
      estado: estado ?? this.estado,
      edadSemanas: edadSemanas ?? this.edadSemanas,
      muertosSemanales: muertosSemanales ?? this.muertosSemanales,
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'nombre': nombre,
      'cantidad_gallinas': cantidadGallinas,
      'precio_unitario': precioUnitario,
      'fecha_inicio': fechaInicio,
      'cantidad_muerto': cantidadMuerto,
      'estado': estado,
      'edad_semanas': edadSemanas,
      'muertos_semanales': muertosSemanales,
    };
    if (id != null) map['id'] = id;
    return map;
  }

  Map<String, dynamic> toJson() => toMap();

  factory Ponedoras.fromMap(Map<String, dynamic> map) {
    int? parseInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      return int.tryParse(v.toString());
    }

    double parseDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is double) return v;
      if (v is int) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0.0;
    }

    return Ponedoras(
      id: parseInt(map['id']),
      nombre: (map['nombre'] ?? '').toString(),
      cantidadGallinas: parseInt(map['cantidad_gallinas'] ?? 0) ?? 0,
      precioUnitario: parseDouble(map['precio_unitario'] ?? 0),
      fechaInicio: (map['fecha_inicio'] ?? '').toString(),
      cantidadMuerto: parseInt(map['cantidad_muerto'] ?? 0) ?? 0,
      estado: parseInt(map['estado'] ?? 0) ?? 0,
      edadSemanas: parseInt(map['edad_semanas'] ?? 0) ?? 0,
      muertosSemanales: parseInt(map['muertos_semanales'] ?? 0) ?? 0,
    );
  }

  factory Ponedoras.fromJson(Map<String, dynamic> json) => Ponedoras.fromMap(json);
}