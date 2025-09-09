import 'dart:convert';
import 'package:crypto/crypto.dart';

class Licencia {
  final String deviceId;
  final DateTime fechaActivacion;
  final DateTime fechaExpiracion;
  final String firma;

  static const String _secretKey = "kiraxññ@23sxdf@hashpaspin@#1075316707elquerobeesgey@#";

  Licencia({
    required this.deviceId,
    required this.fechaActivacion,
    required this.fechaExpiracion,
    required this.firma,
  });

  Map<String, dynamic> toJson() => {
    'deviceId': deviceId,
    'fechaActivacion': fechaActivacion.toIso8601String(),
    'fechaExpiracion': fechaExpiracion.toIso8601String(),
    'firma': firma,
  };

  factory Licencia.fromJson(Map<String, dynamic> json) {
    return Licencia(
      deviceId: json['deviceId'],
      fechaActivacion: DateTime.parse(json['fechaActivacion']),
      fechaExpiracion: DateTime.parse(json['fechaExpiracion']),
      firma: json['firma'],
    );
  }

  bool esValida(String deviceActual) {
    final ahora = DateTime.now();
    final firmaEsperada = _firmar(deviceId, fechaExpiracion.toIso8601String());

    return deviceId == deviceActual &&
        ahora.isBefore(fechaExpiracion) &&
        firma == firmaEsperada;
  }

  static String _firmar(String deviceId, String fechaExpiracion) {
    final data = "$deviceId$fechaExpiracion$_secretKey";
    final bytes = utf8.encode(data);
    return sha256.convert(bytes).toString();
  }

  static Licencia? desdeLicenciaFirmada(String jsonLicencia) {
    try {
      final Map<String, dynamic> data = json.decode(jsonLicencia);
      return Licencia.fromJson(data);
    } catch (e) {
      print('Error decodificando licencia: $e');
      return null;
    }
  }
}