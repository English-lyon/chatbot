import 'package:flutter_test/flutter_test.dart';
import 'package:english_learning_app/models/user_profile.dart';
import 'package:english_learning_app/models/user_progress.dart';

void main() {
  group('Root Screen Routing Logic', () {
    test('new user needs setup', () {
      final profile = UserProfile();
      expect(profile.hasCompletedSetup, false);
      // RootScreen should show ProfileSetupScreen
    });

    test('user who completed setup but not placement needs placement', () {
      final profile = UserProfile(hasCompletedSetup: true);
      expect(profile.hasCompletedSetup, true);
      expect(profile.hasCompletedPlacement, false);
      // RootScreen should show PlacementTestScreen
    });

    test('user who completed both goes to menu', () {
      final profile = UserProfile(
        hasCompletedSetup: true,
        hasCompletedPlacement: true,
      );
      expect(profile.hasCompletedSetup, true);
      expect(profile.hasCompletedPlacement, true);
      // RootScreen should show MenuScreen
    });
  });

  group('Profile Setup Flow', () {
    test('profile stores all setup fields', () {
      final profile = UserProfile();
      profile.name = 'Emma';
      profile.avatarEmoji = '🦄';
      profile.favoriteColorValue = 0xFFE91E63;
      profile.hasCompletedSetup = true;

      expect(profile.name, 'Emma');
      expect(profile.avatarEmoji, '🦄');
      expect(profile.favoriteColorValue, 0xFFE91E63);
      expect(profile.hasCompletedSetup, true);
    });

    test('profile setup → placement → menu flow via flags', () {
      final profile = UserProfile();

      // Step 1: Setup
      expect(profile.hasCompletedSetup, false);
      expect(profile.hasCompletedPlacement, false);

      profile.name = 'Lucas';
      profile.avatarEmoji = '🐻';
      profile.favoriteColorValue = 0xFF3366CC;
      profile.hasCompletedSetup = true;

      // Step 2: Placement
      expect(profile.hasCompletedSetup, true);
      expect(profile.hasCompletedPlacement, false);

      profile.hasCompletedPlacement = true;
      profile.placedLevel = 'A1';

      // Step 3: Ready for menu
      expect(profile.hasCompletedSetup, true);
      expect(profile.hasCompletedPlacement, true);
      expect(profile.placedLevel, 'A1');
    });

    test('profile survives full JSON roundtrip with all fields', () {
      final profile = UserProfile(
        name: 'Zoé',
        avatarEmoji: '🦋',
        favoriteColorValue: 0xFF9C27B0,
        hasCompletedSetup: true,
        hasCompletedPlacement: true,
        placedLevel: 'A2',
      );

      final restored = UserProfile.fromJsonString(profile.toJsonString());

      expect(restored.name, 'Zoé');
      expect(restored.avatarEmoji, '🦋');
      expect(restored.favoriteColorValue, 0xFF9C27B0);
      expect(restored.hasCompletedSetup, true);
      expect(restored.hasCompletedPlacement, true);
      expect(restored.placedLevel, 'A2');
    });
  });

  group('Full User Journey Simulation', () {
    test('complete user journey: setup → placement → learn → progress', () {
      // 1. Create profile
      final profile = UserProfile(
        name: 'Léa',
        avatarEmoji: '🧚',
        favoriteColorValue: 0xFFFF8F00,
        hasCompletedSetup: true,
      );

      // 2. Placement test: beginner
      profile.hasCompletedPlacement = true;
      profile.placedLevel = 'A1';

      // 3. Learning: complete 3 units with varying accuracy
      final progress = UserProgress();
      progress.completeUnit('a1_greetings_1', 100, accuracy: 1.0);
      progress.completeUnit('a1_greetings_2', 75, accuracy: 0.75);
      progress.completeUnit('a1_greetings_review', 50, accuracy: 0.5);

      // 4. Verify progress
      expect(progress.completedUnitIds.length, 3);
      expect(progress.totalPoints, 225);
      expect(progress.recentAccuracy, closeTo(0.75, 0.01));
      expect(progress.cefrLevel, 'A2'); // 225 >= 200

      // 5. Verify serialization preserves everything
      final restoredProgress =
          UserProgress.fromJsonString(progress.toJsonString());
      expect(restoredProgress.completedUnitIds.length, 3);
      expect(restoredProgress.totalPoints, 225);
      expect(restoredProgress.unitAccuracyHistory.length, 3);

      final restoredProfile =
          UserProfile.fromJsonString(profile.toJsonString());
      expect(restoredProfile.name, 'Léa');
      expect(restoredProfile.placedLevel, 'A1');
    });
  });
}
