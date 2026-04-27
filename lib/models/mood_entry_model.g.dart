// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mood_entry_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MoodEntryModel _$MoodEntryModelFromJson(Map<String, dynamic> json) =>
    MoodEntryModel(
      id: json['id'] as String,
      userId: MoodEntryModel._readUserId(json, 'userId') as String,
      mood: $enumDecode(_$MoodLevelEnumMap, json['mood']),
      note: json['note'] as String? ?? '',
      tags: json['tags'] as Map<String, dynamic>? ?? const {},
      timestamp: MoodEntryModel._timestampFromJson(json['timestamp']),
    );

Map<String, dynamic> _$MoodEntryModelToJson(MoodEntryModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'mood': _$MoodLevelEnumMap[instance.mood]!,
      'note': instance.note,
      'tags': instance.tags,
      'timestamp': MoodEntryModel._timestampToJson(instance.timestamp),
    };

const _$MoodLevelEnumMap = {
  MoodLevel.veryBad: 1,
  MoodLevel.bad: 2,
  MoodLevel.neutral: 3,
  MoodLevel.good: 4,
  MoodLevel.veryGood: 5,
};
