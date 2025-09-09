// class LotePonedoras {
//   final int id;
//   final String nombre;
//   final int cantidad;
//   final String fechaInicio;
//   final String fechaFin;
//   final String estado;

//   LotePonedoras({
//     required this.id,
//     required this.nombre,
//     required this.cantidad,
//     required this.fechaInicio,
//     required this.fechaFin,
//     required this.estado,
//   });

//   factory LotePonedoras.fromMap(Map<String, dynamic> map) {
//     return LotePonedoras(
//       id: map['id'],
//       nombre: map['nombre'],
//       cantidad: map['cantidad'],
//       fechaInicio: map['fecha_inicio'],
//       fechaFin: map['fecha_fin'],
//       estado: map['estado'],
//     );
//   }

//   Map<String, dynamic> toMap() {
//     return {
//       'id': id,
//       'nombre': nombre,
//       'cantidad': cantidad,
//       'fecha_inicio': fechaInicio,
//       'fecha_fin': fechaFin,
//       'estado': estado,
//     };
//   }
// }