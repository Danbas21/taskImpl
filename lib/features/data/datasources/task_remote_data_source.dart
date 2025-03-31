import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';
import 'package:task_test/core/failures.dart';
import 'package:task_test/core/network/connectivity_service.dart';
import 'package:task_test/core/network/offline_queue.dart';
import 'package:task_test/features/data/models/task_model.dart';

abstract class TaskDataSource {
  Future<Either<Failure, TaskModel>> getTaskById(String taskId);
  Future<Either<Failure, List<TaskModel>>> getTasks();
  Future<Either<Failure, Unit>> addTask(TaskModel task);
  Future<Either<Failure, Unit>> updateTask(TaskModel task);
  Future<Either<Failure, Unit>> deleteTask(String id);
  Stream<Either<Failure, List<TaskModel>>> watchTask();
  Future<Either<Failure, Unit>> cleanTask();
}

@Injectable(as: TaskDataSource)
class TaskFirestoreDataSource implements TaskDataSource {

  final FirebaseFirestore _firestore;
  final ConnectivityService _connectivityService;
  final OfflineQueueService _offlineQueueService;
  final BehaviorSubject<Either<Failure, List<TaskModel>>> _tasksSubject =
      BehaviorSubject<Either<Failure, List<TaskModel>>>();
  DateTime? _lastFetchTime;
  static const _cacheDuration = Duration(minutes: 5);

  TaskFirestoreDataSource({
    required FirebaseFirestore firestore,
    required ConnectivityService connectivityService,
    required OfflineQueueService offlineQueueService,
  })  : _firestore = firestore,
        _connectivityService = connectivityService,
        _offlineQueueService = offlineQueueService {
    _registerOfflineHandlers();
    // Suscribirse a cambios en Firestore para mantener el caché actualizado
    _setupFirestoreListener();
  }

    // Referencia a la colección de tareas
  CollectionReference<Map<String, dynamic>> get _tasksCollection =>
      _firestore.collection('tasks');

  void _setupFirestoreListener() {
    // Esta suscripción mantendrá _tasksSubject actualizado automáticamente
    _tasksCollection.snapshots().listen((snapshot) {
      try {
        final tasks = snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id; // Asegurar que el ID esté incluido
          return TaskModel.fromJson(data);
        }).toList();
        
        _tasksSubject.add(Right(tasks));
        _lastFetchTime = DateTime.now();
      } catch (e) {
        // No actualizar el subject en caso de error para mantener los datos anteriores
        print('Error en Firestore listener: $e');
      }
    }, onError: (error) {
      print('Error en Firestore listener: $error');
      // No actualizamos el subject para mantener los últimos datos buenos
    });
  }

  /// Registra los handlers para operaciones offline
  void _registerOfflineHandlers() {
    // Registrar handler para añadir tareas
    _offlineQueueService.registerHandler<TaskModel>(
      'add_task',
      (operation) => _sendAddTaskToServer(operation.data!),
      fromJson: TaskModel.fromJson,
      toJson: (TaskModel task) => task.toJson(),
    );

    // Registrar handler para actualizar tareas
    _offlineQueueService.registerHandler<TaskModel>(
      'update_task',
      (operation) => _sendUpdateTaskToServer(operation.data!),
      fromJson: TaskModel.fromJson,
      toJson: (TaskModel task) => task.toJson(),
    );

    // Registrar handler para eliminar tareas
    _offlineQueueService.registerHandler<String>(
      'delete_task',
      (operation) => _sendDeleteTaskToServer(operation.resourceId!),
    );
  }

  
  Future<Either<Failure, TaskModel>> getTaskById(String taskId) async {
  // Verificar conectividad
  final isConnected = await _connectivityService.isConnected;
  if (!isConnected) {
    return Left(NetworkFailure('No hay conexión a Internet'));
  }

  try {
  final docSnapshot = await _tasksCollection.doc(taskId).get();
      
     if (docSnapshot.exists) {
        final data = docSnapshot.data()!;
        data['id'] = docSnapshot.id;
        final task = TaskModel.fromJson(data);
        return Right(task);
      } else {
        return Left(NotFoundFailure());
      }
    } catch (e) {
      return Left(NetworkFailure(e.toString()));
    }
  }
  
  /// Obtener todas las tareas
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
    final isConnected = await _connectivityService.isConnected;
    if (!isConnected) {
      // Si no hay conexión y hay caché (incluso con error), usar caché
      if (_tasksSubject.hasValue) {
        return _tasksSubject.value;
      }
      return Left(NetworkFailure('No hay conexión a Internet'));
    }

    try {
      final snapshot = await _tasksCollection.get();
      final tasks = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return TaskModel.fromJson(data);
      }).toList();

      // Actualizar caché y timestamp
      final result = Right<Failure, List<TaskModel>>(tasks);
      _tasksSubject.add(result);
      _lastFetchTime = DateTime.now();

      return result;
    } catch (e) {
      final failure = NetworkFailure(e.toString());
      return Left(failure);
    }
  }
  /// Agregar una tarea
  Future<Either<Failure, Unit>> addTask(TaskModel task) async {
    // Crear una nueva tarea con ID temporal si es necesario
    final taskToAdd = task.id.isEmpty
        ? task.copyWith(id: _firestore.collection('tasks').doc().id)
        : task;

    // Siempre hacer actualización optimista
    await _updateTasksOptimistically((tasks) => [...tasks, taskToAdd]);

    // Verificar conectividad
    final isConnected = await _connectivityService.isConnected;
    if (!isConnected) {
      // Si no hay conexión, agregar a la cola offline
      await _offlineQueueService.addOperation(
        PendingOperation<TaskModel>(
          type: 'add_task',
          data: taskToAdd,
          resourceId: taskToAdd.id,
        ),
      );

      return Right(unit);
    }

    // Si hay conexión, enviar a Firestore
    return await _sendAddTaskToServer(taskToAdd);
  }

  
  Future<Either<Failure, Unit>> updateTask(TaskModel task) async {
    // Actualización optimista
    await _updateTasksOptimistically((tasks) {
      return tasks.map((t) => t.id == task.id ? task : t).toList();
    });

    // Verificar conectividad
    final isConnected = await _connectivityService.isConnected;
    if (!isConnected) {
      // Si no hay conexión, agregar a la cola offline
      await _offlineQueueService.addOperation(
        PendingOperation<TaskModel>(
          type: 'update_task',
          data: task,
          resourceId: task.id,
        ),
      );

      return Right(unit);
    }

    // Si hay conexión, enviar a Firestore
    return await _sendUpdateTaskToServer(task);
  }

 Future<Either<Failure, Unit>> deleteTask(String id) async {
    // Actualización optimista: eliminar la tarea localmente primero
    await _updateTasksOptimistically(
      (tasks) => tasks.where((task) => task.id != id).toList(),
    );

    // Verificar conectividad
    final isConnected = await _connectivityService.isConnected;
    if (!isConnected) {
      // Si no hay conexión, agregar a la cola offline
      await _offlineQueueService.addOperation(
        PendingOperation<String>(type: 'delete_task', resourceId: id),
      );

      return Right(unit);
    }

    // Si hay conexión, enviar a Firestore
    return await _sendDeleteTaskToServer(id);
  }

  // Métodos privados para enviar operaciones al servidor

   Future<Either<Failure, Unit>> _sendAddTaskToServer(TaskModel task) async {
    try {
      // Remover el id del objeto para que Firestore use el de la ruta
      final taskData = task.toJson();
      
      // No enviamos el ID en los datos para evitar duplicación
      if (taskData.containsKey('id')) {
        taskData.remove('id');
      }
      
      await _tasksCollection.doc(task.id).set(taskData);
      return Right(unit);
    } catch (e) {
      // Revertir cambio optimista y manejar error
      _revertOptimisticUpdate();
      return Left(NetworkFailure(e.toString()));
    }
  }


 Future<Either<Failure, Unit>> _sendUpdateTaskToServer(TaskModel task) async {
    try {
      // Remover el id del objeto para que Firestore use el de la ruta
      final taskData = task.toJson();
      if (taskData.containsKey('id')) {
        taskData.remove('id');
      }
      
      await _tasksCollection.doc(task.id).update(taskData);
      return Right(unit);
    } catch (e) {
      // Revertir actualización optimista
      _revertOptimisticUpdate();
      return Left(NetworkFailure(e.toString()));
    }
  }

    Future<Either<Failure, Unit>> _sendDeleteTaskToServer(String id) async {
    try {
      await _tasksCollection.doc(id).delete();
      return Right(unit);
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

  Future<Either<Failure, Unit>>   cleanTask() async {
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
