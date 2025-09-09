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
    this.estado = 0, // Por defecto, el estado es 0 (activo)
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
  
  //para guardar en la bd pero formato JSON
 Map<String, dynamic> toMap() {
  final map = <String, dynamic>{
    'nombre': nombre,
    'cantidad_pollos': cantidadPollos,
    'precio_unitario': precioUnitario, // Asegúrate de que este campo esté presente
    'fecha_inicio': fechaInicio,
    'cantidad_muertos': cantidadMuertos, // Asegúrate de que este campo esté presente
    'estado': estado, // Asegúrate de que este campo esté presente
    
  };

  // Verifica y agrega solo si id tiene un valor (no es null)
  final idValue = id;
  if (idValue != null) {
    map['id'] = idValue;
  }

  return map;
}


  //Para recuperar de la bd
  factory Lotes.fromMap(Map<String, dynamic> map) {
    return Lotes(
      id: map['id'],
      nombre: map['nombre'],
      cantidadPollos: map['cantidad_pollos'],
      precioUnitario: map['precio_unitario'], // Asegúrate de convertir a double
      fechaInicio: map['fecha_inicio'],
      cantidadMuertos: map['cantidad_muertos'], // Asegúrate de convertir a int
      estado: map['estado'] ?? 0, // Asegúrate de que este campo tenga un valor por defecto
    );
  }


}
