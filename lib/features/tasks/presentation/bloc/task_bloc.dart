import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import 'task_event.dart';
import 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskRepository taskRepository;

  TaskBloc({required this.taskRepository}) : super(const TaskInitial()) {
    on<TasksLoadRequested>(_onTasksLoadRequested);
    on<TaskAdded>(_onTaskAdded);
    on<TaskUpdated>(_onTaskUpdated);
    on<TaskDeleted>(_onTaskDeleted);
    on<TaskStatusChanged>(_onTaskStatusChanged);
  }

  Future<void> _onTasksLoadRequested(
    TasksLoadRequested event,
    Emitter<TaskState> emit,
  ) async {
    emit(const TaskLoading());
    final result = await taskRepository.getTasksByProject(event.projectId);
    result.when(
      success: (tasks) => emit(TasksLoaded(tasks: tasks)),
      failure: (failure) => emit(TaskError(message: failure.message)),
    );
  }

  Future<void> _onTaskAdded(TaskAdded event, Emitter<TaskState> emit) async {
    final result = await taskRepository.addTask(event.task);
    result.when(
      success: (newTask) {
        final current = state;
        if (current is TasksLoaded) {
          final updated = [newTask, ...current.tasks];
          emit(TasksLoaded(tasks: updated));
        } else {
          emit(TasksLoaded(tasks: [newTask]));
        }
      },
      failure: (failure) {
        final current = state;
        final prev = current is TasksLoaded ? current.tasks : null;
        emit(TaskError(message: failure.message, previousTasks: prev));
        if (prev != null) {
          emit(TasksLoaded(tasks: prev));
        }
      },
    );
  }

  Future<void> _onTaskUpdated(
    TaskUpdated event,
    Emitter<TaskState> emit,
  ) async {
    final result = await taskRepository.updateTask(event.task);
    result.when(
      success: (updatedTask) {
        final current = state;
        if (current is TasksLoaded) {
          final updated = current.tasks.map((t) {
            return t.id == updatedTask.id ? updatedTask : t;
          }).toList();
          emit(TasksLoaded(tasks: updated));
        }
      },
      failure: (failure) {
        final current = state;
        final prev = current is TasksLoaded ? current.tasks : null;
        emit(TaskError(message: failure.message, previousTasks: prev));
        if (prev != null) {
          emit(TasksLoaded(tasks: prev));
        }
      },
    );
  }

  Future<void> _onTaskDeleted(
    TaskDeleted event,
    Emitter<TaskState> emit,
  ) async {
    final current = state;
    List<Task>? prev;
    if (current is TasksLoaded) {
      prev = current.tasks;
      final updated = current.tasks.where((t) => t.id != event.taskId).toList();
      emit(TasksLoaded(tasks: updated));
    }

    final result = await taskRepository.deleteTask(event.taskId);
    result.when(
      success: (_) {},
      failure: (failure) {
        emit(TaskError(message: failure.message, previousTasks: prev));
        if (prev != null) {
          emit(TasksLoaded(tasks: prev));
        }
      },
    );
  }

  Future<void> _onTaskStatusChanged(
    TaskStatusChanged event,
    Emitter<TaskState> emit,
  ) async {
    final current = state;
    if (current is! TasksLoaded) return;

    final oldTasks = current.tasks;
    // İyimser güncelleme (optimistic update)
    final optimisticTasks = oldTasks.map((t) {
      if (t.id == event.taskId) {
        return t.copyWith(status: event.newStatus);
      }
      return t;
    }).toList();

    emit(TasksLoaded(tasks: optimisticTasks));

    final result = await taskRepository.changeStatus(
      event.taskId,
      event.newStatus,
    );
    result.when(
      success: (savedTask) {
        final finalTasks = optimisticTasks.map((t) {
          return t.id == savedTask.id ? savedTask : t;
        }).toList();
        emit(TasksLoaded(tasks: finalTasks));
      },
      failure: (failure) {
        // Geri al
        emit(
          TaskError(
            message: 'Durum güncellenemedi: ${failure.message}',
            previousTasks: oldTasks,
          ),
        );
        emit(TasksLoaded(tasks: oldTasks));
      },
    );
  }
}
