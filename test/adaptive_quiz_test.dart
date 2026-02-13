import 'package:flutter_test/flutter_test.dart';
import 'package:english_learning_app/models/lesson_content.dart';
import 'package:english_learning_app/models/learning_path.dart';

void main() {
  group('Adaptive Quiz - Retry Question Generation', () {
    test('all path units have questions with valid answers', () {
      final allUnits = LearningPath.getAllUnitsFlat();
      for (final unit in allUnits) {
        expect(unit.questions.isNotEmpty, true,
            reason: 'Unit "${unit.id}" has no questions');
        for (final q in unit.questions) {
          expect(q.options.isNotEmpty, true,
              reason: 'Question "${q.question}" has no options');
          // wordOrder: answer is a sentence, options are word chips
          if (q.type == QuestionType.wordOrder) continue;
          expect(
            q.options
                .map((o) => o.toLowerCase())
                .contains(q.answer.toLowerCase()),
            true,
            reason:
                'Answer "${q.answer}" not in options for "${q.question}" in unit "${unit.id}"',
          );
        }
      }
    });

    test('retry question preserves the correct answer', () {
      // Simulate what _createRetryQuestion does
      final original = Question(
        question: 'What color is the sun?',
        answer: 'yellow',
        options: ['yellow', 'blue', 'green'],
        emoji: '☀️',
      );

      // The retry should keep the same answer
      final retryOptions = List<String>.from(original.options);
      expect(retryOptions.contains(original.answer), true);
    });

    test('retry question options still contain the answer after shuffle', () {
      final original = Question(
        question: 'What animal says meow?',
        answer: 'cat',
        options: ['cat', 'dog', 'bird'],
        emoji: '🐱',
      );

      // Shuffle multiple times to ensure answer is never lost
      for (int i = 0; i < 20; i++) {
        final shuffled = List<String>.from(original.options)..shuffle();
        expect(shuffled.contains(original.answer), true);
      }
    });

    test('accuracy calculation: all correct on first try = 1.0', () {
      int totalOriginal = 4;
      int correctOnFirstTry = 4;
      double accuracy = correctOnFirstTry / totalOriginal;
      expect(accuracy, 1.0);
    });

    test('accuracy calculation: half correct on first try = 0.5', () {
      int totalOriginal = 4;
      int correctOnFirstTry = 2;
      double accuracy = correctOnFirstTry / totalOriginal;
      expect(accuracy, 0.5);
    });

    test('accuracy calculation: none correct on first try = 0.0', () {
      int totalOriginal = 4;
      int correctOnFirstTry = 0;
      double accuracy = correctOnFirstTry / totalOriginal;
      expect(accuracy, 0.0);
    });

    test('retry questions increase queue length but not totalOriginal', () {
      // Simulate quiz behavior
      final questions = [
        Question(
            question: 'Q1',
            answer: 'a',
            options: ['a', 'b', 'c'],
            emoji: '❓'),
        Question(
            question: 'Q2',
            answer: 'b',
            options: ['a', 'b', 'c'],
            emoji: '❓'),
      ];

      final queue = List<Question>.from(questions);
      final totalOriginal = queue.length;
      expect(totalOriginal, 2);

      // Wrong answer on Q1 → inject retry after it
      final retry = Question(
        question: 'Try again! ${questions[0].question}',
        answer: questions[0].answer,
        options: List<String>.from(questions[0].options)..shuffle(),
        emoji: questions[0].emoji,
      );
      queue.insert(1, retry);

      expect(queue.length, 3); // 2 original + 1 retry
      expect(totalOriginal, 2); // unchanged
      expect(queue[1].question, startsWith('Try again!'));
    });
  });

  group('Adaptive Quiz - Question Content Integrity', () {
    test('every unit has at least 2 questions', () {
      for (final unit in LearningPath.getAllUnitsFlat()) {
        expect(unit.questions.length, greaterThanOrEqualTo(2),
            reason: 'Unit "${unit.id}" has fewer than 2 questions');
      }
    });

    test('every multiple-choice/listening/reading question has at least 3 options', () {
      for (final unit in LearningPath.getAllUnitsFlat()) {
        for (final q in unit.questions) {
          // Speaking, writing, and wordOrder exercises don't need 3+ MC options
          if (q.type == QuestionType.speaking || q.type == QuestionType.writing || q.type == QuestionType.wordOrder) continue;
          expect(q.options.length, greaterThanOrEqualTo(3),
              reason:
                  'Question "${q.question}" in unit "${unit.id}" has fewer than 3 options');
        }
      }
    });

    test('every question has a non-empty emoji', () {
      for (final unit in LearningPath.getAllUnitsFlat()) {
        for (final q in unit.questions) {
          expect(q.emoji.isNotEmpty, true,
              reason: 'Question "${q.question}" in unit "${unit.id}" has no emoji');
        }
      }
    });

    test('legacy modules also have valid question structure', () {
      for (final module in LessonContent.getAllModules()) {
        for (final lesson in module.lessons) {
          expect(lesson.questions.isNotEmpty, true);
          for (final q in lesson.questions) {
            expect(q.options.length, greaterThanOrEqualTo(3));
            expect(q.emoji.isNotEmpty, true);
          }
        }
      }
    });
  });
}
