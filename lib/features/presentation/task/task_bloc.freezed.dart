// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'task_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TaskEvent {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TaskEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'TaskEvent()';
}


}

/// @nodoc
class $TaskEventCopyWith<$Res>  {
$TaskEventCopyWith(TaskEvent _, $Res Function(TaskEvent) __);
}


/// @nodoc


class _FetchTasks implements TaskEvent {
  const _FetchTasks();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FetchTasks);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'TaskEvent.fetchTasks()';
}


}




/// @nodoc


class _UpdateTask implements TaskEvent {
  const _UpdateTask(this.params);
  

 final  UpdateTaskParams params;

/// Create a copy of TaskEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateTaskCopyWith<_UpdateTask> get copyWith => __$UpdateTaskCopyWithImpl<_UpdateTask>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateTask&&(identical(other.params, params) || other.params == params));
}


@override
int get hashCode => Object.hash(runtimeType,params);

@override
String toString() {
  return 'TaskEvent.updateTask(params: $params)';
}


}

/// @nodoc
abstract mixin class _$UpdateTaskCopyWith<$Res> implements $TaskEventCopyWith<$Res> {
  factory _$UpdateTaskCopyWith(_UpdateTask value, $Res Function(_UpdateTask) _then) = __$UpdateTaskCopyWithImpl;
@useResult
$Res call({
 UpdateTaskParams params
});




}
/// @nodoc
class __$UpdateTaskCopyWithImpl<$Res>
    implements _$UpdateTaskCopyWith<$Res> {
  __$UpdateTaskCopyWithImpl(this._self, this._then);

  final _UpdateTask _self;
  final $Res Function(_UpdateTask) _then;

/// Create a copy of TaskEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? params = null,}) {
  return _then(_UpdateTask(
null == params ? _self.params : params // ignore: cast_nullable_to_non_nullable
as UpdateTaskParams,
  ));
}


}

/// @nodoc


class _DeleteTask implements TaskEvent {
  const _DeleteTask(this.id);
  

 final  String id;

/// Create a copy of TaskEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DeleteTaskCopyWith<_DeleteTask> get copyWith => __$DeleteTaskCopyWithImpl<_DeleteTask>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DeleteTask&&(identical(other.id, id) || other.id == id));
}


@override
int get hashCode => Object.hash(runtimeType,id);

@override
String toString() {
  return 'TaskEvent.deleteTask(id: $id)';
}


}

/// @nodoc
abstract mixin class _$DeleteTaskCopyWith<$Res> implements $TaskEventCopyWith<$Res> {
  factory _$DeleteTaskCopyWith(_DeleteTask value, $Res Function(_DeleteTask) _then) = __$DeleteTaskCopyWithImpl;
@useResult
$Res call({
 String id
});




}
/// @nodoc
class __$DeleteTaskCopyWithImpl<$Res>
    implements _$DeleteTaskCopyWith<$Res> {
  __$DeleteTaskCopyWithImpl(this._self, this._then);

  final _DeleteTask _self;
  final $Res Function(_DeleteTask) _then;

/// Create a copy of TaskEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? id = null,}) {
  return _then(_DeleteTask(
null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class _AddTask implements TaskEvent {
  const _AddTask(this.params);
  

 final  CreateTaskParams params;

/// Create a copy of TaskEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AddTaskCopyWith<_AddTask> get copyWith => __$AddTaskCopyWithImpl<_AddTask>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AddTask&&(identical(other.params, params) || other.params == params));
}


@override
int get hashCode => Object.hash(runtimeType,params);

@override
String toString() {
  return 'TaskEvent.addTask(params: $params)';
}


}

/// @nodoc
abstract mixin class _$AddTaskCopyWith<$Res> implements $TaskEventCopyWith<$Res> {
  factory _$AddTaskCopyWith(_AddTask value, $Res Function(_AddTask) _then) = __$AddTaskCopyWithImpl;
@useResult
$Res call({
 CreateTaskParams params
});




}
/// @nodoc
class __$AddTaskCopyWithImpl<$Res>
    implements _$AddTaskCopyWith<$Res> {
  __$AddTaskCopyWithImpl(this._self, this._then);

  final _AddTask _self;
  final $Res Function(_AddTask) _then;

/// Create a copy of TaskEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? params = null,}) {
  return _then(_AddTask(
null == params ? _self.params : params // ignore: cast_nullable_to_non_nullable
as CreateTaskParams,
  ));
}


}

/// @nodoc


class _ClearCache implements TaskEvent {
  const _ClearCache();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ClearCache);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'TaskEvent.clearCache()';
}


}




/// @nodoc


class _GetTaskById implements TaskEvent {
  const _GetTaskById(this.id);
  

 final  String id;

/// Create a copy of TaskEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GetTaskByIdCopyWith<_GetTaskById> get copyWith => __$GetTaskByIdCopyWithImpl<_GetTaskById>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GetTaskById&&(identical(other.id, id) || other.id == id));
}


@override
int get hashCode => Object.hash(runtimeType,id);

@override
String toString() {
  return 'TaskEvent.getTaskById(id: $id)';
}


}

/// @nodoc
abstract mixin class _$GetTaskByIdCopyWith<$Res> implements $TaskEventCopyWith<$Res> {
  factory _$GetTaskByIdCopyWith(_GetTaskById value, $Res Function(_GetTaskById) _then) = __$GetTaskByIdCopyWithImpl;
@useResult
$Res call({
 String id
});




}
/// @nodoc
class __$GetTaskByIdCopyWithImpl<$Res>
    implements _$GetTaskByIdCopyWith<$Res> {
  __$GetTaskByIdCopyWithImpl(this._self, this._then);

  final _GetTaskById _self;
  final $Res Function(_GetTaskById) _then;

/// Create a copy of TaskEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? id = null,}) {
  return _then(_GetTaskById(
null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class _WatchTasks implements TaskEvent {
  const _WatchTasks();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WatchTasks);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'TaskEvent.watchTasks()';
}


}




/// @nodoc


class _RefreshTask implements TaskEvent {
  const _RefreshTask(this.id);
  

 final  String id;

/// Create a copy of TaskEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RefreshTaskCopyWith<_RefreshTask> get copyWith => __$RefreshTaskCopyWithImpl<_RefreshTask>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RefreshTask&&(identical(other.id, id) || other.id == id));
}


@override
int get hashCode => Object.hash(runtimeType,id);

@override
String toString() {
  return 'TaskEvent.refreshTask(id: $id)';
}


}

/// @nodoc
abstract mixin class _$RefreshTaskCopyWith<$Res> implements $TaskEventCopyWith<$Res> {
  factory _$RefreshTaskCopyWith(_RefreshTask value, $Res Function(_RefreshTask) _then) = __$RefreshTaskCopyWithImpl;
@useResult
$Res call({
 String id
});




}
/// @nodoc
class __$RefreshTaskCopyWithImpl<$Res>
    implements _$RefreshTaskCopyWith<$Res> {
  __$RefreshTaskCopyWithImpl(this._self, this._then);

  final _RefreshTask _self;
  final $Res Function(_RefreshTask) _then;

/// Create a copy of TaskEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? id = null,}) {
  return _then(_RefreshTask(
null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$TaskState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TaskState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'TaskState()';
}


}

/// @nodoc
class $TaskStateCopyWith<$Res>  {
$TaskStateCopyWith(TaskState _, $Res Function(TaskState) __);
}


/// @nodoc


class Initial implements TaskState {
  const Initial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Initial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'TaskState.initial()';
}


}




/// @nodoc


class Loading implements TaskState {
  const Loading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Loading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'TaskState.loading()';
}


}




/// @nodoc


class Loaded implements TaskState {
  const Loaded(final  List<Task> tasks): _tasks = tasks;
  

 final  List<Task> _tasks;
 List<Task> get tasks {
  if (_tasks is EqualUnmodifiableListView) return _tasks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tasks);
}


/// Create a copy of TaskState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LoadedCopyWith<Loaded> get copyWith => _$LoadedCopyWithImpl<Loaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Loaded&&const DeepCollectionEquality().equals(other._tasks, _tasks));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_tasks));

@override
String toString() {
  return 'TaskState.loaded(tasks: $tasks)';
}


}

/// @nodoc
abstract mixin class $LoadedCopyWith<$Res> implements $TaskStateCopyWith<$Res> {
  factory $LoadedCopyWith(Loaded value, $Res Function(Loaded) _then) = _$LoadedCopyWithImpl;
@useResult
$Res call({
 List<Task> tasks
});




}
/// @nodoc
class _$LoadedCopyWithImpl<$Res>
    implements $LoadedCopyWith<$Res> {
  _$LoadedCopyWithImpl(this._self, this._then);

  final Loaded _self;
  final $Res Function(Loaded) _then;

/// Create a copy of TaskState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? tasks = null,}) {
  return _then(Loaded(
null == tasks ? _self._tasks : tasks // ignore: cast_nullable_to_non_nullable
as List<Task>,
  ));
}


}

/// @nodoc


class Error implements TaskState {
  const Error(this.failure);
  

 final  Failure failure;

/// Create a copy of TaskState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ErrorCopyWith<Error> get copyWith => _$ErrorCopyWithImpl<Error>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Error&&(identical(other.failure, failure) || other.failure == failure));
}


@override
int get hashCode => Object.hash(runtimeType,failure);

@override
String toString() {
  return 'TaskState.error(failure: $failure)';
}


}

/// @nodoc
abstract mixin class $ErrorCopyWith<$Res> implements $TaskStateCopyWith<$Res> {
  factory $ErrorCopyWith(Error value, $Res Function(Error) _then) = _$ErrorCopyWithImpl;
@useResult
$Res call({
 Failure failure
});




}
/// @nodoc
class _$ErrorCopyWithImpl<$Res>
    implements $ErrorCopyWith<$Res> {
  _$ErrorCopyWithImpl(this._self, this._then);

  final Error _self;
  final $Res Function(Error) _then;

/// Create a copy of TaskState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? failure = null,}) {
  return _then(Error(
null == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as Failure,
  ));
}


}

// dart format on
