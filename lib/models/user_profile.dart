import 'dart:convert';

class UserProfile {
  String name;
  String avatarEmoji;
  int favoriteColorValue;
  bool hasCompletedSetup;
  bool hasCompletedPlacement;
  String? placedLevel; // CEFR level determined by placement test

  UserProfile({
    this.name = '',
    this.avatarEmoji = '🧒',
    this.favoriteColorValue = 0xFF3366CC,
    this.hasCompletedSetup = false,
    this.hasCompletedPlacement = false,
    this.placedLevel,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'avatarEmoji': avatarEmoji,
        'favoriteColorValue': favoriteColorValue,
        'hasCompletedSetup': hasCompletedSetup,
        'hasCompletedPlacement': hasCompletedPlacement,
        'placedLevel': placedLevel,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] ?? '',
      avatarEmoji: json['avatarEmoji'] ?? '🧒',
      favoriteColorValue: json['favoriteColorValue'] ?? 0xFF3366CC,
      hasCompletedSetup: json['hasCompletedSetup'] ?? false,
      hasCompletedPlacement: json['hasCompletedPlacement'] ?? false,
      placedLevel: json['placedLevel'],
    );
  }

  String toJsonString() => jsonEncode(toJson());

  factory UserProfile.fromJsonString(String jsonString) {
    return UserProfile.fromJson(jsonDecode(jsonString));
  }
}
