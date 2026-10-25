class HiveBoxNames {
  const HiveBoxNames._();

  static const String users = 'users';
  static const String projects = 'projects';
  static const String memberships = 'memberships';
  static const String tasks = 'tasks';
  static const String activity = 'activity';
  static const String session = 'session';
  static const String messages = 'messages';
}

class SessionKeys {
  const SessionKeys._();

  static const String currentUserId = 'current_user_id';
  static const String activeProjectId = 'active_project_id';
  static const String seedApplied = 'seed_applied_v1';
  static const String themeMode = 'user_theme_mode';
  static String nextTaskNumber(String projectId) =>
      'next_task_number_$projectId';
}
