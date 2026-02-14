/// Types of exercises for children — based on real Duolingo exercise types
enum QuestionType {
  multipleChoice, // Read question + pick from options
  listening,      // 🎧 CO: Hear a word via TTS, pick the right answer
  listenType,     // 🎧✍️ CO: Hear a phrase via TTS, type what you heard (dictation)
  speaking,       // 🗣️ EOC: See a word, say it aloud
  reading,        // 📖 CE: Read an English sentence, answer a comprehension question
  writing,        // ✍️ EE: Type the answer (translate or spell)
  fillBlank,      // 📝 CE/EE: Complete a sentence with the missing word (pick from options)
  conversation,   // 💬 EOI: Complete a mini-dialogue (pick the right reply)
  wordOrder,      // 🧩 EE: Tap word chips to build a sentence (Duolingo-style)
  matchPairs,     // 🔗 Vocab: Match FR↔EN pairs (Duolingo "Appuie sur les paires")
}

class Question {
  final String question;
  final String answer;
  final List<String> options;
  final String emoji;
  final QuestionType type;
  final Map<String, String>? pairs; // For matchPairs: {french: english}

  Question({
    required this.question,
    required this.answer,
    required this.options,
    required this.emoji,
    this.type = QuestionType.multipleChoice,
    this.pairs,
  });

  Map<String, dynamic> toJson() => {
        'question': question,
        'answer': answer,
        'options': options,
        'emoji': emoji,
        'type': type.name,
        if (pairs != null) 'pairs': pairs,
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
        pairs: json['pairs'] != null
            ? Map<String, String>.from(json['pairs'])
            : null,
      );
}

