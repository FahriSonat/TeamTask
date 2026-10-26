// Dosya: lib/features/tasks/data/datasources/task_local_datasource.dart
// Görevlerin Hive işlemleri ve projeye özel görev numarası sayacı.

import 'package:hive/hive.dart';

import '../../../../core/constants/hive_box_names.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/task_model.dart';

/// Görev veri kaynağı sözleşmesi.
abstract interface class TaskLocalDataSource {
  Future<List<TaskModel>> getTasksByProject(String projectId);
  Future<List<TaskModel>> getTasksAssignedTo(String userId);
  Future<TaskModel?> getTaskById(String taskId);
  Future<void> saveTask(TaskModel task);
  Future<void> deleteTask(String taskId);
  Future<int> getNextTaskNumber(String projectId);
}

/// Hive gerçeklemesi.
class TaskLocalDataSourceImpl implements TaskLocalDataSource {
  final Box<TaskModel> taskBox;
  final Box sessionBox;

  TaskLocalDataSourceImpl({required this.taskBox, required this.sessionBox});

  /// Projenin görevleri.
  @override
  Future<List<TaskModel>> getTasksByProject(String projectId) async {
    try {
      final list = taskBox.values
          .where((t) => t.projectId == projectId)
          .toList();
      return list;
    } catch (e) {
      throw CacheException('Proje görevleri alınamadı: $e');
    }
  }

  /// Kullanıcıya atanmış görevler (tüm projeler).
  @override
  Future<List<TaskModel>> getTasksAssignedTo(String userId) async {
    try {
      final list = taskBox.values.where((t) => t.assigneeId == userId).toList();
      return list;
    } catch (e) {
      throw CacheException('Kullanıcıya atanmış görevler alınamadı: $e');
    }
  }

  /// ID ile görev.
  @override
  Future<TaskModel?> getTaskById(String taskId) async {
    try {
      return taskBox.get(taskId);
    } catch (e) {
      throw CacheException('Görev detayı alınamadı: $e');
    }
  }

  /// Görevi kaydeder / günceller.
  @override
  Future<void> saveTask(TaskModel task) async {
    try {
      await taskBox.put(task.id, task);
    } catch (e) {
      throw CacheException('Görev kaydedilemedi: $e');
    }
  }

  /// Görevi siler.
  @override
  Future<void> deleteTask(String taskId) async {
    try {
      await taskBox.delete(taskId);
    } catch (e) {
      throw CacheException('Görev silinemedi: $e');
    }
  }

  /// Sayacı bir artırıp yeni numarayı verir; silinen numaralar tekrar kullanılmaz.
  @override
  Future<int> getNextTaskNumber(String projectId) async {
    try {
      final key = SessionKeys.nextTaskNumber(projectId);
      final current = sessionBox.get(key) as int?;
      final nextNumber = (current ?? 0) + 1;
      await sessionBox.put(key, nextNumber);
      return nextNumber;
    } catch (e) {
      throw CacheException('Görev numarası üretilemedi: $e');
    }
  }
}
