// Dosya: lib/features/projects/presentation/bloc/project_state.dart
// ProjectBloc durumları.

import 'package:equatable/equatable.dart';

import '../../../auth/domain/entities/user.dart';
import '../../domain/entities/project.dart';

/// Tüm proje durumlarının atası.
sealed class ProjectState extends Equatable {
  const ProjectState();

  @override
  List<Object?> get props => [];
}

/// Henüz yüklenmedi.
final class ProjectInitial extends ProjectState {
  const ProjectInitial();
}

/// Yükleniyor.
final class ProjectLoading extends ProjectState {
  const ProjectLoading();
}

/// Projeler, aktif proje ve aktif projenin üyeleri.
final class ProjectsLoaded extends ProjectState {
  final List<Project> projects;
  final Project? activeProject;
  final List<User> members;

  const ProjectsLoaded({
    required this.projects,
    this.activeProject,
    this.members = const [],
  });

  ProjectsLoaded copyWith({
    List<Project>? projects,
    Project? activeProject,
    List<User>? members,
  }) {
    return ProjectsLoaded(
      projects: projects ?? this.projects,
      activeProject: activeProject ?? this.activeProject,
      members: members ?? this.members,
    );
  }

  @override
  List<Object?> get props => [projects, activeProject, members];
}

/// Hata mesajı.
final class ProjectError extends ProjectState {
  final String message;
  const ProjectError(this.message);

  @override
  List<Object?> get props => [message];
}
