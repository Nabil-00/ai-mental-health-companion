import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'mood_entry_model.g.dart';

enum MoodLevel {
  @JsonValue(1)
  veryBad(1, '😢'),
  @JsonValue(2)
  bad(2, '😔'),
  @JsonValue(3)
  neutral(3, '😐'),
  @JsonValue(4)
  good(4, '🙂'),
  @JsonValue(5)
  veryGood(5, '😄');

  final int value;
  final String emoji;

  const MoodLevel(this.value, this.emoji);

  static MoodLevel fromValue(int value) {
    return MoodLevel.values.firstWhere(
      (m) => m.value == value,
      orElse: () => MoodLevel.neutral,
    );
  }
}

@JsonSerializable()
class MoodEntryModel {
  final String id;
  @JsonKey(readValue: _readUserId)
  final String userId;
  final MoodLevel mood;
  final String note;
  final Map<String, dynamic> tags;
  @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
  final DateTime timestamp;

  const MoodEntryModel({
    required this.id,
    required this.userId,
    required this.mood,
    this.note = '',
    this.tags = const {},
    required this.timestamp,
  });

  factory MoodEntryModel.fromJson(Map<String, dynamic> json) =>
      _$MoodEntryModelFromJson(json);
  Map<String, dynamic> toJson() => _$MoodEntryModelToJson(this);

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
