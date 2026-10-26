// Dosya: lib/features/auth/domain/entities/user.dart
// Kullanıcı varlığı (domain). Parola özeti burada tutulmaz.

import 'package:equatable/equatable.dart';

/// Uygulamadaki kullanıcı; Equatable ile alan bazlı karşılaştırılır.
class User extends Equatable {
  final String id;
  final String name;
  final String email;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.createdAt,
  });

  /// Bazı alanları değiştirilmiş yeni bir kopya üretir.
  User copyWith({
    String? id,
    String? name,
    String? email,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, name, email, createdAt];
}
