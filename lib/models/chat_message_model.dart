import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'chat_message_model.g.dart';

enum MessageSender {
  @JsonValue('user')
  user,
  @JsonValue('ai')
  ai,
}

@JsonSerializable()
class ChatMessageModel {
  final String id;
  @JsonKey(readValue: _readUserId)
  final String userId;
  final String content;
  final MessageSender sender;
  @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
  final DateTime timestamp;
  final bool isLoading;
  final Map<String, dynamic> metadata;

  const ChatMessageModel({
    required this.id,
    required this.userId,
    required this.content,
    required this.sender,
    required this.timestamp,
    this.isLoading = false,
    this.metadata = const {},
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageModelFromJson(json);
  Map<String, dynamic> toJson() => _$ChatMessageModelToJson(this);

  static Object? _readUserId(Map<dynamic, dynamic> json, String key) {
    return json['userId'];
  }

  static DateTime _timestampFromJson(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.parse(value);
    return DateTime.now();
  }

  static Object _timestampToJson(DateTime value) => value.toIso8601String();
}
