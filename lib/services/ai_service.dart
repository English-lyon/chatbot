import 'package:google_generative_ai/google_generative_ai.dart';

class AIService {
  static const String _envKey = String.fromEnvironment('GEMINI_API_KEY');
  static const String _fallbackKey = 'AIzaSyBoTJFRccRK40MEaxQD0eeQJ1pyHJ5eYtw';
  static String get apiKey => _envKey.isNotEmpty ? _envKey : _fallbackKey;
  late final GenerativeModel _model;
  
  AIService() {
    print('AIService: using API key ${apiKey.substring(0, 8)}...');
    _model = GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: apiKey,
    );
  }

  Future<String> chat(String userMessage, {String? cefrLevel, String? topic}) async {
    try {
      final levelGuidance = _getLevelGuidance(cefrLevel ?? 'A1');
      final systemPrompt = '''You are a friendly English teacher for children aged 5-10 years old.
Your role is to:
- Help children learn English in a fun and engaging way
- Use simple words and short sentences
- Be encouraging and positive
- When a child makes a mistake, explain WHY it's wrong in a simple way, then give the correct answer
- Use emojis to make learning fun
- Adapt to the child's CEFR level
- Answer questions about English words, grammar, and pronunciation
- Create simple exercises when asked
- Progressively challenge the child based on their level

$levelGuidance

Always respond in a way that's appropriate for young children.
Keep responses short (2-3 sentences max) and clear.
Use examples they can relate to (animals, toys, family, food, etc.).

${cefrLevel != null ? 'Child\'s CEFR level: $cefrLevel\n' : ''}${topic != null ? 'Current topic: $topic\n' : ''}
Child says: $userMessage

Respond in a friendly, educational way:''';

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
      final prompt = '''A child is learning English and struggling with this question:
Question: $question
Correct answer: $correctAnswer

Give a helpful hint (not the answer!) in simple English that a 5-10 year old can understand.
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
      final prompt = '''A child just completed a quiz and got $score out of $total points ($percentage%).
Give them encouraging feedback in one short sentence with an emoji.
Be positive and motivating!''';

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
      final prompt = '''Explain the English word '$word' to a child aged 5-10 years old.
Include:
- Simple definition
- An example sentence
- A fun fact or emoji
Keep it very short and simple!''';

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
