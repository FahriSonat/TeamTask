import 'package:equatable/equatable.dart';

import '../../domain/entities/chat_message.dart';

sealed class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

final class ChatInitial extends ChatState {
  const ChatInitial();
}

final class ChatLoading extends ChatState {
  const ChatLoading();
}

final class ChatLoaded extends ChatState {
  final List<ChatMessage> messages;

  const ChatLoaded({required this.messages});

  @override
  List<Object?> get props => [messages];
}

final class ChatError extends ChatState {
  final String message;

  const ChatError(this.message);

  @override
  List<Object?> get props => [message];
}
