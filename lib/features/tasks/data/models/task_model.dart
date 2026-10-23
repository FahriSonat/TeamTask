import 'package:hive/hive.dart';

import '../../../../core/constants/hive_type_ids.dart';
import '../../domain/entities/task.dart';
import '../../domain/enums/task_priority.dart';
import '../../domain/enums/task_status.dart';

class TaskModel {
  final String id;
  final String projectId;
  final int number;
  final String title;
  final String description;
  final String statusKey;
  final String priorityKey;
  final String? assigneeId;
  final DateTime? dueDate;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TaskModel({
    required this.id,
    required this.projectId,
    required this.number,
    required this.title,
    required this.description,
    required this.statusKey,
    required this.priorityKey,
    this.assigneeId,
    this.dueDate,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  Task toEntity() {
    return Task(
      id: id,
      projectId: projectId,
      number: number,
      title: title,
      description: description,
      status: TaskStatus.fromStorageKey(statusKey),
      priority: TaskPriority.fromStorageKey(priorityKey),
      assigneeId: assigneeId,
      dueDate: dueDate,
      createdBy: createdBy,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory TaskModel.fromEntity(Task task) {
    return TaskModel(
      id: task.id,
      projectId: task.projectId,
      number: task.number,
      title: task.title,
      description: task.description,
      statusKey: task.status.storageKey,
      priorityKey: task.priority.storageKey,
      assigneeId: task.assigneeId,
      dueDate: task.dueDate,
      createdBy: task.createdBy,
      createdAt: task.createdAt,
      updatedAt: task.updatedAt,
    );
  }

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as String,
      projectId: json['projectId'] as String,
      number: json['number'] as int,
      title: json['title'] as String,
      description: (json['description'] as String?) ?? '',
      statusKey: json['status'] as String,
      priorityKey: json['priority'] as String,
      assigneeId: json['assigneeId'] as String?,
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'] as String)
          : null,
      createdBy: json['createdBy'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectId': projectId,
      'number': number,
      'title': title,
      'description': description,
      'status': statusKey,
      'priority': priorityKey,
      'assigneeId': assigneeId,
      'dueDate': dueDate?.toIso8601String(),
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class TaskModelAdapter extends TypeAdapter<TaskModel> {
  @override
  final int typeId = HiveTypeIds.taskModel;

  @override
  TaskModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TaskModel(
      id: fields[0] as String,
      projectId: fields[1] as String,
      number: fields[2] as int,
      title: fields[3] as String,
      description: fields[4] as String,
      statusKey: fields[5] as String,
      priorityKey: fields[6] as String,
      assigneeId: fields[7] as String?,
      dueDate: fields[8] != null ? DateTime.parse(fields[8] as String) : null,
      createdBy: fields[9] as String,
      createdAt: DateTime.parse(fields[10] as String),
      updatedAt: DateTime.parse(fields[11] as String),
    );
  }

  @override
  void write(BinaryWriter writer, TaskModel obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.projectId)
      ..writeByte(2)
      ..write(obj.number)
      ..writeByte(3)
      ..write(obj.title)
      ..writeByte(4)
      ..write(obj.description)
      ..writeByte(5)
      ..write(obj.statusKey)
      ..writeByte(6)
      ..write(obj.priorityKey)
      ..writeByte(7)
      ..write(obj.assigneeId)
      ..writeByte(8)
      ..write(obj.dueDate?.toIso8601String())
      ..writeByte(9)
      ..write(obj.createdBy)
      ..writeByte(10)
      ..write(obj.createdAt.toIso8601String())
      ..writeByte(11)
      ..write(obj.updatedAt.toIso8601String());
  }
}
