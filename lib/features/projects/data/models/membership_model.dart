import 'package:hive/hive.dart';

import '../../../../core/constants/hive_type_ids.dart';
import '../../domain/entities/membership.dart';
import '../../domain/enums/project_role.dart';

class MembershipModel {
  final String id;
  final String projectId;
  final String userId;
  final String roleKey;
  final DateTime joinedAt;

  const MembershipModel({
    required this.id,
    required this.projectId,
    required this.userId,
    required this.roleKey,
    required this.joinedAt,
  });

  Membership toEntity() {
    return Membership(
      id: id,
      projectId: projectId,
      userId: userId,
      role: ProjectRole.fromStorageKey(roleKey),
      joinedAt: joinedAt,
    );
  }

  factory MembershipModel.fromEntity(Membership membership) {
    return MembershipModel(
      id: membership.id,
      projectId: membership.projectId,
      userId: membership.userId,
      roleKey: membership.role.storageKey,
      joinedAt: membership.joinedAt,
    );
  }

  factory MembershipModel.fromJson(Map<String, dynamic> json) {
    return MembershipModel(
      id: json['id'] as String,
      projectId: json['projectId'] as String,
      userId: json['userId'] as String,
      roleKey: json['role'] as String,
      joinedAt: DateTime.parse(json['joinedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectId': projectId,
      'userId': userId,
      'role': roleKey,
      'joinedAt': joinedAt.toIso8601String(),
    };
  }
}

class MembershipModelAdapter extends TypeAdapter<MembershipModel> {
  @override
  final int typeId = HiveTypeIds.membershipModel;

  @override
  MembershipModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MembershipModel(
      id: fields[0] as String,
      projectId: fields[1] as String,
      userId: fields[2] as String,
      roleKey: fields[3] as String,
      joinedAt: DateTime.parse(fields[4] as String),
    );
  }

  @override
  void write(BinaryWriter writer, MembershipModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.projectId)
      ..writeByte(2)
      ..write(obj.userId)
      ..writeByte(3)
      ..write(obj.roleKey)
      ..writeByte(4)
      ..write(obj.joinedAt.toIso8601String());
  }
}
