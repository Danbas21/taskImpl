import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';
import 'package:task_test/core/failures.dart';
import 'package:task_test/core/network/connectivity_service.dart';
import 'package:task_test/core/network/offline_queue.dart';
import 'package:task_test/features/data/models/task_model.dart';

@injectable
class TaskRemoteDataSourceImpl {
  final http.Client client;
  final String baseUrl;
  final ConnectivityService connectivityService;
  final OfflineQueueService offlineQueueService;
  final BehaviorSubject<Either<Failure, List<TaskModel>>> _tasksSubject =
      BehaviorSubject<Either<Failure, List<TaskModel>>>();
  DateTime? _lastFetchTime;
  static const _cacheDuration = Duration(minutes: 5);

  TaskRemoteDataSourceImpl({
    required this.client,
    @Named('apiBaseUrl') required this.baseUrl,
    required this.connectivityService,
    required this.offlineQueueService,
  }) {
    _registerOfflineHandlers();
  }

  /// Registra los handlers para operaciones offline
  void _registerOfflineHandlers() {
    // Registrar handler para añadir tareas
    offlineQueueService.registerHandler<TaskModel>(
      'add_task',
      (operation) => _sendAddTaskToServer(operation.data!),
      fromJson: TaskModel.fromJson,
      toJson: (TaskModel task) => task.toJson(),
    );

    // Registrar handler para actualizar tareas
    offlineQueueService.registerHandler<TaskModel>(
      'update_task',
      (operation) => _sendUpdateTaskToServer(operation.data!),
      fromJson: TaskModel.fromJson,
      toJson: (TaskModel task) => task.toJson(),
    );

    // Registrar handler para eliminar tareas
    offlineQueueService.registerHandler<String>(
      'delete_task',
      (operation) => _sendDeleteTaskToServer(operation.resourceId!),
    );
  }

  Future<Either<Failure, List<TaskModel>>> getTasks() async {
    // Verificar caché con TTL
    if (_lastFetchTime != null &&
        DateTime.now().difference(_lastFetchTime!) < _cacheDuration &&
        _tasksSubject.hasValue) {
      final cachedValue = _tasksSubject.value;
      // Solo retornar de caché si es un valor exitoso
      if (cachedValue.isRight()) {
        return cachedValue;
      }
    }

    // Verificar conectividad
    final isConnected = await connectivityService.isConnected;
    if (!isConnected) {
      // Si no hay conexión y hay caché (incluso con error), usar caché
      if (_tasksSubject.hasValue) {
        return _tasksSubject.value;
      }
      return Left(NetworkFailure('No hay conexión a Internet'));
    }

    try {
      final response = await client.get(
        Uri.parse('$baseUrl/tasks'),
        headers: {'Accept-Encoding': 'gzip'}, // Solicitar compresión
      );

      if (response.statusCode == 200) {
        final List<dynamic> tasksJson = json.decode(response.body);
        final List<TaskModel> tasks =
            tasksJson.map((json) => TaskModel.fromJson(json)).toList();

        // Actualizar caché y timestamp
        final result = Right<Failure, List<TaskModel>>(tasks);
        _tasksSubject.add(result);
        _lastFetchTime = DateTime.now();

        return result;
      } else {
        final failure = _handleErrorResponse(response);
        _tasksSubject.add(Left(failure));
        return Left(failure);
      }
    } catch (e) {
      final failure = NetworkFailure(e.toString());
      _tasksSubject.add(Left(failure));
      return Left(failure);
    }
  }

  Future<Either<Failure, Unit>> addTask(TaskModel task) async {
    // Siempre hacer actualización optimista
    await _updateTasksOptimistically((tasks) => [...tasks, task]);

    // Verificar conectividad
    final isConnected = await connectivityService.isConnected;
    if (!isConnected) {
      // Si no hay conexión, agregar a la cola offline
      await offlineQueueService.addOperation(
        PendingOperation<TaskModel>(
          type: 'add_task',
          data: task,
          resourceId: task.id,
        ),
      );

      return Right(unit);
    }

    // Si hay conexión, enviar al servidor
    return await _sendAddTaskToServer(task);
  }

  Future<Either<Failure, Unit>> updateTask(TaskModel task) async {
    // Actualización optimista
    await _updateTasksOptimistically((tasks) {
      return tasks.map((t) => t.id == task.id ? task : t).toList();
    });

    // Verificar conectividad
    final isConnected = await connectivityService.isConnected;
    if (!isConnected) {
      // Si no hay conexión, agregar a la cola offline
      await offlineQueueService.addOperation(
        PendingOperation<TaskModel>(
          type: 'update_task',
          data: task,
          resourceId: task.id,
        ),
      );

      return Right(unit);
    }

    // Si hay conexión, enviar al servidor
    return await _sendUpdateTaskToServer(task);
  }

  Future<Either<Failure, Unit>> deleteTask(String id) async {
    // Guardar estado actual para posible reversión
    final currentState = _tasksSubject.value;

    // Actualización optimista: eliminar la tarea localmente primero
    await _updateTasksOptimistically(
      (tasks) => tasks.where((task) => task.id != id).toList(),
    );

    // Verificar conectividad
    final isConnected = await connectivityService.isConnected;
    if (!isConnected) {
      // Si no hay conexión, agregar a la cola offline
      await offlineQueueService.addOperation(
        PendingOperation<String>(type: 'delete_task', resourceId: id),
      );

      return Right(unit);
    }

    // Si hay conexión, enviar al servidor
    return await _sendDeleteTaskToServer(id);
  }

  // Métodos privados para enviar operaciones al servidor

  Future<Either<Failure, Unit>> _sendAddTaskToServer(TaskModel task) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/tasks'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(task.toJson()),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Operación exitosa, actualizar stream
        _updateTasksStream();
        return Right(unit);
      } else {
        // Revertir cambio optimista y manejar error
        _revertOptimisticUpdate();
        return Left(_handleErrorResponse(response));
      }
    } catch (e) {
      // Revertir cambio optimista y manejar error
      _revertOptimisticUpdate();
      return Left(NetworkFailure(e.toString()));
    }
  }

  Future<Either<Failure, Unit>> _sendUpdateTaskToServer(TaskModel task) async {
    try {
      final response = await client.put(
        Uri.parse('$baseUrl/tasks/${task.id}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(task.toJson()),
      );

      if (response.statusCode == 200) {
        return Right(unit);
      } else {
        // Revertir actualización optimista
        _revertOptimisticUpdate();
        return Left(_handleErrorResponse(response));
      }
    } catch (e) {
      // Revertir actualización optimista
      _revertOptimisticUpdate();
      return Left(NetworkFailure(e.toString()));
    }
  }

  Future<Either<Failure, Unit>> _sendDeleteTaskToServer(String id) async {
    try {
      final response = await client.delete(Uri.parse('$baseUrl/tasks/$id'));

      if (response.statusCode == 200 || response.statusCode == 204) {
        return Right(unit);
      } else {
        // Revertir al estado anterior
        _revertOptimisticUpdate();
        return Left(_handleErrorResponse(response));
      }
    } catch (e) {
      // Revertir la actualización optimista
      _revertOptimisticUpdate();
      return Left(NetworkFailure(e.toString()));
    }
  }

  // Métodos para manejar actualizaciones optimistas y reversiones

  // Respaldo para revertir actualizaciones optimistas
  Either<Failure, List<TaskModel>>? _lastKnownGoodState;

  // Actualización optimista con callback para transformar los datos
  Future<void> _updateTasksOptimistically(
    List<TaskModel> Function(List<TaskModel>) transform,
  ) async {
    if (_tasksSubject.hasValue && _tasksSubject.value.isRight()) {
      // Guardar estado actual para posible reversión
      _lastKnownGoodState = _tasksSubject.value;

      // Aplicar transformación y actualizar subject
      final tasks = _tasksSubject.value.getOrElse(() => []);
      final updatedTasks = transform(tasks);
      _tasksSubject.add(Right<Failure, List<TaskModel>>(updatedTasks));
    }
  }

  // Revertir actualización optimista
  void _revertOptimisticUpdate() {
    if (_lastKnownGoodState != null) {
      _tasksSubject.add(_lastKnownGoodState!);
      _lastKnownGoodState = null;
    }
  }

  // Método para actualizar el stream con datos actuales
  Future<void> _updateTasksStream() async {
    final result = await getTasks();
    _lastKnownGoodState = null;
  }

  // Centralizar manejo de errores HTTP
  Failure _handleErrorResponse(http.Response response) {
    switch (response.statusCode) {
      case 400:
        return BadRequestFailure();
      case 401:
        return UnauthorizedFailure();
      case 403:
        return ForbiddenFailure();
      case 404:
        return NotFoundFailure();
      case 422:
        try {
          final errorData = json.decode(response.body);
          return ValidationFailure(
            message: errorData['message'] ?? 'Validation Error',
            errors: Map<String, List<String>>.from(errorData['errors'] ?? {}),
          );
        } catch (_) {
          return ValidationFailure();
        }
      case 500:
        return InternalServerFailure();
      default:
        return ServerFailure(
          message: 'Server error ${response.statusCode}',
          statusCode: response.statusCode,
        );
    }
  }

  Stream<Either<Failure, List<TaskModel>>> watchTask() {
    // Si el subject está vacío o los datos están obsoletos, actualizar
    if (!_tasksSubject.hasValue ||
        _lastFetchTime == null ||
        DateTime.now().difference(_lastFetchTime!) > _cacheDuration) {
      getTasks().then((tasks) => null); // Iniciar carga pero no esperar
    }

    // Retornar stream con transformaciones para rendimiento
    return _tasksSubject.stream
        .distinct() // Evitar emisiones duplicadas
        .debounceTime(const Duration(milliseconds: 100)); // Evitar sobrecarga
  }

  Future<Either<Failure, Unit>> cleanTask() async {
    try {
      _tasksSubject.add(Right<Failure, List<TaskModel>>([]));
      _lastFetchTime = null;
      return Right(unit);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  void dispose() {
    _tasksSubject.close();
  }
}
