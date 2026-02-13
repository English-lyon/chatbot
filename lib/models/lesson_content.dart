/// Types of exercises for children
enum QuestionType {
  multipleChoice, // Read question + pick from options
  listening,      // Hear a word via TTS, pick the right answer
  speaking,       // See a word, say it aloud, self-assess
  reading,        // Read an English sentence, answer a comprehension question
  writing,        // Type the answer (no multiple choice)
  wordOrder,      // Tap word chips to build a sentence (Duolingo-style)
}

class Question {
  final String question;
  final String answer;
  final List<String> options;
  final String emoji;
  final QuestionType type;

  // For backwards compat
  bool get isAudio => type == QuestionType.listening;

  Question({
    required this.question,
    required this.answer,
    required this.options,
    required this.emoji,
    this.type = QuestionType.multipleChoice,
  });

  Map<String, dynamic> toJson() => {
        'question': question,
        'answer': answer,
        'options': options,
        'emoji': emoji,
        'type': type.name,
      };

  factory Question.fromJson(Map<String, dynamic> json) => Question(
        question: json['question'],
        answer: json['answer'],
        options: List<String>.from(json['options']),
        emoji: json['emoji'],
        type: QuestionType.values.firstWhere(
          (t) => t.name == json['type'],
          orElse: () => (json['isAudio'] == true)
              ? QuestionType.listening
              : QuestionType.multipleChoice,
        ),
      );
}

class Lesson {
  final String id;
  final String title;
  final int level;
  final List<Question> questions;

  Lesson({
    required this.id,
    required this.title,
    required this.level,
    required this.questions,
  });
}

class Module {
  final String id;
  final String name;
  final String icon;
  final List<Lesson> lessons;

  Module({
    required this.id,
    required this.name,
    required this.icon,
    required this.lessons,
  });
}

class LessonContent {
  static final Map<String, Module> modules = {
    'colors': Module(
      id: 'colors',
      name: 'Couleurs',
      icon: '🎨',
      lessons: [
        Lesson(
          id: 'colors_1',
          title: 'Couleurs de base',
          level: 1,
          questions: [
            Question(
              question: 'What color is the apple?',
              answer: 'red',
              options: ['red', 'blue', 'green'],
              emoji: '🍎',
            ),
            Question(
              question: 'What color is the sky?',
              answer: 'blue',
              options: ['red', 'blue', 'yellow'],
              emoji: '☁️',
            ),
            Question(
              question: 'What color is the sun?',
              answer: 'yellow',
              options: ['yellow', 'green', 'purple'],
              emoji: '☀️',
            ),
            Question(
              question: 'What color is grass?',
              answer: 'green',
              options: ['green', 'orange', 'pink'],
              emoji: '🌿',
            ),
          ],
        ),
        Lesson(
          id: 'colors_2',
          title: 'Plus de couleurs',
          level: 2,
          questions: [
            Question(
              question: 'What color is an orange?',
              answer: 'orange',
              options: ['orange', 'purple', 'brown'],
              emoji: '🍊',
            ),
            Question(
              question: 'What color is a grape?',
              answer: 'purple',
              options: ['purple', 'white', 'black'],
              emoji: '🍇',
            ),
            Question(
              question: 'What color is chocolate?',
              answer: 'brown',
              options: ['brown', 'pink', 'gray'],
              emoji: '🍫',
            ),
            Question(
              question: 'What color is snow?',
              answer: 'white',
              options: ['white', 'black', 'red'],
              emoji: '❄️',
            ),
          ],
        ),
      ],
    ),
    'animals': Module(
      id: 'animals',
      name: 'Animaux',
      icon: '🐾',
      lessons: [
        Lesson(
          id: 'animals_1',
          title: 'Animaux domestiques',
          level: 1,
          questions: [
            Question(
              question: "What animal says 'meow'?",
              answer: 'cat',
              options: ['cat', 'dog', 'bird'],
              emoji: '🐱',
            ),
            Question(
              question: "What animal says 'woof'?",
              answer: 'dog',
              options: ['dog', 'cat', 'mouse'],
              emoji: '🐶',
            ),
            Question(
              question: "What animal says 'tweet'?",
              answer: 'bird',
              options: ['bird', 'fish', 'rabbit'],
              emoji: '🐦',
            ),
            Question(
              question: 'What animal hops and has long ears?',
              answer: 'rabbit',
              options: ['rabbit', 'hamster', 'turtle'],
              emoji: '🐰',
            ),
          ],
        ),
        Lesson(
          id: 'animals_2',
          title: 'Animaux de la ferme',
          level: 2,
          questions: [
            Question(
              question: "What animal says 'moo'?",
              answer: 'cow',
              options: ['cow', 'pig', 'sheep'],
              emoji: '🐮',
            ),
            Question(
              question: "What animal says 'oink'?",
              answer: 'pig',
              options: ['pig', 'horse', 'chicken'],
              emoji: '🐷',
            ),
            Question(
              question: 'What animal gives us eggs?',
              answer: 'chicken',
              options: ['chicken', 'duck', 'goose'],
              emoji: '🐔',
            ),
            Question(
              question: "What animal says 'baa'?",
              answer: 'sheep',
              options: ['sheep', 'goat', 'donkey'],
              emoji: '🐑',
            ),
          ],
        ),
        Lesson(
          id: 'animals_3',
          title: 'Animaux sauvages',
          level: 3,
          questions: [
            Question(
              question: 'What is the king of the jungle?',
              answer: 'lion',
              options: ['lion', 'tiger', 'bear'],
              emoji: '🦁',
            ),
            Question(
              question: 'What animal has a long trunk?',
              answer: 'elephant',
              options: ['elephant', 'giraffe', 'rhino'],
              emoji: '🐘',
            ),
            Question(
              question: 'What animal has black and white stripes?',
              answer: 'zebra',
              options: ['zebra', 'horse', 'donkey'],
              emoji: '🦓',
            ),
            Question(
              question: 'What animal swings in trees?',
              answer: 'monkey',
              options: ['monkey', 'koala', 'sloth'],
              emoji: '🐵',
            ),
          ],
        ),
      ],
    ),
    'numbers': Module(
      id: 'numbers',
      name: 'Nombres',
      icon: '🔢',
      lessons: [
        Lesson(
          id: 'numbers_1',
          title: 'Nombres 1-5',
          level: 1,
          questions: [
            Question(
              question: 'How many fingers on one hand?',
              answer: 'five',
              options: ['five', 'four', 'three'],
              emoji: '✋',
            ),
            Question(
              question: 'How many eyes do you have?',
              answer: 'two',
              options: ['two', 'one', 'three'],
              emoji: '👀',
            ),
            Question(
              question: 'How many noses do you have?',
              answer: 'one',
              options: ['one', 'two', 'zero'],
              emoji: '👃',
            ),
            Question(
              question: 'How many wheels on a tricycle?',
              answer: 'three',
              options: ['three', 'two', 'four'],
              emoji: '🚲',
            ),
          ],
        ),
        Lesson(
          id: 'numbers_2',
          title: 'Nombres 6-10',
          level: 2,
          questions: [
            Question(
              question: 'How many legs does an insect have?',
              answer: 'six',
              options: ['six', 'eight', 'four'],
              emoji: '🐜',
            ),
            Question(
              question: 'How many days in a week?',
              answer: 'seven',
              options: ['seven', 'six', 'five'],
              emoji: '📅',
            ),
            Question(
              question: 'How many legs does a spider have?',
              answer: 'eight',
              options: ['eight', 'six', 'ten'],
              emoji: '🕷️',
            ),
            Question(
              question: 'How many fingers on both hands?',
              answer: 'ten',
              options: ['ten', 'eight', 'twelve'],
              emoji: '🙌',
            ),
          ],
        ),
      ],
    ),
    'greetings': Module(
      id: 'greetings',
      name: 'Salutations',
      icon: '👋',
      lessons: [
        Lesson(
          id: 'greetings_1',
          title: 'Dire bonjour',
          level: 1,
          questions: [
            Question(
              question: "How do you say 'bonjour' in English?",
              answer: 'hello',
              options: ['hello', 'goodbye', 'thanks'],
              emoji: '👋',
            ),
            Question(
              question: "How do you say 'au revoir' in English?",
              answer: 'goodbye',
              options: ['goodbye', 'hello', 'sorry'],
              emoji: '👋',
            ),
            Question(
              question: "How do you say 'merci' in English?",
              answer: 'thank you',
              options: ['thank you', 'please', 'sorry'],
              emoji: '🙏',
            ),
            Question(
              question: "How do you say 's'il te plaît' in English?",
              answer: 'please',
              options: ['please', 'thanks', 'yes'],
              emoji: '🙏',
            ),
          ],
        ),
        Lesson(
          id: 'greetings_2',
          title: 'Politesse',
          level: 2,
          questions: [
            Question(
              question: 'What do you say when you make a mistake?',
              answer: 'sorry',
              options: ['sorry', 'thanks', 'bye'],
              emoji: '😔',
            ),
            Question(
              question: 'What do you say in the morning?',
              answer: 'good morning',
              options: ['good morning', 'good night', 'good afternoon'],
              emoji: '🌅',
            ),
            Question(
              question: 'What do you say before sleeping?',
              answer: 'good night',
              options: ['good night', 'good morning', 'goodbye'],
              emoji: '🌙',
            ),
            Question(
              question: 'What do you say when someone helps you?',
              answer: 'thank you',
              options: ['thank you', 'sorry', 'hello'],
              emoji: '❤️',
            ),
          ],
        ),
      ],
    ),
    'food': Module(
      id: 'food',
      name: 'Nourriture',
      icon: '🍕',
      lessons: [
        Lesson(
          id: 'food_1',
          title: 'Fruits',
          level: 2,
          questions: [
            Question(
              question: 'What fruit is yellow and monkeys love it?',
              answer: 'banana',
              options: ['banana', 'apple', 'orange'],
              emoji: '🍌',
            ),
            Question(
              question: 'What red fruit grows on trees?',
              answer: 'apple',
              options: ['apple', 'strawberry', 'cherry'],
              emoji: '🍎',
            ),
            Question(
              question: 'What orange fruit has the same name as its color?',
              answer: 'orange',
              options: ['orange', 'lemon', 'peach'],
              emoji: '🍊',
            ),
            Question(
              question: 'What small red fruit has seeds on the outside?',
              answer: 'strawberry',
              options: ['strawberry', 'raspberry', 'cherry'],
              emoji: '🍓',
            ),
          ],
        ),
        Lesson(
          id: 'food_2',
          title: 'Repas',
          level: 3,
          questions: [
            Question(
              question: 'What do you drink in the morning?',
              answer: 'milk',
              options: ['milk', 'juice', 'water'],
              emoji: '🥛',
            ),
            Question(
              question: 'What do you eat with butter and jam?',
              answer: 'bread',
              options: ['bread', 'rice', 'pasta'],
              emoji: '🍞',
            ),
            Question(
              question: 'What Italian food has tomato sauce and cheese?',
              answer: 'pizza',
              options: ['pizza', 'pasta', 'burger'],
              emoji: '🍕',
            ),
            Question(
              question: 'What sweet food do bees make?',
              answer: 'honey',
              options: ['honey', 'sugar', 'jam'],
              emoji: '🍯',
            ),
          ],
        ),
      ],
    ),
    'body': Module(
      id: 'body',
      name: 'Corps humain',
      icon: '👤',
      lessons: [
        Lesson(
          id: 'body_1',
          title: 'Visage',
          level: 2,
          questions: [
            Question(
              question: 'What do you see with?',
              answer: 'eyes',
              options: ['eyes', 'ears', 'nose'],
              emoji: '👀',
            ),
            Question(
              question: 'What do you hear with?',
              answer: 'ears',
              options: ['ears', 'eyes', 'mouth'],
              emoji: '👂',
            ),
            Question(
              question: 'What do you smell with?',
              answer: 'nose',
              options: ['nose', 'mouth', 'ears'],
              emoji: '👃',
            ),
            Question(
              question: 'What do you eat with?',
              answer: 'mouth',
              options: ['mouth', 'nose', 'eyes'],
              emoji: '👄',
            ),
          ],
        ),
        Lesson(
          id: 'body_2',
          title: 'Corps',
          level: 2,
          questions: [
            Question(
              question: 'What do you use to write?',
              answer: 'hand',
              options: ['hand', 'foot', 'head'],
              emoji: '✋',
            ),
            Question(
              question: 'What do you walk with?',
              answer: 'feet',
              options: ['feet', 'hands', 'legs'],
              emoji: '👣',
            ),
            Question(
              question: 'What connects your hand to your body?',
              answer: 'arm',
              options: ['arm', 'leg', 'neck'],
              emoji: '💪',
            ),
            Question(
              question: 'What do you think with?',
              answer: 'brain',
              options: ['brain', 'heart', 'stomach'],
              emoji: '🧠',
            ),
          ],
        ),
      ],
    ),
  };

  static Module? getModule(String moduleId) {
    return modules[moduleId];
  }

  static List<Module> getAllModules() {
    return modules.values.toList();
  }

  static List<Lesson> getLessonsForLevel(int level) {
    List<Lesson> availableLessons = [];
    for (var module in modules.values) {
      for (var lesson in module.lessons) {
        if (lesson.level <= level) {
          availableLessons.add(lesson);
        }
      }
    }
    return availableLessons;
  }
}
