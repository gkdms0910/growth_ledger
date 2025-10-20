import 'package:json_annotation/json_annotation.dart';

part 'progress_record.g.dart';

@JsonSerializable()
class ProgressRecord {
  final DateTime recordedAt;
  final double value; // Or int, depending on how progress is measured

  ProgressRecord({
    required this.recordedAt,
    required this.value,
  });

  factory ProgressRecord.fromJson(Map<String, dynamic> json) => _$ProgressRecordFromJson(json);
  Map<String, dynamic> toJson() => _$ProgressRecordToJson(this);
}
