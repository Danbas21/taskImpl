part of 'task_bloc.dart';

@freezed
sealed class TaskState with _$TaskState {
  const factory TaskState.initial() = Initial;
  const factory TaskState.loading() = Loading;
  const factory TaskState.loaded(List<Task> tasks) = Loaded;
  const factory TaskState.error(Failure failure) = Error;
}