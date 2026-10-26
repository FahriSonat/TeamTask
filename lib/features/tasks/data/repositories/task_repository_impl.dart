// Dosya: lib/features/tasks/data/repositories/task_repository_impl.dart
// TaskRepository'nin yerel gerçeklemesi.
// Başlık/açıklama doğrulama, atanan kişinin üye olma kontrolü, numara verme ve sıralama.

import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/utils/validators.dart';
import '../../../projects/data/datasources/project_local_datasource.dart';
import '../../domain/entities/task.dart';
import '../../domain/enums/task_priority.dart';
import '../../domain/enums/task_status.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/task_local_datasource.dart';
import '../models/task_model.dart';

/// Görev iş kuralları.
class TaskRepositoryImpl implements TaskRepository {
  final TaskLocalDataSource localDataSource;
  final ProjectLocalDataSource projectLocalDataSource;
  final Uuid _uuid;

  TaskRepositoryImpl({
    required this.localDataSource,
    required this.projectLocalDataSource,
    Uuid? uuid,
  }) : _uuid = uuid ?? const Uuid();

  /// Projenin görevleri, sıralanmış.
  @override
  Future<Result<List<Task>>> getTasksByProject(String projectId) async {
    try {
      final models = await localDataSource.getTasksByProject(projectId);
      final tasks = models.map((m) => m.toEntity()).toList();
      _sortTasks(tasks);
      return Result.success(tasks);
    } catch (e) {
      return Result.failure(CacheFailure('Görevler yüklenemedi: $e'));
    }
  }

  /// Bana atananlar, sıralanmış.
  @override
  Future<Result<List<Task>>> getTasksAssignedTo(String userId) async {
    try {
      final models = await localDataSource.getTasksAssignedTo(userId);
      final tasks = models.map((m) => m.toEntity()).toList();
      _sortTasks(tasks);
      return Result.success(tasks);
    } catch (e) {
      return Result.failure(CacheFailure('Atanmış görevler yüklenemedi: $e'));
    }
  }

  /// Doğrular, sıradaki TT numarasını verir ve kaydeder.
  @override
  Future<Result<Task>> addTask(Task task) async {
    final titleError = Validators.validateTaskTitle(task.title);
    if (titleError != null) {
      return Result.failure(ValidationFailure(titleError));
    }
    final descError = Validators.validateTaskDescription(task.description);
    if (descError != null) {
      return Result.failure(ValidationFailure(descError));
    }

    try {
      // Atanan kişi projenin üyesi mi kontrol et
      if (task.assigneeId != null && task.assigneeId!.isNotEmpty) {
        final memberships = await projectLocalDataSource
            .getMembershipsForProject(task.projectId);
        final isMember = memberships.any((m) => m.userId == task.assigneeId);
        if (!isMember) {
          return const Result.failure(
            ValidationFailure(AppStrings.memberNotFoundError),
          );
        }
      }

      final nextNumber = await localDataSource.getNextTaskNumber(
        task.projectId,
      );
      final now = DateTime.now().toUtc();
      final newTask = task.copyWith(
        id: task.id.isEmpty ? _uuid.v4() : task.id,
        number: nextNumber,
        createdAt: now,
        updatedAt: now,
      );

      await localDataSource.saveTask(TaskModel.fromEntity(newTask));
      return Result.success(newTask);
    } catch (e) {
      return Result.failure(CacheFailure('Görev eklenemedi: $e'));
    }
  }

  /// Doğrular ve updatedAt'i yenileyerek kaydeder.
  @override
  Future<Result<Task>> updateTask(Task task) async {
    final titleError = Validators.validateTaskTitle(task.title);
    if (titleError != null) {
      return Result.failure(ValidationFailure(titleError));
    }
    final descError = Validators.validateTaskDescription(task.description);
    if (descError != null) {
      return Result.failure(ValidationFailure(descError));
    }

    try {
      if (task.assigneeId != null && task.assigneeId!.isNotEmpty) {
        final memberships = await projectLocalDataSource
            .getMembershipsForProject(task.projectId);
        final isMember = memberships.any((m) => m.userId == task.assigneeId);
        if (!isMember) {
          return const Result.failure(
            ValidationFailure(AppStrings.memberNotFoundError),
          );
        }
      }

      final updatedTask = task.copyWith(updatedAt: DateTime.now().toUtc());

      await localDataSource.saveTask(TaskModel.fromEntity(updatedTask));
      return Result.success(updatedTask);
    } catch (e) {
      return Result.failure(CacheFailure('Görev güncellenemedi: $e'));
    }
  }

  /// Görevi siler.
  @override
  Future<Result<void>> deleteTask(String taskId) async {
    try {
      await localDataSource.deleteTask(taskId);
      return const Result.success(null);
    } catch (e) {
      return Result.failure(CacheFailure('Görev silinemedi: $e'));
    }
  }

  /// Sadece durumu değiştirir (sürükle-bırak ve durum düğmeleri).
  @override
  Future<Result<Task>> changeStatus(String taskId, TaskStatus status) async {
    try {
      final model = await localDataSource.getTaskById(taskId);
      if (model == null) {
        return const Result.failure(NotFoundFailure('Görev bulunamadı.'));
      }

      final updated = model.toEntity().copyWith(
        status: status,
        updatedAt: DateTime.now().toUtc(),
      );
      await localDataSource.saveTask(TaskModel.fromEntity(updated));
      return Result.success(updated);
    } catch (e) {
      return Result.failure(CacheFailure('Görev durumu güncellenemedi: $e'));
    }
  }

  /// Sıralama: önce öncelik, sonra yakın teslim tarihi, sonra en yeni.
  void _sortTasks(List<Task> tasks) {
    tasks.sort((a, b) {
      // 1. Öncelik sırası: urgent(2) > medium(1) > low(0)
      final priorityA = _priorityScore(a.priority);
      final priorityB = _priorityScore(b.priority);
      if (priorityA != priorityB) {
        return priorityB.compareTo(priorityA);
      }

      // 2. Teslim tarihi: olanlar önce ve yakın olan en önce
      if (a.dueDate != null && b.dueDate != null) {
        final dateCompare = a.dueDate!.compareTo(b.dueDate!);
        if (dateCompare != 0) return dateCompare;
      } else if (a.dueDate != null) {
        return -1;
      } else if (b.dueDate != null) {
        return 1;
      }

      // 3. Oluşturulma tarihi: yeni olan önce
      return b.createdAt.compareTo(a.createdAt);
    });
  }

  int _priorityScore(TaskPriority priority) {
    return switch (priority) {
      TaskPriority.urgent => 3,
      TaskPriority.medium => 2,
      TaskPriority.low => 1,
    };
  }
}
