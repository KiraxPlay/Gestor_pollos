/// Modelo para el estado del mini-galpón
class MiniGalpon {
  int gallinas;
  int huevosProducidos;
  double presupuesto;
  double comidaKg;
  double saludPromedio; // 0-100
  int diasTranscurridos;
  List<String> eventos;

  MiniGalpon({
    this.gallinas = 10,
    this.huevosProducidos = 0,
    this.presupuesto = 500.0,
    this.comidaKg = 50.0,
    this.saludPromedio = 80.0,
    this.diasTranscurridos = 0,
    this.eventos = const [],
  });

  /// Copia con cambios
  MiniGalpon copyWith({
    int? gallinas,
    int? huevosProducidos,
    double? presupuesto,
    double? comidaKg,
    double? saludPromedio,
    int? diasTranscurridos,
    List<String>? eventos,
  }) {
    return MiniGalpon(
      gallinas: gallinas ?? this.gallinas,
      huevosProducidos: huevosProducidos ?? this.huevosProducidos,
      presupuesto: presupuesto ?? this.presupuesto,
      comidaKg: comidaKg ?? this.comidaKg,
      saludPromedio: saludPromedio ?? this.saludPromedio,
      diasTranscurridos: diasTranscurridos ?? this.diasTranscurridos,
      eventos: eventos ?? this.eventos,
    );
  }

  /// Calcula si el galpón sigue viable
  bool estaViable() {
    return gallinas > 0 && presupuesto > 0 && saludPromedio > 10;
  }

  /// Calcula ganancia diaria
  double calcularGanancia() {
    return (huevosProducidos * 2.5) - (comidaKg * 1.2) - (gallinas * 0.5);
  }
}
