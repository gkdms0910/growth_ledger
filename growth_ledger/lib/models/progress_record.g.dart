// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'progress_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProgressRecord _$ProgressRecordFromJson(Map<String, dynamic> json) =>
    ProgressRecord(
      recordedAt: DateTime.parse(json['recordedAt'] as String),
      value: (json['value'] as num).toDouble(),
    );

Map<String, dynamic> _$ProgressRecordToJson(ProgressRecord instance) =>
    <String, dynamic>{
      'recordedAt': instance.recordedAt.toIso8601String(),
      'value': instance.value,
    };
