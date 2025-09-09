// class Huevos {
//   final int id;
//   final int LotePonedorasId;
//   final int cantidad;
//   final String fecha; // yyyy-MM-dd
//   final int huevosRecogidos;
//   final int huevosRotos;

//   Huevos({
//     required this.id,
//     required this.LotePonedorasId,
//     required this.cantidad,
//     required this.fecha,
//     required this.huevosRecogidos,
//     required this.huevosRotos,
//   });

//   factory Huevos.fromMap(Map<String, dynamic> map) {
//     return Huevos(
//       id: map['id'],
//       LotePonedorasId: map['lote_ponedoras_id'],
//       cantidad: map['cantidad'],
//       fecha: map['fecha'],
//       huevosRecogidos: map['huevos_recogidos'],
//       huevosRotos: map['huevos_rotos'],
//     );
//   }

//   Map<String, dynamic> toMap() {
//     return {
//       'id': id,
//       'lote_ponedoras_id': LotePonedorasId,
//       'cantidad': cantidad,
//       'fecha': fecha,
//       'huevos_recogidos': huevosRecogidos,
//       'huevos_rotos': huevosRotos,
//     };
//   }
// }

