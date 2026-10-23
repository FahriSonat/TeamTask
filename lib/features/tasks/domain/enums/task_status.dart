enum TaskStatus {
  todo('todo'),
  inProgress('in_progress'),
  done('done');

  final String storageKey;
  const TaskStatus(this.storageKey);

  static TaskStatus fromStorageKey(String key) {
    for (final status in TaskStatus.values) {
      if (status.storageKey == key) return status;
    }
    return TaskStatus.todo;
  }
}
