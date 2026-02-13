import 'package:flutter_test/flutter_test.dart';
import 'package:english_learning_app/models/user_profile.dart';

void main() {
  group('UserProfile', () {
    test('creates with defaults', () {
      final profile = UserProfile();
      expect(profile.name, '');
      expect(profile.avatarEmoji, '🧒');
      expect(profile.favoriteColorValue, 0xFF3366CC);
      expect(profile.hasCompletedSetup, false);
      expect(profile.hasCompletedPlacement, false);
      expect(profile.placedLevel, isNull);
    });

    test('creates with custom values', () {
      final profile = UserProfile(
        name: 'Alice',
        avatarEmoji: '🦄',
        favoriteColorValue: 0xFFFF0000,
        hasCompletedSetup: true,
        hasCompletedPlacement: true,
        placedLevel: 'A2',
      );
      expect(profile.name, 'Alice');
      expect(profile.avatarEmoji, '🦄');
      expect(profile.favoriteColorValue, 0xFFFF0000);
      expect(profile.hasCompletedSetup, true);
      expect(profile.hasCompletedPlacement, true);
      expect(profile.placedLevel, 'A2');
    });

    test('serializes to JSON', () {
      final profile = UserProfile(
        name: 'Bob',
        avatarEmoji: '🐻',
        favoriteColorValue: 0xFF00FF00,
        hasCompletedSetup: true,
      );
      final json = profile.toJson();
      expect(json['name'], 'Bob');
      expect(json['avatarEmoji'], '🐻');
      expect(json['favoriteColorValue'], 0xFF00FF00);
      expect(json['hasCompletedSetup'], true);
      expect(json['hasCompletedPlacement'], false);
    });

    test('deserializes from JSON', () {
      final json = {
        'name': 'Clara',
        'avatarEmoji': '🦊',
        'favoriteColorValue': 0xFF0000FF,
        'hasCompletedSetup': true,
        'hasCompletedPlacement': true,
        'placedLevel': 'B1',
      };
      final profile = UserProfile.fromJson(json);
      expect(profile.name, 'Clara');
      expect(profile.avatarEmoji, '🦊');
      expect(profile.favoriteColorValue, 0xFF0000FF);
      expect(profile.hasCompletedSetup, true);
      expect(profile.hasCompletedPlacement, true);
      expect(profile.placedLevel, 'B1');
    });

    test('roundtrip JSON string serialization', () {
      final original = UserProfile(
        name: 'David',
        avatarEmoji: '🚀',
        favoriteColorValue: 0xFFFFFF00,
        hasCompletedSetup: true,
        hasCompletedPlacement: true,
        placedLevel: 'A1',
      );
      final jsonString = original.toJsonString();
      final restored = UserProfile.fromJsonString(jsonString);
      expect(restored.name, original.name);
      expect(restored.avatarEmoji, original.avatarEmoji);
      expect(restored.favoriteColorValue, original.favoriteColorValue);
      expect(restored.hasCompletedSetup, original.hasCompletedSetup);
      expect(restored.placedLevel, original.placedLevel);
    });

    test('handles missing fields gracefully', () {
      final profile = UserProfile.fromJson({});
      expect(profile.name, '');
      expect(profile.avatarEmoji, '🧒');
      expect(profile.hasCompletedSetup, false);
    });
  });
}
