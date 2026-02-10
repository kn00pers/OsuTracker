import 'package:flutter/material.dart';
import '../models/score.dart';
import '../services/api_service.dart';
import '../colors/app_colors.dart';

class ScoresScreen extends StatefulWidget {
  final int userId;

  const ScoresScreen({super.key, required this.userId});

  @override
  State<ScoresScreen> createState() => _ScoresScreenState();
}

class _ScoresScreenState extends State<ScoresScreen> {
  late Future<List<Score>> _scoresFuture;

  @override
  void initState() {
    super.initState();
    _scoresFuture = ApiService.fetchUserScores(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Top Scores'),
        backgroundColor: AppColors.background,
      ),
      backgroundColor: AppColors.background,
      body: FutureBuilder<List<Score>>(
        future: _scoresFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No scores found.'));
          } else {
            final scores = snapshot.data!;
            return ListView.builder(
              itemCount: scores.length,
              itemBuilder: (context, index) {
                final score = scores[index];
                return Card(
                  color: AppColors.buttons,
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    leading: Image.network(score.beatmapset.covers.list),
                    title: Text(
                      '${score.beatmapset.artist} - ${score.beatmapset.title} [${score.beatmap.version}]',
                      style: const TextStyle(color: AppColors.text),
                    ),
                    subtitle: Text(
                      '${score.pp.toStringAsFixed(2)}pp | ${score.accuracy.toStringAsFixed(2)}% | ${score.rank} | ${score.maxCombo}x',
                      style: const TextStyle(color: AppColors.text),
                    ),
                    trailing: Text(
                      '${score.beatmap.difficultyRating.toStringAsFixed(2)}*',
                      style: const TextStyle(color: AppColors.text),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
