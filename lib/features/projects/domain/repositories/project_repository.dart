import '../../../../core/errors/result.dart';
import '../../../auth/domain/entities/user.dart';
import '../entities/membership.dart';
import '../entities/project.dart';

abstract interface class ProjectRepository {
  Future<Result<List<Project>>> getProjectsForUser(String userId);
  Future<Result<Project>> createProject({
    required String name,
    String? description,
    required String ownerId,
  });
  Future<Result<Project?>> getProject(String projectId);
  Future<Result<List<User>>> getMembers(String projectId);
  Future<Result<Membership>> addLocalMember({
    required String projectId,
    required User user,
  });
  Future<Result<void>> setActiveProject(String projectId);
  Future<Result<Project?>> getActiveProject();
}
