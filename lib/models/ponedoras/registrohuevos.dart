class RegistroHuevos {
  final int? id;
  final int loteId;
  final String fecha;
  final int cantidadHuevos;

  RegistroHuevos({
    this.id,
    required this.loteId,
    required this.fecha,
    required this.cantidadHuevos,
  });

  RegistroHuevos copyWith({
    int? id,
    int? loteId,
    String? fecha,
    int? cantidadHuevos,
  }) {
    return RegistroHuevos(
      id: id ?? this.id,
      loteId: loteId ?? this.loteId,
      fecha: fecha ?? this.fecha,
      cantidadHuevos: cantidadHuevos ?? this.cantidadHuevos,
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'lote_id': loteId,
      'fecha': fecha,
      'cantidad_huevos': cantidadHuevos,
    };
    if (id != null) map['id'] = id;
    return map;
  }

  Map<String, dynamic> toJson() => toMap();

  factory RegistroHuevos.fromMap(Map<String, dynamic> map) {
    int? parseInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      return int.tryParse(v.toString());
    }

    return RegistroHuevos(
      id: parseInt(map['id']),
      loteId: parseInt(map['lote_id'] ?? map['loteId'] ?? 0) ?? 0,
      fecha: (map['fecha'] ?? '').toString(),
      cantidadHuevos: parseInt(map['cantidad_huevos'] ?? map['cantidadHuevos'] ?? 0) ?? 0,
    );
  }

  factory RegistroHuevos.fromJson(Map<String, dynamic> json) => RegistroHuevos.fromMap(json);
}