// Dosya: lib/core/constants/hive_box_names.dart
// Hive kutu (tablo) adları ve oturum kutusundaki anahtarlar.

/// Hive'da açılan kutuların adları (veritabanı tabloları gibi düşünülebilir).
class HiveBoxNames {
  const HiveBoxNames._();

  /// Kayıtlı kullanıcılar.
  static const String users = 'users';

  /// Projeler.
  static const String projects = 'projects';

  /// Proje-kullanıcı üyelik kayıtları.
  static const String memberships = 'memberships';

  /// Görevler.
  static const String tasks = 'tasks';

  /// İleride aktivite geçmişi için ayrıldı (şu an kullanılmıyor).
  static const String activity = 'activity';

  /// Oturum, tema, aktif proje gibi tekil ayarlar.
  static const String session = 'session';

  /// Proje sohbet mesajları.
  static const String messages = 'messages';
}

/// Oturum kutusunda kullanılan anahtar adları.
class SessionKeys {
  const SessionKeys._();

  /// Giriş yapmış kullanıcının ID'si.
  static const String currentUserId = 'current_user_id';

  /// En son açılan (aktif) proje.
  static const String activeProjectId = 'active_project_id';

  /// Demo verisi yüklendi mi? (bir kez yüklenir)
  static const String seedApplied = 'seed_applied_v1';

  /// Kullanıcının seçtiği tema (dark / light).
  static const String themeMode = 'user_theme_mode';

  /// Projeye özel son kullanılan görev numarası (TT-n sayacı).
  static String nextTaskNumber(String projectId) =>
      'next_task_number_$projectId';
}
