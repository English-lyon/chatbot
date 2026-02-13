import 'package:flutter_test/flutter_test.dart';
import 'package:english_learning_app/models/learning_path.dart';
import 'package:english_learning_app/models/lesson_content.dart';

void main() {
  group('LearningPath Structure', () {
    test('has at least 2 sections', () {
      final sections = LearningPath.getSections();
      expect(sections.length, greaterThanOrEqualTo(2));
    });

    test('sections have valid CEFR levels', () {
      final validLevels = ['A1-', 'A1', 'A1+', 'A2-', 'A2', 'A2+', 'B1', 'B2', 'C1', 'C2'];
      for (final section in LearningPath.getSections()) {
        expect(validLevels.contains(section.cefrLevel), true,
            reason: '${section.cefrLevel} is not a valid CEFR level');
      }
    });

    test('each section has at least one chapter', () {
      for (final section in LearningPath.getSections()) {
        expect(section.chapters.isNotEmpty, true,
            reason: 'Section ${section.id} has no chapters');
      }
    });

    test('each chapter has at least one unit', () {
      for (final section in LearningPath.getSections()) {
        for (final chapter in section.chapters) {
          expect(chapter.units.isNotEmpty, true,
              reason: 'Chapter ${chapter.id} has no units');
        }
      }
    });

    test('each unit has at least one question', () {
      for (final unit in LearningPath.getAllUnitsFlat()) {
        expect(unit.questions.isNotEmpty, true,
            reason: 'Unit ${unit.id} has no questions');
      }
    });

    test('all unit IDs are unique', () {
      final ids = LearningPath.getAllUnitsFlat().map((u) => u.id).toList();
      expect(ids.toSet().length, ids.length,
          reason: 'Duplicate unit IDs found');
    });

    test('all questions have answer in options', () {
      for (final unit in LearningPath.getAllUnitsFlat()) {
        for (final q in unit.questions) {
          // wordOrder: answer is a sentence, options are word chips
          if (q.type == QuestionType.wordOrder) continue;
          expect(
            q.options.map((o) => o.toLowerCase()).contains(q.answer.toLowerCase()),
            true,
            reason:
                'Answer "${q.answer}" not in options for "${q.question}" in unit ${unit.id}',
          );
        }
      }
    });

    test('each chapter ends with a review unit', () {
      for (final section in LearningPath.getSections()) {
        for (final chapter in section.chapters) {
          final lastUnit = chapter.units.last;
          expect(lastUnit.type, UnitType.review,
              reason: 'Chapter ${chapter.id} does not end with a review unit');
        }
      }
    });

    test('review units have higher pointsReward', () {
      for (final unit in LearningPath.getAllUnitsFlat()) {
        if (unit.type == UnitType.review) {
          expect(unit.pointsReward, greaterThan(25),
              reason: 'Review unit ${unit.id} should reward more than 25 points');
        }
      }
    });
  });

  group('LearningPath Navigation', () {
    test('getAllUnitsFlat returns all units in order', () {
      final allUnits = LearningPath.getAllUnitsFlat();
      expect(allUnits.length, LearningPath.getTotalUnits());
      expect(allUnits.length, greaterThan(0));
    });

    test('getNextUnit returns first unit when none completed', () {
      final next = LearningPath.getNextUnit({});
      final allUnits = LearningPath.getAllUnitsFlat();
      expect(next, isNotNull);
      expect(next!.id, allUnits.first.id);
    });

    test('getNextUnit returns second unit when first completed', () {
      final allUnits = LearningPath.getAllUnitsFlat();
      final next = LearningPath.getNextUnit({allUnits.first.id});
      expect(next, isNotNull);
      expect(next!.id, allUnits[1].id);
    });

    test('getNextUnit returns null when all completed', () {
      final allIds = LearningPath.getAllUnitsFlat().map((u) => u.id).toSet();
      final next = LearningPath.getNextUnit(allIds);
      expect(next, isNull);
    });

    test('getUnitById finds existing unit', () {
      final allUnits = LearningPath.getAllUnitsFlat();
      for (final unit in allUnits) {
        final found = LearningPath.getUnitById(unit.id);
        expect(found, isNotNull);
        expect(found!.id, unit.id);
      }
    });

    test('getUnitById returns null for non-existent unit', () {
      expect(LearningPath.getUnitById('nonexistent'), isNull);
    });

    test('isUnitUnlocked: first unit is always unlocked', () {
      final allUnits = LearningPath.getAllUnitsFlat();
      expect(LearningPath.isUnitUnlocked(allUnits.first.id, {}), true);
    });

    test('isUnitUnlocked: second unit locked when first not completed', () {
      final allUnits = LearningPath.getAllUnitsFlat();
      expect(LearningPath.isUnitUnlocked(allUnits[1].id, {}), false);
    });

    test('isUnitUnlocked: completed units are always unlocked', () {
      final allUnits = LearningPath.getAllUnitsFlat();
      expect(
        LearningPath.isUnitUnlocked(allUnits.first.id, {allUnits.first.id}),
        true,
      );
    });

    test('getCurrentSection returns A1- for empty progress', () {
      final section = LearningPath.getCurrentSection({});
      expect(section, isNotNull);
      expect(section!.cefrLevel, 'A1-');
    });

    test('getCurrentChapter returns first chapter for empty progress', () {
      final chapter = LearningPath.getCurrentChapter({});
      expect(chapter, isNotNull);
      expect(chapter!.id, LearningPath.getSections().first.chapters.first.id);
    });
  });

  group('LearningPath Progress', () {
    test('overall progress is 0 when nothing completed', () {
      expect(LearningPath.getOverallProgress({}), 0.0);
    });

    test('overall progress is 1.0 when all completed', () {
      final allIds = LearningPath.getAllUnitsFlat().map((u) => u.id).toSet();
      expect(LearningPath.getOverallProgress(allIds), 1.0);
    });

    test('section progress is 0 when nothing completed', () {
      expect(LearningPath.getSectionProgress('section_a1_minus', {}), 0.0);
    });

    test('section progress increases with completed units', () {
      final firstSection = LearningPath.getSections().first;
      final units = <String>[];
      for (final chapter in firstSection.chapters) {
        for (final unit in chapter.units) {
          units.add(unit.id);
        }
      }

      final halfCompleted = units.sublist(0, units.length ~/ 2).toSet();
      final progress = LearningPath.getSectionProgress(firstSection.id, halfCompleted);
      expect(progress, greaterThan(0.0));
      expect(progress, lessThan(1.0));
    });

    test('section progress is 1.0 when all section units completed', () {
      final firstSection = LearningPath.getSections().first;
      final ids = <String>{};
      for (final chapter in firstSection.chapters) {
        for (final unit in chapter.units) {
          ids.add(unit.id);
        }
      }
      expect(LearningPath.getSectionProgress(firstSection.id, ids), 1.0);
    });

    test('getTotalUnits matches getAllUnitsFlat length', () {
      expect(LearningPath.getTotalUnits(), LearningPath.getAllUnitsFlat().length);
    });
  });
}
