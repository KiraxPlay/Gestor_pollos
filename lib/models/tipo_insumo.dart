enum TipoInsumo {
  alimento,
  medicamento,
  vacuna,
  vitamina,
  desinfectante,
  otro,
}

// Mapa de unidades por tipo
final Map<TipoInsumo, List<String>> unidadesPorTipo = {
  TipoInsumo.alimento: ['kg', 'bulto', 'gramos'],
  TipoInsumo.medicamento: ['ml', 'cc', 'dosis'],
  TipoInsumo.vacuna: ['dosis', 'frasco'],
  TipoInsumo.vitamina: ['ml', 'sobre', 'cc'],
  TipoInsumo.desinfectante: ['ml', 'litro'],
  TipoInsumo.otro: ['unidad', 'kg', 'litro', 'ml'],
};

// Obtener unidades para un tipo específico
List<String> getUnidadesPorTipo(TipoInsumo tipo) {
  final unidades = unidadesPorTipo[tipo];
  print(
    'Obteniendo unidades para ${tipoInsumoToString(tipo)}: $unidades',
  ); // Debug
  return unidades ?? ['unidad'];
}

String tipoInsumoToString(TipoInsumo tipo) {
  switch (tipo) {
    case TipoInsumo.alimento:
      return 'Alimento';
    case TipoInsumo.medicamento:
      return 'Medicamento';
    case TipoInsumo.vacuna:
      return 'Vacuna';
    case TipoInsumo.vitamina:
      return 'Vitamina';
    case TipoInsumo.desinfectante:
      return 'Desinfectante';
    case TipoInsumo.otro:
      return 'Otro';
  }
}

TipoInsumo tipoInsumoFromString(String? tipo) {
  if (tipo == null) return TipoInsumo.otro;

  switch (tipo.trim()) {
    case 'Alimento':
      return TipoInsumo.alimento;
    case 'Medicamento':
      return TipoInsumo.medicamento;
    case 'Vacuna':
      return TipoInsumo.vacuna;
    case 'Vitamina':
      return TipoInsumo.vitamina;
    case 'Desinfectante':
      return TipoInsumo.desinfectante;
    case 'Otro':
      return TipoInsumo.otro;
    default:
      return TipoInsumo.otro; // Valor por defecto
  }
}
