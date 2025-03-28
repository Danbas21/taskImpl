import 'package:injectable/injectable.dart';
import 'connectivity_service.dart';

/// Clase utilitaria que proporciona información sobre el estado de la red.
abstract class NetworkInfo {
  /// Indica si el dispositivo está conectado a Internet.
  Future<bool> get isConnected;

  /// Stream que emite cuando cambia el estado de conectividad.
  Stream<bool> get connectivityChanges;
}

@LazySingleton(as: NetworkInfo)
class NetworkInfoImpl implements NetworkInfo {
  final ConnectivityService _connectivityService;

  NetworkInfoImpl(this._connectivityService);

  @override
  Future<bool> get isConnected => _connectivityService.isConnected;

  @override
  Stream<bool> get connectivityChanges =>
      _connectivityService.connectivityChanges;
}
