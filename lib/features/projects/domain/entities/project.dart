// Dosya: lib/features/projects/domain/entities/project.dart
// Proje varlığı (ad, açıklama, davet kodu, sahip).

import 'package:equatable/equatable.dart';

/// Bir ekip projesi.
class Project extends Equatable {
  final String id;
  final String name;
  final String description;
  final String inviteCode;
  final String ownerId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Project({
    required this.id,
    required this.name,
    this.description = '',
    required this.inviteCode,
    required this.ownerId,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Bazı alanları değiştirilmiş yeni kopya.
  Project copyWith({
    String? id,
    String? name,
    String? description,
    String? inviteCode,
    String? ownerId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      inviteCode: inviteCode ?? this.inviteCode,
      ownerId: ownerId ?? this.ownerId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    inviteCode,
    ownerId,
    createdAt,
    updatedAt,
  ];
}
