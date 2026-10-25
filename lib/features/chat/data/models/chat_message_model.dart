import 'package:hive/hive.dart';

import '../../../../core/constants/hive_type_ids.dart';
import '../../domain/entities/chat_message.dart';

class ChatMessageModel {
  final String id;
  final String projectId;
  final String senderId;
  final String senderName;
  final String text;
  final DateTime createdAt;

  const ChatMessageModel({
    required this.id,
    required this.projectId,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.createdAt,
  });

  ChatMessage toEntity() {
    return ChatMessage(
      id: id,
      projectId: projectId,
      senderId: senderId,
      senderName: senderName,
      text: text,
      createdAt: createdAt,
    );
  }

  factory ChatMessageModel.fromEntity(ChatMessage message) {
    return ChatMessageModel(
      id: message.id,
      projectId: message.projectId,
      senderId: message.senderId,
      senderName: message.senderName,
      text: message.text,
      createdAt: message.createdAt,
    );
  }

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'] as String,
      projectId: json['projectId'] as String,
      senderId: json['senderId'] as String,
      senderName: json['senderName'] as String,
      text: json['text'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectId': projectId,
      'senderId': senderId,
      'senderName': senderName,
      'text': text,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class ChatMessageModelAdapter extends TypeAdapter<ChatMessageModel> {
  @override
  final int typeId = HiveTypeIds.chatMessageModel;

  @override
  ChatMessageModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ChatMessageModel(
      id: fields[0] as String,
      projectId: fields[1] as String,
      senderId: fields[2] as String,
      senderName: fields[3] as String,
      text: fields[4] as String,
      createdAt: DateTime.parse(fields[5] as String),
    );
  }

  @override
  void write(BinaryWriter writer, ChatMessageModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.projectId)
      ..writeByte(2)
      ..write(obj.senderId)
      ..writeByte(3)
      ..write(obj.senderName)
      ..writeByte(4)
      ..write(obj.text)
      ..writeByte(5)
      ..write(obj.createdAt.toIso8601String());
  }
}
