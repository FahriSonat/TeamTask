import '../../../../core/errors/result.dart';
import '../entities/chat_message.dart';

abstract interface class ChatRepository {
  Future<Result<List<ChatMessage>>> getMessages(String projectId);
  Future<Result<ChatMessage>> sendMessage({
    required String projectId,
    required String senderId,
    required String senderName,
    required String text,
  });
}
