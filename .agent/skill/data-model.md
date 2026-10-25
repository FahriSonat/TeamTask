# TeamTask — Veri Modeli ve Sözleşmeler

## Entity'ler

### User

| Alan | Tip | Kural |
|---|---|---|
| `id` | `String` | UUID v4 |
| `name` | `String` | 2–50 karakter |
| `email` | `String` | normalize edilir, benzersiz |
| `createdAt` | `DateTime` | UTC saklanır |

`passwordHash` yalnız `UserModel` içindedir; domain entity ve Bloc state içinde yer almaz.

### Project

| Alan | Tip | Kural |
|---|---|---|
| `id` | `String` | UUID v4 |
| `name` | `String` | 2–60 karakter |
| `description` | `String` | en fazla 300 |
| `inviteCode` | `String` | yerel demo kodu, 6 karakter |
| `ownerId` | `String` | User id |
| `createdAt` | `DateTime` | UTC |
| `updatedAt` | `DateTime` | UTC |

### Membership

| Alan | Tip | Kural |
|---|---|---|
| `id` | `String` | UUID v4 |
| `projectId` | `String` | Project id |
| `userId` | `String` | User id |
| `role` | `ProjectRole` | MVP: `owner`, `member` |
| `joinedAt` | `DateTime` | UTC |

`projectId + userId` bileşimi benzersizdir.

### Task

| Alan | Tip | Kural |
|---|---|---|
| `id` | `String` | UUID v4 |
| `projectId` | `String` | zorunlu |
| `number` | `int` | proje başına artar, tekrar kullanılmaz |
| `title` | `String` | 1–80 karakter |
| `description` | `String` | en fazla 500 |
| `status` | `TaskStatus` | varsayılan `todo` |
| `priority` | `TaskPriority` | varsayılan `medium` |
| `assigneeId` | `String?` | proje üyesi veya null |
| `dueDate` | `DateTime?` | gün hassasiyetinde |
| `createdBy` | `String` | User id |
| `createdAt` | `DateTime` | UTC |
| `updatedAt` | `DateTime` | UTC |

Hesaplanan alanlar: `code = TT-$number`; `isOverdue = dueDate geçmiş && status != done`.

### Activity (opsiyonel)

| Alan | Tip |
|---|---|
| `id` | `String` |
| `projectId` | `String` |
| `actorId` | `String` |
| `taskId` | `String?` |
| `type` | `ActivityType` |
| `metadata` | `Map<String, String>` |
| `createdAt` | `DateTime` |

## Enum storage anahtarları

| Enum | Değer → storage key |
|---|---|
| `TaskStatus` | `todo`, `inProgress` → `in_progress`, `done` |
| `TaskPriority` | `low`, `medium`, `urgent` |
| `ProjectRole` | `owner`, `member` |

Hive'a enum index'i yazılmaz. UI etiketleri presentation extension'larında tanımlanır.

## Repository sözleşmeleri

```dart
abstract interface class AuthRepository {
  Future<Result<User>> register({required String name, required String email, required String password});
  Future<Result<User>> login({required String email, required String password});
  Future<Result<User?>> getCurrentUser();
  Future<Result<void>> logout();
}

abstract interface class ProjectRepository {
  Future<Result<List<Project>>> getProjectsForUser(String userId);
  Future<Result<Project>> createProject(Project project);
  Future<Result<Project?>> getProject(String projectId);
  Future<Result<List<User>>> getMembers(String projectId);
  Future<Result<Membership>> addLocalMember({required String projectId, required User user});
  Future<Result<void>> setActiveProject(String projectId);
  Future<Result<Project?>> getActiveProject();
}

abstract interface class TaskRepository {
  Future<Result<List<Task>>> getTasksByProject(String projectId);
  Future<Result<List<Task>>> getTasksAssignedTo(String userId);
  Future<Result<Task>> addTask(Task task);
  Future<Result<Task>> updateTask(Task task);
  Future<Result<void>> deleteTask(String taskId);
  Future<Result<Task>> changeStatus(String taskId, TaskStatus status);
}
```

## Bütünlük kuralları

- Task'ın `assigneeId` değeri, aynı `projectId` için üyelik sahibi olmalıdır.
- Proje silme MVP'de desteklenmez; böylece cascading delete riski ertelenir.
- Üye kaldırma MVP'de desteklenmez; atanmış görevlerin yetim kalması önlenir.
- Kullanıcı silme MVP'de yoktur.
- Tarihler UTC saklanır, cihaz saat diliminde gösterilir.
- Görev numarası `session` kutusunda `nextTaskNumber:<projectId>` ile atomik mantıkta artırılır.

