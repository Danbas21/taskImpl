import 'package:dartz/dartz.dart' hide Task;
import 'package:dartz/dartz.dart' show Either;
import 'package:task_test/core/failures.dart';
import 'package:injectable/injectable.dart';
import 'package:task_test/core/usecases/usecase.dart';
import 'package:task_test/features/domain/repository/task_repository.dart';
import '../entities/task.dart';

class DeleteTaskParams {
  final String taskId;
  const DeleteTaskParams(this.taskId);
}

@injectable
class DeleteTaskUseCase implements UseCase<Task, DeleteTaskParams> {
  final TaskRepository repository;

  DeleteTaskUseCase(this.repository);

  @override
  Future<Either<Failure, Task>> call(DeleteTaskParams params) async {
    return await repository.deleteTask(params.taskId);
  }
}
