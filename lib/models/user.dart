class User {
  final int id;
  final String username;
  final String avatarUrl;
  final Country country;
  final bool isActive;
  final bool isBot;
  final bool isOnline;
  final bool isSupporter;
  final String? lastVisit;
  final Statistics? statistics;
  final String joinDate;

  User({
    required this.id,
    required this.username,
    required this.avatarUrl,
    required this.country,
    required this.isActive,
    required this.isBot,
    required this.isOnline,
    required this.isSupporter,
    required this.lastVisit,
    required this.statistics,
    required this.joinDate,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      avatarUrl: json['avatar_url'],
      country: Country.fromJson(json['country']),
      isActive: json['is_active'],
      isBot: json['is_bot'],
      isOnline: json['is_online'],
      isSupporter: json['is_supporter'],
      lastVisit: json['last_visit'],
      statistics: json['statistics'] != null ? Statistics.fromJson(json['statistics']) : null,
      joinDate: json['join_date'],
    );
  }
}

class Country {
  final String code;
  final String name;

  Country({required this.code, required this.name});

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      code: json['code'],
      name: json['name'],
    );
  }
}

class Statistics {
  final double? pp;
  final int? globalRank;
  final int? countryRank;
  final Level? level;
  final double? hitAccuracy;

  Statistics({this.pp, this.globalRank, this.countryRank, this.level, this.hitAccuracy});

  factory Statistics.fromJson(Map<String, dynamic> json) {
    return Statistics(
      pp: (json['pp'] as num?)?.toDouble(),
      globalRank: json['global_rank'],
      countryRank: json['country_rank'],
      level: json['level'] != null ? Level.fromJson(json['level']) : null,
      hitAccuracy: json['hit_accuracy'],
    );
  }
}

class Level {
  final int? current;

  Level({this.current});

  factory Level.fromJson(Map<String, dynamic> json) {
    return Level(
      current: json['current'],
    );
  }
}