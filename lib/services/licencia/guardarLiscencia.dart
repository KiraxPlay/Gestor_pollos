import 'package:shared_preferences/shared_preferences.dart';
import 'package:gestorgalpon_app/models/licencia/licencia.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';
import 'dart:convert';

class LicenciaService {
  static const _licKey = 'licencia_data';

  static Future<void> guardarLicencia(Licencia licencia) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_licKey, jsonEncode(licencia.toJson()));
  }

  static Future<Licencia?> obtenerLicencia() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_licKey);
    if (data == null) return null;

    return Licencia.fromJson(jsonDecode(data));
  }

  static Future<void> borrarLicencia() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(_licKey);
  }



static Future<String?> getDeviceId() async {
    final deviceInfo = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      return androidInfo.id ?? 'unknown';
    } else if (Platform.isWindows) {
      final windowsInfo = await deviceInfo.windowsInfo;
      return windowsInfo.deviceId;
    } else if (Platform.isLinux) {
      final linuxInfo = await deviceInfo.linuxInfo;
      return linuxInfo.machineId;
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return iosInfo.identifierForVendor;
    }

    return null;
  }

}
