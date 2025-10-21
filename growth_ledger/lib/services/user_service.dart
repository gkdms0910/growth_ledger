import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../models/user.dart';
import 'storage_service.dart';

class UserService {
  final StorageService _storageService = StorageService();

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  Future<User?> authenticate(String email, String password) async {
    final users = await _storageService.readUsers();
    final hashed = _hashPassword(password);
    try {
      return users.firstWhere((user) => user.email == email && user.passwordHash == hashed);
    } catch (_) {
      return null;
    }
  }

  Future<User?> findUserByEmail(String email) async {
    final users = await _storageService.readUsers();
    try {
      return users.firstWhere((user) => user.email == email);
    } catch (_) {
      return null;
    }
  }

  Future<User> register({
    required String email,
    required String password,
    required String name,
  }) async {
    final users = await _storageService.readUsers();
    final emailExists = users.any((user) => user.email.toLowerCase() == email.toLowerCase());
    if (emailExists) {
      throw StateError('이미 등록된 이메일입니다.');
    }
    final user = User(
      email: email,
      name: name,
      passwordHash: _hashPassword(password),
      createdAt: DateTime.now(),
    );
    users.add(user);
    await _storageService.writeUsers(users);
    return user;
  }

  Future<User> updateUser(User updatedUser) async {
    final users = await _storageService.readUsers();
    final index = users.indexWhere((user) => user.email == updatedUser.email);
    if (index == -1) {
      throw StateError('사용자를 찾을 수 없습니다.');
    }
    users[index] = updatedUser;
    await _storageService.writeUsers(users);
    return updatedUser;
  }

  Future<void> updatePreferredCategories(String email, List<String> categories) async {
    final user = await findUserByEmail(email);
    if (user == null) return;
    user.preferredCategories = categories;
    await updateUser(user);
  }

  Future<User?> updateNotificationPreferences({
    required String email,
    bool? notificationsEnabled,
    bool? emailSummaryEnabled,
  }) async {
    final user = await findUserByEmail(email);
    if (user == null) return null;
    final updatedUser = user.copyWith(
      notificationsEnabled: notificationsEnabled,
      emailSummaryEnabled: emailSummaryEnabled,
    );
    await updateUser(updatedUser);
    return updatedUser;
  }
}
