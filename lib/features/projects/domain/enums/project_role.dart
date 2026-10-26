// Dosya: lib/features/projects/domain/enums/project_role.dart
// Projedeki rol: sahip (owner) veya üye (member).

/// storageKey veritabanında saklanan metin karşılığıdır.
enum ProjectRole {
  owner('owner'),
  member('member');

  final String storageKey;
  const ProjectRole(this.storageKey);

  /// Bilinmeyen değer gelirse "member" kabul edilir.
  static ProjectRole fromStorageKey(String key) {
    for (final role in ProjectRole.values) {
      if (role.storageKey == key) return role;
    }
    return ProjectRole.member;
  }
}
