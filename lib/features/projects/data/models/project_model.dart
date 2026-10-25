import 'package:hive/hive.dart';

import '../../../../core/constants/hive_type_ids.dart';
import '../../domain/entities/project.dart';

class ProjectModel {
  final String id;
  final String name;
  final String description;
  final String inviteCode;
  final String ownerId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProjectModel({
    required this.id,
    required this.name,
    required this.description,
    required this.inviteCode,
    required this.ownerId,
    required this.createdAt,
    required this.updatedAt,
  });

  Project toEntity() {
    return Project(
      id: id,
      name: name,
      description: description,
      inviteCode: inviteCode,
      ownerId: ownerId,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory ProjectModel.fromEntity(Project project) {
    return ProjectModel(
      id: project.id,
      name: project.name,
      description: project.description,
      inviteCode: project.inviteCode,
      ownerId: project.ownerId,
      createdAt: project.createdAt,
      updatedAt: project.updatedAt,
    );
  }

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: (json['description'] as String?) ?? '',
      inviteCode: json['inviteCode'] as String,
      ownerId: json['ownerId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'inviteCode': inviteCode,
      'ownerId': ownerId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class ProjectModelAdapter extends TypeAdapter<ProjectModel> {
  @override
  final int typeId = HiveTypeIds.projectModel;

  @override
  ProjectModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProjectModel(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String,
      inviteCode: fields[3] as String,
      ownerId: fields[4] as String,
      createdAt: DateTime.parse(fields[5] as String),
      updatedAt: DateTime.parse(fields[6] as String),
    );
  }

  @override
  void write(BinaryWriter writer, ProjectModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.inviteCode)
      ..writeByte(4)
      ..write(obj.ownerId)
      ..writeByte(5)
      ..write(obj.createdAt.toIso8601String())
      ..writeByte(6)
      ..write(obj.updatedAt.toIso8601String());
  }
}
