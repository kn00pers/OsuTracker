import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'user_detail_screen.dart';
import 'favorite_screen.dart';
import '../services/api_service.dart';
import '../models/user.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  User? _user;
  List<User> _favoriteUsers = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final String? favoriteJson = prefs.getString('favorites');
    if (favoriteJson != null) {
      final List<dynamic> userMap = jsonDecode(favoriteJson);
      setState(() {
        _favoriteUsers = userMap.map((data) => User.fromJson(data)).toList();
      });
    }
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteJson = _favoriteUsers.map((user) => user.toJson()).toList();
    await prefs.setString('favorites', jsonEncode(favoriteJson));
  }

  void _fetchUserData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final accessToken = await ApiService.getAccessToken();
    if (accessToken == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Unable to obtain access token";
      });
      return;
    }

    final user = await ApiService.fetchUserData(_controller.text, accessToken);
    setState(() {
      _isLoading = false;
      if (user != null) {
        _user = user;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserDetailScreen(
              user: _user!,
              onAddToFavorites: _addToFavorites,
              onRemoveFromFavorites: _removeFromFavorites,
              favoriteUsers: _favoriteUsers,
              onUpdateUser: _updateUser,
            ),
          ),
        );
      } else {
        _errorMessage = "User not found";
      }
    });
  }

  void _validateAndFetchUserData() {
    if (_controller.text.isEmpty) {
      setState(() {
        _errorMessage = "Text field can't be empty";
      });
    } else {
      _fetchUserData();
    }
  }

  void _addToFavorites(User user) {
    setState(() {
      if (!_favoriteUsers.any((u) => u.id == user.id)) {
        _favoriteUsers.add(user);
        _saveFavorites();
      }
    });
  }

  void _removeFromFavorites(User user) {
    setState(() {
      _favoriteUsers.removeWhere((u) => u.id == user.id);
      _saveFavorites();
    });
  }

  void _updateUser(User user) {
    setState(() {
      int index = _favoriteUsers.indexWhere((u) => u.id == user.id);
      if (index != -1) {
        _favoriteUsers[index] = user;
        _saveFavorites();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Color(0xFF302e39), // Tło
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: _controller,
                  autocorrect: false,
                  decoration: InputDecoration(
                    labelStyle: TextStyle(fontFamily: 'Exo2', color: Color(0xFFeeedf2)),
                    filled: true,
                    fillColor: Color(0xFF18171c),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: Icon(Icons.person, color: Color(0xFFeeedf2)),
                  ),
                  style: TextStyle(fontFamily: 'Exo2', color: Color(0xFFeeedf2)),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _validateAndFetchUserData,
                  icon: Icon(Icons.search, color: Color(0xFFfa66a5)),
                  label: Text('Get Stats', style: TextStyle(fontFamily: 'Exo2', color: Color(0xFFeeedf2), fontSize: 16, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF18171c),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                    elevation: 5,
                  ),
                ),
                const SizedBox(height: 10),
                if (_isLoading) CircularProgressIndicator(color: Color(0xFFfa66a5)),
                if (_errorMessage != null)
                  Text(
                    _errorMessage!,
                    style: TextStyle(fontFamily: 'Exo2', color: Colors.red),
                  ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FavoriteScreen(
                          favoriteUsers: _favoriteUsers,
                          onRemoveFromFavorites: _removeFromFavorites,
                          onUpdateUser: _updateUser,
                        ),
                      ),
                    );
                  },
                  icon: Icon(Icons.favorite, color: Color(0xFFfa66a5)),
                  label: Text('Favorites', style: TextStyle(fontFamily: 'Exo2', color: Color(0xFFeeedf2), fontSize: 16, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF18171c),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                    elevation: 5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
