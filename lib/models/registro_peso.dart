class RegistroPeso {
  final int id;
  final int lotesId;  // ← DECIDISTE MANTENER lotesId
  final String fecha;
  final double pesoPromedio;

  RegistroPeso({
    required this.id,
    required this.lotesId,
    required this.fecha,
    required this.pesoPromedio,
  });

  // Para la base de datos LOCAL - usar lote_id (sin 's')
  Map<String, dynamic> toMap() => {
        'id': id,
        'lote_id': lotesId,  // ← SIN 's' para BD local
        'fecha': fecha,
        'peso_promedio': pesoPromedio,
      };

  factory RegistroPeso.fromMap(Map<String, dynamic> map) => RegistroPeso(
        id: map['id'],
        lotesId: map['lote_id'],  // ← SIN 's'
        fecha: map['fecha'],
        pesoPromedio: map['peso_promedio']?.toDouble() ?? 0.0,
      );

  // Para el API (Django) - mantener lotes_id (con 's')
  Map<String, dynamic> toJson() => {
        'id': id,
        'lotes_id': lotesId,  // ← CON 's' para API
        'fecha': fecha,
        'peso_promedio': pesoPromedio,
      };

  factory RegistroPeso.fromJson(Map<String, dynamic> json) => RegistroPeso(
        id: json['id'],
        lotesId: json['lotes_id'] ?? json['lote_id'],
        fecha: json['fecha'],
        pesoPromedio: json['peso_promedio']?.toDouble() ?? 0.0,
      );
}