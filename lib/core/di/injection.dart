import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:task_test/features/data/datasources/task_remote_data_source.dart';
import 'package:task_test/features/data/repositories/task_repository_impl.dart';
import 'package:task_test/features/domain/repository/task_repository.dart';

import 'injection.config.dart';

final GetIt getIt = GetIt.instance;

@module
abstract class CoreModule {
  @Named("apiBaseUrl")
  String get apiBaseUrl => 'https://api-example.com';

  @lazySingleton
  http.Client get httpClient => http.Client();

  get http => null;
}

@module
abstract class RepositoryModule {
  @lazySingleton
  TaskRepository providesTaskRepository(
    TaskRemoteDataSourceImpl remoteDataSource,
    // Otros parámetros que necesite tu implementación
  ) => TaskRepositoryImpl(
    remoteDataSource,
    // Otros parámetros
  );
}
