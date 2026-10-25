enum TaskPriority {
  low('low'),
  medium('medium'),
  urgent('urgent');

  final String storageKey;
  const TaskPriority(this.storageKey);

  static TaskPriority fromStorageKey(String key) {
    for (final priority in TaskPriority.values) {
      if (priority.storageKey == key) return priority;
    }
    return TaskPriority.medium;
  }
}
