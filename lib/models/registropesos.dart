class RegistroPeso {
  final int id;
  final int lotesId;
  final String fecha;
  final double pesoPromedio; // en gramos o kg

  RegistroPeso({
    required this.id,
    required this.lotesId,
    required this.fecha,
    required this.pesoPromedio,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'lotes_id': lotesId,
        'fecha': fecha,
        'peso_promedio': pesoPromedio,
      };

  factory RegistroPeso.fromMap(Map<String, dynamic> map) => RegistroPeso(
        id: map['id'],
        lotesId: map['lotes_id'],
        fecha: map['fecha'],
        pesoPromedio: map['peso_promedio'],
      );
}
