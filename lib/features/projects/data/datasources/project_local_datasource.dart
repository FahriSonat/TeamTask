import 'package:hive/hive.dart';

import '../../../../core/constants/hive_box_names.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../auth/data/models/user_model.dart';
import '../models/membership_model.dart';
import '../models/project_model.dart';

abstract interface class ProjectLocalDataSource {
  Future<List<ProjectModel>> getProjectsForUser(String userId);
  Future<ProjectModel?> getProjectById(String id);
  Future<void> saveProject(ProjectModel project);
  Future<List<MembershipModel>> getMembershipsForProject(String projectId);
  Future<void> saveMembership(MembershipModel membership);
  Future<List<UserModel>> getUsersByIds(List<String> userIds);
  Future<String?> getActiveProjectId();
  Future<void> setActiveProjectId(String? projectId);
}

class ProjectLocalDataSourceImpl implements ProjectLocalDataSource {
  final Box<ProjectModel> projectBox;
  final Box<MembershipModel> membershipBox;
  final Box<UserModel> userBox;
  final Box sessionBox;

  ProjectLocalDataSourceImpl({
    required this.projectBox,
    required this.membershipBox,
    required this.userBox,
    required this.sessionBox,
  });

  @override
  Future<List<ProjectModel>> getProjectsForUser(String userId) async {
    try {
      final userProjectIds = membershipBox.values
          .where((m) => m.userId == userId)
          .map((m) => m.projectId)
          .toSet();

      final list =
          projectBox.values.where((p) => userProjectIds.contains(p.id)).toList()
            ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      return list;
    } catch (e) {
      throw CacheException('Projeler listelenirken hata oluştu: $e');
    }
  }

  @override
  Future<ProjectModel?> getProjectById(String id) async {
    try {
      return projectBox.get(id);
    } catch (e) {
      throw CacheException('Proje bilgisi alınamadı: $e');
    }
  }

  @override
  Future<void> saveProject(ProjectModel project) async {
    try {
      await projectBox.put(project.id, project);
    } catch (e) {
      throw CacheException('Proje kaydedilemedi: $e');
    }
  }

  @override
  Future<List<MembershipModel>> getMembershipsForProject(
    String projectId,
  ) async {
    try {
      return membershipBox.values
          .where((m) => m.projectId == projectId)
          .toList();
    } catch (e) {
      throw CacheException('Üyelik listesi alınamadı: $e');
    }
  }

  @override
  Future<void> saveMembership(MembershipModel membership) async {
    try {
      await membershipBox.put(membership.id, membership);
    } catch (e) {
      throw CacheException('Üyelik kaydedilemedi: $e');
    }
  }

  @override
  Future<List<UserModel>> getUsersByIds(List<String> userIds) async {
    try {
      final idSet = userIds.toSet();
      return userBox.values.where((u) => idSet.contains(u.id)).toList();
    } catch (e) {
      throw CacheException('Kullanıcı listesi alınamadı: $e');
    }
  }

  @override
  Future<String?> getActiveProjectId() async {
    try {
      return sessionBox.get(SessionKeys.activeProjectId) as String?;
    } catch (e) {
      throw CacheException('Aktif proje bilgisi okunamadı: $e');
    }
  }

  @override
  Future<void> setActiveProjectId(String? projectId) async {
    try {
      if (projectId == null) {
        await sessionBox.delete(SessionKeys.activeProjectId);
      } else {
        await sessionBox.put(SessionKeys.activeProjectId, projectId);
      }
    } catch (e) {
      throw CacheException('Aktif proje bilgisi güncellenemedi: $e');
    }
  }
}
