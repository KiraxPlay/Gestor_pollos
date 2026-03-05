// models/ponedoras/insumos_ponedoras.dart
class InsumoPonedora {
  final int? id;
  final int lotesId;
  final String nombre;
  final int cantidad;
  final String unidad;
  final double precio;
  final String tipo;
  final String fecha;

  InsumoPonedora({
    this.id,
    required this.lotesId,
    required this.nombre,
    required this.cantidad,
    required this.unidad,
    required this.precio,
    required this.tipo,
    required this.fecha,
  });

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'lotes_id': lotesId,
      'nombre': nombre,
      'cantidad': cantidad,
      'unidad': unidad,
      'precio': precio,
      'tipo': tipo,
      'fecha': fecha,
    };
  }

  factory InsumoPonedora.fromJson(Map<String, dynamic> json) {
    return InsumoPonedora(
      id: json['id'],
      lotesId: json['lotes_id'] ?? json['lotesId'],
      nombre: json['nombre'],
      cantidad: json['cantidad'],
      unidad: json['unidad'],
      precio: json['precio'] is double ? json['precio'] : double.parse(json['precio'].toString()),
      tipo: json['tipo'],
      fecha: json['fecha'],
    );
  }
}