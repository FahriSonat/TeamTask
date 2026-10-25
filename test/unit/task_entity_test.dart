import 'package:flutter_test/flutter_test.dart';
import 'package:team_task/features/tasks/domain/entities/task.dart';
import 'package:team_task/features/tasks/domain/enums/task_priority.dart';
import 'package:team_task/features/tasks/domain/enums/task_status.dart';

void main() {
  group('Task Entity & Enums Test', () {
    test('task code generates TT-number', () {
      final task = Task(
        id: '1',
        projectId: 'p1',
        number: 42,
        title: 'Örnek Görev',
        createdBy: 'u1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(task.code, 'TT-42');
    });

    test('isOverdue returns true for past due date when not done', () {
      final overdueTask = Task(
        id: '1',
        projectId: 'p1',
        number: 1,
        title: 'Gecikmiş Görev',
        status: TaskStatus.todo,
        dueDate: DateTime.now().subtract(const Duration(days: 2)),
        createdBy: 'u1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(overdueTask.isOverdue, isTrue);
    });

    test('isOverdue returns false when task is done even if past due date', () {
      final doneTask = Task(
        id: '1',
        projectId: 'p1',
        number: 1,
        title: 'Tamamlanmış Görev',
        status: TaskStatus.done,
        dueDate: DateTime.now().subtract(const Duration(days: 2)),
        createdBy: 'u1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(doneTask.isOverdue, isFalse);
    });

    test('TaskStatus storageKey and fromStorageKey map correctly', () {
      expect(TaskStatus.todo.storageKey, 'todo');
      expect(TaskStatus.inProgress.storageKey, 'in_progress');
      expect(TaskStatus.done.storageKey, 'done');

      expect(TaskStatus.fromStorageKey('in_progress'), TaskStatus.inProgress);
      expect(TaskStatus.fromStorageKey('unknown'), TaskStatus.todo);
    });

    test('TaskPriority storageKey and fromStorageKey map correctly', () {
      expect(TaskPriority.urgent.storageKey, 'urgent');
      expect(TaskPriority.medium.storageKey, 'medium');
      expect(TaskPriority.low.storageKey, 'low');

      expect(TaskPriority.fromStorageKey('urgent'), TaskPriority.urgent);
    });
  });
}
