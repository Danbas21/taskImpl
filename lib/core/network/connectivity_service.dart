import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:injectable/injectable.dart';

/// Servicio para monitorear y obtener el estado de conectividad del dispositivo.
abstract class ConnectivityService {
  /// Stream que emite cuando cambia el estado de la conectividad.
  Stream<bool> get connectivityChanges;

  /// Comprueba si el dispositivo está actualmente conectado a Internet.
  Future<bool> get isConnected;

  /// Libera los recursos cuando ya no se necesitan.
  void dispose();
}

@LazySingleton(as: ConnectivityService)
class ConnectivityServiceImpl implements ConnectivityService {
  final Connectivity _connectivity;

  late StreamController<bool> _connectivityController;

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  bool _lastKnownState = false;

  ConnectivityServiceImpl(this._connectivity) {
    _connectivityController = StreamController<bool>.broadcast();
    _initConnectivity();
    _setupConnectivityListener();
  }

  /// Inicializa el estado de conectividad al crear el servicio.
  Future<void> _initConnectivity() async {
    try {
      final connectivityResults = await _connectivity.checkConnectivity();
      if (connectivityResults.isNotEmpty) {
        _updateConnectionStatus(
          connectivityResults.first != ConnectivityResult.none,
        );
      } else {
        _connectivityController.add(false);
      }
    } catch (e) {
      _connectivityController.add(false);
    }
  }

  /// Configura un listener para cambios en la conectividad.
  ///

  void _setupConnectivityListener() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((
      connectivityResults,
    ) {
      final isConnected = connectivityResults.any(
        (result) => result != ConnectivityResult.none,
      );
      _updateConnectionStatus(isConnected);
    });
  }

  /// Actualiza el estado de conexión y notifica a los observadores.
  void _updateConnectionStatus(bool isConnected) {
    // Solo emitir si hay un cambio real
    if (_lastKnownState != isConnected) {
      _lastKnownState = isConnected;
      _connectivityController.add(isConnected);
    }
  }

  @override
  Stream<bool> get connectivityChanges => _connectivityController.stream;

  @override
  Future<bool> get isConnected async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    _connectivityController.close();
  }

  /// Método de fábrica para la inyección de dependencias.
  @factoryMethod
  static ConnectivityServiceImpl create() {
    return ConnectivityServiceImpl(Connectivity());
  }
}
