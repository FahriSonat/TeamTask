// Dosya: lib/features/tasks/presentation/bloc/task_state.dart
// TaskBloc durumları ve pano için hazır hesaplamalar.

import 'package:equatable/equatable.dart';

import '../../domain/entities/task.dart';
import '../../domain/enums/task_status.dart';

/// Tüm görev durumlarının atası.
sealed class TaskState extends Equatable {
  const TaskState();

  @override
  List<Object?> get props => [];
}

/// Henüz yüklenmedi.
final class TaskInitial extends TaskState {
  const TaskInitial();
}

/// Yükleniyor.
final class TaskLoading extends TaskState {
  const TaskLoading();
}

/// Görev listesi; kolonlara göre filtreler ve ilerleme oranı içerir.
final class TasksLoaded extends TaskState {
  final List<Task> tasks;

  const TasksLoaded({required this.tasks});

  /// Kolon listeleri.
  List<Task> get todoTasks =>
      tasks.where((t) => t.status == TaskStatus.todo).toList();
  List<Task> get inProgressTasks =>
      tasks.where((t) => t.status == TaskStatus.inProgress).toList();
  List<Task> get doneTasks =>
      tasks.where((t) => t.status == TaskStatus.done).toList();

  /// İlerleme çubuğu için sayaçlar.
  int get totalCount => tasks.length;
  int get doneCount => doneTasks.length;
  double get progress => totalCount == 0 ? 0 : doneCount / totalCount;

  @override
  List<Object?> get props => [tasks];
}

/// Hata; previousTasks ile ekran boşalmadan eski liste korunur.
final class TaskError extends TaskState {
  final String message;
  final List<Task>? previousTasks;

  const TaskError({required this.message, this.previousTasks});

  @override
  List<Object?> get props => [message, previousTasks];
}
