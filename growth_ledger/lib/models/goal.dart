import 'package:json_annotation/json_annotation.dart';
import 'progress_record.dart';

part 'goal.g.dart';

@JsonSerializable(explicitToJson: true)
class Goal {
  final String id;
  String title;
  String? description;
  String category;
  final DateTime createdAt;
  List<ProgressRecord> progressRecords;

  Goal({
    required this.id,
    required this.title,
    this.description,
    required this.category,
    required this.createdAt,
    List<ProgressRecord>? progressRecords,
  }) : progressRecords = progressRecords ?? [];

  factory Goal.fromJson(Map<String, dynamic> json) => _$GoalFromJson(json);
  Map<String, dynamic> toJson() => _$GoalToJson(this);
}