import 'package:flutter/material.dart';
import 'dart:async';
import '../models/user.dart';
import 'user_detail_screen.dart';
import '../services/api_service.dart';

class FavoriteScreen extends StatefulWidget {
  final List<User> favoriteUsers;
  final Function(User) onRemoveFromFavorites;
  final Function(User) onUpdateUser;

  FavoriteScreen({
    required this.favoriteUsers,
    required this.onRemoveFromFavorites,
    required this.onUpdateUser,
  });

  @override
  _FavoriteScreenState createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  late List<User> _favoriteUsers;
  late List<User> _filteredUsers;
  String _filterType = 'alphabetical';
  bool _isLoading = false;
  String? _errorMessage;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _favoriteUsers = widget.favoriteUsers;
    _filteredUsers = List.from(_favoriteUsers);
    _applyFilter();
    _startAutoUpdate();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startAutoUpdate() {
    _timer = Timer.periodic(Duration(minutes: 15), (timer) {
      _updateAllUsers(showLoading: false);
    });
  }

  Future<void> _updateAllUsers({bool showLoading = true}) async {
    for (User user in _favoriteUsers) {
      await _fetchUserData(user, showLoading: showLoading);
    }
  }

  void _removeFromFavorites(User user) {
    setState(() {
      _favoriteUsers.remove(user);
      _filteredUsers.remove(user);
      widget.onRemoveFromFavorites(user);
    });
  }

  void _applyFilter() {
    setState(() {
      if (_filterType == 'alphabetical') {
        _filteredUsers.sort((a, b) => a.username.compareTo(b.username));
      } else if (_filterType == 'ranking') {
        _filteredUsers.sort((a, b) => (a.statistics?.globalRank ?? double.infinity)
            .compareTo(b.statistics?.globalRank ?? double.infinity));
      }
    });
  }

  Future<void> _fetchUserData(User user, {bool showLoading = true}) async {
    if (showLoading) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    final accessToken = await ApiService.getAccessToken();
    if (accessToken == null) {
      if (showLoading) {
        setState(() {
          _isLoading = false;
          _errorMessage = "Unable to obtain access token";
        });
      }
      return;
    }

    final updatedUser = await ApiService.fetchUserData(user.username, accessToken);
    if (showLoading) {
      setState(() {
        _isLoading = false;
        if (updatedUser != null) {
          _updateUser(updatedUser);
        } else {
          _errorMessage = "User not found";
        }
      });
    } else {
      if (updatedUser != null) {
        _updateUser(updatedUser);
      }
    }
  }

  void _updateUser(User user) {
    setState(() {
      int index = _favoriteUsers.indexWhere((u) => u.id == user.id);
      if (index != -1) {
        _favoriteUsers[index] = user;
        _filteredUsers[index] = user;
        _applyFilter();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFF062A1), Color(0xFFFF87C6)],
              ),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 40.0, left: 10.0, right: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      PopupMenuButton<String>(
                        onSelected: (String result) {
                          setState(() {
                            _filterType = result;
                            _applyFilter();
                          });
                        },
                        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                          PopupMenuItem<String>(
                            value: 'alphabetical',
                            child: Row(
                              children: [
                                Icon(Icons.sort_by_alpha),
                                SizedBox(width: 10),
                                Text('Alphabetical'),
                              ],
                            ),
                          ),
                          PopupMenuItem<String>(
                            value: 'ranking',
                            child: Row(
                              children: [
                                Icon(Icons.leaderboard),
                                SizedBox(width: 10),
                                Text('Ranking'),
                              ],
                            ),
                          ),
                        ],
                        child: ElevatedButton(
                          onPressed: null,
                          child: Icon(Icons.filter_list, color: Colors.white),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.pink,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_isLoading) CircularProgressIndicator(),
                if (_errorMessage != null)
                  Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red),
                  ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20.0), // Przesunięcie listy niżej
                    child: ListView.builder(
                      itemCount: _filteredUsers.length,
                      itemBuilder: (context, index) {
                        final user = _filteredUsers[index];
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.15), // Przezroczyste czarne tło
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(user.avatarUrl),
                            ),
                            title: Text(
                              user.username,
                              style: TextStyle(color: Colors.white),
                            ),
                            subtitle: Text(
                              'Ranking: ${user.statistics?.globalRank ?? 'N/A'}',
                              style: TextStyle(color: Colors.white70),
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.delete, color: Colors.white),
                              onPressed: () {
                                _removeFromFavorites(user);
                              },
                            ),
                            onTap: () async {
                              await _fetchUserData(user, showLoading: true);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => UserDetailScreen(
                                    user: user,
                                    onAddToFavorites: (User user) {
                                      setState(() {
                                        if (!_favoriteUsers.any((u) => u.id == user.id)) {
                                          _favoriteUsers.add(user);
                                          _applyFilter();
                                        }
                                      });
                                    },
                                    onRemoveFromFavorites: (User user) {
                                      setState(() {
                                        _favoriteUsers.removeWhere((u) => u.id == user.id);
                                        _applyFilter();
                                      });
                                    },
                                    favoriteUsers: _favoriteUsers,
                                    onUpdateUser: _updateUser,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}