// Dosya: lib/features/projects/presentation/bloc/project_event.dart
// ProjectBloc olayları.

import 'package:equatable/equatable.dart';

import '../../../auth/domain/entities/user.dart';

/// Tüm proje olaylarının atası.
sealed class ProjectEvent extends Equatable {
  const ProjectEvent();

  @override
  List<Object?> get props => [];
}

/// Kullanıcının projelerini yükle.
final class ProjectsLoadRequested extends ProjectEvent {
  final String userId;
  const ProjectsLoadRequested(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// Yeni proje oluştur.
final class ProjectCreateRequested extends ProjectEvent {
  final String name;
  final String? description;
  final String ownerId;

  const ProjectCreateRequested({
    required this.name,
    this.description,
    required this.ownerId,
  });

  @override
  List<Object?> get props => [name, description, ownerId];
}

/// Aktif projeyi değiştir.
final class ProjectSelectRequested extends ProjectEvent {
  final String projectId;
  const ProjectSelectRequested(this.projectId);

  @override
  List<Object?> get props => [projectId];
}

/// Proje üyelerini yükle.
final class ProjectMembersLoadRequested extends ProjectEvent {
  final String projectId;
  const ProjectMembersLoadRequested(this.projectId);

  @override
  List<Object?> get props => [projectId];
}

/// Projeye (demo) üye ekle.
final class ProjectMemberAddRequested extends ProjectEvent {
  final String projectId;
  final User user;

  const ProjectMemberAddRequested({
    required this.projectId,
    required this.user,
  });

  @override
  List<Object?> get props => [projectId, user];
}
