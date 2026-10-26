// Dosya: lib/features/projects/data/repositories/project_repository_impl.dart
// ProjectRepository'nin yerel gerçeklemesi.
// Proje adı doğrulama, davet kodu üretimi, sahibin otomatik üye yapılması burada.

import 'dart:math';

import 'package:uuid/uuid.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/utils/password_hasher.dart';
import '../../../../core/utils/validators.dart';
import '../../../auth/data/datasources/auth_local_datasource.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/domain/entities/user.dart';
import '../../domain/entities/membership.dart';
import '../../domain/entities/project.dart';
import '../../domain/enums/project_role.dart';
import '../../domain/repositories/project_repository.dart';
import '../datasources/project_local_datasource.dart';
import '../models/membership_model.dart';
import '../models/project_model.dart';

/// Proje iş kuralları.
class ProjectRepositoryImpl implements ProjectRepository {
  final ProjectLocalDataSource localDataSource;
  final AuthLocalDataSource authLocalDataSource;
  final Uuid _uuid;

  ProjectRepositoryImpl({
    required this.localDataSource,
    required this.authLocalDataSource,
    Uuid? uuid,
  }) : _uuid = uuid ?? const Uuid();

  /// Kullanıcının projeleri.
  @override
  Future<Result<List<Project>>> getProjectsForUser(String userId) async {
    try {
      final list = await localDataSource.getProjectsForUser(userId);
      return Result.success(list.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Result.failure(CacheFailure('Projeler alınamadı: $e'));
    }
  }

  /// Adı doğrular, davet kodu üretir, sahibi üye yapar ve projeyi aktif seçer.
  @override
  Future<Result<Project>> createProject({
    required String name,
    String? description,
    required String ownerId,
  }) async {
    final nameError = Validators.validateProjectName(name);
    if (nameError != null) {
      return Result.failure(ValidationFailure(nameError));
    }

    try {
      final now = DateTime.now().toUtc();
      final inviteCode = _generateInviteCode();
      final project = Project(
        id: _uuid.v4(),
        name: name.trim(),
        description: description?.trim() ?? '',
        inviteCode: inviteCode,
        ownerId: ownerId,
        createdAt: now,
        updatedAt: now,
      );

      await localDataSource.saveProject(ProjectModel.fromEntity(project));

      // Otomatik owner üyeliği oluştur
      final membership = Membership(
        id: _uuid.v4(),
        projectId: project.id,
        userId: ownerId,
        role: ProjectRole.owner,
        joinedAt: now,
      );
      await localDataSource.saveMembership(
        MembershipModel.fromEntity(membership),
      );
      await localDataSource.setActiveProjectId(project.id);

      return Result.success(project);
    } catch (e) {
      return Result.failure(CacheFailure('Proje oluşturulamadı: $e'));
    }
  }

  /// Tek proje.
  @override
  Future<Result<Project?>> getProject(String projectId) async {
    try {
      final model = await localDataSource.getProjectById(projectId);
      return Result.success(model?.toEntity());
    } catch (e) {
      return Result.failure(CacheFailure('Proje bilgisi alınamadı: $e'));
    }
  }

  /// Üyelikleri kullanıcı listesine çevirir.
  @override
  Future<Result<List<User>>> getMembers(String projectId) async {
    try {
      final memberships = await localDataSource.getMembershipsForProject(
        projectId,
      );
      final userIds = memberships.map((m) => m.userId).toList();
      final userModels = await localDataSource.getUsersByIds(userIds);
      return Result.success(userModels.map((u) => u.toEntity()).toList());
    } catch (e) {
      return Result.failure(CacheFailure('Ekip üyeleri alınamadı: $e'));
    }
  }

  /// Demo üye ekler; kullanıcı yoksa varsayılan parolayla (123456) oluşturur.
  @override
  Future<Result<Membership>> addLocalMember({
    required String projectId,
    required User user,
  }) async {
    try {
      // Kullanıcı mevcut mu kontrol et, değilse demo kullanıcı olarak kaydet
      final existingUser = await authLocalDataSource.getUserById(user.id);
      if (existingUser == null) {
        final userModel = UserModel.fromEntity(
          user,
          passwordHash: PasswordHasher.hash('123456'),
        );
        await authLocalDataSource.saveUser(userModel);
      }

      // Üyelik zaten var mı?
      final currentMemberships = await localDataSource.getMembershipsForProject(
        projectId,
      );
      final alreadyMember = currentMemberships.any((m) => m.userId == user.id);
      if (alreadyMember) {
        final existing = currentMemberships.firstWhere(
          (m) => m.userId == user.id,
        );
        return Result.success(existing.toEntity());
      }

      final membership = Membership(
        id: _uuid.v4(),
        projectId: projectId,
        userId: user.id,
        role: ProjectRole.member,
        joinedAt: DateTime.now().toUtc(),
      );

      await localDataSource.saveMembership(
        MembershipModel.fromEntity(membership),
      );
      return Result.success(membership);
    } catch (e) {
      return Result.failure(CacheFailure('Ekip üyesi eklenemedi: $e'));
    }
  }

  /// Aktif projeyi kaydeder.
  @override
  Future<Result<void>> setActiveProject(String projectId) async {
    try {
      await localDataSource.setActiveProjectId(projectId);
      return const Result.success(null);
    } catch (e) {
      return Result.failure(CacheFailure('Aktif proje seçilemedi: $e'));
    }
  }

  /// Aktif projeyi döndürür.
  @override
  Future<Result<Project?>> getActiveProject() async {
    try {
      final activeId = await localDataSource.getActiveProjectId();
      if (activeId == null) {
        return const Result.success(null);
      }
      final model = await localDataSource.getProjectById(activeId);
      return Result.success(model?.toEntity());
    } catch (e) {
      return Result.failure(CacheFailure('Aktif proje okunamadı: $e'));
    }
  }

  /// "TT" + karışması zor 4 karakter (0/O, 1/I yok) davet kodu.
  String _generateInviteCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random();
    return 'TT${List.generate(4, (_) => chars[random.nextInt(chars.length)]).join()}';
  }
}
