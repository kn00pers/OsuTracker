import 'package:flutter/material.dart';
import 'dart:async';
import '../models/user.dart';
import 'user_detail_screen.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class FavoriteScreen extends StatefulWidget {
  final List<User> favoriteUsers;
  final Function(User) onRemoveFromFavorites;
  final Function(User) onUpdateUser;
  final Map<String, Map<String, dynamic>> historicalStats; 

  FavoriteScreen({
    required this.favoriteUsers,
    required this.onRemoveFromFavorites,
    required this.onUpdateUser,
    required this.historicalStats,
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
    _timer = Timer.periodic(const Duration(minutes: 30), (timer) {
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
        _filteredUsers.sort((a, b) {
          return (a.username.toLowerCase()).compareTo(b.username.toLowerCase());
        });
      } else if (_filterType == 'ranking') {
        _filteredUsers.sort((a, b) {
          return (a.statistics?.globalRank?? double.infinity).compareTo(b.statistics?.globalRank?? double.infinity);
        });
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
          _isLoading = true;
          _errorMessage = "Unable to obtain access token";
        });
      }
      return;
    }

    final updatedUser = await ApiService.fetchUserData(user.username, accessToken);
    if (updatedUser!= null) {
      updatedUser.previousStatistics = user.statistics;
      await StorageService.saveUserStats(updatedUser);
      _updateUser(updatedUser);
    } else {
      if (showLoading) {
        setState(() {
          _isLoading = false;
          _errorMessage = "User not found";
        });
      }
    }
  }

  void _updateUser(User user) {
    setState(() {
      int index = _favoriteUsers.indexWhere((u) => u.id == user.id);
      if (index!= -1) {
        _favoriteUsers[index] = user;
      }
      index = _filteredUsers.indexWhere((u) => u.id == user.id);
      if (index!= -1) {
        _filteredUsers[index] = user;
      }
      _applyFilter();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF302e39),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 40.0, left: 10.0, right: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Color(0xFFeeedf2)),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      PopupMenuButton<String>(
                        color: const Color(0xFF18171c),
                        onSelected: (String result) {
                          setState(() {
                            _filterType = result;
                            _applyFilter();
                          });
                        },
                        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                          const PopupMenuItem<String>(
                            value: 'alphabetical',
                            child: Row(
                              children: [
                                Icon(Icons.sort_by_alpha, color: Color(0xFFeeedf2)),
                                SizedBox(width: 10),
                                Text('Alphabetical', style: TextStyle(fontFamily: 'Exo2', color: Color(0xFFeeedf2))),
                              ],
                            ),
                          ),
                          const PopupMenuItem<String>(
                            value: 'ranking',
                            child: Row(
                              children: [
                                Icon(Icons.leaderboard, color: Color(0xFFeeedf2)),
                                SizedBox(width: 10),
                                Text('By rank', style: TextStyle(fontFamily: 'Exo2', color: Color(0xFFeeedf2))),
                              ],
                            ),
                          ),
                        ],
                        child: ElevatedButton(
                          onPressed: null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                          ),
                          child: const Icon(Icons.filter_list, color: Color(0xFFeeedf2)),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_isLoading) const CircularProgressIndicator(color: Color(0xFFfa66a5)),
                if (_errorMessage!= null)
                  Text(
                    _errorMessage!,
                    style: const TextStyle(fontFamily: 'Exo2', color: Colors.red),
                  ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: ListView.builder(
                      itemCount: _filteredUsers.length,
                      itemBuilder: (context, index) {
                        final user = _filteredUsers[index];
                        final previousStats = widget.historicalStats[user.username]; 
                        final int? globalRankDiff = user.statistics?.globalRank!= null && previousStats?['globalRank']!= null
                          ? user.statistics!.globalRank! - (previousStats!['globalRank'] as int)
                          : null;

                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF18171c),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(user.avatarUrl),
                            ),
                            title: Text(
                              user.username,
                              style: const TextStyle(fontFamily: 'Exo2', color: Color(0xFFeeedf2), fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                RichText(
                                  text: TextSpan(
                                    text: 'Rank: ${user.statistics?.globalRank?? 'N/A'} ',
                                    style: const TextStyle(fontFamily: 'Exo2', color: Color(0xFFeeedf2)),
                                    children: [
                                      if (globalRankDiff != null && globalRankDiff != 0)
                                        TextSpan(
                                          text: ' (${globalRankDiff <= 0 ? '+' : '-'}${globalRankDiff.abs()})', // globalrank
                                          style: TextStyle(
                                          color: globalRankDiff < 0 ? Colors.green : Colors.red,
                                                  ),
                                                ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Color(0xFFeeedf2)),
                              onPressed: () {
                                _removeFromFavorites(user);
                              },
                            ),
                            onTap: () async {
                              await
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
                                    onUpdateUser: _updateUser, historicalStats: {},
                                  ),
                                ),
                              ).then((_) {
                                setState(() {
                                  _isLoading = false;
                                  _applyFilter();
                                });
                              });
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