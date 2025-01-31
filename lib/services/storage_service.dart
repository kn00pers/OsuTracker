import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class StorageService {
  static Future<void> saveUserStats(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('${user.id}_globalRank', user.statistics?.globalRank?? 0);
    await prefs.setInt('${user.id}_countryRank', user.statistics?.countryRank?? 0);
    await prefs.setDouble('${user.id}_pp', user.statistics?.pp?? 0);
  }

  static Future<Map<String, dynamic>?> getUserStats(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final globalRank = prefs.getInt('${userId}_globalRank');
    final countryRank = prefs.getInt('${userId}_countryRank');
    final pp = prefs.getDouble('${userId}_pp');
    if (globalRank!= null && countryRank!= null && pp!= null) {
      return {
        'globalRank': globalRank,
        'countryRank': countryRank,
        'pp': pp,
      };
    }
    return null;
  }
}