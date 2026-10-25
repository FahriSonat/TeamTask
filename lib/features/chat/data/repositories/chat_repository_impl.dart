import 'package:uuid/uuid.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/errors/result.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_local_datasource.dart';
import '../models/chat_message_model.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatLocalDataSource localDataSource;
  final Uuid _uuid;

  ChatRepositoryImpl({required this.localDataSource, Uuid? uuid})
    : _uuid = uuid ?? const Uuid();

  @override
  Future<Result<List<ChatMessage>>> getMessages(String projectId) async {
    try {
      final models = await localDataSource.getMessagesByProject(projectId);
      return Result.success(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Result.failure(CacheFailure('Mesajlar alınamadı: $e'));
    }
  }

  @override
  Future<Result<ChatMessage>> sendMessage({
    required String projectId,
    required String senderId,
    required String senderName,
    required String text,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      return const Result.failure(ValidationFailure('Mesaj boş olamaz.'));
    }

    try {
      final message = ChatMessage(
        id: _uuid.v4(),
        projectId: projectId,
        senderId: senderId,
        senderName: senderName,
        text: trimmed,
        createdAt: DateTime.now().toUtc(),
      );

      await localDataSource.saveMessage(ChatMessageModel.fromEntity(message));
      return Result.success(message);
    } catch (e) {
      return Result.failure(CacheFailure('Mesaj gönderilemedi: $e'));
    }
  }
}
