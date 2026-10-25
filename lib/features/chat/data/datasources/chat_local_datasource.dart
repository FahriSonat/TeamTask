import 'package:hive/hive.dart';

import '../../../../core/errors/exceptions.dart';
import '../models/chat_message_model.dart';

abstract interface class ChatLocalDataSource {
  Future<List<ChatMessageModel>> getMessagesByProject(String projectId);
  Future<void> saveMessage(ChatMessageModel message);
}

class ChatLocalDataSourceImpl implements ChatLocalDataSource {
  final Box<ChatMessageModel> messageBox;

  ChatLocalDataSourceImpl({required this.messageBox});

  @override
  Future<List<ChatMessageModel>> getMessagesByProject(String projectId) async {
    try {
      final list =
          messageBox.values.where((m) => m.projectId == projectId).toList()
            ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
      return list;
    } catch (e) {
      throw CacheException('Mesajlar yüklenemedi: $e');
    }
  }

  @override
  Future<void> saveMessage(ChatMessageModel message) async {
    try {
      await messageBox.put(message.id, message);
    } catch (e) {
      throw CacheException('Mesaj kaydedilemedi: $e');
    }
  }
}
