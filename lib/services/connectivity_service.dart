import 'package:connectivity_plus/connectivity_plus.dart';

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
    final result = await _connectivity.checkConnectivity();
    _isConnected = result == ConnectivityResult.wifi || 
                   result == ConnectivityResult.mobile;
    
    onConnectivityChanged.listen((result) {
      _isConnected = result == ConnectivityResult.wifi || 
                     result == ConnectivityResult.mobile;
      print('Conectividad cambió: $_isConnected');
    });
  }

  Future<bool> checkConnection() async {
    final result = await _connectivity.checkConnectivity();
    _isConnected = result == ConnectivityResult.wifi || 
                   result == ConnectivityResult.mobile;
    return _isConnected;
  }
}