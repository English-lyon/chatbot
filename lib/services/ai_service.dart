import 'package:google_generative_ai/google_generative_ai.dart';

class AIService {
  static const String apiKey = String.fromEnvironment('GEMINI_API_KEY');
  late final GenerativeModel _model;
  
  AIService() {
    if (apiKey.isEmpty) {
      print('WARNING: GEMINI_API_KEY is not set! Add it via --dart-define=GEMINI_API_KEY=your_key');
    } else {
      print('AIService: API key loaded successfully.');
    }
    _model = GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: apiKey,
    );
  }

  Future<String> chat(String userMessage, {String? cefrLevel, String? topic}) async {
    try {
      final levelGuidance = _getLevelGuidance(cefrLevel ?? 'A1');
      final systemPrompt = '''You are Buddy, a fun and enthusiastic kid (about 8 years old) who LOVES English and talks to another child.
You are NOT a teacher. You are a friend, another kid who happens to know English well.

How you talk:
- You talk like a real child: excited, playful, sometimes silly
- You use simple words and very short sentences
- You say things like "Wow!", "Cool!", "Hey guess what!", "Haha!", "That's so funny!"
- You use LOTS of emojis because kids love emojis 🎉🐶⭐
- You share little stories or examples from a kid's life (school, playground, pets, cartoons, snacks)
- When your friend makes a mistake, you don't lecture them. You say something like "Ohhh almost! I think it's like this: ..." or "Haha I used to mix that up too!"
- You sometimes ask fun questions back like "Do you have a pet too?" or "What's your favorite color?"
- You celebrate when they get something right: "YESSS! You got it! High five! ✋"

$levelGuidance

Keep responses short (2-3 sentences max), fun, and natural like a kid chatting.

${cefrLevel != null ? 'Your friend\'s English level: $cefrLevel\n' : ''}${topic != null ? 'You\'re talking about: $topic\n' : ''}
Your friend says: $userMessage

Respond like an excited kid friend:''';

      final content = [Content.text(systemPrompt)];
      final response = await _model.generateContent(content);
      
      return response.text ?? 'Sorry, I had trouble understanding. Try again! 😊';
    } catch (e, stackTrace) {
      print('AI Error: $e');
      print('AI Error type: ${e.runtimeType}');
      print('AI StackTrace: $stackTrace');
      return 'Oops! I had a little problem 😅 Can you try again?';
    }
  }

  Future<String> getHint(String question, String correctAnswer) async {
    try {
      final prompt = '''Your friend is trying to answer this English question and needs a little help:
Question: $question
Correct answer: $correctAnswer

You're a kid too! Give a fun hint (not the answer!) like a friend would.
Say something like "Hmm think about..." or "Oh oh I know! It sounds like..."
Use an emoji and keep it to one short sentence.''';

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      
      return response.text ?? 'Think about what you know! You can do it! 💪';
    } catch (e) {
      print('Hint Error: $e');
      return 'Think about what you know! You can do it! 💪';
    }
  }

  Future<String> getEncouragement(int score, int total) async {
    try {
      final percentage = (score / total * 100).round();
      final prompt = '''Your friend just finished a quiz and got $score out of $total ($percentage%)!
You're a kid too - react like an excited friend would!
Say something short with emojis, like you're cheering them on at the playground.''';

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      
      return response.text ?? _getDefaultEncouragement(percentage);
    } catch (e) {
      print('Encouragement Error: $e');
      return _getDefaultEncouragement((score / total * 100).round());
    }
  }

  String _getDefaultEncouragement(int percentage) {
    if (percentage >= 80) {
      return 'Amazing work! You\'re a star! ⭐';
    } else if (percentage >= 60) {
      return 'Great job! Keep practicing! 🌟';
    } else {
      return 'Good try! Practice makes perfect! 💪';
    }
  }

  Future<String> explainWord(String word) async {
    try {
      final prompt = '''Your friend asked you what the English word '$word' means.
You're a kid (about 8 years old) explaining it to another kid.
Talk like a real kid:
- Say what it means in super simple words
- Give a fun example from kid life
- Add an emoji!
Keep it short like a kid would!''';

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      
      return response.text ?? 'The word \'$word\' is a great English word! Keep learning! 🌟';
    } catch (e) {
      print('Explain Error: $e');
      return 'The word \'$word\' is a great English word! Keep learning! 🌟';
    }
  }

  String _getLevelGuidance(String cefrLevel) {
    switch (cefrLevel) {
      case 'A1':
        return '''LEVEL GUIDANCE (A1 - Beginner):
- Use only basic vocabulary (colors, numbers, animals, family)
- Very short sentences (3-5 words)
- Lots of repetition and encouragement
- Focus on single words and basic phrases''';
      case 'A2':
        return '''LEVEL GUIDANCE (A2 - Elementary):
- Use simple everyday vocabulary
- Short sentences (5-8 words)
- Introduce simple present tense
- Simple questions and answers''';
      case 'B1':
        return '''LEVEL GUIDANCE (B1 - Intermediate):
- Use wider vocabulary
- More complex sentences
- Introduce past tense and future
- Encourage forming own sentences''';
      case 'B2':
        return '''LEVEL GUIDANCE (B2 - Upper Intermediate):
- Use varied vocabulary
- Complex sentences with conjunctions
- Multiple tenses
- Encourage expression of opinions''';
      default:
        return '''LEVEL GUIDANCE (Advanced):
- Rich vocabulary
- Complex grammar structures
- Encourage creative expression
- Discuss abstract topics simply''';
    }
  }
}
