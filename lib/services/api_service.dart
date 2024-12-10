import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';

class ApiService {
  static const String clientId = "36636";
  static const String clientSecret = "0dTGyDRAbhkUTJn0k7cIyZbNOThpKa5s0hEHXemZ";
  static const String tokenUrl = "https://osu.ppy.sh/oauth/token";
  static const String userUrl = "https://osu.ppy.sh/api/v2/users/";

  static Future<String?> getAccessToken() async {
    final response = await http.post(
      Uri.parse(tokenUrl),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'client_id': clientId,
        'client_secret': clientSecret,
        'grant_type': 'client_credentials',
        'scope': 'public',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['access_token'];
    } else {
      return null;
    }
  }

  static Future<User?> fetchUserData(String userId, String accessToken) async {
    final response = await http.get(
      Uri.parse('$userUrl$userId'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return User.fromJson(data);
    } else {
      return null;
    }
  }
}
