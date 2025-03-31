import 'dart:async';

import 'package:dartz/dartz.dart' hide Task;
import 'package:dartz/dartz.dart' show Either;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:task_test/core/failures.dart';
import 'package:task_test/core/usecases/usecase.dart';
import 'package:task_test/features/domain/entities/task.dart';
import 'package:task_test/features/domain/usecases/clear_task.dart';
import 'package:task_test/features/domain/usecases/create_task.dart';
import 'package:task_test/features/domain/usecases/delete_task.dart';
import 'package:task_test/features/domain/usecases/get_task_by_id_usecase.dart';
import 'package:task_test/features/domain/usecases/get_tasks.dart';
import 'package:task_test/features/domain/usecases/observe_task.dart';
import 'package:task_test/features/domain/usecases/refresh_task.dart';
import 'package:task_test/features/domain/usecases/update_task.dart';

part 'task_bloc.freezed.dart';
part 'task_event.dart';
part 'task_state.dart';
 // o @lazySingleton para hacerlo síncrono

class TaskBloc extends Bloc<TaskEvent, TaskState>  {
  final GetTasksUseCase _getTasksUseCase;
  final UpdateTaskUseCase _updateTaskUseCase;
  final DeleteTaskUseCase _deleteTaskUseCase;
  final CreateTaskUseCase _addTaskUseCase;
  final ClearCacheTasks _clearCacheTasksUseCase;
  final GetTaskByIdUseCase _getTaskByIdUseCase;
  final WatchTasks _watchTasksUseCase;
  final RefreshTask _refreshTaskUseCase;

  TaskBloc(
    this._getTasksUseCase,
    this._updateTaskUseCase,
    this._deleteTaskUseCase,
    this._addTaskUseCase,
    this._clearCacheTasksUseCase,
    this._getTaskByIdUseCase,
    this._watchTasksUseCase,
    this._refreshTaskUseCase,
  ) : super(const TaskState.initial()) {
    on<_FetchTasks>(_onFetchTasks);
    on<_UpdateTask>(_onUpdateTask);
    on<_DeleteTask>(_onDeleteTask);
    on<_AddTask>(_onAddTask);
    on<_ClearCache>(_onClearCache);
    on<_GetTaskById>(_onGetTaskById);
    on<_WatchTasks>(_onWatchTasks);
    on<_RefreshTask>(_onRefreshTask);
  }

  StreamSubscription<Either<Failure, List<Task>>>? _taskStreamSubscription;

  Future<void> _onFetchTasks(_FetchTasks event, Emitter<TaskState> emit) async {
    emit(const TaskState.loading());
    
    final result = await _getTasksUseCase(NoParams());
    
    emit(result.fold(
      (failure) => TaskState.error(failure),
      (tasks) => TaskState.loaded(tasks),
    ));
  }

  Future<void> _onUpdateTask(_UpdateTask event, Emitter<TaskState> emit) async {
    // No mostrar loading para actualizaciones (enfoque optimista)
    
    final result = await _updateTaskUseCase(event.params);
    
    // En caso de error, refrescar lista completa
    result.fold(
      (failure) => add(const TaskEvent.fetchTasks()),
      (_) => null, // Ya fue actualizado optimistamente
    );
  }

  // Implementa otros handlers de forma similar

  FutureOr<void> _onDeleteTask(event, Emitter<TaskState> emit)async {
    // No mostrar loading para eliminaciones (enfoque optimista)
    
    final result = await _deleteTaskUseCase(event.id);
    
    // En caso de error, refrescar lista completa
    result.fold(
      (failure) => add(const TaskEvent.fetchTasks()),
      (_) => null, // Ya fue eliminado optimistamente
    );
  }

  FutureOr<void> _onAddTask(event, Emitter<TaskState> emit) async {
    // No mostrar loading para adiciones (enfoque optimista)
    
    final result = await _addTaskUseCase(event.params);
    
    // En caso de error, refrescar lista completa
    result.fold(
      (failure) => add(const TaskEvent.fetchTasks()),
      (_) => null, // Ya fue añadido optimistamente
    );
  }
  FutureOr<void> _onClearCache(event, Emitter<TaskState> emit) async {
    emit(const TaskState.loading());
    
    final result = await _clearCacheTasksUseCase(NoParams());
    
    emit(result.fold(
      (failure) => TaskState.error(failure),
      (_) => const TaskState.initial(),
    ));
  }
  FutureOr<void> _onGetTaskById(event, Emitter<TaskState> emit) async {
    emit(const TaskState.loading());
    
    final result = await _getTaskByIdUseCase(event.id);
    
    emit(result.fold(
      (failure) => TaskState.error(failure),
      (task) => TaskState.loaded([task]),
    ));

    
  }
  
  FutureOr<void> _onWatchTasks(event, Emitter<TaskState> emit) {


  emit(const TaskState.loading());
  
  // Usar el método .listen para manejar las emisiones del Stream
  _taskStreamSubscription?.cancel();
  _taskStreamSubscription = _watchTasksUseCase(NoParams()).listen(
    (result) {
      emit(result.fold(
        (failure) => TaskState.error(failure),
        (tasks) => TaskState.loaded(tasks),
      ));
    },
  );




  }
  FutureOr<void> _onRefreshTask(event, Emitter<TaskState> emit)async {
  emit(const TaskState.loading());
  final result = await _refreshTaskUseCase(NoParams());
  emit(result.fold(
    (failure) => TaskState.error(failure),
    (_) => const TaskState.initial(),
  ));
  }

  @override
Future<void> close() {
  _taskStreamSubscription?.cancel();
  return super.close();
}
}

