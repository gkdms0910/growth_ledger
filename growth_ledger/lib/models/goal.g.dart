// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goal.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Goal _$GoalFromJson(Map<String, dynamic> json) => Goal(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String?,
  category: json['category'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  progressRecords: (json['progressRecords'] as List<dynamic>?)
      ?.map((e) => ProgressRecord.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$GoalToJson(Goal instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'category': instance.category,
  'createdAt': instance.createdAt.toIso8601String(),
  'progressRecords': instance.progressRecords.map((e) => e.toJson()).toList(),
};
