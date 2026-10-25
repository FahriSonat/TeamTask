import 'package:hive/hive.dart';

import '../../../../core/constants/hive_box_names.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/task_model.dart';

abstract interface class TaskLocalDataSource {
  Future<List<TaskModel>> getTasksByProject(String projectId);
  Future<List<TaskModel>> getTasksAssignedTo(String userId);
  Future<TaskModel?> getTaskById(String taskId);
  Future<void> saveTask(TaskModel task);
  Future<void> deleteTask(String taskId);
  Future<int> getNextTaskNumber(String projectId);
}

class TaskLocalDataSourceImpl implements TaskLocalDataSource {
  final Box<TaskModel> taskBox;
  final Box sessionBox;

  TaskLocalDataSourceImpl({required this.taskBox, required this.sessionBox});

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

  @override
  Future<List<TaskModel>> getTasksAssignedTo(String userId) async {
    try {
      final list = taskBox.values.where((t) => t.assigneeId == userId).toList();
      return list;
    } catch (e) {
      throw CacheException('Kullanıcıya atanmış görevler alınamadı: $e');
    }
  }

  @override
  Future<TaskModel?> getTaskById(String taskId) async {
    try {
      return taskBox.get(taskId);
    } catch (e) {
      throw CacheException('Görev detayı alınamadı: $e');
    }
  }

  @override
  Future<void> saveTask(TaskModel task) async {
    try {
      await taskBox.put(task.id, task);
    } catch (e) {
      throw CacheException('Görev kaydedilemedi: $e');
    }
  }

  @override
  Future<void> deleteTask(String taskId) async {
    try {
      await taskBox.delete(taskId);
    } catch (e) {
      throw CacheException('Görev silinemedi: $e');
    }
  }

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
