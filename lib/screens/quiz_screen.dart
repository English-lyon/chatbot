import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../providers/app_state.dart';
import '../models/lesson_content.dart';
import '../models/learning_path.dart';
import '../widgets/answer_button.dart';
import '../widgets/modern_button.dart';
import '../widgets/celebration_widget.dart';
import '../widgets/mascot_widget.dart';
import '../services/audio_service.dart';

class QuizScreen extends StatefulWidget {
  final Lesson? lesson;
  final String? moduleId;
  final PathUnit? unit;

  const QuizScreen({
    super.key,
    this.lesson,
    this.moduleId,
    this.unit,
  });

  List<Question> get questions =>
      unit?.questions ?? lesson?.questions ?? [];

  String get title =>
      unit?.title ?? lesson?.title ?? 'Quiz';

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late List<Question> _questionQueue;
  int _queueIndex = 0;
  int _score = 0;
  int _totalOriginal = 0;
  int _correctOnFirstTry = 0;
  bool _isRetryQuestion = false;
  List<AnswerState> _answerStates = [];
  bool _answered = false;
  bool _showCelebration = false;
  String _feedback = '';
  late List<String> _shuffledOptions;

  // Mascot
  MascotMood _mascotMood = MascotMood.idle;
  String _mascotSpeech = 'Let\'s go! 🚀';

  // Speaking: speech recognition
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _speechAvailable = false;
  bool _isListening = false;
  String _spokenText = '';

  // Writing
  final TextEditingController _writingController = TextEditingController();

  // Word-order: chip builder
  List<String> _wordPool = [];       // available chips
  List<String> _selectedWords = [];  // chips the child tapped (sentence being built)

  // Skip cooldown (5 min) — static so it persists across quiz screens
  static DateTime? _speakingSkipUntil;
  static DateTime? _listeningSkipUntil;
  bool get _speakingCooldown => _speakingSkipUntil != null && DateTime.now().isBefore(_speakingSkipUntil!);
  bool get _listeningCooldown => _listeningSkipUntil != null && DateTime.now().isBefore(_listeningSkipUntil!);

  // Word-by-word highlight for listening
  int _highlightStart = -1;
  int _highlightEnd = -1;
  String _listeningTextForHighlight = '';

  @override
  void initState() {
    super.initState();
    _questionQueue = List<Question>.from(widget.questions);
    _totalOriginal = _questionQueue.length;
    _initSpeech();
    _setupAudioCallbacks();
    _prepareCurrentQuestion();
    _onQuestionReady();
  }

  Future<void> _initSpeech() async {
    _speechAvailable = await _speech.initialize(
      onError: (_) => setState(() => _isListening = false),
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          setState(() => _isListening = false);
        }
      },
    );
  }

  void _setupAudioCallbacks() {
    _audio.onWordSpoken = (start, end) {
      if (mounted) setState(() { _highlightStart = start; _highlightEnd = end; });
    };
    _audio.onSpeakComplete = () {
      if (mounted) setState(() { _highlightStart = -1; _highlightEnd = -1; });
    };
  }

  @override
  void dispose() {
    _writingController.dispose();
    _speech.stop();
    _audio.onWordSpoken = null;
    _audio.onSpeakComplete = null;
    super.dispose();
  }

  AudioService get _audio =>
      Provider.of<AppState>(context, listen: false).audioService;

  void _onQuestionReady() {
    final question = _questionQueue[_queueIndex];
    if (question.type == QuestionType.listening) {
      _setMascot(MascotMood.listening, 'Listen carefully! 🎧');
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) _audio.speak(question.answer);
      });
    } else if (question.type == QuestionType.speaking) {
      _setMascot(MascotMood.speaking, 'Say it like me! 🗣️');
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) _audio.speak(question.answer);
      });
    } else if (question.type == QuestionType.reading) {
      _setMascot(MascotMood.thinking, 'Read carefully! 📖');
    } else if (question.type == QuestionType.writing) {
      _setMascot(MascotMood.thinking, 'You can do it! ✏️');
    } else if (question.type == QuestionType.wordOrder) {
      _setMascot(MascotMood.idle, 'Tap the words! 🧩');
    } else {
      _setMascot(MascotMood.idle, 'Let\'s go! 🚀');
    }
  }

  void _setMascot(MascotMood mood, String speech) {
    setState(() {
      _mascotMood = mood;
      _mascotSpeech = speech;
    });
  }

  void _prepareCurrentQuestion() {
    var question = _questionQueue[_queueIndex];

    // Auto-convert exercises during cooldown
    if (question.type == QuestionType.speaking && _speakingCooldown) {
      question = _convertToMultipleChoice(question);
      _questionQueue[_queueIndex] = question;
    }
    if (question.type == QuestionType.listening && _listeningCooldown) {
      question = _convertToMultipleChoice(question);
      _questionQueue[_queueIndex] = question;
    }

    _spokenText = '';
    _writingController.clear();
    _selectedWords = [];
    _wordPool = [];
    _highlightStart = -1;
    _highlightEnd = -1;
    _listeningTextForHighlight = '';

    if (question.type == QuestionType.speaking || question.type == QuestionType.writing) {
      _shuffledOptions = [];
      _answerStates = [];
    } else if (question.type == QuestionType.wordOrder) {
      // options = scrambled words + distractors; answer = correct sentence
      _wordPool = List<String>.from(question.options)..shuffle();
      _shuffledOptions = [];
      _answerStates = [];
    } else if (question.type == QuestionType.listening) {
      _listeningTextForHighlight = question.answer;
      _shuffledOptions = List<String>.from(question.options)..shuffle();
      _answerStates = List.filled(_shuffledOptions.length, AnswerState.normal);
    } else {
      _shuffledOptions = List<String>.from(question.options)..shuffle();
      _answerStates = List.filled(_shuffledOptions.length, AnswerState.normal);
    }
  }

  /// Convert a speaking/listening question to multipleChoice (for cooldown)
  Question _convertToMultipleChoice(Question q) {
    final mcOptions = q.options.length >= 3
        ? q.options
        : [q.answer, 'cat', 'dog', 'hello'];
    return Question(
      question: q.question.replaceFirst('Say this', 'What is this').replaceFirst('out loud:', '?'),
      answer: q.answer,
      options: mcOptions,
      emoji: q.emoji,
      type: QuestionType.multipleChoice,
    );
  }

  /// Skip a speaking or listening exercise → 5 min cooldown
  void _skipExercise(QuestionType type) {
    setState(() {
      if (type == QuestionType.speaking) {
        _speakingSkipUntil = DateTime.now().add(const Duration(minutes: 5));
      } else if (type == QuestionType.listening) {
        _listeningSkipUntil = DateTime.now().add(const Duration(minutes: 5));
      }
      // Replace current question with a multipleChoice version
      final current = _questionQueue[_queueIndex];
      _questionQueue[_queueIndex] = _convertToMultipleChoice(current);
      // Reset state for the new question
      _answered = false;
      _feedback = '';
      _prepareCurrentQuestion();
      _onQuestionReady();
    });
  }

  void _checkAnswer(String selectedAnswer, int index) {
    if (_answered) return;

    setState(() {
      _answered = true;
      final question = _questionQueue[_queueIndex];
      final correctAnswer = question.answer.toLowerCase().trim();

      if (selectedAnswer.toLowerCase().trim() == correctAnswer) {
        if (index >= 0 && index < _answerStates.length) {
          _answerStates[index] = AnswerState.correct;
        }
        _score += 25;
        _showCelebration = true;

        if (!_isRetryQuestion) {
          _correctOnFirstTry++;
          _feedback = '🌟 Super! That\'s right!';
        } else {
          _feedback = '🌟 You got it this time! Well done!';
        }

        _setMascot(MascotMood.happy, 'Amazing! 🎉');
        _audio.speakCheer();
      } else {
        if (index >= 0 && index < _answerStates.length) {
          _answerStates[index] = AnswerState.wrong;
          final correctIndex = _shuffledOptions
              .indexWhere((opt) => opt.toLowerCase() == correctAnswer);
          if (correctIndex != -1) {
            _answerStates[correctIndex] = AnswerState.correct;
          }
        }
        _feedback = '💡 The answer is "$correctAnswer".\n${_getExplanation(question)}';
        _setMascot(MascotMood.sad, 'Almost! Try again next time 💪');

        if (!_isRetryQuestion) {
          final retry = _createRetryQuestion(question);
          if (retry != null) {
            _questionQueue.insert(_queueIndex + 1, retry);
          }
        }
      }
    });

    Future.delayed(const Duration(milliseconds: 3500), () {
      if (mounted) _nextQuestion();
    });
  }

  void _checkWritingAnswer() {
    final typed = _writingController.text.trim();
    if (typed.isEmpty || _answered) return;
    _checkAnswer(typed, -1);
  }

  // ── Word order: check the built sentence ──
  void _checkWordOrder() {
    if (_answered) return;
    final built = _selectedWords.join(' ');
    _checkAnswer(built, -1);
  }

  // ── Speaking: start listening via microphone ──
  void _startListening() async {
    if (!_speechAvailable || _answered) return;
    setState(() {
      _isListening = true;
      _spokenText = '';
      _mascotMood = MascotMood.listening;
      _mascotSpeech = 'I\'m listening... 👂';
    });
    await _speech.listen(
      onResult: (result) {
        setState(() => _spokenText = result.recognizedWords);
        if (result.finalResult) {
          _evaluateSpokenAnswer(result.recognizedWords);
        }
      },
      listenFor: const Duration(seconds: 5),
      localeId: 'en_US',
    );
  }

  void _stopListening() async {
    await _speech.stop();
    setState(() => _isListening = false);
    if (_spokenText.isNotEmpty) {
      _evaluateSpokenAnswer(_spokenText);
    }
  }

  void _evaluateSpokenAnswer(String spoken) {
    if (_answered) return;
    final expected = _questionQueue[_queueIndex].answer.toLowerCase().trim();
    final said = spoken.toLowerCase().trim();
    final isCorrect = said.contains(expected) || expected.contains(said);

    setState(() {
      _answered = true;
      _isListening = false;
      if (isCorrect) {
        _score += 25;
        _showCelebration = true;
        if (!_isRetryQuestion) _correctOnFirstTry++;
        _feedback = '🌟 Great pronunciation!';
        _setMascot(MascotMood.happy, 'Perfect! 🎤✨');
        _audio.speakCheer();
      } else {
        _feedback = '💪 You said "$spoken" — the word is "$expected"';
        _setMascot(MascotMood.sad, 'Good try! Listen again 🔊');
        _audio.speak(expected);
      }
    });
    Future.delayed(const Duration(milliseconds: 3000), () {
      if (mounted) _nextQuestion();
    });
  }

  Question? _createRetryQuestion(Question original) {
    final a = original.answer;
    String retryQ;
    final q = original.question.toLowerCase();
    if (q.contains('color') || q.contains('colour')) {
      retryQ = 'Try again! Which color is "$a"? ${original.emoji}';
    } else if (q.contains('animal') || q.contains('says')) {
      retryQ = 'Let\'s try once more! What animal is this? ${original.emoji}';
    } else if (q.contains('how many') || q.contains('number')) {
      retryQ = 'One more try! What is the number? ${original.emoji}';
    } else if (q.contains('how do you say')) {
      retryQ = 'Try again! How do you say this in English? ${original.emoji}';
    } else {
      retryQ = 'Let\'s try again! ${original.question} ${original.emoji}';
    }
    // Retries for writing/wordOrder fall back to multipleChoice
    final retryType = (original.type == QuestionType.writing || original.type == QuestionType.wordOrder)
        ? QuestionType.multipleChoice
        : original.type;
    return Question(
      question: retryQ,
      answer: original.answer,
      options: List<String>.from(original.options)..shuffle(),
      emoji: original.emoji,
      type: retryType,
    );
  }

  String _getExplanation(Question question) {
    final q = question.question.toLowerCase();
    final a = question.answer;
    if (q.contains('color') || q.contains('colour')) return 'The color is $a! ${question.emoji}';
    if (q.contains('animal') || q.contains('says')) return 'This animal is a $a! ${question.emoji}';
    if (q.contains('how many') || q.contains('number')) return 'The number is $a! ${question.emoji}';
    if (q.contains('how do you say')) return 'In English we say "$a"! ${question.emoji}';
    return 'The correct word is "$a" ${question.emoji}';
  }

  void _nextQuestion() {
    setState(() {
      _showCelebration = false;
      if (_queueIndex < _questionQueue.length - 1) {
        _queueIndex++;
        _answered = false;
        _feedback = '';
        _isRetryQuestion = _queueIndex >= _totalOriginal ||
            _questionQueue[_queueIndex].question.startsWith('Try again') ||
            _questionQueue[_queueIndex].question.startsWith('Let\'s try') ||
            _questionQueue[_queueIndex].question.startsWith('One more');
        _prepareCurrentQuestion();
        _onQuestionReady();
      } else {
        _showResults();
      }
    });
  }

  void _showResults() async {
    final appState = Provider.of<AppState>(context, listen: false);
    final accuracy = _totalOriginal > 0 ? _correctOnFirstTry / _totalOriginal : 1.0;
    final percentage = (accuracy * 100).round();
    final totalPoints = _totalOriginal * 25;

    String encouragement = await appState.aiService.getEncouragement(_score, totalPoints);

    if (widget.unit != null) {
      appState.completeUnit(widget.unit!.id, _score, accuracy: accuracy);
    } else if (widget.lesson != null && widget.moduleId != null) {
      appState.completeLesson(widget.lesson!.id, widget.moduleId!, _score);
    }

    if (!mounted) return;

    final mascotEmoji = percentage >= 80 ? '🥳' : (percentage >= 50 ? '🐻' : '💪');
    final mascotText = percentage >= 80
        ? 'Perfect lesson!'
        : (percentage >= 50 ? 'Good job!' : 'Keep practicing!');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Column(
          children: [
            Text(mascotEmoji, style: const TextStyle(fontSize: 64)),
            const SizedBox(height: 8),
            Text(mascotText, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF4CAF50))),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('$percentage% correct', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            Text('$_correctOnFirstTry / $_totalOriginal on first try', style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildResultBadge('⚡ XP', '$_score', const Color(0xFF9C27B0)),
                _buildResultBadge('🎯', '$percentage%', const Color(0xFF4CAF50)),
              ],
            ),
            const SizedBox(height: 16),
            Text(encouragement, style: const TextStyle(fontSize: 15), textAlign: TextAlign.center),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _questionQueue = List<Question>.from(widget.questions);
                _queueIndex = 0;
                _score = 0;
                _totalOriginal = widget.questions.length;
                _correctOnFirstTry = 0;
                _isRetryQuestion = false;
                _answered = false;
                _feedback = '';
                _prepareCurrentQuestion();
                _onQuestionReady();
              });
            },
            child: const Text('🔄 Retry'),
          ),
          ElevatedButton(
            onPressed: () { Navigator.pop(context); Navigator.pop(context); },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50), foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: Text(widget.unit != null ? 'Continue ▶' : '🏠 Menu'),
          ),
        ],
      ),
    );
  }

  Widget _buildResultBadge(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 2),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  void _speakQuestion() {
    _audio.speak(_questionQueue[_queueIndex].question);
  }

  void _showHint() async {
    _setMascot(MascotMood.thinking, 'Hmm let me think... 🤔');
    final appState = Provider.of<AppState>(context, listen: false);
    final question = _questionQueue[_queueIndex];
    final hint = await appState.aiService.getHint(question.question, question.answer);
    if (!mounted) return;
    _setMascot(MascotMood.thinking, hint);
  }

  String _typeBadge(QuestionType t) {
    switch (t) {
      case QuestionType.listening: return '🎧';
      case QuestionType.speaking: return '🗣️';
      case QuestionType.reading: return '📖';
      case QuestionType.writing: return '✏️';
      case QuestionType.wordOrder: return '🧩';
      case QuestionType.multipleChoice: return '';
    }
  }

  /// Builds word-by-word text with real-time TTS highlighting (Duolingo-style)
  Widget _buildWordHighlight(String text) {
    final words = text.split(' ');
    int charPos = 0;
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 6,
      runSpacing: 6,
      children: words.map((word) {
        final wordStart = charPos;
        final wordEnd = charPos + word.length;
        charPos = wordEnd + 1; // +1 for space

        final isActive = _highlightStart >= 0 &&
            _highlightEnd > 0 &&
            _highlightStart < wordEnd &&
            _highlightEnd > wordStart;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isActive
                ? const Color(0xFF2196F3).withValues(alpha: 0.25)
                : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isActive ? const Color(0xFF2196F3) : Colors.grey.shade300,
              width: isActive ? 2.5 : 1,
            ),
          ),
          child: Text(
            word,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isActive ? const Color(0xFF2196F3) : Colors.black54,
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final question = _questionQueue[_queueIndex];
    final badge = _typeBadge(question.type);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FF),
      appBar: AppBar(
        title: Text('${_queueIndex + 1}/${_questionQueue.length}${badge.isNotEmpty ? " $badge" : ""}${_isRetryQuestion ? " 🔁" : ""}'),
        backgroundColor: const Color(0xFF3366CC),
        foregroundColor: Colors.white,
        actions: [
          // 🐢 slow button
          IconButton(
            icon: Icon(_audio.isSlow ? Icons.speed : Icons.slow_motion_video_rounded, size: 22),
            tooltip: _audio.isSlow ? 'Normal speed' : 'Slow speed 🐢',
            onPressed: () => setState(() => _audio.toggleSlow()),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(child: Text('⭐ $_score', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
          ),
        ],
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // ── Progress bar ──
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: (_queueIndex + 1) / _questionQueue.length,
                      minHeight: 6,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // ── Mascot + speech bubble ──
                  MascotWidget(mood: _mascotMood, size: 50, speechBubble: _mascotSpeech),
                  const SizedBox(height: 8),
                  // ── Question area ──
                  _buildQuestionArea(question),
                  const SizedBox(height: 8),
                  // ── Feedback ──
                  if (_feedback.isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _feedback.startsWith('🌟') ? Colors.green.shade50 : Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _feedback,
                        style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold,
                          color: _feedback.startsWith('🌟') ? Colors.green.shade700 : Colors.orange.shade800,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  const SizedBox(height: 8),
                  // ── Answer area ──
                  Expanded(child: _buildAnswerArea(question)),
                ],
              ),
            ),
          ),
          if (_showCelebration) const CelebrationWidget(),
        ],
      ),
    );
  }

  Widget _buildQuestionArea(Question question) {
    switch (question.type) {
      case QuestionType.listening:
        return Column(
          children: [
            const Text('🎧 What word do you hear?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
              textAlign: TextAlign.center),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Normal speed
                GestureDetector(
                  onTap: () {
                    setState(() { _listeningTextForHighlight = question.answer; });
                    _audio.speak(question.answer);
                  },
                  child: Container(
                    width: 90, height: 90,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2196F3).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF2196F3), width: 3),
                    ),
                    child: const Icon(Icons.volume_up_rounded, size: 48, color: Color(0xFF2196F3)),
                  ),
                ),
                const SizedBox(width: 16),
                // Slow speed 🐢
                GestureDetector(
                  onTap: () {
                    setState(() { _listeningTextForHighlight = question.answer; });
                    _audio.speakSlow(question.answer);
                  },
                  child: Container(
                    width: 60, height: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2196F3).withValues(alpha: 0.06),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF2196F3).withValues(alpha: 0.5), width: 2),
                    ),
                    child: const Center(child: Text('🐢', style: TextStyle(fontSize: 28))),
                  ),
                ),
              ],
            ),
            // Word-by-word highlight (Duolingo-style)
            if (_listeningTextForHighlight.isNotEmpty) ...[
              const SizedBox(height: 14),
              _buildWordHighlight(_listeningTextForHighlight),
            ],
            // Skip button
            if (!_answered)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: TextButton(
                  onPressed: () => _skipExercise(QuestionType.listening),
                  child: Text('Skip listening (5 min)', style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
                ),
              ),
          ],
        );

      case QuestionType.speaking:
        return Column(
          children: [
            const Text('🗣️ Say this word out loud!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
              textAlign: TextAlign.center),
            const SizedBox(height: 12),
            Text(question.emoji, style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF9C27B0).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                question.answer.toUpperCase(),
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF9C27B0), letterSpacing: 2),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => _audio.speak(question.answer),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.volume_up_rounded, size: 18, color: Color(0xFF2196F3)),
                      SizedBox(width: 4),
                      Text('Hear it', style: TextStyle(fontSize: 13, color: Color(0xFF2196F3))),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: () => _audio.speakSlow(question.answer),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('🐢', style: TextStyle(fontSize: 16)),
                      SizedBox(width: 4),
                      Text('Slow', style: TextStyle(fontSize: 13, color: Color(0xFF2196F3))),
                    ],
                  ),
                ),
              ],
            ),
            // Skip button for speaking
            if (!_answered)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: TextButton(
                  onPressed: () => _skipExercise(QuestionType.speaking),
                  child: Text('Skip speaking (5 min)', style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
                ),
              ),
          ],
        );

      case QuestionType.reading:
        final parts = question.question.split(' — ');
        final sentence = parts.length > 1 ? parts[0].replaceFirst('Read: ', '') : question.question;
        final comprehensionQ = parts.length > 1 ? parts[1] : '';
        return Column(
          children: [
            const Text('📖 Read and answer',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF4CAF50))),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF4CAF50).withValues(alpha: 0.2)),
              ),
              child: Text(sentence,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF333333), height: 1.4),
                textAlign: TextAlign.center),
            ),
            if (comprehensionQ.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(comprehensionQ, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87), textAlign: TextAlign.center),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(icon: const Icon(Icons.volume_up_rounded, color: Color(0xFF2196F3), size: 20), onPressed: () => _audio.speak(sentence)),
                IconButton(icon: const Text('🐢', style: TextStyle(fontSize: 18)), onPressed: () => _audio.speakSlow(sentence)),
              ],
            ),
          ],
        );

      case QuestionType.writing:
        return Column(
          children: [
            const Text('✏️ Write your answer',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFFF8F00))),
            const SizedBox(height: 8),
            Text(question.emoji, style: const TextStyle(fontSize: 40)),
            const SizedBox(height: 4),
            Text(question.question,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
              textAlign: TextAlign.center),
          ],
        );

      case QuestionType.wordOrder:
        return Column(
          children: [
            const Text('🧩 Build the sentence!',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF3366CC))),
            const SizedBox(height: 8),
            Text(question.question,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
              textAlign: TextAlign.center),
            const SizedBox(height: 4),
            GestureDetector(
              onTap: () => _audio.speak(question.answer),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.volume_up_rounded, size: 18, color: Color(0xFF2196F3)),
                  SizedBox(width: 4),
                  Text('Listen', style: TextStyle(fontSize: 13, color: Color(0xFF2196F3))),
                ],
              ),
            ),
          ],
        );

      case QuestionType.multipleChoice:
        return Column(
          children: [
            Text(question.question,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
              textAlign: TextAlign.center),
            const SizedBox(height: 12),
            Text(question.emoji, style: const TextStyle(fontSize: 64)),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ModernButton(text: '🔊 Listen', onPressed: _speakQuestion, backgroundColor: const Color(0xFF2196F3), fontSize: 13, isSmall: true),
                const SizedBox(width: 8),
                ModernButton(text: '🐢 Slow', onPressed: () => _audio.speakSlow(_questionQueue[_queueIndex].question), backgroundColor: const Color(0xFF2196F3), fontSize: 13, isSmall: true),
                const SizedBox(width: 8),
                ModernButton(text: '💡 Hint', onPressed: _showHint, backgroundColor: const Color(0xFFFF9800), fontSize: 13, isSmall: true),
              ],
            ),
          ],
        );
    }
  }

  Widget _buildAnswerArea(Question question) {
    // ── Speaking: real speech recognition ──
    if (question.type == QuestionType.speaking) {
      if (_answered) return const SizedBox.shrink();
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_spokenText.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text('You said: "$_spokenText"',
                style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Color(0xFF9C27B0))),
            ),
          GestureDetector(
            onTap: _isListening ? _stopListening : _startListening,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: _isListening ? 100 : 80,
              height: _isListening ? 100 : 80,
              decoration: BoxDecoration(
                color: _isListening ? const Color(0xFFE91E63) : const Color(0xFF9C27B0),
                shape: BoxShape.circle,
                boxShadow: _isListening
                    ? [BoxShadow(color: const Color(0xFFE91E63).withValues(alpha: 0.4), blurRadius: 20, spreadRadius: 4)]
                    : [BoxShadow(color: const Color(0xFF9C27B0).withValues(alpha: 0.3), blurRadius: 10)],
              ),
              child: Icon(
                _isListening ? Icons.stop_rounded : Icons.mic_rounded,
                size: 44, color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _isListening ? 'Listening... tap to stop' : 'Tap the mic and say the word!',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          if (!_speechAvailable) ...[
            const SizedBox(height: 12),
            const Text('🎤 Microphone not available', style: TextStyle(fontSize: 12, color: Colors.red)),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _evaluateSpokenAnswer(question.answer),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF9C27B0), foregroundColor: Colors.white),
              child: const Text('Skip (I said it) ▶'),
            ),
          ],
        ],
      );
    }

    // ── Word order: chip builder ──
    if (question.type == QuestionType.wordOrder) {
      return Column(
        children: [
          // Built sentence area
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 56),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade300, width: 2),
            ),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (int i = 0; i < _selectedWords.length; i++)
                  GestureDetector(
                    onTap: _answered ? null : () {
                      setState(() {
                        _wordPool.add(_selectedWords.removeAt(i));
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3366CC).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF3366CC), width: 1.5),
                      ),
                      child: Text(_selectedWords[i],
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF3366CC))),
                    ),
                  ),
                if (_selectedWords.isEmpty)
                  Text('Tap the words below...', style: TextStyle(fontSize: 16, color: Colors.grey.shade400, fontStyle: FontStyle.italic)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Word pool
          Expanded(
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: [
                for (int i = 0; i < _wordPool.length; i++)
                  GestureDetector(
                    onTap: _answered ? null : () {
                      setState(() {
                        _selectedWords.add(_wordPool.removeAt(i));
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade300, width: 1.5),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 4, offset: const Offset(0, 2))],
                      ),
                      child: Text(_wordPool[i],
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF333333))),
                    ),
                  ),
              ],
            ),
          ),
          if (!_answered)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedWords.isEmpty ? null : _checkWordOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50), foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('CHECK', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1)),
              ),
            ),
        ],
      );
    }

    // ── Writing: text input ──
    if (question.type == QuestionType.writing) {
      return Column(
        children: [
          TextField(
            controller: _writingController,
            enabled: !_answered,
            autofocus: true,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              hintText: 'Type your answer...',
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 18),
              filled: true, fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFFF8F00), width: 2)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade300, width: 2)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFFF8F00), width: 2)),
            ),
            onSubmitted: (_) => _checkWritingAnswer(),
          ),
          const SizedBox(height: 14),
          if (!_answered)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _checkWritingAnswer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF8F00), foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('CHECK', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1)),
              ),
            ),
        ],
      );
    }

    // ── Multiple choice / Listening / Reading: option buttons ──
    return ListView.separated(
      itemCount: _shuffledOptions.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        return AnswerButton(
          text: _shuffledOptions[index].toUpperCase(),
          onPressed: () => _checkAnswer(_shuffledOptions[index], index),
          state: _answerStates[index],
        );
      },
    );
  }
}
