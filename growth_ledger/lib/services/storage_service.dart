
import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import '../models/goal.dart';
import '../models/social_post.dart';
import '../models/user.dart';

class StorageService {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/goals.json');
  }

  Future<List<Goal>> readGoals() async {
    try {
      final file = await _localFile;
      if (!await file.exists()) {
        return [];
      }
      final contents = await file.readAsString();
      final List<dynamic> json = jsonDecode(contents);
      return json.map((e) => Goal.fromJson(e)).toList();
    } catch (e) {
      // If encountering an error, return an empty list
      return [];
    }
  }

  Future<File> writeGoals(List<Goal> goals) async {
    final file = await _localFile;
    final json = goals.map((e) => e.toJson()).toList();
    return file.writeAsString(jsonEncode(json));
  }

  Future<File> get _localCategoriesFile async {
    final path = await _localPath;
    return File('$path/categories.json');
  }

  Future<List<String>> readCategories() async {
    try {
      final file = await _localCategoriesFile;
      if (!await file.exists()) {
        return [];
      }
      final contents = await file.readAsString();
      final List<dynamic> json = jsonDecode(contents);
      return json.cast<String>();
    } catch (e) {
      return [];
    }
  }

  Future<File> writeCategories(List<String> categories) async {
    final file = await _localCategoriesFile;
    return file.writeAsString(jsonEncode(categories));
  }

  Future<File> get _localUsersFile async {
    final path = await _localPath;
    return File('$path/users.json');
  }

  Future<List<User>> readUsers() async {
    try {
      final file = await _localUsersFile;
      if (!await file.exists()) {
        return [];
      }
      final contents = await file.readAsString();
      final List<dynamic> json = jsonDecode(contents);
      return json.map((e) => User.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<File> writeUsers(List<User> users) async {
    final file = await _localUsersFile;
    final json = users.map((user) => user.toJson()).toList();
    return file.writeAsString(jsonEncode(json));
  }

  Future<File> get _localSocialFeedFile async {
    final path = await _localPath;
    return File('$path/social_feed.json');
  }

  Future<List<SocialPost>> readSocialFeed() async {
    try {
      final file = await _localSocialFeedFile;
      if (!await file.exists()) {
        return [];
      }
      final contents = await file.readAsString();
      final List<dynamic> json = jsonDecode(contents);
      return json.map((e) => SocialPost.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<File> writeSocialFeed(List<SocialPost> posts) async {
    final file = await _localSocialFeedFile;
    final json = posts.map((post) => post.toJson()).toList();
    return file.writeAsString(jsonEncode(json));
  }
}
