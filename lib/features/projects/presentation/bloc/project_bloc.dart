import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/project.dart';
import '../../domain/repositories/project_repository.dart';
import 'project_event.dart';
import 'project_state.dart';

class ProjectBloc extends Bloc<ProjectEvent, ProjectState> {
  final ProjectRepository projectRepository;

  ProjectBloc({required this.projectRepository})
    : super(const ProjectInitial()) {
    on<ProjectsLoadRequested>(_onProjectsLoadRequested);
    on<ProjectCreateRequested>(_onProjectCreateRequested);
    on<ProjectSelectRequested>(_onProjectSelectRequested);
    on<ProjectMembersLoadRequested>(_onProjectMembersLoadRequested);
    on<ProjectMemberAddRequested>(_onProjectMemberAddRequested);
  }

  Future<void> _onProjectsLoadRequested(
    ProjectsLoadRequested event,
    Emitter<ProjectState> emit,
  ) async {
    emit(const ProjectLoading());
    final projectsResult = await projectRepository.getProjectsForUser(
      event.userId,
    );

    await projectsResult.when(
      success: (projects) async {
        final activeResult = await projectRepository.getActiveProject();
        Project? active = activeResult.dataOrNull;

        if (active == null && projects.isNotEmpty) {
          active = projects.first;
          await projectRepository.setActiveProject(active.id);
        } else if (active != null && !projects.any((p) => p.id == active!.id)) {
          active = projects.isNotEmpty ? projects.first : null;
          if (active != null) {
            await projectRepository.setActiveProject(active.id);
          }
        }

        List<dynamic> members = [];
        if (active != null) {
          final membersResult = await projectRepository.getMembers(active.id);
          members = membersResult.dataOrNull ?? [];
        }

        emit(
          ProjectsLoaded(
            projects: projects,
            activeProject: active,
            members: members.cast(),
          ),
        );
      },
      failure: (failure) async => emit(ProjectError(failure.message)),
    );
  }

  Future<void> _onProjectCreateRequested(
    ProjectCreateRequested event,
    Emitter<ProjectState> emit,
  ) async {
    final result = await projectRepository.createProject(
      name: event.name,
      description: event.description,
      ownerId: event.ownerId,
    );

    await result.when(
      success: (project) async {
        final current = state;
        if (current is ProjectsLoaded) {
          final updatedProjects = [project, ...current.projects];
          final membersResult = await projectRepository.getMembers(project.id);
          emit(
            current.copyWith(
              projects: updatedProjects,
              activeProject: project,
              members: membersResult.dataOrNull ?? [],
            ),
          );
        } else {
          add(ProjectsLoadRequested(event.ownerId));
        }
      },
      failure: (failure) async => emit(ProjectError(failure.message)),
    );
  }

  Future<void> _onProjectSelectRequested(
    ProjectSelectRequested event,
    Emitter<ProjectState> emit,
  ) async {
    final current = state;
    if (current is ProjectsLoaded) {
      final selected = current.projects.firstWhere(
        (p) => p.id == event.projectId,
        orElse: () => current.activeProject ?? current.projects.first,
      );
      await projectRepository.setActiveProject(selected.id);
      final membersResult = await projectRepository.getMembers(selected.id);

      emit(
        current.copyWith(
          activeProject: selected,
          members: membersResult.dataOrNull ?? [],
        ),
      );
    }
  }

  Future<void> _onProjectMembersLoadRequested(
    ProjectMembersLoadRequested event,
    Emitter<ProjectState> emit,
  ) async {
    final current = state;
    if (current is ProjectsLoaded) {
      final membersResult = await projectRepository.getMembers(event.projectId);
      membersResult.when(
        success: (members) => emit(current.copyWith(members: members)),
        failure: (_) {},
      );
    }
  }

  Future<void> _onProjectMemberAddRequested(
    ProjectMemberAddRequested event,
    Emitter<ProjectState> emit,
  ) async {
    final result = await projectRepository.addLocalMember(
      projectId: event.projectId,
      user: event.user,
    );

    result.when(
      success: (_) {
        add(ProjectMembersLoadRequested(event.projectId));
      },
      failure: (failure) => emit(ProjectError(failure.message)),
    );
  }
}
