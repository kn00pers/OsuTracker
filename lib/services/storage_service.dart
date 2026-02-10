import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class StorageService {
  static const _favoritesKey = 'favoriteUsers';

  static Future<void> saveFavoriteUsers(List<User> users) async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = users.map((user) => jsonEncode(user.toJson())).toList();
    await prefs.setStringList(_favoritesKey, usersJson);
  }

  static Future<List<User>> getFavoriteUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getStringList(_favoritesKey);
    if (usersJson == null) {
      return [];
    }
    return usersJson.map((json) => User.fromJson(jsonDecode(json))).toList();
  }

  static Future<void> saveUserStats(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('${user.id}_stats', jsonEncode(user.toJson()));
  }

  static Future<User?> getUserStats(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('${userId}_stats');
    if (userJson != null) {
      return User.fromJson(jsonDecode(userJson));
    }
    return null;
  }
}
