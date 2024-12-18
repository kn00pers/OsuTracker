import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/user.dart';

class UserDetailScreen extends StatefulWidget {
  final User user;
  final Function(User) onAddToFavorites;
  final Function(User) onRemoveFromFavorites;
  final List<User> favoriteUsers;
  final Function(User) onUpdateUser;

  UserDetailScreen({
    required this.user,
    required this.onAddToFavorites,
    required this.onRemoveFromFavorites,
    required this.favoriteUsers,
    required this.onUpdateUser,
  });

  @override
  _UserDetailScreenState createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  late bool isFavorite;
  late User user;

  @override
  void initState() {
    super.initState();
    user = widget.user;
    isFavorite = widget.favoriteUsers.any((u) => u.id == user.id);
  }

  void _toggleFavorite() {
    setState(() {
      if (isFavorite) {
        widget.onRemoveFromFavorites(user);
      } else {
        widget.onAddToFavorites(user);
      }
      isFavorite = !isFavorite;
    });
  }

  void _updateUser(User updatedUser) {
    setState(() {
      user = updatedUser;
      widget.onUpdateUser(user);
    });
  }

  @override
  Widget build(BuildContext context) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final DateTime joinDate = DateTime.parse(user.joinDate);
    final String formattedDate = formatter.format(joinDate);
    final String hitAccuracy = user.statistics?.hitAccuracy?.toStringAsFixed(2) ?? 'N/A';
    final String pp = user.statistics?.pp?.toStringAsFixed(0) ?? 'N/A';

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Color(0xFF302e39), // Tło
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      CircleAvatar(
                        radius: 75,
                        backgroundImage: NetworkImage(user.avatarUrl),
                        backgroundColor: Colors.transparent,
                      ),
                      Positioned(
                        bottom: -8,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          child: Text(
                            user.username,
                            style: TextStyle(
                              fontFamily: 'Exo2',
                              color: Color(0xFFeeedf2),
                              fontWeight: FontWeight.bold,
                              fontSize: 32,
                              shadows: [
                                Shadow(
                                  blurRadius: 1,
                                  color: Colors.black,
                                  offset: Offset(2, 2),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _toggleFavorite,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF18171c),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      elevation: 5,
                    ),
                    child: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: Color(0xFFfa66a5),
                    ),
                  ),
                  SizedBox(height: 20),
                  Card(
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    color: Color(0xFF18171c), // Tło karty
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildStatisticRow('Country', user.country.name),
                          _buildStatisticRow('PP', '$pp'),
                          _buildStatisticRow('Hit Accuracy', '$hitAccuracy%'),
                          _buildStatisticRow('Global Rank', user.statistics?.globalRank?.toString() ?? 'N/A'),
                          _buildStatisticRow('Country Rank', user.statistics?.countryRank?.toString() ?? 'N/A'),
                          _buildStatisticRow('Join Date', formattedDate),
                          _buildStatisticRow('Supporter', user.isSupporter ? 'Yes' : 'No'),
                          _buildStatisticRow('Online', user.isOnline ? 'Yes' : 'No'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 40,
              left: 10,
              child: IconButton(
                icon: Icon(Icons.arrow_back, color: Color(0xFFeeedf2)),
                onPressed: () {
                  Navigator.pop(context, user);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Exo2',
              color: Color(0xFFeeedf2),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Exo2',
              color: Color(0xFFeeedf2),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}