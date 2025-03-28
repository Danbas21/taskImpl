import 'package:dartz/dartz.dart';
import 'package:rxdart/rxdart.dart';
import 'package:task_test/core/failures.dart';
import 'package:task_test/features/domain/repository/task_repository.dart';
import '../../domain/entities/task.dart';

import '../datasources/task_remote_data_source.dart';
import '../models/task_model.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskRemoteDataSource remoteDataSource;

  TaskRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, void>> clearTaskCache() {
    // TODO: implement clearTaskCache
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, Task>> createTask(Task task) {
    // TODO: implement createTask
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, Task>> deleteTask(String taskId) {
    // TODO: implement deleteTask
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, Task>> getTaskById(String taskId) {
    // TODO: implement getTaskById
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, List<Task>>> getTasks() {
    // TODO: implement getTasks
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, List<Task>>> refreshTasks() {
    // TODO: implement refreshTasks
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, Task>> updateTask(Task task) {
    // TODO: implement updateTask
    throw UnimplementedError();
  }

  @override
  Stream<Either<Failure, List<Task>>> watchTasks() {
    // TODO: implement watchTasks
    throw UnimplementedError();
  }
}
