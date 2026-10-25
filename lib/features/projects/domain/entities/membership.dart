import 'package:equatable/equatable.dart';

import '../enums/project_role.dart';

class Membership extends Equatable {
  final String id;
  final String projectId;
  final String userId;
  final ProjectRole role;
  final DateTime joinedAt;

  const Membership({
    required this.id,
    required this.projectId,
    required this.userId,
    required this.role,
    required this.joinedAt,
  });

  @override
  List<Object?> get props => [id, projectId, userId, role, joinedAt];
}
