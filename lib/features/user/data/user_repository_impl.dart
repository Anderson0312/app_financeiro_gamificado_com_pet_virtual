import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../shared/providers/app_providers.dart';
import 'user_repository.dart';
import '../domain/models/user.dart';

const _userKey = 'user_data';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return UserRepositoryImpl(prefs);
});

class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl(this._prefs);

  final SharedPreferences _prefs;

  @override
  Future<User?> getUser() async {
    final json = _prefs.getString(_userKey);
    if (json == null) return null;
    try {
      return User.fromJson(jsonDecode(json) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveUser(User user) async {
    await _prefs.setString(_userKey, jsonEncode(user.toJson()));
  }
}
