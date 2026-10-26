// Dosya: lib/core/constants/hive_type_ids.dart
// Hive TypeAdapter kimlikleri.
// DİKKAT: Bu sayılar değiştirilirse cihazdaki kayıtlı veriler okunamaz.

/// Her model için benzersiz Hive tip numarası.
class HiveTypeIds {
  const HiveTypeIds._();

  static const int userModel = 0;
  static const int projectModel = 1;
  static const int membershipModel = 2;
  static const int taskModel = 3;
  static const int activityModel = 4;
  static const int chatMessageModel = 5;
}
