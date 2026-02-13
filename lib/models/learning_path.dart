import 'lesson_content.dart';

enum UnitType { standard, practice, review }

class PathUnit {
  final String id;
  final String title;
  final UnitType type;
  final List<Question> questions;
  final String emoji;
  final int pointsReward;

  PathUnit({
    required this.id,
    required this.title,
    required this.type,
    required this.questions,
    required this.emoji,
    this.pointsReward = 25,
  });
}

class Chapter {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final List<PathUnit> units;

  Chapter({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.units,
  });
}

class Section {
  final String id;
  final String cefrLevel;
  final String title;
  final String description;
  final List<Chapter> chapters;

  Section({
    required this.id,
    required this.cefrLevel,
    required this.title,
    required this.description,
    required this.chapters,
  });
}

class LearningPath {
  static List<Section> getSections() {
    return [
      // ============================================================
      // A1- — Absolute Beginner: First Words
      // ============================================================
      Section(
        id: 'section_a1_minus',
        cefrLevel: 'A1-',
        title: 'First Words',
        description: 'Your very first English words!',
        chapters: [
          Chapter(
            id: 'ch_greetings',
            title: 'Greetings',
            description: 'Say hello and be polite',
            emoji: '👋',
            units: [
              PathUnit(
                id: 'a1m_greetings_1',
                title: 'Say Hello',
                type: UnitType.standard,
                emoji: '👋',
                questions: [
                  Question(question: "How do you say 'bonjour' in English?", answer: 'hello', options: ['hello', 'goodbye', 'thanks'], emoji: '👋'),
                  Question(question: 'Listen and pick the right word', answer: 'hello', options: ['hello', 'sorry', 'goodbye'], emoji: '🔊', type: QuestionType.listening),
                  Question(question: 'Say this word out loud:', answer: 'goodbye', options: ['goodbye'], emoji: '👋', type: QuestionType.speaking),
                  Question(question: "How do you say 'merci' in English?", answer: 'thank you', options: ['thank you', 'please', 'sorry'], emoji: '🙏'),
                  Question(question: "Build: 'hello my friend'", answer: 'hello my friend', options: ['hello', 'my', 'friend', 'cat', 'big'], emoji: '🧩', type: QuestionType.wordOrder),
                ],
              ),
              PathUnit(
                id: 'a1m_greetings_2',
                title: 'Be Polite',
                type: UnitType.standard,
                emoji: '😊',
                questions: [
                  Question(question: 'What do you say when you make a mistake?', answer: 'sorry', options: ['sorry', 'thanks', 'bye'], emoji: '😔'),
                  Question(question: 'Listen and pick the right word', answer: 'please', options: ['please', 'sorry', 'hello'], emoji: '🔊', type: QuestionType.listening),
                  Question(question: 'Read: "Good morning, how are you?" — What time of day is it?', answer: 'morning', options: ['morning', 'night', 'afternoon'], emoji: '📖', type: QuestionType.reading),
                  Question(question: 'Say this word out loud:', answer: 'good morning', options: ['good morning'], emoji: '🌅', type: QuestionType.speaking),
                  Question(question: "Write the English word for 'bonne nuit'", answer: 'good night', options: ['good night'], emoji: '🌙', type: QuestionType.writing),
                ],
              ),
              PathUnit(
                id: 'a1m_greetings_review',
                title: 'Review: First Words',
                type: UnitType.review,
                emoji: '🏆',
                pointsReward: 40,
                questions: [
                  Question(question: "Your friend arrives. What do you say?", answer: 'hello', options: ['hello', 'sorry', 'good night'], emoji: '👋'),
                  Question(question: 'Listen and pick the right word', answer: 'thank you', options: ['thank you', 'goodbye', 'sorry'], emoji: '🔊', type: QuestionType.listening),
                  Question(question: 'Say this word out loud:', answer: 'sorry', options: ['sorry'], emoji: '😔', type: QuestionType.speaking),
                  Question(question: 'Read: "Please give me some water." — What is the polite word?', answer: 'please', options: ['please', 'give', 'water'], emoji: '📖', type: QuestionType.reading),
                  Question(question: "Build: 'thank you very much'", answer: 'thank you very much', options: ['thank', 'you', 'very', 'much', 'cat', 'big'], emoji: '🧩', type: QuestionType.wordOrder),
                ],
              ),
            ],
          ),
        ],
      ),

      // ============================================================
      // A1 — Beginner: Colors
      // ============================================================
      Section(
        id: 'section_a1',
        cefrLevel: 'A1',
        title: 'Colors',
        description: 'Learn the rainbow!',
        chapters: [
          Chapter(
            id: 'ch_colors',
            title: 'Colors',
            description: 'Discover all the colors',
            emoji: '🎨',
            units: [
              PathUnit(
                id: 'a1_colors_1',
                title: 'Basic Colors',
                type: UnitType.standard,
                emoji: '🎨',
                questions: [
                  Question(question: 'What color is the apple?', answer: 'red', options: ['red', 'blue', 'green'], emoji: '🍎'),
                  Question(question: 'Listen and pick the right color', answer: 'blue', options: ['blue', 'red', 'yellow'], emoji: '🔊', type: QuestionType.listening),
                  Question(question: 'Say this color out loud:', answer: 'yellow', options: ['yellow'], emoji: '☀️', type: QuestionType.speaking),
                  Question(question: 'Read: "The frog is green." — What color is the frog?', answer: 'green', options: ['green', 'blue', 'red'], emoji: '📖', type: QuestionType.reading),
                  Question(question: "Build: 'the sky is blue'", answer: 'the sky is blue', options: ['the', 'sky', 'is', 'blue', 'red', 'cat'], emoji: '🧩', type: QuestionType.wordOrder),
                ],
              ),
              PathUnit(
                id: 'a1_colors_2',
                title: 'More Colors',
                type: UnitType.standard,
                emoji: '🌈',
                questions: [
                  Question(question: 'What color is an orange?', answer: 'orange', options: ['orange', 'purple', 'brown'], emoji: '🍊'),
                  Question(question: 'Listen and pick the right color', answer: 'purple', options: ['purple', 'white', 'black'], emoji: '🔊', type: QuestionType.listening),
                  Question(question: 'Say this color out loud:', answer: 'brown', options: ['brown'], emoji: '🍫', type: QuestionType.speaking),
                  Question(question: 'Read: "Snow is white and cold." — What color is snow?', answer: 'white', options: ['white', 'blue', 'gray'], emoji: '📖', type: QuestionType.reading),
                  Question(question: 'Write the color of chocolate', answer: 'brown', options: ['brown'], emoji: '🍫', type: QuestionType.writing),
                ],
              ),
              PathUnit(
                id: 'a1_colors_review',
                title: 'Review: Colors',
                type: UnitType.review,
                emoji: '🏆',
                pointsReward: 40,
                questions: [
                  Question(question: 'Listen and pick the right color', answer: 'yellow', options: ['yellow', 'red', 'purple'], emoji: '🔊', type: QuestionType.listening),
                  Question(question: 'A flamingo is which color?', answer: 'pink', options: ['pink', 'orange', 'red'], emoji: '🦩'),
                  Question(question: 'Say this color out loud:', answer: 'orange', options: ['orange'], emoji: '🍊', type: QuestionType.speaking),
                  Question(question: "Write the color of an apple", answer: 'red', options: ['red'], emoji: '🍎', type: QuestionType.writing),
                  Question(question: 'Read: "The black cat sits on the white rug." — What color is the cat?', answer: 'black', options: ['black', 'white', 'gray'], emoji: '📖', type: QuestionType.reading),
                ],
              ),
            ],
          ),
        ],
      ),

      // ============================================================
      // A1+ — Upper Beginner: Numbers
      // ============================================================
      Section(
        id: 'section_a1_plus',
        cefrLevel: 'A1+',
        title: 'Numbers',
        description: 'Count from 1 to 10!',
        chapters: [
          Chapter(
            id: 'ch_numbers',
            title: 'Numbers',
            description: 'Learn to count in English',
            emoji: '🔢',
            units: [
              PathUnit(
                id: 'a1p_numbers_1',
                title: 'Numbers 1-5',
                type: UnitType.standard,
                emoji: '🔢',
                questions: [
                  Question(question: 'How many fingers on one hand?', answer: 'five', options: ['five', 'four', 'three'], emoji: '✋'),
                  Question(question: 'Listen and pick the right number', answer: 'two', options: ['two', 'one', 'three'], emoji: '🔊', type: QuestionType.listening),
                  Question(question: 'Say this number out loud:', answer: 'three', options: ['three'], emoji: '3️⃣', type: QuestionType.speaking),
                  Question(question: 'Read: "I have one nose and two eyes." — How many eyes?', answer: 'two', options: ['two', 'one', 'three'], emoji: '📖', type: QuestionType.reading),
                  Question(question: 'Write the number of ears you have', answer: 'two', options: ['two'], emoji: '👂', type: QuestionType.writing),
                ],
              ),
              PathUnit(
                id: 'a1p_numbers_2',
                title: 'Numbers 6-10',
                type: UnitType.standard,
                emoji: '🔟',
                questions: [
                  Question(question: 'How many legs does an insect have?', answer: 'six', options: ['six', 'eight', 'four'], emoji: '🐜'),
                  Question(question: 'Listen and pick the right number', answer: 'eight', options: ['eight', 'six', 'ten'], emoji: '🔊', type: QuestionType.listening),
                  Question(question: 'Say this number out loud:', answer: 'seven', options: ['seven'], emoji: '7️⃣', type: QuestionType.speaking),
                  Question(question: 'Read: "There are ten apples on the table." — How many apples?', answer: 'ten', options: ['ten', 'eight', 'five'], emoji: '📖', type: QuestionType.reading),
                  Question(question: 'Write the number of days in a week', answer: 'seven', options: ['seven'], emoji: '📅', type: QuestionType.writing),
                ],
              ),
              PathUnit(
                id: 'a1p_numbers_review',
                title: 'Review: Numbers',
                type: UnitType.review,
                emoji: '🏆',
                pointsReward: 40,
                questions: [
                  Question(question: 'Listen and pick the right number', answer: 'four', options: ['four', 'two', 'six'], emoji: '🔊', type: QuestionType.listening),
                  Question(question: 'How many months in a year?', answer: 'twelve', options: ['twelve', 'ten', 'seven'], emoji: '📆'),
                  Question(question: 'Say this number out loud:', answer: 'nine', options: ['nine'], emoji: '9️⃣', type: QuestionType.speaking),
                  Question(question: 'Write the number of fingers on both hands', answer: 'ten', options: ['ten'], emoji: '🖐️', type: QuestionType.writing),
                  Question(question: 'Read: "The spider has eight legs." — How many legs?', answer: 'eight', options: ['eight', 'six', 'ten'], emoji: '📖', type: QuestionType.reading),
                ],
              ),
            ],
          ),
        ],
      ),

      // ============================================================
      // A2- — Pre-Elementary: Animals
      // ============================================================
      Section(
        id: 'section_a2_minus',
        cefrLevel: 'A2-',
        title: 'Animals',
        description: 'Discover animals in English!',
        chapters: [
          Chapter(
            id: 'ch_animals',
            title: 'Animals',
            description: 'Pets, farm and wild animals',
            emoji: '🐾',
            units: [
              PathUnit(
                id: 'a2m_animals_1',
                title: 'Pets',
                type: UnitType.standard,
                emoji: '🐶',
                questions: [
                  Question(question: "What animal says 'meow'?", answer: 'cat', options: ['cat', 'dog', 'bird'], emoji: '🐱'),
                  Question(question: 'Listen and pick the right animal', answer: 'dog', options: ['dog', 'cat', 'mouse'], emoji: '🔊', type: QuestionType.listening),
                  Question(question: 'Say this animal name out loud:', answer: 'rabbit', options: ['rabbit'], emoji: '🐰', type: QuestionType.speaking),
                  Question(question: 'Read: "The bird is singing in the tree." — What animal is singing?', answer: 'bird', options: ['bird', 'cat', 'fish'], emoji: '📖', type: QuestionType.reading),
                  Question(question: "Write the name of the animal that says 'meow'", answer: 'cat', options: ['cat'], emoji: '🐱', type: QuestionType.writing),
                ],
              ),
              PathUnit(
                id: 'a2m_animals_2',
                title: 'Farm Animals',
                type: UnitType.standard,
                emoji: '🐮',
                questions: [
                  Question(question: "What animal says 'moo'?", answer: 'cow', options: ['cow', 'pig', 'sheep'], emoji: '🐮'),
                  Question(question: 'Listen and pick the right animal', answer: 'sheep', options: ['sheep', 'goat', 'donkey'], emoji: '🔊', type: QuestionType.listening),
                  Question(question: 'Say this animal name out loud:', answer: 'chicken', options: ['chicken'], emoji: '🐔', type: QuestionType.speaking),
                  Question(question: 'Read: "The pig is rolling in the mud." — What animal is in the mud?', answer: 'pig', options: ['pig', 'cow', 'duck'], emoji: '📖', type: QuestionType.reading),
                  Question(question: "Write the name of the animal that gives us eggs", answer: 'chicken', options: ['chicken'], emoji: '🐔', type: QuestionType.writing),
                ],
              ),
              PathUnit(
                id: 'a2m_animals_3',
                title: 'Wild Animals',
                type: UnitType.standard,
                emoji: '🦁',
                questions: [
                  Question(question: 'What is the king of the jungle?', answer: 'lion', options: ['lion', 'tiger', 'bear'], emoji: '🦁'),
                  Question(question: 'Listen and pick the right animal', answer: 'elephant', options: ['elephant', 'giraffe', 'rhino'], emoji: '🔊', type: QuestionType.listening),
                  Question(question: 'Say this animal name out loud:', answer: 'monkey', options: ['monkey'], emoji: '🐵', type: QuestionType.speaking),
                  Question(question: 'Read: "The zebra has black and white stripes." — What does the zebra have?', answer: 'stripes', options: ['stripes', 'spots', 'horns'], emoji: '📖', type: QuestionType.reading),
                  Question(question: 'Write the name of the animal with a long trunk', answer: 'elephant', options: ['elephant'], emoji: '🐘', type: QuestionType.writing),
                ],
              ),
              PathUnit(
                id: 'a2m_animals_review',
                title: 'Review: Animals',
                type: UnitType.review,
                emoji: '🏆',
                pointsReward: 40,
                questions: [
                  Question(question: 'Listen and pick the right animal', answer: 'cat', options: ['cat', 'dog', 'rabbit'], emoji: '🔊', type: QuestionType.listening),
                  Question(question: 'Which farm animal gives us wool?', answer: 'sheep', options: ['sheep', 'cow', 'pig'], emoji: '🐑'),
                  Question(question: 'Say this animal name out loud:', answer: 'giraffe', options: ['giraffe'], emoji: '🦒', type: QuestionType.speaking),
                  Question(question: "Build: 'the cow says moo'", answer: 'the cow says moo', options: ['the', 'cow', 'says', 'moo', 'cat', 'bark'], emoji: '🧩', type: QuestionType.wordOrder),
                  Question(question: 'Read: "The fish swims in the sea." — Where does the fish swim?', answer: 'sea', options: ['sea', 'sky', 'tree'], emoji: '📖', type: QuestionType.reading),
                ],
              ),
            ],
          ),
        ],
      ),

      // ============================================================
      // A2 — Elementary: Food & Drinks
      // ============================================================
      Section(
        id: 'section_a2',
        cefrLevel: 'A2',
        title: 'Food & Drinks',
        description: 'Yummy words to learn!',
        chapters: [
          Chapter(
            id: 'ch_food',
            title: 'Food & Drinks',
            description: 'Fruits, meals and more',
            emoji: '🍕',
            units: [
              PathUnit(
                id: 'a2_food_1',
                title: 'Fruits',
                type: UnitType.standard,
                emoji: '🍎',
                questions: [
                  Question(question: 'What fruit is yellow and monkeys love it?', answer: 'banana', options: ['banana', 'apple', 'orange'], emoji: '🍌'),
                  Question(question: 'Listen and pick the right fruit', answer: 'apple', options: ['apple', 'strawberry', 'cherry'], emoji: '🔊', type: QuestionType.listening),
                  Question(question: 'Say this fruit name out loud:', answer: 'strawberry', options: ['strawberry'], emoji: '🍓', type: QuestionType.speaking),
                  Question(question: 'Read: "The orange is sweet and juicy." — How does it taste?', answer: 'sweet', options: ['sweet', 'sour', 'salty'], emoji: '📖', type: QuestionType.reading),
                  Question(question: "Build: 'I like banana'", answer: 'I like banana', options: ['I', 'like', 'banana', 'pizza', 'run', 'big'], emoji: '🧩', type: QuestionType.wordOrder),
                ],
              ),
              PathUnit(
                id: 'a2_food_2',
                title: 'Meals',
                type: UnitType.standard,
                emoji: '🍽️',
                questions: [
                  Question(question: 'Listen and pick the right word', answer: 'milk', options: ['milk', 'juice', 'water'], emoji: '🔊', type: QuestionType.listening),
                  Question(question: 'What do you eat with butter and jam?', answer: 'bread', options: ['bread', 'rice', 'pasta'], emoji: '🍞'),
                  Question(question: 'Say this food name out loud:', answer: 'pizza', options: ['pizza'], emoji: '🍕', type: QuestionType.speaking),
                  Question(question: 'Read: "I drink water when I am thirsty." — What do I drink?', answer: 'water', options: ['water', 'milk', 'juice'], emoji: '📖', type: QuestionType.reading),
                  Question(question: 'Write the name of the sweet food that bees make', answer: 'honey', options: ['honey'], emoji: '🍯', type: QuestionType.writing),
                ],
              ),
              PathUnit(
                id: 'a2_food_review',
                title: 'Review: Food',
                type: UnitType.review,
                emoji: '🏆',
                pointsReward: 40,
                questions: [
                  Question(question: 'Listen and pick the right word', answer: 'orange', options: ['orange', 'banana', 'apple'], emoji: '🔊', type: QuestionType.listening),
                  Question(question: 'What do you put on bread for breakfast?', answer: 'butter', options: ['butter', 'pizza', 'honey'], emoji: '🧈'),
                  Question(question: 'Say this food name out loud:', answer: 'bread', options: ['bread'], emoji: '🍞', type: QuestionType.speaking),
                  Question(question: 'Write the name of the cold drink from fruits', answer: 'juice', options: ['juice'], emoji: '🧃', type: QuestionType.writing),
                  Question(question: 'Read: "Mom puts butter on my bread every morning." — What goes on the bread?', answer: 'butter', options: ['butter', 'jam', 'cheese'], emoji: '📖', type: QuestionType.reading),
                ],
              ),
            ],
          ),
        ],
      ),

      // ============================================================
      // A2+ — Upper Elementary: My Body
      // ============================================================
      Section(
        id: 'section_a2_plus',
        cefrLevel: 'A2+',
        title: 'My Body',
        description: 'Learn body parts!',
        chapters: [
          Chapter(
            id: 'ch_body',
            title: 'My Body',
            description: 'Face and body parts',
            emoji: '👤',
            units: [
              PathUnit(
                id: 'a2p_body_1',
                title: 'My Face',
                type: UnitType.standard,
                emoji: '😊',
                questions: [
                  Question(question: 'What do you see with?', answer: 'eyes', options: ['eyes', 'ears', 'nose'], emoji: '👀'),
                  Question(question: 'Listen and pick the right body part', answer: 'ears', options: ['ears', 'eyes', 'mouth'], emoji: '🔊', type: QuestionType.listening),
                  Question(question: 'Say this body part out loud:', answer: 'nose', options: ['nose'], emoji: '👃', type: QuestionType.speaking),
                  Question(question: 'Read: "I brush my teeth with a toothbrush." — What do I brush?', answer: 'teeth', options: ['teeth', 'hair', 'nose'], emoji: '📖', type: QuestionType.reading),
                  Question(question: 'Write the body part you use to smell', answer: 'nose', options: ['nose'], emoji: '👃', type: QuestionType.writing),
                ],
              ),
              PathUnit(
                id: 'a2p_body_2',
                title: 'My Body',
                type: UnitType.standard,
                emoji: '💪',
                questions: [
                  Question(question: 'Listen and pick the right body part', answer: 'hand', options: ['hand', 'foot', 'head'], emoji: '🔊', type: QuestionType.listening),
                  Question(question: 'What do you walk with?', answer: 'feet', options: ['feet', 'hands', 'legs'], emoji: '👣'),
                  Question(question: 'Say this body part out loud:', answer: 'arm', options: ['arm'], emoji: '💪', type: QuestionType.speaking),
                  Question(question: 'Read: "My heart is beating fast after running." — What is beating?', answer: 'heart', options: ['heart', 'brain', 'stomach'], emoji: '📖', type: QuestionType.reading),
                  Question(question: 'Write the body part you use to think', answer: 'brain', options: ['brain'], emoji: '🧠', type: QuestionType.writing),
                ],
              ),
              PathUnit(
                id: 'a2p_body_review',
                title: 'Review: My Body',
                type: UnitType.review,
                emoji: '🏆',
                pointsReward: 40,
                questions: [
                  Question(question: 'Listen and pick the right body part', answer: 'heart', options: ['heart', 'brain', 'stomach'], emoji: '🔊', type: QuestionType.listening),
                  Question(question: 'What is on top of your head?', answer: 'hair', options: ['hair', 'ears', 'eyes'], emoji: '💇'),
                  Question(question: 'Say this body part out loud:', answer: 'foot', options: ['foot'], emoji: '🦶', type: QuestionType.speaking),
                  Question(question: "Build: 'I see with my eyes'", answer: 'I see with my eyes', options: ['I', 'see', 'with', 'my', 'eyes', 'eat', 'dog'], emoji: '🧩', type: QuestionType.wordOrder),
                  Question(question: 'Read: "She kicked the ball with her foot." — What body part kicked the ball?', answer: 'foot', options: ['foot', 'hand', 'knee'], emoji: '📖', type: QuestionType.reading),
                ],
              ),
            ],
          ),
        ],
      ),
    ];
  }

  /// Returns all units in linear order across all sections and chapters
  static List<PathUnit> getAllUnitsFlat() {
    final units = <PathUnit>[];
    for (final section in getSections()) {
      for (final chapter in section.chapters) {
        units.addAll(chapter.units);
      }
    }
    return units;
  }

  /// Find a unit by its ID
  static PathUnit? getUnitById(String unitId) {
    for (final section in getSections()) {
      for (final chapter in section.chapters) {
        for (final unit in chapter.units) {
          if (unit.id == unitId) return unit;
        }
      }
    }
    return null;
  }

  /// Get the next uncompleted unit (linear progression)
  static PathUnit? getNextUnit(Set<String> completedUnitIds) {
    for (final unit in getAllUnitsFlat()) {
      if (!completedUnitIds.contains(unit.id)) {
        return unit;
      }
    }
    return null; // All done!
  }

  /// Get current section for a given set of completed units
  static Section? getCurrentSection(Set<String> completedUnitIds) {
    for (final section in getSections()) {
      for (final chapter in section.chapters) {
        for (final unit in chapter.units) {
          if (!completedUnitIds.contains(unit.id)) {
            return section;
          }
        }
      }
    }
    return getSections().last;
  }

  /// Get current chapter for a given set of completed units
  static Chapter? getCurrentChapter(Set<String> completedUnitIds) {
    for (final section in getSections()) {
      for (final chapter in section.chapters) {
        for (final unit in chapter.units) {
          if (!completedUnitIds.contains(unit.id)) {
            return chapter;
          }
        }
      }
    }
    return null;
  }

  /// Check if a unit is unlocked (either it's the next one, or already completed)
  static bool isUnitUnlocked(String unitId, Set<String> completedUnitIds) {
    if (completedUnitIds.contains(unitId)) return true;
    final nextUnit = getNextUnit(completedUnitIds);
    return nextUnit?.id == unitId;
  }

  /// Get overall progress as percentage
  static double getOverallProgress(Set<String> completedUnitIds) {
    final allUnits = getAllUnitsFlat();
    if (allUnits.isEmpty) return 0.0;
    return completedUnitIds.length / allUnits.length;
  }

  /// Get progress within a specific section
  static double getSectionProgress(String sectionId, Set<String> completedUnitIds) {
    final sections = getSections();
    final section = sections.where((s) => s.id == sectionId).firstOrNull;
    if (section == null) return 0.0;

    int total = 0;
    int completed = 0;
    for (final chapter in section.chapters) {
      for (final unit in chapter.units) {
        total++;
        if (completedUnitIds.contains(unit.id)) completed++;
      }
    }
    return total == 0 ? 0.0 : completed / total;
  }

  /// Get the total number of units
  static int getTotalUnits() => getAllUnitsFlat().length;
}
