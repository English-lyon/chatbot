import 'package:flutter_test/flutter_test.dart';
import 'package:english_learning_app/models/lesson_content.dart';

void main() {
  group('Question', () {
    test('should create a question with all fields', () {
      final q = Question(
        question: 'What color is the sky?',
        answer: 'blue',
        options: ['red', 'blue', 'green'],
        emoji: '☁️',
      );
      expect(q.question, 'What color is the sky?');
      expect(q.answer, 'blue');
      expect(q.options.length, 3);
      expect(q.emoji, '☁️');
    });

    test('correct answer should be in options list', () {
      final q = Question(
        question: 'Test?',
        answer: 'blue',
        options: ['red', 'blue', 'green'],
        emoji: '🔵',
      );
      expect(q.options.contains(q.answer), true);
    });

    test('toJson should serialize correctly', () {
      final q = Question(
        question: 'Test?',
        answer: 'blue',
        options: ['red', 'blue', 'green'],
        emoji: '🔵',
      );
      final json = q.toJson();
      expect(json['question'], 'Test?');
      expect(json['answer'], 'blue');
      expect(json['options'], ['red', 'blue', 'green']);
      expect(json['emoji'], '🔵');
    });

    test('fromJson should deserialize correctly', () {
      final json = {
        'question': 'Test?',
        'answer': 'blue',
        'options': ['red', 'blue', 'green'],
        'emoji': '🔵',
      };
      final q = Question.fromJson(json);
      expect(q.question, 'Test?');
      expect(q.answer, 'blue');
      expect(q.options.length, 3);
    });
  });

  group('Lesson', () {
    test('should create a lesson with questions', () {
      final lesson = Lesson(
        id: 'test_1',
        title: 'Test Lesson',
        level: 1,
        questions: [
          Question(
            question: 'Q1?',
            answer: 'a',
            options: ['a', 'b', 'c'],
            emoji: '❓',
          ),
        ],
      );
      expect(lesson.id, 'test_1');
      expect(lesson.title, 'Test Lesson');
      expect(lesson.level, 1);
      expect(lesson.questions.length, 1);
    });
  });

  group('Module', () {
    test('should create a module with lessons', () {
      final module = Module(
        id: 'test',
        name: 'Test Module',
        icon: '📝',
        lessons: [],
      );
      expect(module.id, 'test');
      expect(module.name, 'Test Module');
      expect(module.icon, '📝');
    });
  });

  group('LessonContent', () {
    test('should have at least 4 modules', () {
      final modules = LessonContent.getAllModules();
      expect(modules.length, greaterThanOrEqualTo(4));
    });

    test('all modules should have at least 1 lesson', () {
      final modules = LessonContent.getAllModules();
      for (final module in modules) {
        expect(module.lessons.isNotEmpty, true,
            reason: 'Module ${module.id} has no lessons');
      }
    });

    test('all lessons should have at least 3 questions', () {
      final modules = LessonContent.getAllModules();
      for (final module in modules) {
        for (final lesson in module.lessons) {
          expect(lesson.questions.length, greaterThanOrEqualTo(3),
              reason: 'Lesson ${lesson.id} has fewer than 3 questions');
        }
      }
    });

    test('all questions should have the answer in options', () {
      final modules = LessonContent.getAllModules();
      for (final module in modules) {
        for (final lesson in module.lessons) {
          for (final question in lesson.questions) {
            expect(
              question.options
                  .map((o) => o.toLowerCase())
                  .contains(question.answer.toLowerCase()),
              true,
              reason:
                  'Question "${question.question}" answer "${question.answer}" not in options ${question.options}',
            );
          }
        }
      }
    });

    test('all questions should have at least 3 options', () {
      final modules = LessonContent.getAllModules();
      for (final module in modules) {
        for (final lesson in module.lessons) {
          for (final question in lesson.questions) {
            expect(question.options.length, greaterThanOrEqualTo(3),
                reason:
                    'Question "${question.question}" has fewer than 3 options');
          }
        }
      }
    });

    test('getModule should return correct module', () {
      final module = LessonContent.getModule('colors');
      expect(module, isNotNull);
      expect(module!.id, 'colors');
    });

    test('getModule should return null for unknown module', () {
      final module = LessonContent.getModule('nonexistent');
      expect(module, isNull);
    });

    test('getLessonsForLevel 1 should return only level 1 lessons', () {
      final lessons = LessonContent.getLessonsForLevel(1);
      for (final lesson in lessons) {
        expect(lesson.level, lessThanOrEqualTo(1));
      }
      expect(lessons.isNotEmpty, true);
    });

    test('getLessonsForLevel should include lower levels', () {
      final level1 = LessonContent.getLessonsForLevel(1);
      final level2 = LessonContent.getLessonsForLevel(2);
      expect(level2.length, greaterThanOrEqualTo(level1.length));
    });

    test('each lesson should have a unique id', () {
      final modules = LessonContent.getAllModules();
      final allIds = <String>{};
      for (final module in modules) {
        for (final lesson in module.lessons) {
          expect(allIds.contains(lesson.id), false,
              reason: 'Duplicate lesson id: ${lesson.id}');
          allIds.add(lesson.id);
        }
      }
    });

    test('each module should have a unique id', () {
      final modules = LessonContent.getAllModules();
      final ids = modules.map((m) => m.id).toSet();
      expect(ids.length, modules.length);
    });
  });
}
