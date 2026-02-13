import 'dart:convert';
import 'package:http/http.dart' as http;

class AIService {
  static const String apiKey = String.fromEnvironment('OPENAI_API_KEY');
  static const String _model = 'gpt-4o-mini';
  static const String _apiUrl = 'https://api.openai.com/v1/chat/completions';

  AIService() {
    if (apiKey.isEmpty) {
      print('WARNING: OPENAI_API_KEY is not set! Add it via --dart-define=OPENAI_API_KEY=your_key');
    } else {
      print('AIService: OpenAI API key loaded successfully.');
    }
  }

  Future<String> _ask(String systemPrompt, String userMessage) async {
    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': _model,
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': userMessage},
          ],
          'max_tokens': 200,
          'temperature': 0.8,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'] ?? 'Hmm, I lost my words! 😅';
      } else {
        print('OpenAI Error ${response.statusCode}: ${response.body}');
        return 'Oops! I had a little problem 😅 Can you try again?';
      }
    } catch (e, stackTrace) {
      print('AI Error: $e');
      print('AI StackTrace: $stackTrace');
      return 'Oops! I had a little problem 😅 Can you try again?';
    }
  }

  Future<String> chat(String userMessage, {String? cefrLevel, String? topic}) async {
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
${cefrLevel != null ? 'Your friend\'s English level: $cefrLevel\n' : ''}${topic != null ? 'You\'re talking about: $topic\n' : ''}''';

    return _ask(systemPrompt, userMessage);
  }

  Future<String> getHint(String question, String correctAnswer) async {
    const systemPrompt = '''You're a kid (about 8 years old) helping a friend with an English question.
Give a fun hint (not the answer!) like a friend would.
Say something like "Hmm think about..." or "Oh oh I know! It sounds like..."
Use an emoji and keep it to one short sentence.''';

    final userMsg = 'Question: $question\nCorrect answer: $correctAnswer';

    try {
      return await _ask(systemPrompt, userMsg);
    } catch (e) {
      return 'Think about what you know! You can do it! 💪';
    }
  }

  Future<String> getEncouragement(int score, int total) async {
    final percentage = (score / total * 100).round();
    const systemPrompt = '''You're a kid (about 8 years old) cheering on your friend after a quiz.
React like an excited friend at the playground.
Say something short with emojis.''';

    final userMsg = 'My friend got $score out of $total ($percentage%)!';

    try {
      return await _ask(systemPrompt, userMsg);
    } catch (e) {
      return _getDefaultEncouragement(percentage);
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
    const systemPrompt = '''You're a kid (about 8 years old) explaining an English word to another kid.
Talk like a real kid:
- Say what it means in super simple words
- Give a fun example from kid life
- Add an emoji!
Keep it short like a kid would!''';

    try {
      return await _ask(systemPrompt, 'What does "$word" mean?');
    } catch (e) {
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
