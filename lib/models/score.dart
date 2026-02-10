
import 'dart:convert';

class Score {
  final double pp;
  final double accuracy;
  final String rank;
  final int maxCombo;
  final Beatmap beatmap;
  final Beatmapset beatmapset;

  Score({
    required this.pp,
    required this.accuracy,
    required this.rank,
    required this.maxCombo,
    required this.beatmap,
    required this.beatmapset,
  });

  factory Score.fromRawJson(String str) => Score.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Score.fromJson(Map<String, dynamic> json) => Score(
        pp: json["pp"] == null ? 0.0 : json["pp"].toDouble(),
        accuracy: json["accuracy"].toDouble(),
        rank: json["rank"],
        maxCombo: json["max_combo"],
        beatmap: Beatmap.fromJson(json["beatmap"]),
        beatmapset: Beatmapset.fromJson(json["beatmapset"]),
      );

  Map<String, dynamic> toJson() => {
        "pp": pp,
        "accuracy": accuracy,
        "rank": rank,
        "max_combo": maxCombo,
        "beatmap": beatmap.toJson(),
        "beatmapset": beatmapset.toJson(),
      };
}

class Beatmap {
  final String version;
  final double difficultyRating;

  Beatmap({
    required this.version,
    required this.difficultyRating,
  });

  factory Beatmap.fromRawJson(String str) => Beatmap.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Beatmap.fromJson(Map<String, dynamic> json) => Beatmap(
        version: json["version"],
        difficultyRating: json["difficulty_rating"].toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "version": version,
        "difficulty_rating": difficultyRating,
      };
}

class Beatmapset {
  final String artist;
  final String title;
  final String creator;
  final Covers covers;

  Beatmapset({
    required this.artist,
    required this.title,
    required this.creator,
    required this.covers,
  });

  factory Beatmapset.fromRawJson(String str) =>
      Beatmapset.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Beatmapset.fromJson(Map<String, dynamic> json) => Beatmapset(
        artist: json["artist"],
        title: json["title"],
        creator: json["creator"],
        covers: Covers.fromJson(json["covers"]),
      );

  Map<String, dynamic> toJson() => {
        "artist": artist,
        "title": title,
        "creator": creator,
        "covers": covers.toJson(),
      };
}

class Covers {
  final String list;

  Covers({required this.list});

  factory Covers.fromRawJson(String str) => Covers.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Covers.fromJson(Map<String, dynamic> json) => Covers(
        list: json["list"],
      );

  Map<String, dynamic> toJson() => {
        "list": list,
      };
}
