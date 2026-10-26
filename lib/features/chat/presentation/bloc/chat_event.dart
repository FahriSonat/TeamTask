// Dosya: lib/features/chat/presentation/bloc/chat_event.dart
// ChatBloc olayları.

import 'package:equatable/equatable.dart';

/// Tüm sohbet olaylarının atası.
sealed class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

/// Mesajları yükle.
final class ChatMessagesLoadRequested extends ChatEvent {
  final String projectId;
  const ChatMessagesLoadRequested(this.projectId);

  @override
  List<Object?> get props => [projectId];
}

/// Mesaj gönder.
final class ChatMessageSent extends ChatEvent {
  final String projectId;
  final String senderId;
  final String senderName;
  final String text;

  const ChatMessageSent({
    required this.projectId,
    required this.senderId,
    required this.senderName,
    required this.text,
  });

  @override
  List<Object?> get props => [projectId, senderId, senderName, text];
}
