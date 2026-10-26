// Dosya: lib/features/tasks/domain/enums/task_priority.dart
// Görev önceliği.

/// Düşük / Orta / Acil.
enum TaskPriority {
  low('low'),
  medium('medium'),
  urgent('urgent');

  final String storageKey;
  const TaskPriority(this.storageKey);

  /// Bilinmeyen değer "medium" kabul edilir.
  static TaskPriority fromStorageKey(String key) {
    for (final priority in TaskPriority.values) {
      if (priority.storageKey == key) return priority;
    }
    return TaskPriority.medium;
  }
}
