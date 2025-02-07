import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/user.dart';

class UserDetailScreen extends StatefulWidget {
  final User user;
  final Function(User) onAddToFavorites;
  final Function(User) onRemoveFromFavorites;
  final List<User> favoriteUsers;
  final Function(User) onUpdateUser;
  final Map<String, Map<String, dynamic>> historicalStats; // Dodano przekazywanie statystyk

  UserDetailScreen({
    required this.user,
    required this.onAddToFavorites,
    required this.onRemoveFromFavorites,
    required this.favoriteUsers,
    required this.onUpdateUser,
    required this.historicalStats, // Nowy parametr
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

  @override
  Widget build(BuildContext context) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final DateTime joinDate = DateTime.parse(user.joinDate);
    final String formattedDate = formatter.format(joinDate);
    final String hitAccuracy = user.statistics?.hitAccuracy?.toStringAsFixed(2) ?? 'N/A';

    // Pobranie historycznych statystyk użytkownika
    final previousStats = widget.historicalStats[user.username];

    final int? globalRankDiff = user.statistics?.globalRank != null && previousStats?['globalRank'] != null
        ? user.statistics!.globalRank! - (previousStats!['globalRank'] as int)
        : null;

    final int? countryRankDiff = user.statistics?.countryRank != null && previousStats?['countryRank'] != null
        ? user.statistics!.countryRank! - (previousStats!['countryRank'] as int)
        : null;

    final double? ppDiff = user.statistics?.pp != null && previousStats?['pp'] != null
        ? user.statistics!.pp! - (previousStats!['pp'] as double)
        : null;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF302e39), // Tło aplikacji
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
                        bottom: -5,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(
                              maxWidth: 150,
                            ),
                            child: Text(
                              user.username,
                              style: const TextStyle(
                                fontFamily: 'Exo2',
                                color: Color(0xFFeeedf2),
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                                shadows: [
                                  Shadow(
                                    blurRadius: 1,
                                    color: Colors.black,
                                    offset: Offset(2, 2),
                                  ),
                                ],
                              ),
                              overflow: TextOverflow.ellipsis,
                              softWrap: true,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _toggleFavorite,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF18171c),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      elevation: 5,
                    ),
                    child: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: const Color(0xFFfa66a5),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Card(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    color: const Color(0xFF18171c),
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildStatisticRow('Country', user.country.name),
                          _buildStatisticRow('PP', user.statistics?.pp?.toStringAsFixed(0) ?? 'N/A', ppDifference: ppDiff),
                          _buildStatisticRow('Hit Accuracy', '$hitAccuracy%'),
                          _buildStatisticRow('Global Rank', user.statistics?.globalRank?.toString() ?? 'N/A', rankDifference: globalRankDiff),
                          _buildStatisticRow('Country Rank', user.statistics?.countryRank?.toString() ?? 'N/A', rankDifference: countryRankDiff),
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
                icon: const Icon(Icons.arrow_back, color: Color(0xFFeeedf2)),
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

  Widget _buildStatisticRow(String label, String value, {double? ppDifference, int? rankDifference}) {
    String differenceText = '';

    if (ppDifference != null && ppDifference != 0) {
      differenceText = ' (${ppDifference >= 0 ? '+' : ''}${ppDifference.toStringAsFixed(0)})'; // pp difference
    } else if (rankDifference != null && rankDifference != 0) {
      differenceText = ' (${rankDifference >= 0 ? '+' : ''}$rankDifference)'; // rank difference
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Exo2',
              color: Color(0xFFeeedf2),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: const TextStyle(
                    fontFamily: 'Exo2',
                    color: Color(0xFFeeedf2),
                    fontSize: 16,
                  ),
                ),
                if (differenceText.isNotEmpty)
                  TextSpan(
                    text: differenceText,
                    style: TextStyle(
                      color: differenceText.contains('+') ? Colors.green : Colors.red,
                      fontSize: 16,
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
