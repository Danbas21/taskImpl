import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:task_test/features/domain/entities/task.dart';
import 'package:uuid/uuid.dart';

part 'task_model.freezed.dart';
part 'task_model.g.dart';

@freezed
sealed class TaskModel with _$TaskModel {
  const factory TaskModel({
    required String id,
    required String title,
    required String description,
    required DateTime dueDate,
    @Default(false) bool isCompleted,
  }) = _TaskModel;

  // Constructor para crear con ID generado automáticamente
  factory TaskModel.create({
    required String title,
    required String description,
    required DateTime dueDate,
    @Default(false) bool? isCompleted,
  }) => TaskModel(
    id: Uuid().v4(),
    title: title,
    description: description,
    dueDate: dueDate,
    isCompleted: isCompleted ?? false,
  );

  factory TaskModel.fromJson(Map<String, dynamic> json) =>
      _$TaskModelFromJson(json);

  factory TaskModel.fromDomain(Task task) {
    if (task.title.isEmpty) {
      throw ArgumentError('Title cannot be empty');
    }

    return TaskModel(
      id: task.id,
      title: task.title,
      description: task.description,
      dueDate: task.dueDate,
      isCompleted: task.isCompleted,
    );
  }
}

extension TaskModelX on TaskModel {
  TaskModel markAsCompleted() => copyWith(isCompleted: true);
  TaskModel markAsIncomplete() => copyWith(isCompleted: false);
  bool get isOverdue => dueDate.isBefore(DateTime.now());
  bool get isValidDate => dueDate.isAfter(DateTime(2000));
  Task toDomain() => Task(
    id: id,
    title: title,
    description: description,
    isCompleted: isCompleted,
    dueDate: dueDate,
  );
}
