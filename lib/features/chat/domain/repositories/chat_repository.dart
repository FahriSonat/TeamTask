// Dosya: lib/features/chat/domain/repositories/chat_repository.dart
// Sohbet işlemleri sözleşmesi.

import '../../../../core/errors/result.dart';
import '../entities/chat_message.dart';

/// Mesajları getirme ve gönderme.
abstract interface class ChatRepository {
  Future<Result<List<ChatMessage>>> getMessages(String projectId);
  Future<Result<ChatMessage>> sendMessage({
    required String projectId,
    required String senderId,
    required String senderName,
    required String text,
  });
}
