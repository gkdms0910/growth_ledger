// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'progress_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProgressRecord _$ProgressRecordFromJson(Map<String, dynamic> json) =>
    ProgressRecord(
      id: json['id'] as String,
      goalId: json['goalId'] as String,
      note: json['note'] as String,
      value: (json['value'] as num?)?.toDouble(),
      recordedAt: DateTime.parse(json['recordedAt'] as String),
    );

Map<String, dynamic> _$ProgressRecordToJson(ProgressRecord instance) =>
    <String, dynamic>{
      'id': instance.id,
      'goalId': instance.goalId,
      'note': instance.note,
      'value': instance.value,
      'recordedAt': instance.recordedAt.toIso8601String(),
    };
