import 'package:flutter_test/flutter_test.dart';
import 'package:english_learning_app/models/user_progress.dart';
import 'package:english_learning_app/models/lesson_content.dart';
import 'package:english_learning_app/models/learning_path.dart';

void main() {
  group('App Smoke Tests', () {
    test('UserProgress can be created with defaults', () {
      final progress = UserProgress();
      expect(progress.level, 1);
      expect(progress.totalPoints, 0);
      expect(progress.cefrLevel, 'A1');
      expect(progress.completedUnitIds, isEmpty);
    });

    test('LessonContent has modules', () {
      final modules = LessonContent.getAllModules();
      expect(modules.isNotEmpty, true);
    });

    test('LearningPath has sections and units', () {
      final sections = LearningPath.getSections();
      expect(sections.isNotEmpty, true);
      expect(LearningPath.getTotalUnits(), greaterThan(0));
    });

    test('All legacy questions have valid answers in options', () {
      for (final module in LessonContent.getAllModules()) {
        for (final lesson in module.lessons) {
          for (final q in lesson.questions) {
            expect(
              q.options.map((o) => o.toLowerCase()).contains(q.answer.toLowerCase()),
              true,
              reason: 'Answer "${q.answer}" missing from options in "${q.question}"',
            );
          }
        }
      }
    });

    test('All path questions have valid answers in options', () {
      for (final unit in LearningPath.getAllUnitsFlat()) {
        for (final q in unit.questions) {
          // wordOrder: answer is a sentence, options are word chips
          if (q.type == QuestionType.wordOrder) continue;
          expect(
            q.options.map((o) => o.toLowerCase()).contains(q.answer.toLowerCase()),
            true,
            reason: 'Answer "${q.answer}" missing from options in unit "${unit.id}"',
          );
        }
      }
    });

    test('CEFR levels progress correctly', () {
      final p = UserProgress();
      expect(p.cefrLevel, 'A1');
      p.totalPoints = 250;
      expect(p.cefrLevel, 'A2');
      p.totalPoints = 600;
      expect(p.cefrLevel, 'B1');
      p.totalPoints = 1500;
      expect(p.cefrLevel, 'B2');
    });

    test('Streak resets on skipped day', () {
      final p = UserProgress();
      final threeDaysAgo = DateTime.now().subtract(const Duration(days: 3));
      p.lastActivity = threeDaysAgo.toIso8601String().split('T')[0];
      p.currentStreak = 5;
      p.updateStreak();
      expect(p.currentStreak, 1);
    });

    test('Streak continues on consecutive day', () {
      final p = UserProgress();
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      p.lastActivity = yesterday.toIso8601String().split('T')[0];
      p.currentStreak = 3;
      p.updateStreak();
      expect(p.currentStreak, 4);
    });

    test('Multiple level ups work correctly', () {
      final p = UserProgress();
      p.addPoints(300);
      expect(p.level, greaterThan(2));
    });

    test('completeUnit tracks unit and adds points', () {
      final p = UserProgress();
      p.completeUnit('a1_greetings_1', 100);
      expect(p.completedUnitIds.contains('a1_greetings_1'), true);
      expect(p.totalPoints, 100);
    });

    test('Linear path progression works', () {
      final allUnits = LearningPath.getAllUnitsFlat();
      final completed = <String>{};

      // Complete first 3 units
      for (int i = 0; i < 3; i++) {
        completed.add(allUnits[i].id);
      }

      final next = LearningPath.getNextUnit(completed);
      expect(next, isNotNull);
      expect(next!.id, allUnits[3].id);
    });

    test('completedUnitIds serializes correctly', () {
      final p = UserProgress();
      p.completedUnitIds.add('test_unit_1');
      p.completedUnitIds.add('test_unit_2');

      final json = p.toJson();
      final restored = UserProgress.fromJson(json);
      expect(restored.completedUnitIds, contains('test_unit_1'));
      expect(restored.completedUnitIds, contains('test_unit_2'));
    });
  });
}
