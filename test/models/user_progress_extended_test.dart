import 'package:flutter_test/flutter_test.dart';
import 'package:english_learning_app/models/user_progress.dart';

void main() {
  group('UserProgress - Accuracy Tracking', () {
    test('completeUnit stores accuracy in history', () {
      final p = UserProgress();
      p.completeUnit('u1', 100, accuracy: 0.75);
      expect(p.unitAccuracyHistory['u1'], 0.75);
    });

    test('completeUnit defaults to accuracy 1.0', () {
      final p = UserProgress();
      p.completeUnit('u1', 50);
      expect(p.unitAccuracyHistory['u1'], 1.0);
    });

    test('recentAccuracy returns 1.0 when no history', () {
      final p = UserProgress();
      expect(p.recentAccuracy, 1.0);
    });

    test('recentAccuracy averages last 3 units', () {
      final p = UserProgress();
      p.completeUnit('u1', 100, accuracy: 1.0);
      p.completeUnit('u2', 100, accuracy: 0.5);
      p.completeUnit('u3', 100, accuracy: 0.5);
      p.completeUnit('u4', 100, accuracy: 0.0);
      // Last 3: 0.5, 0.5, 0.0 → average = 0.333...
      expect(p.recentAccuracy, closeTo(0.333, 0.01));
    });

    test('recentAccuracy with fewer than 3 units averages all', () {
      final p = UserProgress();
      p.completeUnit('u1', 100, accuracy: 0.5);
      p.completeUnit('u2', 100, accuracy: 1.0);
      expect(p.recentAccuracy, 0.75);
    });
  });

  group('UserProgress - Accuracy Serialization', () {
    test('unitAccuracyHistory survives JSON roundtrip', () {
      final p = UserProgress();
      p.completeUnit('u1', 50, accuracy: 0.8);
      p.completeUnit('u2', 75, accuracy: 0.6);

      final json = p.toJson();
      final restored = UserProgress.fromJson(json);

      expect(restored.unitAccuracyHistory['u1'], 0.8);
      expect(restored.unitAccuracyHistory['u2'], 0.6);
    });

    test('unitAccuracyHistory survives string roundtrip', () {
      final p = UserProgress();
      p.completeUnit('x', 100, accuracy: 0.42);

      final restored = UserProgress.fromJsonString(p.toJsonString());
      expect(restored.unitAccuracyHistory['x'], closeTo(0.42, 0.001));
    });

    test('empty unitAccuracyHistory deserializes from missing key', () {
      final p = UserProgress.fromJson({});
      expect(p.unitAccuracyHistory, isEmpty);
    });
  });

  group('UserProgress - Achievements with units', () {
    test('completing units adds points and triggers level up', () {
      final p = UserProgress();
      p.completeUnit('u1', 150);
      expect(p.totalPoints, 150);
      expect(p.level, 2); // 150 >= 1*100
    });

    test('completing many units triggers multiple level ups', () {
      final p = UserProgress();
      p.completeUnit('u1', 500);
      expect(p.level, greaterThanOrEqualTo(3));
    });
  });
}
