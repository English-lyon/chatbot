import 'package:flutter_test/flutter_test.dart';
import 'package:english_learning_app/models/learning_path.dart';
import 'package:english_learning_app/models/user_progress.dart';
import 'package:english_learning_app/models/user_profile.dart';

void main() {
  group('Placement Logic', () {
    test('skipping all A1* sections lands on A2-', () {
      final sections = LearningPath.getSections();
      final a1Units = <String>{};
      for (final section in sections) {
        if (section.cefrLevel.startsWith('A1')) {
          for (final chapter in section.chapters) {
            for (final unit in chapter.units) {
              a1Units.add(unit.id);
            }
          }
        }
      }
      expect(a1Units.isNotEmpty, true);

      final progress = UserProgress();
      for (final unitId in a1Units) {
        progress.completedUnitIds.add(unitId);
      }

      final next = LearningPath.getNextUnit(progress.completedUnitIds);
      expect(next, isNotNull);

      final currentSection =
          LearningPath.getCurrentSection(progress.completedUnitIds);
      expect(currentSection, isNotNull);
      expect(currentSection!.cefrLevel, 'A2-');
    });

    test('skipping A1- section leaves A1 units', () {
      final sections = LearningPath.getSections();
      final a1MinusSection = sections.firstWhere((s) => s.cefrLevel == 'A1-');
      final skippedUnits = <String>{};
      for (final chapter in a1MinusSection.chapters) {
        for (final unit in chapter.units) {
          skippedUnits.add(unit.id);
        }
      }

      final progress = UserProgress();
      for (final unitId in skippedUnits) {
        progress.completedUnitIds.add(unitId);
      }

      final next = LearningPath.getNextUnit(progress.completedUnitIds);
      expect(next, isNotNull);
      final currentSection =
          LearningPath.getCurrentSection(progress.completedUnitIds);
      expect(currentSection!.cefrLevel, 'A1');
    });

    test('no skipping means start at very first unit', () {
      final next = LearningPath.getNextUnit({});
      final allUnits = LearningPath.getAllUnitsFlat();
      expect(next, isNotNull);
      expect(next!.id, allUnits.first.id);
    });
  });

  group('Profile + Placement integration', () {
    test('profile tracks placement level', () {
      final profile = UserProfile(
        name: 'Test',
        hasCompletedSetup: true,
        hasCompletedPlacement: true,
        placedLevel: 'A2',
      );
      expect(profile.placedLevel, 'A2');
      expect(profile.hasCompletedPlacement, true);
    });

    test('new profile needs both setup and placement', () {
      final profile = UserProfile();
      expect(profile.hasCompletedSetup, false);
      expect(profile.hasCompletedPlacement, false);
    });
  });

  group('Re-assessment detection', () {
    test('no reassessment needed with good accuracy', () {
      final p = UserProgress();
      p.completeUnit('u1', 100, accuracy: 0.9);
      p.completeUnit('u2', 100, accuracy: 0.85);
      p.completeUnit('u3', 100, accuracy: 0.8);
      expect(p.recentAccuracy, greaterThan(0.5));
    });

    test('reassessment needed with poor accuracy', () {
      final p = UserProgress();
      p.completeUnit('u1', 25, accuracy: 0.25);
      p.completeUnit('u2', 25, accuracy: 0.25);
      p.completeUnit('u3', 0, accuracy: 0.0);
      expect(p.recentAccuracy, lessThan(0.5));
    });

    test('accuracy only considers last 3 units', () {
      final p = UserProgress();
      // First 2 are bad
      p.completeUnit('u1', 0, accuracy: 0.0);
      p.completeUnit('u2', 0, accuracy: 0.0);
      // Last 3 are good
      p.completeUnit('u3', 100, accuracy: 1.0);
      p.completeUnit('u4', 100, accuracy: 1.0);
      p.completeUnit('u5', 100, accuracy: 0.9);
      // Recent = average of last 3 = (1.0 + 1.0 + 0.9) / 3 = 0.966
      expect(p.recentAccuracy, greaterThan(0.9));
    });
  });
}
