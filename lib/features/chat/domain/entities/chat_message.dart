// Dosya: lib/features/chat/domain/entities/chat_message.dart
// Sohbet mesajı varlığı.

import 'package:equatable/equatable.dart';

/// Bir projedeki tek mesaj.
class ChatMessage extends Equatable {
  final String id;
  final String projectId;
  final String senderId;
  final String senderName;
  final String text;
  final DateTime createdAt;

  const ChatMessage({
    required this.id,
    required this.projectId,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    projectId,
    senderId,
    senderName,
    text,
    createdAt,
  ];
}
