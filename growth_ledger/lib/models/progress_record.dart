import 'package:json_annotation/json_annotation.dart';

part 'progress_record.g.dart';

@JsonSerializable()
class ProgressRecord {
  final String id;
  final String goalId;
  String note;
  double? value;
  final DateTime recordedAt;

  ProgressRecord({
    required this.id,
    required this.goalId,
    required this.note,
    this.value,
    required this.recordedAt,
  });

  factory ProgressRecord.fromJson(Map<String, dynamic> json) => _$ProgressRecordFromJson(json);
  Map<String, dynamic> toJson() => _$ProgressRecordToJson(this);
}