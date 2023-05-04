import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:star_wars_quiz/model/user.dart';

class SharedPrefs {
  static const _userKey = 'user';

  static Future<bool> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  static Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final user = prefs.getString(_userKey);
    return user != null ? User.fromJson(jsonDecode(user)) : null;
  }

  static Future<bool> logout() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.remove(_userKey);
  }
}
