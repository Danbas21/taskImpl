import 'package:dartz/dartz.dart' hide Task; // Oculta la clase Task de dartz
import 'package:dartz/dartz.dart' show Either;
import 'package:task_test/core/failures.dart';

import '../entities/task.dart';

abstract class TaskRepository {
  Future<Either<Failure, List<Task>>> getTasks();
  Future<Either<Failure, Task>> createTask(Task task);
  Future<Either<Failure, Task>> updateTask(Task task);
  Future<Either<Failure, Task>> deleteTask(String taskId);
  Future<Either<Failure, Task>> getTaskById(String taskId);
  Stream<Either<Failure, List<Task>>> watchTasks();

  /// Limpia la caché de tareas
  Future<Either<Failure, void>> clearTaskCache();

  /// Fuerza la recarga de datos desde la fuente remota
  Future<Either<Failure, List<Task>>> refreshTasks();
}
