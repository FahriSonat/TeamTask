import 'package:equatable/equatable.dart';

sealed class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

final class ChatMessagesLoadRequested extends ChatEvent {
  final String projectId;
  const ChatMessagesLoadRequested(this.projectId);

  @override
  List<Object?> get props => [projectId];
}

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
