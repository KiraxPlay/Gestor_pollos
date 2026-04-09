import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  final Connectivity _connectivity = Connectivity();
  
  bool _isConnected = false;

  bool get isConnected => _isConnected;
  
  // Exponer el stream de cambios
  Stream<ConnectivityResult> get onConnectivityChanged => 
      _connectivity.onConnectivityChanged;

  factory ConnectivityService() {
    return _instance;
  }

  ConnectivityService._internal();

  Future<void> initialize() async {
    // En web, siempre asumimos que hay conexión
    if (kIsWeb) {
      _isConnected = true;
      print('Web: Conectividad asumida como activa');
      return;
    }

    try {
      final result = await _connectivity.checkConnectivity();
      _isConnected = result == ConnectivityResult.wifi || 
                     result == ConnectivityResult.mobile;
      
      onConnectivityChanged.listen((result) {
        _isConnected = result == ConnectivityResult.wifi || 
                       result == ConnectivityResult.mobile;
        print('Conectividad cambió: $_isConnected');
      });
    } catch (e) {
      print('Error inicializando conectividad: $e');
      _isConnected = true; // Asumir conectado si falla
    }
  }

  Future<bool> checkConnection() async {
    if (kIsWeb) {
      return true; // En web siempre hay conexión
    }

    try {
      final result = await _connectivity.checkConnectivity();
      _isConnected = result == ConnectivityResult.wifi || 
                     result == ConnectivityResult.mobile;
      return _isConnected;
    } catch (e) {
      print('Error verificando conectividad: $e');
      return true; // Asumir conectado si hay error
    }
  }
 

  }