enum ProjectRole {
  owner('owner'),
  member('member');

  final String storageKey;
  const ProjectRole(this.storageKey);

  static ProjectRole fromStorageKey(String key) {
    for (final role in ProjectRole.values) {
      if (role.storageKey == key) return role;
    }
    return ProjectRole.member;
  }
}
