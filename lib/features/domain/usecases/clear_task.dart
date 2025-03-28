import 'package:dartz/dartz.dart' hide Task;
import 'package:dartz/dartz.dart' show Either;
import 'package:task_test/core/failures.dart';
import 'package:injectable/injectable.dart';
import 'package:task_test/core/usecases/usecase.dart';
import 'package:task_test/features/domain/repository/task_repository.dart';

@injectable
class ClearCacheTasks implements UseCase<void, NoParams> {
  final TaskRepository repository;

  ClearCacheTasks(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await repository.clearTaskCache();
  }
}
