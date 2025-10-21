import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable(explicitToJson: true)
class User {
  final String email;
  String name;
  String passwordHash;
  String? bio;
  final DateTime createdAt;
  List<String> preferredCategories;
  bool notificationsEnabled;
  bool emailSummaryEnabled;

  User({
    required this.email,
    required this.name,
    required this.passwordHash,
    this.bio,
    required this.createdAt,
    List<String>? preferredCategories,
    bool? notificationsEnabled,
    bool? emailSummaryEnabled,
  })  : preferredCategories = preferredCategories ?? [],
        notificationsEnabled = notificationsEnabled ?? true,
        emailSummaryEnabled = emailSummaryEnabled ?? false;

  User copyWith({
    String? name,
    String? passwordHash,
    String? bio,
    List<String>? preferredCategories,
    bool? notificationsEnabled,
    bool? emailSummaryEnabled,
  }) {
    return User(
      email: email,
      name: name ?? this.name,
      passwordHash: passwordHash ?? this.passwordHash,
      bio: bio ?? this.bio,
      createdAt: createdAt,
      preferredCategories: preferredCategories ?? List<String>.from(this.preferredCategories),
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      emailSummaryEnabled: emailSummaryEnabled ?? this.emailSummaryEnabled,
    );
  }

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}
