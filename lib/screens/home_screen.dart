import 'package:flutter/material.dart';
import 'user_detail_screen.dart';
import 'favorite_screen.dart';
import '../services/api_service.dart';
import '../models/user.dart';
import '../services/storage_service.dart';
import '../colors/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  List<User> _favoriteUsers = [];
  final Map<String, Map<String, dynamic>> _historicalStats = {};

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    _favoriteUsers = await StorageService.getFavoriteUsers();
    await _loadHistoricalStats();
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _loadHistoricalStats() async {
    for (var user in _favoriteUsers) {
      final storedUser = await StorageService.getUserStats(user.id.toString());
      if (storedUser != null && storedUser.statistics != null) {
        _historicalStats[user.username] = {
          'globalRank': storedUser.statistics!.globalRank,
          'countryRank': storedUser.statistics!.countryRank,
          'pp': storedUser.statistics!.pp,
        };
      }
    }
  }

  Future<void> _saveFavorites() async {
    await StorageService.saveFavoriteUsers(_favoriteUsers);
  }

  void _fetchUserData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = await ApiService.fetchUser(_controller.text);
      await StorageService.saveUserStats(user);
      if (!mounted) return;

      final historicalUser = await StorageService.getUserStats(user.id.toString());
      Map<String, dynamic> historicalData = {};
      if (historicalUser != null && historicalUser.statistics != null) {
        historicalData = {
          'globalRank': historicalUser.statistics!.globalRank,
          'countryRank': historicalUser.statistics!.countryRank,
          'pp': historicalUser.statistics!.pp,
        };
      }

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserDetailScreen(
              user: user,
              onAddToFavorites: _addToFavorites,
              onRemoveFromFavorites: _removeFromFavorites,
              favoriteUsers: _favoriteUsers,
              onUpdateUser: _updateUser,
              historicalStats: {user.username: historicalData},
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = "Failed to fetch user data.";
      });
    }
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
        decoration: const BoxDecoration(
          color: AppColors.background,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextField(
                      controller: _controller,
                      autocorrect: false,
                      decoration: InputDecoration(
                        labelText: 'Enter osu! username',
                        labelStyle: const TextStyle(
                            fontFamily: 'Exo2', color: AppColors.text),
                        filled: true,
                        fillColor: AppColors.buttons,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon:
                            const Icon(Icons.person, color: AppColors.favorite),
                      ),
                      style: const TextStyle(
                          fontFamily: 'Exo2', color: AppColors.text),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _validateAndFetchUserData,
                      icon: const Icon(Icons.search, color: AppColors.favorite),
                      label: const Text('Get Stats',
                          style: TextStyle(
                              fontFamily: 'Exo2',
                              color: AppColors.text,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.buttons,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 15),
                        elevation: 5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (_isLoading)
                      const CircularProgressIndicator(color: AppColors.favorite),
                    if (_errorMessage != null)
                      Text(
                        _errorMessage!,
                        style: const TextStyle(
                            fontFamily: 'Exo2', color: Colors.red),
                      ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: () async {
                        setState(() {
                          _isLoading = true;
                        });

                        List<User> updatedUsers = [];
                        for (var user in _favoriteUsers) {
                          try {
                            final updatedUser = await ApiService.fetchUser(user.username);
                            updatedUser.previousStatistics = user.statistics;
                            await StorageService.saveUserStats(updatedUser);
                            updatedUsers.add(updatedUser);
                          } catch (e) {
                             updatedUsers.add(user);
                          }
                        }

                        setState(() {
                          _favoriteUsers = updatedUsers;
                           _isLoading = false;
                        });
                        await _saveFavorites();
                        await _loadHistoricalStats();

                        if (!mounted) return;

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FavoriteScreen(
                              favoriteUsers: _favoriteUsers,
                              onRemoveFromFavorites: _removeFromFavorites,
                              onUpdateUser: _updateUser,
                              historicalStats: _historicalStats,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.favorite, color: AppColors.favorite),
                      label: const Text('Favorites',
                          style: TextStyle(
                              fontFamily: 'Exo2',
                              color: AppColors.text,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.buttons,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 15),
                        elevation: 5,
                      ),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: Text(
                  "Created by @kn00pers",
                  style: TextStyle(
                    fontFamily: 'Exo2',
                    color: Color.fromARGB(255, 173, 172, 176),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
