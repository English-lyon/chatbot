import 'package:flutter_test/flutter_test.dart';
import 'package:english_learning_app/models/user_progress.dart';

void main() {
  group('UserProgress', () {
    late UserProgress progress;

    setUp(() {
      progress = UserProgress();
    });

    group('Initial state', () {
      test('should start at level 1', () {
        expect(progress.level, 1);
      });

      test('should start with 0 points', () {
        expect(progress.totalPoints, 0);
      });

      test('should start with empty completed lessons', () {
        expect(progress.completedLessons, isEmpty);
      });

      test('should start with 0 streak', () {
        expect(progress.currentStreak, 0);
        expect(progress.bestStreak, 0);
      });

      test('should start with no achievements', () {
        expect(progress.achievements, isEmpty);
      });

      test('should start with no module progress', () {
        expect(progress.moduleProgress, isEmpty);
      });

      test('should have A1 CEFR level initially', () {
        expect(progress.cefrLevel, 'A1');
      });
    });

    group('addPoints', () {
      test('should add points correctly', () {
        progress.addPoints(50);
        expect(progress.totalPoints, 50);
      });

      test('should accumulate points', () {
        progress.addPoints(30);
        progress.addPoints(20);
        expect(progress.totalPoints, 50);
      });

      test('should trigger level up when threshold is reached', () {
        progress.addPoints(100);
        expect(progress.level, greaterThanOrEqualTo(2));
      });
    });

    group('checkLevelUp', () {
      test('should level up at 100 points (level 1 threshold)', () {
        progress.addPoints(100);
        expect(progress.level, 2);
      });

      test('should not level up below threshold', () {
        progress.addPoints(50);
        expect(progress.level, 1);
      });

      test('should handle multiple level ups from large score', () {
        // If threshold is level*100, then level 1->2 at 100, 2->3 at 200 total
        // Giving 300 points should push past level 1 threshold at minimum
        progress.addPoints(300);
        expect(progress.level, greaterThan(2));
      });
    });

    group('completeLesson', () {
      test('should add lesson to completed list', () {
        progress.completeLesson('colors_1', 'colors', 75);
        expect(progress.completedLessons, contains('colors_1'));
      });

      test('should not duplicate completed lessons', () {
        progress.completeLesson('colors_1', 'colors', 75);
        progress.completeLesson('colors_1', 'colors', 100);
        expect(
            progress.completedLessons.where((l) => l == 'colors_1').length, 1);
      });

      test('should create module progress on first lesson', () {
        progress.completeLesson('colors_1', 'colors', 75);
        expect(progress.moduleProgress.containsKey('colors'), true);
        expect(progress.moduleProgress['colors']!.completed, 1);
      });

      test('should track best score per module', () {
        progress.completeLesson('colors_1', 'colors', 50);
        progress.completeLesson('colors_2', 'colors', 100);
        expect(progress.moduleProgress['colors']!.bestScore, 100);
      });

      test('should add points when completing a lesson', () {
        progress.completeLesson('colors_1', 'colors', 75);
        expect(progress.totalPoints, 75);
      });
    });

    group('updateStreak', () {
      test('should increment streak on first activity', () {
        progress.updateStreak();
        expect(progress.currentStreak, 1);
      });

      test('should not increment streak twice on same day', () {
        progress.updateStreak();
        progress.updateStreak();
        expect(progress.currentStreak, 1);
      });

      test('should reset streak when a day is skipped', () {
        // Simulate activity 3 days ago
        final threeDaysAgo =
            DateTime.now().subtract(const Duration(days: 3));
        progress.lastActivity =
            threeDaysAgo.toIso8601String().split('T')[0];
        progress.currentStreak = 5;

        progress.updateStreak();
        // Streak should reset to 1 since we skipped days
        expect(progress.currentStreak, 1);
      });

      test('should continue streak on consecutive day', () {
        final yesterday =
            DateTime.now().subtract(const Duration(days: 1));
        progress.lastActivity =
            yesterday.toIso8601String().split('T')[0];
        progress.currentStreak = 3;

        progress.updateStreak();
        expect(progress.currentStreak, 4);
      });

      test('should update best streak', () {
        progress.currentStreak = 0;
        progress.bestStreak = 0;
        progress.updateStreak();
        expect(progress.bestStreak, 1);
      });
    });

    group('checkAchievements', () {
      test('should unlock first_lesson after 1 completed lesson', () {
        progress.completedLessons.add('test_1');
        final achievement = progress.checkAchievements();
        expect(achievement, isNotNull);
        expect(progress.achievements, contains('first_lesson'));
      });

      test('should not re-unlock already earned achievement', () {
        progress.completedLessons.add('test_1');
        progress.achievements.add('first_lesson');
        final achievement = progress.checkAchievements();
        // Should not return 'Premier pas' again
        expect(achievement != 'Premier pas', true);
      });

      test('should unlock five_lessons after 5 lessons', () {
        for (int i = 0; i < 5; i++) {
          progress.completedLessons.add('test_$i');
        }
        // First call unlocks first_lesson
        progress.checkAchievements();
        // Second call should unlock five_lessons
        progress.checkAchievements();
        expect(progress.achievements, contains('five_lessons'));
      });

      test('should unlock streak_3 when streak >= 3', () {
        progress.currentStreak = 3;
        progress.checkAchievements();
        expect(progress.achievements, contains('streak_3'));
      });
    });

    group('CEFR Level', () {
      test('A1 for low points', () {
        expect(progress.cefrLevel, 'A1');
      });

      test('A2 for intermediate points', () {
        progress.totalPoints = 250;
        expect(progress.cefrLevel, 'A2');
      });

      test('B1 for higher points', () {
        progress.totalPoints = 600;
        expect(progress.cefrLevel, 'B1');
      });

      test('B2 for advanced points', () {
        progress.totalPoints = 1200;
        expect(progress.cefrLevel, 'B2');
      });
    });

    group('Serialization', () {
      test('toJson should include all fields', () {
        progress.addPoints(50);
        progress.completedLessons.add('test_1');
        final json = progress.toJson();

        expect(json['level'], progress.level);
        expect(json['totalPoints'], 50);
        expect(json['completedLessons'], contains('test_1'));
        expect(json['currentStreak'], progress.currentStreak);
        expect(json['bestStreak'], progress.bestStreak);
        expect(json.containsKey('achievements'), true);
      });

      test('fromJson should restore all fields', () {
        final json = {
          'level': 3,
          'totalPoints': 250,
          'completedLessons': ['a', 'b'],
          'currentStreak': 5,
          'bestStreak': 7,
          'lastActivity': '2025-01-01',
          'moduleProgress': {
            'colors': {'completed': 2, 'totalScore': 150, 'bestScore': 100}
          },
          'achievements': ['first_lesson'],
        };

        final restored = UserProgress.fromJson(json);
        expect(restored.level, 3);
        expect(restored.totalPoints, 250);
        expect(restored.completedLessons.length, 2);
        expect(restored.currentStreak, 5);
        expect(restored.bestStreak, 7);
        expect(restored.lastActivity, '2025-01-01');
        expect(restored.moduleProgress['colors']!.completed, 2);
        expect(restored.achievements, contains('first_lesson'));
      });

      test('fromJson with missing fields should use defaults', () {
        final restored = UserProgress.fromJson({});
        expect(restored.level, 1);
        expect(restored.totalPoints, 0);
        expect(restored.completedLessons, isEmpty);
      });

      test('toJsonString and fromJsonString roundtrip', () {
        progress.addPoints(100);
        progress.completedLessons.add('test');
        progress.achievements.add('first_lesson');

        final jsonStr = progress.toJsonString();
        final restored = UserProgress.fromJsonString(jsonStr);

        expect(restored.totalPoints, progress.totalPoints);
        expect(restored.level, progress.level);
        expect(restored.completedLessons, progress.completedLessons);
        expect(restored.achievements, progress.achievements);
      });
    });
  });

  group('ModuleProgress', () {
    test('should start with defaults', () {
      final mp = ModuleProgress();
      expect(mp.completed, 0);
      expect(mp.totalScore, 0);
      expect(mp.bestScore, 0);
    });

    test('toJson should serialize correctly', () {
      final mp = ModuleProgress(completed: 3, totalScore: 200, bestScore: 90);
      final json = mp.toJson();
      expect(json['completed'], 3);
      expect(json['totalScore'], 200);
      expect(json['bestScore'], 90);
    });

    test('fromJson should deserialize correctly', () {
      final mp = ModuleProgress.fromJson({
        'completed': 5,
        'totalScore': 400,
        'bestScore': 100,
      });
      expect(mp.completed, 5);
      expect(mp.totalScore, 400);
      expect(mp.bestScore, 100);
    });

    test('fromJson with missing fields uses defaults', () {
      final mp = ModuleProgress.fromJson({});
      expect(mp.completed, 0);
      expect(mp.totalScore, 0);
      expect(mp.bestScore, 0);
    });
  });
}
