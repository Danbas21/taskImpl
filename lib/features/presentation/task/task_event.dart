part of 'task_bloc.dart';

@freezed
sealed class TaskEvent with _$TaskEvent {
  const factory TaskEvent.fetchTasks() = _FetchTasks;
  const factory TaskEvent.updateTask(UpdateTaskParams params) = _UpdateTask;
  const factory TaskEvent.deleteTask(String id) = _DeleteTask;
  const factory TaskEvent.addTask(CreateTaskParams params) = _AddTask;
  const factory TaskEvent.clearCache() = _ClearCache;
  const factory TaskEvent.getTaskById(String id) = _GetTaskById;
  const factory TaskEvent.watchTasks() = _WatchTasks;
  const factory TaskEvent.refreshTask(String id) = _RefreshTask;
}