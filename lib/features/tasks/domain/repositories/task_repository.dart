import '../../../../core/errors/result.dart';
import '../entities/task.dart';
import '../enums/task_status.dart';

abstract interface class TaskRepository {
  Future<Result<List<Task>>> getTasksByProject(String projectId);
  Future<Result<List<Task>>> getTasksAssignedTo(String userId);
  Future<Result<Task>> addTask(Task task);
  Future<Result<Task>> updateTask(Task task);
  Future<Result<void>> deleteTask(String taskId);
  Future<Result<Task>> changeStatus(String taskId, TaskStatus status);
}
