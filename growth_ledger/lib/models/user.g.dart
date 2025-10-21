// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
  email: json['email'] as String,
  name: json['name'] as String,
  passwordHash: json['passwordHash'] as String,
  bio: json['bio'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  preferredCategories: (json['preferredCategories'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  notificationsEnabled: json['notificationsEnabled'] as bool?,
  emailSummaryEnabled: json['emailSummaryEnabled'] as bool?,
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'email': instance.email,
  'name': instance.name,
  'passwordHash': instance.passwordHash,
  'bio': instance.bio,
  'createdAt': instance.createdAt.toIso8601String(),
  'preferredCategories': instance.preferredCategories,
  'notificationsEnabled': instance.notificationsEnabled,
  'emailSummaryEnabled': instance.emailSummaryEnabled,
};
