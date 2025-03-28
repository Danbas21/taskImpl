import 'package:dartz/dartz.dart' hide Task;
import 'package:dartz/dartz.dart' show Either;
import 'package:task_test/core/failures.dart';
import 'package:injectable/injectable.dart';
import 'package:task_test/core/usecases/usecase.dart';
import 'package:task_test/features/domain/repository/task_repository.dart';
import '../entities/task.dart';

@injectable
class CreateTaskParams {
  final Task task;
  const CreateTaskParams(this.task);
}

@injectable
class UpdateTaskUseCase implements UseCase<Task, CreateTaskParams> {
  final TaskRepository repository;

  UpdateTaskUseCase(this.repository);

  @override
  Future<Either<Failure, Task>> call(CreateTaskParams params) async {
    return await repository.createTask(params.task);
  }
}
