// lib/features/domain/usecases/get_task_by_id_usecase.dart
import 'package:dartz/dartz.dart' hide Task;
import 'package:injectable/injectable.dart';
import 'package:task_test/core/failures.dart';
import 'package:task_test/core/usecases/usecase.dart';
import 'package:task_test/features/domain/repository/task_repository.dart';
import '../entities/task.dart';

class GetTaskByIdParams {
  final String taskId;
  const GetTaskByIdParams(this.taskId);
}

@injectable
class GetTaskByIdUseCase implements UseCase<Task, GetTaskByIdParams> {
  final TaskRepository repository;

  GetTaskByIdUseCase(this.repository);

  @override
  Future<Either<Failure, Task>> call(GetTaskByIdParams params) async {
    return await repository.getTaskById(params.taskId);
  }
}
