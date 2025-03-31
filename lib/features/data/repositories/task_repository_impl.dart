import 'dart:async';

import 'package:dartz/dartz.dart' hide Task; // Oculta la clase Task de dartz
import 'package:task_test/core/failures.dart';
import 'package:task_test/features/data/datasources/task_remote_data_source.dart';
import 'package:task_test/features/data/models/task_model.dart';
import 'package:task_test/features/domain/repository/task_repository.dart';

import '../../domain/entities/task.dart';


class TaskRepositoryImpl implements TaskRepository {
  final TaskDataSource remoteDataSource;

  TaskRepositoryImpl(this.remoteDataSource);

@override
Future<Either<Failure, void>> clearTaskCache() {
  return remoteDataSource.cleanTask().then((result) {
    return result.fold(
      (failure) => Left(failure),
      (_) => const Right(null)
    );
  });
}

@override
Future<Either<Failure, Task>> createTask(Task task) async {
  final taskModel = TaskModel.fromDomain(task);
  return remoteDataSource.addTask(taskModel).then((result) {
    return result.fold(
      (failure) => Left(failure),
      (_) => Right(task)
    );
  });
}
 @override
Future<Either<Failure, Task>> deleteTask(String taskId) {
  // Primero deberías obtener la tarea para poder devolverla
  return getTaskById(taskId).then((taskResult) {
    return taskResult.fold(
      (failure) => Left(failure),
      (task) => remoteDataSource.deleteTask(taskId).then((result) {
        return result.fold(
          (failure) => Left(failure),
          (_) => Right(task)  // Devuelve la tarea que se eliminó
        );
      })
    );
  });
}

 @override
Future<Either<Failure, Task>> getTaskById(String taskId) {
  return remoteDataSource.getTaskById(taskId).then((result) {
    return result.fold(
      (failure) => Left(failure),
      (taskModel) => Right(taskModel.toDomain())
    );
  });
}
@override
Future<Either<Failure, List<Task>>> getTasks() {
  return remoteDataSource.getTasks().then((result) {
    return result.fold(
      (failure) => Left(failure),
      (taskModels) => Right(taskModels.map((model) => model.toDomain()).toList())
    );
  });
}

 @override
Future<Either<Failure, List<Task>>> refreshTasks() {
  // Primero limpiar la caché si es necesario
  return remoteDataSource.cleanTask().then((_) {
    // Luego obtener datos frescos
    return remoteDataSource.getTasks().then((result) {
      return result.fold(
        (failure) => Left(failure),
        (taskModels) => Right(taskModels.map((model) => model.toDomain()).toList())
      );
    });
  });
}

    @override
    Future<Either<Failure, Task>> updateTask(Task task) {
      return remoteDataSource.updateTask(TaskModel.fromDomain(task)).then((result) {
        return result.fold(
          (failure) => Left(failure),
          (taskModel) => Right(task)
        );
      });
    }
@override
Stream<Either<Failure, List<Task>>> watchTasks() {
  final controller = StreamController<Either<Failure, List<Task>>>();
  
  final subscription = remoteDataSource.watchTask().listen((result) {
    result.fold(
      (failure) => controller.add(Left(failure)),
      (taskModels) => controller.add(Right(taskModels.map((model) => model.toDomain()).toList()))
    );
  }, onError: controller.addError);
  
  // Asegurar que el controller se cierre correctamente cuando el stream se cierre
  controller.onCancel = () {
    subscription.cancel();
    controller.close();
  };
  
  return controller.stream;
}
}
