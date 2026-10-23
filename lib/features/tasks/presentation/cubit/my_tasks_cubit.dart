import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/task.dart';
import '../../domain/enums/task_status.dart';
import '../../domain/repositories/task_repository.dart';

enum MyTasksFilter { all, todo, inProgress, done }

sealed class MyTasksState extends Equatable {
  const MyTasksState();

  @override
  List<Object?> get props => [];
}

final class MyTasksInitial extends MyTasksState {
  const MyTasksInitial();
}

final class MyTasksLoading extends MyTasksState {
  const MyTasksLoading();
}

final class MyTasksLoaded extends MyTasksState {
  final List<Task> allMyTasks;
  final MyTasksFilter filter;

  const MyTasksLoaded({
    required this.allMyTasks,
    this.filter = MyTasksFilter.all,
  });

  List<Task> get filteredTasks {
    return switch (filter) {
      MyTasksFilter.all => allMyTasks,
      MyTasksFilter.todo =>
        allMyTasks.where((t) => t.status == TaskStatus.todo).toList(),
      MyTasksFilter.inProgress =>
        allMyTasks.where((t) => t.status == TaskStatus.inProgress).toList(),
      MyTasksFilter.done =>
        allMyTasks.where((t) => t.status == TaskStatus.done).toList(),
    };
  }

  int get totalCount => allMyTasks.length;
  int get openCount =>
      allMyTasks.where((t) => t.status != TaskStatus.done).length;

  MyTasksLoaded copyWith({List<Task>? allMyTasks, MyTasksFilter? filter}) {
    return MyTasksLoaded(
      allMyTasks: allMyTasks ?? this.allMyTasks,
      filter: filter ?? this.filter,
    );
  }

  @override
  List<Object?> get props => [allMyTasks, filter];
}

final class MyTasksError extends MyTasksState {
  final String message;
  const MyTasksError(this.message);

  @override
  List<Object?> get props => [message];
}

class MyTasksCubit extends Cubit<MyTasksState> {
  final TaskRepository taskRepository;

  MyTasksCubit({required this.taskRepository}) : super(const MyTasksInitial());

  Future<void> loadMyTasks(String userId) async {
    emit(const MyTasksLoading());
    final result = await taskRepository.getTasksAssignedTo(userId);
    result.when(
      success: (tasks) => emit(MyTasksLoaded(allMyTasks: tasks)),
      failure: (failure) => emit(MyTasksError(failure.message)),
    );
  }

  void updateFromProjectTasks(List<Task> allProjectTasks, String userId) {
    final assigned = allProjectTasks
        .where((t) => t.assigneeId == userId)
        .toList();
    final current = state;
    if (current is MyTasksLoaded) {
      emit(current.copyWith(allMyTasks: assigned));
    } else {
      emit(MyTasksLoaded(allMyTasks: assigned));
    }
  }

  void changeFilter(MyTasksFilter filter) {
    final current = state;
    if (current is MyTasksLoaded) {
      emit(current.copyWith(filter: filter));
    }
  }
}
