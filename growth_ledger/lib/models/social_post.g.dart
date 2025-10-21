// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'social_post.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SocialPost _$SocialPostFromJson(Map<String, dynamic> json) => SocialPost(
  id: json['id'] as String,
  authorName: json['authorName'] as String,
  authorEmail: json['authorEmail'] as String,
  content: json['content'] as String,
  goalTitle: json['goalTitle'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  likedByEmails: (json['likedByEmails'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  comments:
      (json['comments'] as List<dynamic>?)
          ?.map((e) => SocialComment.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
);

Map<String, dynamic> _$SocialPostToJson(SocialPost instance) =>
    <String, dynamic>{
      'id': instance.id,
      'authorName': instance.authorName,
      'authorEmail': instance.authorEmail,
      'content': instance.content,
      'goalTitle': instance.goalTitle,
      'createdAt': instance.createdAt.toIso8601String(),
      'likedByEmails': instance.likedByEmails,
      'comments': instance.comments.map((e) => e.toJson()).toList(),
    };
