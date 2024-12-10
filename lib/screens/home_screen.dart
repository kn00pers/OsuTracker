import 'package:flutter/material.dart';
import 'user_detail_screen.dart';
import 'favorite_screen.dart'; // Importuj nowy ekran
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
  bool _showDetailsButton = false;

  void _fetchUserData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _showDetailsButton = false;
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
        _showDetailsButton = true;
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
      }
    });
  }

  void _removeFromFavorites(User user) {
    setState(() {
      _favoriteUsers.removeWhere((u) => u.id == user.id);
    });
  }

  void _updateUser(User user) {
    setState(() {
      int index = _favoriteUsers.indexWhere((u) => u.id == user.id);
      if (index != -1) {
        _favoriteUsers[index] = user;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final String userId = _controller.text;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF062A1), Color(0xFFFF87C6)],
          ),
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
                    labelStyle: TextStyle(color: Colors.white),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: Icon(Icons.person, color: Colors.white),
                  ),
                  style: TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _validateAndFetchUserData,
                  icon: Icon(Icons.search, color: Colors.pink),
                  label: Text('Get Stats', style: TextStyle(color: Colors.pink)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    elevation: 5,
                  ),
                ),
                const SizedBox(height: 16),
                if (_isLoading) CircularProgressIndicator(),
                if (_errorMessage != null)
                  Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red),
                  ),
                if (_showDetailsButton && _user != null)
                  ElevatedButton.icon(
                    onPressed: () {
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
                      ).then((_) {
                        setState(() {
                          _showDetailsButton = false;
                        });
                      });
                    },
                    icon: Icon(Icons.arrow_forward, color: Colors.pink),
                    label: Text("View $userId's Details", style: TextStyle(color: Colors.pink)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      elevation: 5,
                    ),
                  ),
                const SizedBox(height: 16),
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
                  icon: Icon(Icons.favorite, color: Colors.pink),
                  label: Text('View Favorites', style: TextStyle(color: Colors.pink)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
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