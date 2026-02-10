import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/user.dart';
import '../colors/app_colors.dart';
import 'scores_screen.dart';

class UserDetailScreen extends StatefulWidget {
  final User user;
  final Function(User) onAddToFavorites;
  final Function(User) onRemoveFromFavorites;
  final List<User> favoriteUsers;
  final Function(User) onUpdateUser;
  final Map<String, Map<String, dynamic>> historicalStats;

  const UserDetailScreen({
    super.key,
    required this.user,
    required this.onAddToFavorites,
    required this.onRemoveFromFavorites,
    required this.favoriteUsers,
    required this.onUpdateUser,
    required this.historicalStats,
  });

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
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
        color: AppColors.background,
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
                                color: AppColors.text,
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: _toggleFavorite,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.buttons,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                          elevation: 5,
                        ),
                        child: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: AppColors.favorite,
                        ),
                      ),
                      const SizedBox(width: 20),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ScoresScreen(userId: user.id),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.buttons,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                          elevation: 5,
                        ),
                        child: const Text('View Top Scores', style: TextStyle(color: AppColors.text)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Card(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    color: AppColors.buttons,
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
                icon: const Icon(Icons.arrow_back, color: AppColors.text),
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
    Widget differenceWidget = const SizedBox();

    if (ppDifference != null && ppDifference != 0) {
      differenceWidget = Text(
        ' (${ppDifference > 0 ? '+' : ''}${ppDifference.toStringAsFixed(0)})',
        style: TextStyle(color: ppDifference > 0 ? Colors.green : Colors.red),
      );
    } else if (rankDifference != null && rankDifference != 0) {
      differenceWidget = Text(
        ' (${rankDifference > 0 ? '+' : ''}$rankDifference)',
        style: TextStyle(color: rankDifference < 0 ? Colors.green : Colors.red),
      );
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
              color: AppColors.text,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Row(
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontFamily: 'Exo2',
                  color: AppColors.text,
                  fontSize: 16,
                ),
              ),
              differenceWidget,
            ],
          )
        ],
      ),
    );
  }
}
