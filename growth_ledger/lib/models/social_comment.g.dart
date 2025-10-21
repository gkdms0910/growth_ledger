// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'social_comment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SocialComment _$SocialCommentFromJson(Map<String, dynamic> json) =>
    SocialComment(
      id: json['id'] as String,
      authorName: json['authorName'] as String,
      authorEmail: json['authorEmail'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$SocialCommentToJson(SocialComment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'authorName': instance.authorName,
      'authorEmail': instance.authorEmail,
      'content': instance.content,
      'createdAt': instance.createdAt.toIso8601String(),
    };
