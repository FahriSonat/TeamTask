// Dosya: lib/features/tasks/domain/enums/task_status.dart
// Görev durumu = Kanban kolonu.

/// Yapılacak / Devam ediyor / Tamamlandı.
enum TaskStatus {
  todo('todo'),
  inProgress('in_progress'),
  done('done');

  final String storageKey;
  const TaskStatus(this.storageKey);

  /// Bilinmeyen değer "todo" kabul edilir.
  static TaskStatus fromStorageKey(String key) {
    for (final status in TaskStatus.values) {
      if (status.storageKey == key) return status;
    }
    return TaskStatus.todo;
  }
}
