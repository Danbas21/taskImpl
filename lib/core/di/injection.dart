// En lib/core/di/injection.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:task_test/features/data/datasources/task_remote_data_source.dart';
import 'package:task_test/features/data/repositories/task_repository_impl.dart';
import 'package:task_test/features/domain/repository/task_repository.dart';
import 'package:task_test/features/domain/usecases/clear_task.dart';
import 'package:task_test/features/domain/usecases/create_task.dart';
import 'package:task_test/features/domain/usecases/delete_task.dart';
import 'package:task_test/features/domain/usecases/get_task_by_id_usecase.dart';
import 'package:task_test/features/domain/usecases/get_tasks.dart';
import 'package:task_test/features/domain/usecases/observe_task.dart';
import 'package:task_test/features/domain/usecases/refresh_task.dart';
import 'package:task_test/features/domain/usecases/update_task.dart';
import 'package:task_test/features/presentation/task/task_bloc.dart';

// Usar part para incluir el archivo generado
import 'injection.config.dart';

final GetIt getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: true,
  throwOnMissingDependencies: false // Ignorar dependencias faltantes
)
void configureDependencies() => getIt.init();

@module
abstract class CoreModule {
  // Todavía podemos mantener esto para otras partes de la app que usen HTTP

  // Añadir Firestore
  @lazySingleton
  FirebaseFirestore get firestore => FirebaseFirestore.instance;
}


@module
abstract class RepositoryModule {
  // Primero registra el repositorio
  @lazySingleton
  TaskRepository provideTaskRepository(
    TaskDataSource dataSource,
  ) {
    return TaskRepositoryImpl(dataSource);
  }

  // Luego el bloc
  @singleton
  TaskBloc provideTaskBloc(
    GetTasksUseCase getTasksUseCase,
    UpdateTaskUseCase updateTaskUseCase,
    DeleteTaskUseCase deleteTaskUseCase,
    CreateTaskUseCase createTaskUseCase,
    ClearCacheTasks clearCacheTasksUseCase,
    GetTaskByIdUseCase getTaskByIdUseCase,
    WatchTasks watchTasksUseCase,
    RefreshTask refreshTaskUseCase,
  ) {
    return TaskBloc(
      getTasksUseCase,
      updateTaskUseCase,
      deleteTaskUseCase,
      createTaskUseCase,
      clearCacheTasksUseCase,
      getTaskByIdUseCase,
      watchTasksUseCase,
      refreshTaskUseCase,
    );
  }
}