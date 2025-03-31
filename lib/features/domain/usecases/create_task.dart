import 'package:dartz/dartz.dart' hide Task;
import 'package:dartz/dartz.dart' show Either;
import 'package:injectable/injectable.dart';
import 'package:task_test/core/failures.dart';
import 'package:task_test/core/usecases/usecase.dart';
import 'package:task_test/features/domain/repository/task_repository.dart';
import 'package:uuid/uuid.dart';

import '../entities/task.dart';

@injectable
class CreateTaskParams {
  final String title;
  final String description;
  final DateTime dueDate;
  final bool isCompleted;

  const CreateTaskParams({
    required this.title,
    required this.description,
    required this.dueDate,
    this.isCompleted = false,
  });
}



@injectable
class CreateTaskUseCase implements UseCase<Task, CreateTaskParams> {
  final TaskRepository repository;

  CreateTaskUseCase(this.repository);

  @override
  Future<Either<Failure, Task>> call(CreateTaskParams params) async {
    // Crear una nueva entidad Task con un ID generado
    final task = Task(
      id: Uuid().v4(), // Generar un nuevo ID
      title: params.title,
      description: params.description,
      dueDate: params.dueDate,
      isCompleted: params.isCompleted,
    );
    
    return await repository.createTask(task);
  }
}