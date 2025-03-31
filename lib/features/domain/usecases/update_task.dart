import 'package:dartz/dartz.dart' hide Task;
import 'package:dartz/dartz.dart' show Either;
import 'package:injectable/injectable.dart';
import 'package:task_test/core/failures.dart';
import 'package:task_test/core/usecases/usecase.dart';
import 'package:task_test/features/domain/repository/task_repository.dart';

import '../entities/task.dart';

@injectable
class UpdateTaskParams {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final bool isCompleted;

  const UpdateTaskParams({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.isCompleted,
  });
  
  // Método de fábrica útil
  factory UpdateTaskParams.fromTask(Task task) => UpdateTaskParams(
    id: task.id,
    title: task.title,
    description: task.description,
    dueDate: task.dueDate,
    isCompleted: task.isCompleted,
  );
}


@injectable
class UpdateTaskUseCase implements UseCase<Task, UpdateTaskParams> {
  final TaskRepository repository;

  UpdateTaskUseCase(this.repository);

  @override
  Future<Either<Failure, Task>> call(UpdateTaskParams params) async {
    // Crear la entidad Task a partir de los parámetros
    final task = Task(
      id: params.id,
      title: params.title,
      description: params.description,
      dueDate: params.dueDate,
      isCompleted: params.isCompleted,
    );
    
    return await repository.updateTask(task);
  }
}