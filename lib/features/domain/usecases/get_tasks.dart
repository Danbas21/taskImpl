import 'package:dartz/dartz.dart' hide Task;
import 'package:dartz/dartz.dart' show Either;
import 'package:task_test/core/failures.dart';
import 'package:injectable/injectable.dart';
import 'package:task_test/core/usecases/usecase.dart';
import 'package:task_test/features/domain/repository/task_repository.dart';
import '../entities/task.dart';

@injectable
class GetTasksUseCase implements UseCase<List<Task>, NoParams> {
  final TaskRepository repository;

  GetTasksUseCase(this.repository);

  @override
  Future<Either<Failure, List<Task>>> call(NoParams params) async {
    return await repository.getTasks();
  }
}
