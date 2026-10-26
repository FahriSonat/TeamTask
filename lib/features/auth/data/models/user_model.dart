// Dosya: lib/features/auth/data/models/user_model.dart
// Kullanıcının Hive'da saklanan hali (parola özeti dahil) ve Hive adapter'ı.

import 'package:hive/hive.dart';

import '../../../../core/constants/hive_type_ids.dart';
import '../../domain/entities/user.dart';

/// Veritabanı modeli; User varlığına dönüştürülerek arayüze verilir.
class UserModel {
  final String id;
  final String name;
  final String email;
  final String passwordHash;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.passwordHash,
    required this.createdAt,
  });

  /// Model -> domain varlığı (parola özeti dışarı çıkmaz).
  User toEntity() {
    return User(id: id, name: name, email: email, createdAt: createdAt);
  }

  /// Domain varlığı + parola özeti -> model.
  factory UserModel.fromEntity(User user, {required String passwordHash}) {
    return UserModel(
      id: user.id,
      name: user.name,
      email: user.email,
      passwordHash: passwordHash,
      createdAt: user.createdAt,
    );
  }

  /// Seed JSON'undan model oluşturur.
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      passwordHash: json['passwordHash'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// Modeli JSON'a çevirir.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'passwordHash': passwordHash,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

/// Elle yazılmış Hive adapter'ı (kod üretimi kullanılmadı).
class UserModelAdapter extends TypeAdapter<UserModel> {
  @override
  final int typeId = HiveTypeIds.userModel;

  /// Diskten alan numarası -> değer şeklinde okur.
  @override
  UserModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserModel(
      id: fields[0] as String,
      name: fields[1] as String,
      email: fields[2] as String,
      passwordHash: fields[3] as String,
      createdAt: DateTime.parse(fields[4] as String),
    );
  }

  /// Alanları sırayla (0-4) diske yazar.
  @override
  void write(BinaryWriter writer, UserModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.passwordHash)
      ..writeByte(4)
      ..write(obj.createdAt.toIso8601String());
  }
}
