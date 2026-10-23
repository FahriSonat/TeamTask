import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/validators.dart';
import '../../domain/entities/task.dart';
import '../../domain/enums/task_priority.dart';
import '../../domain/enums/task_status.dart';

class TaskFormState extends Equatable {
  final String title;
  final String description;
  final TaskStatus status;
  final TaskPriority priority;
  final String? assigneeId;
  final DateTime? dueDate;
  final String? titleError;
  final String? descError;
  final bool isEditMode;
  final String? initialTaskId;

  const TaskFormState({
    this.title = '',
    this.description = '',
    this.status = TaskStatus.todo,
    this.priority = TaskPriority.medium,
    this.assigneeId,
    this.dueDate,
    this.titleError,
    this.descError,
    this.isEditMode = false,
    this.initialTaskId,
  });

  bool get isValid =>
      titleError == null &&
      descError == null &&
      title.trim().isNotEmpty &&
      title.trim().length <= 80 &&
      description.length <= 500;

  TaskFormState copyWith({
    String? title,
    String? description,
    TaskStatus? status,
    TaskPriority? priority,
    String? assigneeId,
    bool clearAssignee = false,
    DateTime? dueDate,
    bool clearDueDate = false,
    String? titleError,
    bool clearTitleError = false,
    String? descError,
    bool clearDescError = false,
    bool? isEditMode,
    String? initialTaskId,
  }) {
    return TaskFormState(
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      assigneeId: clearAssignee ? null : (assigneeId ?? this.assigneeId),
      dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
      titleError: clearTitleError ? null : (titleError ?? this.titleError),
      descError: clearDescError ? null : (descError ?? this.descError),
      isEditMode: isEditMode ?? this.isEditMode,
      initialTaskId: initialTaskId ?? this.initialTaskId,
    );
  }

  @override
  List<Object?> get props => [
    title,
    description,
    status,
    priority,
    assigneeId,
    dueDate,
    titleError,
    descError,
    isEditMode,
    initialTaskId,
  ];
}

class TaskFormCubit extends Cubit<TaskFormState> {
  TaskFormCubit({Task? initialTask, TaskStatus defaultStatus = TaskStatus.todo})
    : super(
        initialTask != null
            ? TaskFormState(
                title: initialTask.title,
                description: initialTask.description,
                status: initialTask.status,
                priority: initialTask.priority,
                assigneeId: initialTask.assigneeId,
                dueDate: initialTask.dueDate,
                isEditMode: true,
                initialTaskId: initialTask.id,
              )
            : TaskFormState(status: defaultStatus),
      );

  void titleChanged(String value) {
    final error = Validators.validateTaskTitle(value);
    emit(
      state.copyWith(
        title: value,
        titleError: error,
        clearTitleError: error == null,
      ),
    );
  }

  void descriptionChanged(String value) {
    final error = Validators.validateTaskDescription(value);
    emit(
      state.copyWith(
        description: value,
        descError: error,
        clearDescError: error == null,
      ),
    );
  }

  void statusChanged(TaskStatus status) {
    emit(state.copyWith(status: status));
  }

  void priorityChanged(TaskPriority priority) {
    emit(state.copyWith(priority: priority));
  }

  void assigneeChanged(String? assigneeId) {
    emit(
      state.copyWith(assigneeId: assigneeId, clearAssignee: assigneeId == null),
    );
  }

  void dueDateChanged(DateTime? dueDate) {
    emit(state.copyWith(dueDate: dueDate, clearDueDate: dueDate == null));
  }

  bool validate() {
    final tError = Validators.validateTaskTitle(state.title);
    final dError = Validators.validateTaskDescription(state.description);
    emit(
      state.copyWith(
        titleError: tError,
        clearTitleError: tError == null,
        descError: dError,
        clearDescError: dError == null,
      ),
    );
    return tError == null && dError == null;
  }
}
