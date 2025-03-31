// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:cloud_firestore/cloud_firestore.dart' as _i974;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../../features/data/datasources/task_remote_data_source.dart' as _i922;
import '../../features/domain/repository/task_repository.dart' as _i509;
import '../../features/domain/usecases/clear_task.dart' as _i447;
import '../../features/domain/usecases/create_task.dart' as _i991;
import '../../features/domain/usecases/delete_task.dart' as _i129;
import '../../features/domain/usecases/get_task_by_id_usecase.dart' as _i392;
import '../../features/domain/usecases/get_tasks.dart' as _i485;
import '../../features/domain/usecases/observe_task.dart' as _i984;
import '../../features/domain/usecases/refresh_task.dart' as _i749;
import '../../features/domain/usecases/update_task.dart' as _i213;
import '../../features/presentation/task/task_bloc.dart' as _i280;
import '../network/connectivity_service.dart' as _i491;
import '../network/network_info.dart' as _i932;
import '../network/offline_queue.dart' as _i906;
import '../storage/storage_service.dart' as _i865;
import '../utils/retry_service.dart' as _i57;
import 'injection.dart' as _i464;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final coreModule = _$CoreModule();
    final repositoryModule = _$RepositoryModule();
    gh.lazySingleton<_i974.FirebaseFirestore>(() => coreModule.firestore);
    gh.lazySingletonAsync<_i865.StorageService>(
      () => _i865.StorageServiceImpl.create(),
    );
    gh.lazySingleton<_i491.ConnectivityService>(
      () => _i491.ConnectivityServiceImpl.create(),
    );
    gh.lazySingleton<_i57.RetryService>(() => _i57.RetryServiceImpl());
    gh.factory<_i213.UpdateTaskParams>(
      () => _i213.UpdateTaskParams(
        id: gh<String>(),
        title: gh<String>(),
        description: gh<String>(),
        dueDate: gh<DateTime>(),
        isCompleted: gh<bool>(),
      ),
    );
    gh.factory<_i991.CreateTaskParams>(
      () => _i991.CreateTaskParams(
        title: gh<String>(),
        description: gh<String>(),
        dueDate: gh<DateTime>(),
        isCompleted: gh<bool>(),
      ),
    );
    gh.lazySingleton<_i932.NetworkInfo>(
      () => _i932.NetworkInfoImpl(gh<_i491.ConnectivityService>()),
    );
    gh.lazySingletonAsync<_i906.OfflineQueueService>(
      () async => _i906.OfflineQueueServiceImpl.create(
        await getAsync<_i865.StorageService>(),
        gh<_i491.ConnectivityService>(),
      ),
    );
    gh.factoryAsync<_i922.TaskDataSource>(
      () async => _i922.TaskFirestoreDataSource(
        firestore: gh<_i974.FirebaseFirestore>(),
        connectivityService: gh<_i491.ConnectivityService>(),
        offlineQueueService: await getAsync<_i906.OfflineQueueService>(),
      ),
    );
    gh.lazySingletonAsync<_i509.TaskRepository>(
      () async => repositoryModule.provideTaskRepository(
        await getAsync<_i922.TaskDataSource>(),
      ),
    );
    gh.factoryAsync<_i447.ClearCacheTasks>(
      () async => _i447.ClearCacheTasks(await getAsync<_i509.TaskRepository>()),
    );
    gh.factoryAsync<_i213.UpdateTaskUseCase>(
      () async =>
          _i213.UpdateTaskUseCase(await getAsync<_i509.TaskRepository>()),
    );
    gh.factoryAsync<_i991.CreateTaskUseCase>(
      () async =>
          _i991.CreateTaskUseCase(await getAsync<_i509.TaskRepository>()),
    );
    gh.factoryAsync<_i984.WatchTasks>(
      () async => _i984.WatchTasks(await getAsync<_i509.TaskRepository>()),
    );
    gh.factoryAsync<_i392.GetTaskByIdUseCase>(
      () async =>
          _i392.GetTaskByIdUseCase(await getAsync<_i509.TaskRepository>()),
    );
    gh.factoryAsync<_i485.GetTasksUseCase>(
      () async => _i485.GetTasksUseCase(await getAsync<_i509.TaskRepository>()),
    );
    gh.factoryAsync<_i129.DeleteTaskUseCase>(
      () async =>
          _i129.DeleteTaskUseCase(await getAsync<_i509.TaskRepository>()),
    );
    gh.factoryAsync<_i749.RefreshTask>(
      () async => _i749.RefreshTask(await getAsync<_i509.TaskRepository>()),
    );
    gh.singletonAsync<_i280.TaskBloc>(
      () async => repositoryModule.provideTaskBloc(
        await getAsync<_i485.GetTasksUseCase>(),
        await getAsync<_i213.UpdateTaskUseCase>(),
        await getAsync<_i129.DeleteTaskUseCase>(),
        await getAsync<_i991.CreateTaskUseCase>(),
        await getAsync<_i447.ClearCacheTasks>(),
        await getAsync<_i392.GetTaskByIdUseCase>(),
        await getAsync<_i984.WatchTasks>(),
        await getAsync<_i749.RefreshTask>(),
      ),
    );
    return this;
  }
}

class _$CoreModule extends _i464.CoreModule {}

class _$RepositoryModule extends _i464.RepositoryModule {}
