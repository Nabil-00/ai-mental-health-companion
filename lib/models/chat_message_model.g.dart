// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_message_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatMessageModel _$ChatMessageModelFromJson(Map<String, dynamic> json) =>
    ChatMessageModel(
      id: json['id'] as String,
      userId: ChatMessageModel._readUserId(json, 'userId') as String,
      content: json['content'] as String,
      sender: $enumDecode(_$MessageSenderEnumMap, json['sender']),
      timestamp: ChatMessageModel._timestampFromJson(json['timestamp']),
      isLoading: json['isLoading'] as bool? ?? false,
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$ChatMessageModelToJson(ChatMessageModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'content': instance.content,
      'sender': _$MessageSenderEnumMap[instance.sender]!,
      'timestamp': ChatMessageModel._timestampToJson(instance.timestamp),
      'isLoading': instance.isLoading,
      'metadata': instance.metadata,
    };

const _$MessageSenderEnumMap = {
  MessageSender.user: 'user',
  MessageSender.ai: 'ai',
};
