import 'package:equatable/equatable.dart';

import '../enums/task_priority.dart';
import '../enums/task_status.dart';

class Task extends Equatable {
  final String id;
  final String projectId;
  final int number;
  final String title;
  final String description;
  final TaskStatus status;
  final TaskPriority priority;
  final String? assigneeId;
  final DateTime? dueDate;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Task({
    required this.id,
    required this.projectId,
    required this.number,
    required this.title,
    this.description = '',
    this.status = TaskStatus.todo,
    this.priority = TaskPriority.medium,
    this.assigneeId,
    this.dueDate,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  String get code => 'TT-$number';

  bool get isOverdue {
    if (status == TaskStatus.done || dueDate == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueDate!.year, dueDate!.month, dueDate!.day);
    return due.isBefore(today);
  }

  Task copyWith({
    String? id,
    String? projectId,
    int? number,
    String? title,
    String? description,
    TaskStatus? status,
    TaskPriority? priority,
    String? assigneeId,
    bool clearAssignee = false,
    DateTime? dueDate,
    bool clearDueDate = false,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Task(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      number: number ?? this.number,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      assigneeId: clearAssignee ? null : (assigneeId ?? this.assigneeId),
      dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    projectId,
    number,
    title,
    description,
    status,
    priority,
    assigneeId,
    dueDate,
    createdBy,
    createdAt,
    updatedAt,
  ];
}
