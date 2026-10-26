// Dosya: lib/features/chat/presentation/bloc/chat_state.dart
// ChatBloc durumları.

import 'package:equatable/equatable.dart';

import '../../domain/entities/chat_message.dart';

/// Tüm sohbet durumlarının atası.
sealed class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

/// Henüz yüklenmedi.
final class ChatInitial extends ChatState {
  const ChatInitial();
}

/// Yükleniyor.
final class ChatLoading extends ChatState {
  const ChatLoading();
}

/// Mesaj listesi.
final class ChatLoaded extends ChatState {
  final List<ChatMessage> messages;

  const ChatLoaded({required this.messages});

  @override
  List<Object?> get props => [messages];
}

/// Hata mesajı.
final class ChatError extends ChatState {
  final String message;

  const ChatError(this.message);

  @override
  List<Object?> get props => [message];
}
