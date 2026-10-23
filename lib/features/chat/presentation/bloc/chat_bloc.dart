import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/chat_repository.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository chatRepository;

  ChatBloc({required this.chatRepository}) : super(const ChatInitial()) {
    on<ChatMessagesLoadRequested>(_onChatMessagesLoadRequested);
    on<ChatMessageSent>(_onChatMessageSent);
  }

  Future<void> _onChatMessagesLoadRequested(
    ChatMessagesLoadRequested event,
    Emitter<ChatState> emit,
  ) async {
    emit(const ChatLoading());
    final result = await chatRepository.getMessages(event.projectId);
    result.when(
      success: (messages) => emit(ChatLoaded(messages: messages)),
      failure: (failure) => emit(ChatError(failure.message)),
    );
  }

  Future<void> _onChatMessageSent(
    ChatMessageSent event,
    Emitter<ChatState> emit,
  ) async {
    final result = await chatRepository.sendMessage(
      projectId: event.projectId,
      senderId: event.senderId,
      senderName: event.senderName,
      text: event.text,
    );

    result.when(
      success: (newMessage) {
        final current = state;
        if (current is ChatLoaded) {
          emit(ChatLoaded(messages: [...current.messages, newMessage]));
        } else {
          emit(ChatLoaded(messages: [newMessage]));
        }
      },
      failure: (failure) => emit(ChatError(failure.message)),
    );
  }
}
