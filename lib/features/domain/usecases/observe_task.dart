import 'package:dartz/dartz.dart' hide Task;
import 'package:dartz/dartz.dart' show Either;
import 'package:task_test/core/failures.dart';
import 'package:injectable/injectable.dart';
import 'package:task_test/core/usecases/usecase.dart';
import 'package:task_test/features/domain/repository/task_repository.dart';
import '../entities/task.dart';

@injectable
class WatchTasks implements StreamUseCase<List<Task>, NoParams> {
  final TaskRepository repository;

  WatchTasks(this.repository);

  @override
  Stream<Either<Failure, List<Task>>> call(NoParams params) {
    return repository.watchTasks();
  }
}
