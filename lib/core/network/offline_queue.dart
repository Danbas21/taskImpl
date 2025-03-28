import 'dart:async';
import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';

import '../failures.dart';
import '../storage/storage_service.dart';
import 'connectivity_service.dart';

/// Representa una operación pendiente para ser ejecutada cuando haya conexión.
class PendingOperation<T> {
  /// Identificador único de la operación.
  final String id;

  /// Tipo de operación ('create', 'update', 'delete', etc.).
  final String type;

  /// Datos asociados con la operación.
  final T? data;

  /// Identificador del recurso (si aplica).
  final String? resourceId;

  /// Marca de tiempo cuando se creó la operación.
  final DateTime timestamp;

  /// Número de intentos de ejecución.
  final int retryCount;

  /// Función que serializa los datos a un mapa.
  final Map<String, dynamic> Function(T data)? dataToJson;

  /// Función que deserializa los datos desde un mapa.
  final T Function(Map<String, dynamic> json)? dataFromJson;

  final Map<String, dynamic Function(Map<String, dynamic>)> _jsonFromFunctions =
      {};

  PendingOperation({
    String? id,
    required this.type,
    this.data,
    this.resourceId,
    DateTime? timestamp,
    this.retryCount = 0,
    this.dataToJson,
    this.dataFromJson,
  }) : id = id ?? const Uuid().v4(),
       timestamp = timestamp ?? DateTime.now();

  /// Crea una nueva operación con un contador de reintentos incrementado.
  PendingOperation<T> incrementRetry() {
    return PendingOperation<T>(
      id: id,
      type: type,
      data: data,
      resourceId: resourceId,
      timestamp: timestamp,
      retryCount: retryCount + 1,
      dataToJson: dataToJson,
      dataFromJson: dataFromJson,
    );
  }

  /// Serializa la operación a un mapa.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'data':
          data != null && dataToJson != null ? dataToJson!(data as T) : null,
      'resourceId': resourceId,
      'timestamp': timestamp.toIso8601String(),
      'retryCount': retryCount,
    };
  }

  /// Crea una operación desde un mapa serializado.
  factory PendingOperation.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>)? fromJson,
  ) {
    return PendingOperation<T>(
      id: json['id'] as String,
      type: json['type'] as String,
      data:
          json['data'] != null && fromJson != null
              ? fromJson(json['data'] as Map<String, dynamic>)
              : null,
      resourceId: json['resourceId'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      retryCount: json['retryCount'] as int? ?? 0,
      dataFromJson: fromJson,
      dataToJson: null, // Este se debe establecer externamente si es necesario
    );
  }
}

/// Define una cola de operaciones pendientes que se ejecutarán cuando haya conexión.
abstract class OfflineQueueService {
  /// Añade una operación a la cola pendiente.
  Future<void> addOperation<T>(PendingOperation<T> operation);

  /// Procesa la cola de operaciones pendientes.
  Future<void> processQueue();

  /// Registra un manejador para un tipo específico de operación.
  void registerHandler<T>(
    String type,
    Future<Either<Failure, Unit>> Function(PendingOperation<T>) handler, {
    T Function(Map<String, dynamic>)? fromJson,
    Map<String, dynamic> Function(T)? toJson,
  });

  /// Obtiene todas las operaciones pendientes.
  List<PendingOperation> getOperations();

  /// Obtiene un stream que emite cuando cambia la cola.
  Stream<List<PendingOperation>> get queueChanges;

  /// Limpia todos los recursos cuando ya no se necesitan.
  void dispose();
}

@LazySingleton(as: OfflineQueueService)
class OfflineQueueServiceImpl implements OfflineQueueService {
  final StorageService _storageService;
  final ConnectivityService _connectivityService;

  /// Clave para almacenar la cola pendiente en el almacenamiento.
  static const String _queueKey = 'offline_operation_queue';

  /// Cola de operaciones pendientes.
  final List<PendingOperation> _operationQueue = [];

  /// Subject para notificar cambios en la cola.
  final _queueSubject = BehaviorSubject<List<PendingOperation>>();

  /// Handlers para diferentes tipos de operaciones.
  final Map<String, Function> _operationHandlers = {};

  /// Funciones de serialización por tipo.
  final Map<String, Function> _jsonFromFunctions = {};
  final Map<String, Function> _jsonToFunctions = {};

  /// Indica si la cola se está procesando actualmente.
  bool _isProcessing = false;

  /// Suscripción a los cambios de conectividad.
  StreamSubscription? _connectivitySubscription;

  OfflineQueueServiceImpl(this._storageService, this._connectivityService) {
    _loadQueue();
    _setupConnectivityListener();
  }
  
  get e => null;

  /// Configura un listener para procesar la cola cuando se restaura la conexión.
  void _setupConnectivityListener() {
    _connectivitySubscription = _connectivityService.connectivityChanges.listen(
      (isConnected) {
        if (isConnected) {
          processQueue();
        }
      },
    );
  }

  /// Carga la cola desde el almacenamiento persistente.
  Future<void> _loadQueue() async {
    final queueData = _storageService.getStringList(_queueKey);
    if (queueData != null) {
      for (final jsonStr in queueData) {
        try {
          final json = jsonDecode(jsonStr) as Map<String, dynamic>;
          final type = json['type'] as String;

          if (_jsonFromFunctions.containsKey(type)) {
            // Hacer el cast explícito aquí
            final fromJsonFunction =
                _jsonFromFunctions[type]
                    as dynamic Function(Map<String, dynamic>)?;

            final operation = PendingOperation.fromJson(json, fromJsonFunction);
            _operationQueue.add(operation);
          }
        } catch (e) {
          // Ignorar operaciones mal formadas
        }
      }
    }
    _queueSubject.add(List.unmodifiable(_operationQueue));
  }

  /// Guarda la cola en el almacenamiento persistente.
  Future<void> _saveQueue() async {
    final queueData =
        _operationQueue.map((op) {
          final type = op.type;
          if (_jsonToFunctions.containsKey(type)) {
            final updatedOperation = PendingOperation(
              id: op.id,
              type: op.type,
              data: op.data,
              resourceId: op.resourceId,
              timestamp: op.timestamp,
              retryCount: op.retryCount,
              dataToJson: _jsonToFunctions[type] as Map<String, dynamic> Function(dynamic)?,
              dataFromJson: op.dataFromJson,
            );
            return jsonEncode(updatedOperation.toJson());
          }
          return jsonEncode(op.toJson());
        }).toList();

    await _storageService.setStringList(_queueKey, queueData);
    _queueSubject.add(List.unmodifiable(_operationQueue));
  }

  @override
  Future<void> addOperation<T>(PendingOperation<T> operation) async {
    _operationQueue.add(operation);
    await _saveQueue();

    // Si hay conexión, intentar procesar la cola inmediatamente
    final isConnected = await _connectivityService.isConnected;
    if (isConnected) {
      processQueue();
    }
  }

  @override
  Future<void> processQueue() async {
    if (_isProcessing || _operationQueue.isEmpty) {
      return;
    }

    _isProcessing = true;

    final isConnected = await _connectivityService.isConnected;
    if (!isConnected) {
      _isProcessing = false;
      return;
    }

    // Ordenar operaciones por timestamp
    _operationQueue.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    // Procesar cada operación
    final operationsToProcess = List<PendingOperation>.from(_operationQueue);

    for (final operation in operationsToProcess) {
      if (!_operationHandlers.containsKey(operation.type)) {
        // Si no hay handler, remover la operación
        _operationQueue.remove(operation);
        continue;
      }

      final handler = _operationHandlers[operation.type];
      try {
        if (handler != null) {
          final result = await handler(operation) as Either<Failure, Unit>;

        if (result.isRight()) {
          // Operación exitosa, removerla de la cola
          _operationQueue.remove(operation);
        } else if (operation.retryCount >= 3) {
          // Demasiados reintentos, remover la operación
          _operationQueue.remove(operation);
        } else {
          // Incrementar contador de reintentos
          final index = _operationQueue.indexOf(operation);
          if (index != -1) {
            _operationQueue[index] = operation.incrementRetry();
          }
        }
      } catch (e) {
        // Error en el handler, incrementar reintentos
        final index = _operationQueue.indexOf(operation);
        if (index != -1 && operation.retryCount < 3) {
          _operationQueue[index] = operation.incrementRetry();
        } else {
          _operationQueue.remove(operation);
        }
      }
    }

    // Guardar estado actualizado de la cola
    await _saveQueue();

    _isProcessing = false;
  }

  @override
  void registerHandler<T>(
    String type,
    Future<Either<Failure, Unit>> Function(PendingOperation<T>) handler, {
    T Function(Map<String, dynamic>)? fromJson,
    Map<String, dynamic> Function(T)? toJson,
  }) {
    _operationHandlers[type] = handler;

    if (fromJson != null) {
      _jsonFromFunctions[type] = fromJson;
    }

    if (toJson != null) {
      _jsonToFunctions[type] = toJson;
    }
  }

  @override
  List<PendingOperation> getOperations() {
    return List.unmodifiable(_operationQueue);
  }

  @override
  Stream<List<PendingOperation>> get queueChanges => _queueSubject.stream;

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    _queueSubject.close();
  }

  @factoryMethod
  static Future<OfflineQueueServiceImpl> create(
    StorageService storageService,
    ConnectivityService connectivityService,
  ) async {
    return OfflineQueueServiceImpl(storageService, connectivityService);
  }
}
