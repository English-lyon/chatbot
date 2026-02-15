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
                  // CO: Listen and choose
                  Question(
                      question: 'Listen and choose the correct word',
                      answer: 'hello',
                      options: ['hello', 'sorry', 'goodbye'],
                      emoji: '🎧',
                      type: QuestionType.listening),
                  // CE: Fill in the blank
                  Question(
                      question: 'Good ___, how are you?',
                      answer: 'morning',
                      options: ['morning', 'cat', 'blue'],
                      emoji: '📝',
                      type: QuestionType.fillBlank),
                  // EOI: Conversation
                  Question(
                      question: '🧑 Hello! What is your name?',
                      answer: "My name is Max!",
                      options: [
                        "My name is Max!",
                        "I like pizza.",
                        "It is blue."
                      ],
                      emoji: '💬',
                      type: QuestionType.conversation),
                  // CO: Dictation
                  Question(
                      question: 'Type what you hear',
                      answer: 'goodbye',
                      options: [],
                      emoji: '🎧',
                      type: QuestionType.listenType),
                  // EOC: Speaking
                  Question(
                      question: 'Say this out loud:',
                      answer: 'thank you',
                      options: ['thank you'],
                      emoji: '🗣️',
                      type: QuestionType.speaking),
                  // Vocab: Match pairs
                  Question(
                      question: 'Match the pairs',
                      answer: 'matched',
                      options: [],
                      emoji: '🔗',
                      type: QuestionType.matchPairs,
                      pairs: {
                        'bonjour': 'hello',
                        'au revoir': 'goodbye',
                        'merci': 'thank you'
                      }),
                ],
              ),
              PathUnit(
                id: 'a1m_greetings_2',
                title: 'Be Polite',
                type: UnitType.standard,
                emoji: '😊',
                questions: [
                  // CO: Listen and choose
                  Question(
                      question: 'Listen and choose the correct word',
                      answer: 'please',
                      options: ['please', 'hello', 'sorry'],
                      emoji: '🎧',
                      type: QuestionType.listening),
                  // CE: Reading comprehension
                  Question(
                      question:
                          'Read: "She says sorry when she is late." — What does she say?',
                      answer: 'sorry',
                      options: ['sorry', 'hello', 'please'],
                      emoji: '📖',
                      type: QuestionType.reading),
                  // CE: Fill in the blank
                  Question(
                      question: 'Thank you very ___!',
                      answer: 'much',
                      options: ['much', 'big', 'red'],
                      emoji: '📝',
                      type: QuestionType.fillBlank),
                  // EOI: Conversation
                  Question(
                      question: '🧑 Can I have some water, please?',
                      answer: 'Yes, here you go!',
                      options: [
                        'Yes, here you go!',
                        'I am a cat.',
                        'Good night!'
                      ],
                      emoji: '💬',
                      type: QuestionType.conversation),
                  // CO: Dictation
                  Question(
                      question: 'Type what you hear',
                      answer: 'good night',
                      options: [],
                      emoji: '🎧',
                      type: QuestionType.listenType),
                  // Vocab: Match pairs
                  Question(
                      question: 'Match the pairs',
                      answer: 'matched',
                      options: [],
                      emoji: '🔗',
                      type: QuestionType.matchPairs,
                      pairs: {
                        "s'il te plaît": 'please',
                        'pardon': 'sorry',
                        'bonne nuit': 'good night',
                        'de rien': "you're welcome"
                      }),
                ],
              ),
              PathUnit(
                id: 'a1m_greetings_review',
                title: 'Review: First Words',
                type: UnitType.review,
                emoji: '🏆',
                pointsReward: 40,
                questions: [
                  // CO: Listen and choose
                  Question(
                      question: 'Listen and choose the correct word',
                      answer: 'thank you',
                      options: ['thank you', 'goodbye', 'sorry'],
                      emoji: '🎧',
                      type: QuestionType.listening),
                  // EE: Word order
                  Question(
                      question: 'Bonjour mon ami',
                      answer: 'good morning my friend',
                      options: [
                        'good',
                        'morning',
                        'my',
                        'friend',
                        'cat',
                        'blue'
                      ],
                      emoji: '🧩',
                      type: QuestionType.wordOrder),
                  // EOI: Conversation
                  Question(
                      question: '🧑 Good night!\n🤖 ___',
                      answer: 'Good night!',
                      options: ['Good night!', 'Good morning!', 'I am hungry.'],
                      emoji: '💬',
                      type: QuestionType.conversation),
                  // CE: Fill in the blank
                  Question(
                      question: '___ you very much!',
                      answer: 'Thank',
                      options: ['Thank', 'Cat', 'Red'],
                      emoji: '📝',
                      type: QuestionType.fillBlank),
                  // EOC: Speaking
                  Question(
                      question: 'Say this out loud:',
                      answer: 'sorry',
                      options: ['sorry'],
                      emoji: '🗣️',
                      type: QuestionType.speaking),
                  // Vocab: Match pairs
                  Question(
                      question: 'Match the pairs',
                      answer: 'matched',
                      options: [],
                      emoji: '🔗',
                      type: QuestionType.matchPairs,
                      pairs: {
                        'bonjour': 'hello',
                        'merci': 'thank you',
                        'pardon': 'sorry',
                        "s'il te plaît": 'please'
                      }),
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
                  // CO: Listen and choose
                  Question(
                      question: 'Listen and choose the correct color',
                      answer: 'red',
                      options: ['red', 'blue', 'green'],
                      emoji: '🎧',
                      type: QuestionType.listening),
                  // CE: Fill in the blank
                  Question(
                      question: 'The sky is ___.',
                      answer: 'blue',
                      options: ['blue', 'red', 'happy'],
                      emoji: '📝',
                      type: QuestionType.fillBlank),
                  // EOI: Conversation
                  Question(
                      question: '🧑 What color is the sun?',
                      answer: "It's yellow!",
                      options: ["It's yellow!", "It's a dog.", "Thank you!"],
                      emoji: '💬',
                      type: QuestionType.conversation),
                  // CE: Reading comprehension
                  Question(
                      question:
                          'Read: "The frog is green and small." — What color is the frog?',
                      answer: 'green',
                      options: ['green', 'blue', 'red'],
                      emoji: '📖',
                      type: QuestionType.reading),
                  // CO: Dictation
                  Question(
                      question: 'Type what you hear',
                      answer: 'yellow',
                      options: [],
                      emoji: '🎧',
                      type: QuestionType.listenType),
                  // Vocab: Match pairs
                  Question(
                      question: 'Match the pairs',
                      answer: 'matched',
                      options: [],
                      emoji: '🔗',
                      type: QuestionType.matchPairs,
                      pairs: {
                        'rouge': 'red',
                        'bleu': 'blue',
                        'jaune': 'yellow',
                        'vert': 'green'
                      }),
                ],
              ),
              PathUnit(
                id: 'a1_colors_2',
                title: 'More Colors',
                type: UnitType.standard,
                emoji: '🌈',
                questions: [
                  // CO: Listen and choose
                  Question(
                      question: 'Listen and choose the correct color',
                      answer: 'purple',
                      options: ['purple', 'white', 'black'],
                      emoji: '🎧',
                      type: QuestionType.listening),
                  // CE: Fill in the blank
                  Question(
                      question: 'Snow is ___ and cold.',
                      answer: 'white',
                      options: ['white', 'red', 'green'],
                      emoji: '📝',
                      type: QuestionType.fillBlank),
                  // MC: Basic question
                  Question(
                      question: 'Which color name is also a fruit?',
                      answer: 'orange',
                      options: ['orange', 'purple', 'brown'],
                      emoji: '❓'),
                  // EOC: Speaking
                  Question(
                      question: 'Say this color out loud:',
                      answer: 'brown',
                      options: ['brown'],
                      emoji: '🗣️',
                      type: QuestionType.speaking),
                  // CO: Dictation
                  Question(
                      question: 'Type what you hear',
                      answer: 'orange',
                      options: [],
                      emoji: '🎧',
                      type: QuestionType.listenType),
                  // Vocab: Match pairs
                  Question(
                      question: 'Match the pairs',
                      answer: 'matched',
                      options: [],
                      emoji: '🔗',
                      type: QuestionType.matchPairs,
                      pairs: {
                        'orange': 'orange',
                        'violet': 'purple',
                        'marron': 'brown',
                        'blanc': 'white'
                      }),
                ],
              ),
              PathUnit(
                id: 'a1_colors_review',
                title: 'Review: Colors',
                type: UnitType.review,
                emoji: '🏆',
                pointsReward: 40,
                questions: [
                  // EE: Word order
                  Question(
                      question: 'Le ciel est bleu',
                      answer: 'the sky is blue',
                      options: ['the', 'sky', 'is', 'blue', 'red', 'cat'],
                      emoji: '🧩',
                      type: QuestionType.wordOrder),
                  // EOI: Conversation
                  Question(
                      question: '🧑 What color is the night sky?',
                      answer: "It's black!",
                      options: [
                        "It's black!",
                        "I like pizza.",
                        "Good morning!"
                      ],
                      emoji: '💬',
                      type: QuestionType.conversation),
                  // CE: Fill in the blank
                  Question(
                      question: 'A stop sign is ___.',
                      answer: 'red',
                      options: ['red', 'blue', 'green'],
                      emoji: '📝',
                      type: QuestionType.fillBlank),
                  // CO: Listen and choose
                  Question(
                      question: 'Listen and choose the correct color',
                      answer: 'pink',
                      options: ['pink', 'orange', 'red'],
                      emoji: '🎧',
                      type: QuestionType.listening),
                  // CE: Reading
                  Question(
                      question:
                          'Read: "The black cat sits on the white rug." — What color is the cat?',
                      answer: 'black',
                      options: ['black', 'white', 'gray'],
                      emoji: '📖',
                      type: QuestionType.reading),
                  // Vocab: Match pairs
                  Question(
                      question: 'Match the pairs',
                      answer: 'matched',
                      options: [],
                      emoji: '🔗',
                      type: QuestionType.matchPairs,
                      pairs: {
                        'rouge': 'red',
                        'noir': 'black',
                        'rose': 'pink',
                        'vert': 'green'
                      }),
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
                  // CO: Listen and choose
                  Question(
                      question: 'Listen and choose the correct number',
                      answer: 'three',
                      options: ['three', 'five', 'one'],
                      emoji: '🎧',
                      type: QuestionType.listening),
                  // CE: Fill in the blank
                  Question(
                      question: 'I have ___ eyes.',
                      answer: 'two',
                      options: ['two', 'five', 'red'],
                      emoji: '📝',
                      type: QuestionType.fillBlank),
                  // EOI: Conversation
                  Question(
                      question: '🧑 How many fingers on one hand?',
                      answer: 'Five!',
                      options: ['Five!', 'Blue!', 'Hello!'],
                      emoji: '💬',
                      type: QuestionType.conversation),
                  // CE: Reading
                  Question(
                      question:
                          'Read: "I have one nose and two eyes." — How many eyes?',
                      answer: 'two',
                      options: ['two', 'one', 'three'],
                      emoji: '📖',
                      type: QuestionType.reading),
                  // CO: Dictation
                  Question(
                      question: 'Type what you hear',
                      answer: 'four',
                      options: [],
                      emoji: '🎧',
                      type: QuestionType.listenType),
                  // Vocab: Match pairs
                  Question(
                      question: 'Match the pairs',
                      answer: 'matched',
                      options: [],
                      emoji: '🔗',
                      type: QuestionType.matchPairs,
                      pairs: {
                        'un': 'one',
                        'deux': 'two',
                        'trois': 'three',
                        'cinq': 'five'
                      }),
                ],
              ),
              PathUnit(
                id: 'a1p_numbers_2',
                title: 'Numbers 6-10',
                type: UnitType.standard,
                emoji: '🔟',
                questions: [
                  // CO: Listen and choose
                  Question(
                      question: 'Listen and choose the correct number',
                      answer: 'eight',
                      options: ['eight', 'six', 'ten'],
                      emoji: '🎧',
                      type: QuestionType.listening),
                  // CE: Fill in the blank
                  Question(
                      question: 'There are ___ days in a week.',
                      answer: 'seven',
                      options: ['seven', 'ten', 'three'],
                      emoji: '📝',
                      type: QuestionType.fillBlank),
                  // EOI: Conversation
                  Question(
                      question: '🧑 How many legs does a spider have?',
                      answer: 'Eight!',
                      options: ['Eight!', 'Red!', 'Sorry!'],
                      emoji: '💬',
                      type: QuestionType.conversation),
                  // EOC: Speaking
                  Question(
                      question: 'Say this number out loud:',
                      answer: 'nine',
                      options: ['nine'],
                      emoji: '🗣️',
                      type: QuestionType.speaking),
                  // CE: Reading
                  Question(
                      question:
                          'Read: "There are ten apples on the table." — How many apples?',
                      answer: 'ten',
                      options: ['ten', 'eight', 'five'],
                      emoji: '📖',
                      type: QuestionType.reading),
                  // Vocab: Match pairs
                  Question(
                      question: 'Match the pairs',
                      answer: 'matched',
                      options: [],
                      emoji: '🔗',
                      type: QuestionType.matchPairs,
                      pairs: {
                        'six': 'six',
                        'sept': 'seven',
                        'huit': 'eight',
                        'dix': 'ten'
                      }),
                ],
              ),
              PathUnit(
                id: 'a1p_numbers_review',
                title: 'Review: Numbers',
                type: UnitType.review,
                emoji: '🏆',
                pointsReward: 40,
                questions: [
                  // CO: Listen and choose
                  Question(
                      question: 'Listen and choose the correct number',
                      answer: 'four',
                      options: ['four', 'two', 'six'],
                      emoji: '🎧',
                      type: QuestionType.listening),
                  // EE: Word order
                  Question(
                      question: "J'ai deux yeux",
                      answer: 'I have two eyes',
                      options: ['I', 'have', 'two', 'eyes', 'cat', 'blue'],
                      emoji: '🧩',
                      type: QuestionType.wordOrder),
                  // EOI: Conversation
                  Question(
                      question: '🧑 How old are you?',
                      answer: "I'm seven!",
                      options: ["I'm seven!", "I'm red.", "Thank you!"],
                      emoji: '💬',
                      type: QuestionType.conversation),
                  // CE: Fill in the blank
                  Question(
                      question: 'A spider has ___ legs.',
                      answer: 'eight',
                      options: ['eight', 'six', 'four'],
                      emoji: '📝',
                      type: QuestionType.fillBlank),
                  // CO: Dictation
                  Question(
                      question: 'Type what you hear',
                      answer: 'ten',
                      options: [],
                      emoji: '🎧',
                      type: QuestionType.listenType),
                  // Vocab: Match pairs
                  Question(
                      question: 'Match the pairs',
                      answer: 'matched',
                      options: [],
                      emoji: '🔗',
                      type: QuestionType.matchPairs,
                      pairs: {
                        'quatre': 'four',
                        'neuf': 'nine',
                        'dix': 'ten',
                        'douze': 'twelve'
                      }),
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
                  // CO: Listen and choose
                  Question(
                      question: 'Listen and choose the correct animal',
                      answer: 'cat',
                      options: ['cat', 'dog', 'bird'],
                      emoji: '🎧',
                      type: QuestionType.listening),
                  // CE: Fill in the blank
                  Question(
                      question: 'The ___ says meow.',
                      answer: 'cat',
                      options: ['cat', 'dog', 'bird'],
                      emoji: '📝',
                      type: QuestionType.fillBlank),
                  // EOI: Conversation
                  Question(
                      question: '🧑 Do you have a pet?',
                      answer: 'Yes, I have a dog!',
                      options: [
                        'Yes, I have a dog!',
                        'The sky is blue.',
                        'Good morning!'
                      ],
                      emoji: '💬',
                      type: QuestionType.conversation),
                  // CE: Reading
                  Question(
                      question:
                          'Read: "The bird is singing in the tree." — What is singing?',
                      answer: 'bird',
                      options: ['bird', 'cat', 'fish'],
                      emoji: '📖',
                      type: QuestionType.reading),
                  // CO: Dictation
                  Question(
                      question: 'Type what you hear',
                      answer: 'rabbit',
                      options: [],
                      emoji: '🎧',
                      type: QuestionType.listenType),
                  // Vocab: Match pairs
                  Question(
                      question: 'Match the pairs',
                      answer: 'matched',
                      options: [],
                      emoji: '🔗',
                      type: QuestionType.matchPairs,
                      pairs: {
                        'chat': 'cat',
                        'chien': 'dog',
                        'oiseau': 'bird',
                        'lapin': 'rabbit'
                      }),
                ],
              ),
              PathUnit(
                id: 'a2m_animals_2',
                title: 'Farm Animals',
                type: UnitType.standard,
                emoji: '🐮',
                questions: [
                  // CO: Listen and choose
                  Question(
                      question: 'Listen and choose the correct animal',
                      answer: 'cow',
                      options: ['cow', 'pig', 'sheep'],
                      emoji: '🎧',
                      type: QuestionType.listening),
                  // CE: Fill in the blank
                  Question(
                      question: 'The ___ gives us eggs.',
                      answer: 'chicken',
                      options: ['chicken', 'cow', 'pig'],
                      emoji: '📝',
                      type: QuestionType.fillBlank),
                  // EOI: Conversation
                  Question(
                      question: '🧑 What animal gives us milk?',
                      answer: 'The cow!',
                      options: ['The cow!', 'Thank you!', 'Good night!'],
                      emoji: '💬',
                      type: QuestionType.conversation),
                  // EOC: Speaking
                  Question(
                      question: 'Say this animal name out loud:',
                      answer: 'sheep',
                      options: ['sheep'],
                      emoji: '🗣️',
                      type: QuestionType.speaking),
                  // CE: Reading
                  Question(
                      question:
                          'Read: "The pig is rolling in the mud." — What is in the mud?',
                      answer: 'pig',
                      options: ['pig', 'cow', 'duck'],
                      emoji: '📖',
                      type: QuestionType.reading),
                  // Vocab: Match pairs
                  Question(
                      question: 'Match the pairs',
                      answer: 'matched',
                      options: [],
                      emoji: '🔗',
                      type: QuestionType.matchPairs,
                      pairs: {
                        'vache': 'cow',
                        'cochon': 'pig',
                        'mouton': 'sheep',
                        'poulet': 'chicken'
                      }),
                ],
              ),
              PathUnit(
                id: 'a2m_animals_3',
                title: 'Wild Animals',
                type: UnitType.standard,
                emoji: '🦁',
                questions: [
                  // CO: Listen and choose
                  Question(
                      question: 'Listen and choose the correct animal',
                      answer: 'elephant',
                      options: ['elephant', 'giraffe', 'lion'],
                      emoji: '🎧',
                      type: QuestionType.listening),
                  // CE: Fill in the blank
                  Question(
                      question: 'The ___ has a big mane and roars.',
                      answer: 'lion',
                      options: ['lion', 'cat', 'dog'],
                      emoji: '🦁',
                      type: QuestionType.fillBlank),
                  // EOI: Conversation
                  Question(
                      question: '🧑 What is your favorite animal?',
                      answer: 'I love monkeys!',
                      options: [
                        'I love monkeys!',
                        'I like pizza.',
                        'Good morning!'
                      ],
                      emoji: '💬',
                      type: QuestionType.conversation),
                  // EOC: Speaking
                  Question(
                      question: 'Say this animal name out loud:',
                      answer: 'giraffe',
                      options: ['giraffe'],
                      emoji: '🗣️',
                      type: QuestionType.speaking),
                  // CO: Dictation
                  Question(
                      question: 'Type what you hear',
                      answer: 'zebra',
                      options: [],
                      emoji: '🎧',
                      type: QuestionType.listenType),
                  // Vocab: Match pairs
                  Question(
                      question: 'Match the pairs',
                      answer: 'matched',
                      options: [],
                      emoji: '🔗',
                      type: QuestionType.matchPairs,
                      pairs: {
                        'lion': 'lion',
                        'singe': 'monkey',
                        'éléphant': 'elephant',
                        'zèbre': 'zebra'
                      }),
                ],
              ),
              PathUnit(
                id: 'a2m_animals_review',
                title: 'Review: Animals',
                type: UnitType.review,
                emoji: '🏆',
                pointsReward: 40,
                questions: [
                  // CO: Listen and choose
                  Question(
                      question: 'Listen and choose the correct animal',
                      answer: 'dog',
                      options: ['dog', 'cat', 'rabbit'],
                      emoji: '🎧',
                      type: QuestionType.listening),
                  // EE: Word order
                  Question(
                      question: 'Le chat dit miaou',
                      answer: 'the cat says meow',
                      options: ['the', 'cat', 'says', 'meow', 'dog', 'blue'],
                      emoji: '🧩',
                      type: QuestionType.wordOrder),
                  // EOI: Conversation
                  Question(
                      question: '🧑 What does a cow say?',
                      answer: 'Moo!',
                      options: ['Moo!', 'Hello!', 'Blue!'],
                      emoji: '💬',
                      type: QuestionType.conversation),
                  // CE: Reading
                  Question(
                      question:
                          'Read: "The fish swims in the sea." — Where does the fish swim?',
                      answer: 'sea',
                      options: ['sea', 'sky', 'tree'],
                      emoji: '📖',
                      type: QuestionType.reading),
                  // CE: Fill in the blank
                  Question(
                      question: 'The ___ has a long trunk.',
                      answer: 'elephant',
                      options: ['elephant', 'cat', 'bird'],
                      emoji: '📝',
                      type: QuestionType.fillBlank),
                  // Vocab: Match pairs
                  Question(
                      question: 'Match the pairs',
                      answer: 'matched',
                      options: [],
                      emoji: '🔗',
                      type: QuestionType.matchPairs,
                      pairs: {
                        'chat': 'cat',
                        'vache': 'cow',
                        'lion': 'lion',
                        'singe': 'monkey'
                      }),
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
                  // CO: Listen and choose
                  Question(
                      question: 'Listen and choose the correct fruit',
                      answer: 'banana',
                      options: ['banana', 'apple', 'orange'],
                      emoji: '🎧',
                      type: QuestionType.listening),
                  // CE: Fill in the blank
                  Question(
                      question: 'I like to eat ___ for breakfast.',
                      answer: 'apple',
                      options: ['apple', 'chair', 'blue'],
                      emoji: '📝',
                      type: QuestionType.fillBlank),
                  // EOI: Conversation
                  Question(
                      question: '🧑 What fruit do you want?',
                      answer: 'I want a banana!',
                      options: [
                        'I want a banana!',
                        'I am a cat.',
                        'Good night!'
                      ],
                      emoji: '💬',
                      type: QuestionType.conversation),
                  // CE: Reading
                  Question(
                      question:
                          'Read: "The orange is sweet and juicy." — How is the orange?',
                      answer: 'sweet',
                      options: ['sweet', 'sour', 'salty'],
                      emoji: '📖',
                      type: QuestionType.reading),
                  // CO: Dictation
                  Question(
                      question: 'Type what you hear',
                      answer: 'strawberry',
                      options: [],
                      emoji: '🎧',
                      type: QuestionType.listenType),
                  // Vocab: Match pairs
                  Question(
                      question: 'Match the pairs',
                      answer: 'matched',
                      options: [],
                      emoji: '🔗',
                      type: QuestionType.matchPairs,
                      pairs: {
                        'banane': 'banana',
                        'pomme': 'apple',
                        'fraise': 'strawberry',
                        'orange': 'orange'
                      }),
                ],
              ),
              PathUnit(
                id: 'a2_food_2',
                title: 'Meals',
                type: UnitType.standard,
                emoji: '🍽️',
                questions: [
                  // CO: Listen and choose
                  Question(
                      question: 'Listen and choose the correct word',
                      answer: 'bread',
                      options: ['bread', 'juice', 'water'],
                      emoji: '🎧',
                      type: QuestionType.listening),
                  // CE: Fill in the blank
                  Question(
                      question: 'I drink ___ when I am thirsty.',
                      answer: 'water',
                      options: ['water', 'bread', 'dog'],
                      emoji: '📝',
                      type: QuestionType.fillBlank),
                  // EOI: Conversation
                  Question(
                      question: '🧑 Are you hungry?',
                      answer: 'Yes, I want pizza!',
                      options: [
                        'Yes, I want pizza!',
                        'It is blue.',
                        'Good morning!'
                      ],
                      emoji: '💬',
                      type: QuestionType.conversation),
                  // EOC: Speaking
                  Question(
                      question: 'Say this food name out loud:',
                      answer: 'milk',
                      options: ['milk'],
                      emoji: '🗣️',
                      type: QuestionType.speaking),
                  // CE: Reading
                  Question(
                      question:
                          'Read: "Mom puts butter on my bread." — What goes on the bread?',
                      answer: 'butter',
                      options: ['butter', 'jam', 'cheese'],
                      emoji: '📖',
                      type: QuestionType.reading),
                  // Vocab: Match pairs
                  Question(
                      question: 'Match the pairs',
                      answer: 'matched',
                      options: [],
                      emoji: '🔗',
                      type: QuestionType.matchPairs,
                      pairs: {
                        'lait': 'milk',
                        'pain': 'bread',
                        'eau': 'water',
                        'miel': 'honey'
                      }),
                ],
              ),
              PathUnit(
                id: 'a2_food_review',
                title: 'Review: Food',
                type: UnitType.review,
                emoji: '🏆',
                pointsReward: 40,
                questions: [
                  // CO: Listen and choose
                  Question(
                      question: 'Listen and choose the correct word',
                      answer: 'juice',
                      options: ['juice', 'milk', 'bread'],
                      emoji: '🎧',
                      type: QuestionType.listening),
                  // EE: Word order
                  Question(
                      question: "J'aime la pizza",
                      answer: 'I like pizza',
                      options: ['I', 'like', 'pizza', 'cat', 'blue', 'run'],
                      emoji: '🧩',
                      type: QuestionType.wordOrder),
                  // EOI: Conversation
                  Question(
                      question: '🧑 What do you want to eat?',
                      answer: 'I want an apple!',
                      options: ['I want an apple!', 'Hello!', "It's a dog."],
                      emoji: '💬',
                      type: QuestionType.conversation),
                  // CE: Fill in the blank
                  Question(
                      question: 'Bees make ___.',
                      answer: 'honey',
                      options: ['honey', 'bread', 'milk'],
                      emoji: '📝',
                      type: QuestionType.fillBlank),
                  // CO: Dictation
                  Question(
                      question: 'Type what you hear',
                      answer: 'butter',
                      options: [],
                      emoji: '🎧',
                      type: QuestionType.listenType),
                  // Vocab: Match pairs
                  Question(
                      question: 'Match the pairs',
                      answer: 'matched',
                      options: [],
                      emoji: '🔗',
                      type: QuestionType.matchPairs,
                      pairs: {
                        'beurre': 'butter',
                        'jus': 'juice',
                        'pizza': 'pizza',
                        'pain': 'bread'
                      }),
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
                  // CO: Listen and choose
                  Question(
                      question: 'Listen and choose the correct body part',
                      answer: 'eyes',
                      options: ['eyes', 'ears', 'nose'],
                      emoji: '🎧',
                      type: QuestionType.listening),
                  // CE: Fill in the blank
                  Question(
                      question: 'I smell with my ___.',
                      answer: 'nose',
                      options: ['nose', 'eyes', 'mouth'],
                      emoji: '📝',
                      type: QuestionType.fillBlank),
                  // EOI: Conversation
                  Question(
                      question: '🧑 What do you hear with?',
                      answer: 'My ears!',
                      options: ['My ears!', 'My nose!', 'Thank you!'],
                      emoji: '💬',
                      type: QuestionType.conversation),
                  // CE: Reading
                  Question(
                      question:
                          'Read: "I brush my teeth every morning." — What do I brush?',
                      answer: 'teeth',
                      options: ['teeth', 'hair', 'nose'],
                      emoji: '📖',
                      type: QuestionType.reading),
                  // CO: Dictation
                  Question(
                      question: 'Type what you hear',
                      answer: 'mouth',
                      options: [],
                      emoji: '🎧',
                      type: QuestionType.listenType),
                  // Vocab: Match pairs
                  Question(
                      question: 'Match the pairs',
                      answer: 'matched',
                      options: [],
                      emoji: '🔗',
                      type: QuestionType.matchPairs,
                      pairs: {
                        'yeux': 'eyes',
                        'oreilles': 'ears',
                        'nez': 'nose',
                        'bouche': 'mouth'
                      }),
                ],
              ),
              PathUnit(
                id: 'a2p_body_2',
                title: 'My Body',
                type: UnitType.standard,
                emoji: '💪',
                questions: [
                  // CO: Listen and choose
                  Question(
                      question: 'Listen and choose the correct body part',
                      answer: 'hand',
                      options: ['hand', 'foot', 'head'],
                      emoji: '🎧',
                      type: QuestionType.listening),
                  // CE: Fill in the blank
                  Question(
                      question: 'I walk with my ___.',
                      answer: 'feet',
                      options: ['feet', 'hands', 'eyes'],
                      emoji: '📝',
                      type: QuestionType.fillBlank),
                  // EOI: Conversation
                  Question(
                      question: '🧑 Where does it hurt?',
                      answer: 'My head hurts!',
                      options: [
                        'My head hurts!',
                        'I like pizza.',
                        'Good night!'
                      ],
                      emoji: '💬',
                      type: QuestionType.conversation),
                  // EOC: Speaking
                  Question(
                      question: 'Say this body part out loud:',
                      answer: 'arm',
                      options: ['arm'],
                      emoji: '🗣️',
                      type: QuestionType.speaking),
                  // CE: Reading
                  Question(
                      question:
                          'Read: "My heart beats fast after running." — What beats fast?',
                      answer: 'heart',
                      options: ['heart', 'brain', 'stomach'],
                      emoji: '📖',
                      type: QuestionType.reading),
                  // Vocab: Match pairs
                  Question(
                      question: 'Match the pairs',
                      answer: 'matched',
                      options: [],
                      emoji: '🔗',
                      type: QuestionType.matchPairs,
                      pairs: {
                        'main': 'hand',
                        'pied': 'foot',
                        'bras': 'arm',
                        'cerveau': 'brain'
                      }),
                ],
              ),
              PathUnit(
                id: 'a2p_body_review',
                title: 'Review: My Body',
                type: UnitType.review,
                emoji: '🏆',
                pointsReward: 40,
                questions: [
                  // CO: Listen and choose
                  Question(
                      question: 'Listen and choose the correct body part',
                      answer: 'heart',
                      options: ['heart', 'brain', 'stomach'],
                      emoji: '🎧',
                      type: QuestionType.listening),
                  // EE: Word order
                  Question(
                      question: 'Je vois avec mes yeux',
                      answer: 'I see with my eyes',
                      options: ['I', 'see', 'with', 'my', 'eyes', 'eat', 'dog'],
                      emoji: '🧩',
                      type: QuestionType.wordOrder),
                  // EOI: Conversation
                  Question(
                      question: '🧑 What happened to your arm?',
                      answer: 'I hurt my arm!',
                      options: [
                        'I hurt my arm!',
                        'The sky is blue.',
                        'Thank you!'
                      ],
                      emoji: '💬',
                      type: QuestionType.conversation),
                  // CE: Fill in the blank
                  Question(
                      question: 'I think with my ___.',
                      answer: 'brain',
                      options: ['brain', 'foot', 'ear'],
                      emoji: '📝',
                      type: QuestionType.fillBlank),
                  // CE: Reading
                  Question(
                      question:
                          'Read: "She kicked the ball with her foot." — What kicked the ball?',
                      answer: 'foot',
                      options: ['foot', 'hand', 'knee'],
                      emoji: '📖',
                      type: QuestionType.reading),
                  // Vocab: Match pairs
                  Question(
                      question: 'Match the pairs',
                      answer: 'matched',
                      options: [],
                      emoji: '🔗',
                      type: QuestionType.matchPairs,
                      pairs: {
                        'yeux': 'eyes',
                        'main': 'hand',
                        'coeur': 'heart',
                        'cheveux': 'hair'
                      }),
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
  static double getSectionProgress(
      String sectionId, Set<String> completedUnitIds) {
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
