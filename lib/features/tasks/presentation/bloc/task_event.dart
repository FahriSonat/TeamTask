// Dosya: lib/features/tasks/presentation/bloc/task_event.dart
// TaskBloc olayları.

import 'package:equatable/equatable.dart';

import '../../domain/entities/task.dart';
import '../../domain/enums/task_status.dart';

/// Tüm görev olaylarının atası.
sealed class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object?> get props => [];
}

/// Projenin görevlerini yükle.
final class TasksLoadRequested extends TaskEvent {
  final String projectId;
  const TasksLoadRequested(this.projectId);

  @override
  List<Object?> get props => [projectId];
}

/// Yeni görev ekle.
final class TaskAdded extends TaskEvent {
  final Task task;
  const TaskAdded(this.task);

  @override
  List<Object?> get props => [task];
}

/// Görevi güncelle.
final class TaskUpdated extends TaskEvent {
  final Task task;
  const TaskUpdated(this.task);

  @override
  List<Object?> get props => [task];
}

/// Görevi sil.
final class TaskDeleted extends TaskEvent {
  final String taskId;
  const TaskDeleted(this.taskId);

  @override
  List<Object?> get props => [taskId];
}

/// Silinen görevi geri getir.
final class TaskRestored extends TaskEvent {
  final Task task;
  const TaskRestored(this.task);

  @override
  List<Object?> get props => [task];
}

/// Görevin durumunu (kolonunu) değiştir.
final class TaskStatusChanged extends TaskEvent {
  final String taskId;
  final TaskStatus newStatus;

  const TaskStatusChanged({required this.taskId, required this.newStatus});

  @override
  List<Object?> get props => [taskId, newStatus];
}
