// Dosya: lib/features/chat/data/datasources/chat_local_datasource.dart
// Mesajların Hive işlemleri.

import 'package:hive/hive.dart';

import '../../../../core/errors/exceptions.dart';
import '../models/chat_message_model.dart';

/// Mesaj veri kaynağı sözleşmesi.
abstract interface class ChatLocalDataSource {
  Future<List<ChatMessageModel>> getMessagesByProject(String projectId);
  Future<void> saveMessage(ChatMessageModel message);
}

/// Hive gerçeklemesi.
class ChatLocalDataSourceImpl implements ChatLocalDataSource {
  final Box<ChatMessageModel> messageBox;

  ChatLocalDataSourceImpl({required this.messageBox});

  /// Projenin mesajları, eskiden yeniye.
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

  /// Mesajı kaydeder.
  @override
  Future<void> saveMessage(ChatMessageModel message) async {
    try {
      await messageBox.put(message.id, message);
    } catch (e) {
      throw CacheException('Mesaj kaydedilemedi: $e');
    }
  }
}
