import 'package:json_annotation/json_annotation.dart';

part 'social_comment.g.dart';

@JsonSerializable()
class SocialComment {
  final String id;
  final String authorName;
  final String authorEmail;
  final String content;
  final DateTime createdAt;

  SocialComment({
    required this.id,
    required this.authorName,
    required this.authorEmail,
    required this.content,
    required this.createdAt,
  });

  factory SocialComment.fromJson(Map<String, dynamic> json) => _$SocialCommentFromJson(json);
  Map<String, dynamic> toJson() => _$SocialCommentToJson(this);
}
