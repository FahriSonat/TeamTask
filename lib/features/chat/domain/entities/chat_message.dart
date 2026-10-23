import 'package:equatable/equatable.dart';

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
