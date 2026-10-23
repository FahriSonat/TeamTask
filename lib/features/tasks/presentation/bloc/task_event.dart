import 'package:equatable/equatable.dart';

import '../../domain/entities/task.dart';
import '../../domain/enums/task_status.dart';

sealed class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object?> get props => [];
}

final class TasksLoadRequested extends TaskEvent {
  final String projectId;
  const TasksLoadRequested(this.projectId);

  @override
  List<Object?> get props => [projectId];
}

final class TaskAdded extends TaskEvent {
  final Task task;
  const TaskAdded(this.task);

  @override
  List<Object?> get props => [task];
}

final class TaskUpdated extends TaskEvent {
  final Task task;
  const TaskUpdated(this.task);

  @override
  List<Object?> get props => [task];
}

final class TaskDeleted extends TaskEvent {
  final String taskId;
  const TaskDeleted(this.taskId);

  @override
  List<Object?> get props => [taskId];
}

final class TaskStatusChanged extends TaskEvent {
  final String taskId;
  final TaskStatus newStatus;

  const TaskStatusChanged({required this.taskId, required this.newStatus});

  @override
  List<Object?> get props => [taskId, newStatus];
}
