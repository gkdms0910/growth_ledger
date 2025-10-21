import 'package:json_annotation/json_annotation.dart';

import 'social_comment.dart';

part 'social_post.g.dart';

@JsonSerializable(explicitToJson: true)
class SocialPost {
  final String id;
  final String authorName;
  final String authorEmail;
  final String content;
  final String? goalTitle;
  final DateTime createdAt;
  List<String> likedByEmails;
  @JsonKey(defaultValue: [])
  List<SocialComment> comments;

  SocialPost({
    required this.id,
    required this.authorName,
    required this.authorEmail,
    required this.content,
    this.goalTitle,
    required this.createdAt,
    List<String>? likedByEmails,
    List<SocialComment>? comments,
  })  : likedByEmails = likedByEmails ?? [],
        comments = comments ?? [];

  int get likeCount => likedByEmails.length;
  int get commentCount => comments.length;

  bool isLikedBy(String email) => likedByEmails.contains(email);

  factory SocialPost.fromJson(Map<String, dynamic> json) => _$SocialPostFromJson(json);
  Map<String, dynamic> toJson() => _$SocialPostToJson(this);
}
