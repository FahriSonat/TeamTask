// Dosya: lib/features/tasks/domain/repositories/task_repository.dart
// Görev işlemleri sözleşmesi.

import '../../../../core/errors/result.dart';
import '../entities/task.dart';
import '../enums/task_status.dart';

/// Listeleme, ekleme, güncelleme, silme ve durum değiştirme.
abstract interface class TaskRepository {
  Future<Result<List<Task>>> getTasksByProject(String projectId);
  Future<Result<List<Task>>> getTasksAssignedTo(String userId);
  Future<Result<Task>> addTask(Task task);
  Future<Result<Task>> updateTask(Task task);
  Future<Result<void>> deleteTask(String taskId);
  Future<Result<Task>> changeStatus(String taskId, TaskStatus status);

  /// Silinen görevi aynı ID ve TT numarasıyla geri kaydeder (silmeyi geri al).
  Future<Result<Task>> restoreTask(Task task);
}
