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
  final PathUnit? unit;

  const QuizScreen({
    super.key,
    this.unit,
  });

  List<Question> get questions =>
      unit?.questions ?? [];

  String get title =>
      unit?.title ?? 'Quiz';

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late List<Question> _questionQueue;
  int _queueIndex = 0;
  int? _selectedOptionIndex;
  int _lives = 5;
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
  String _mascotSpeech = 'C\'est parti ! \u{1F680}';

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

  // Match pairs state
  List<String> _pairItems = [];           // all items (FR + EN) for length check
  List<String> _leftPairItems = [];       // FR words (shuffled independently)
  List<String> _rightPairItems = [];      // EN words (shuffled independently)
  Map<String, String> _pairMap = {};      // correct mapping {item: partner}
  String? _selectedPairItem;              // currently tapped item
  Set<String> _matchedPairs = {};         // successfully matched items
  Set<String> _wrongPairItems = {};       // items that just got wrong (flash red)

  // Skip cooldown (5 min) — static so it persists across quiz screens
  static DateTime? _speakingSkipUntil;
  static DateTime? _listeningSkipUntil;
  bool get _speakingCooldown => _speakingSkipUntil != null && DateTime.now().isBefore(_speakingSkipUntil!);
  bool get _listeningCooldown => _listeningSkipUntil != null && DateTime.now().isBefore(_listeningSkipUntil!);

  // Word-by-word highlight for listening
  int _highlightStart = -1;
  int _highlightEnd = -1;
  String _listeningTextForHighlight = '';

  // User profile
  late Color _themeColor;
  late String _userName;

  @override
  void initState() {
    super.initState();
    final appState = Provider.of<AppState>(context, listen: false);
    _themeColor = Color(appState.profile.favoriteColorValue);
    _userName = appState.profile.name;
    _questionQueue = _buildDuolingoExerciseFlow(widget.questions);
    _questionQueue.shuffle(); // Random order for every user
    _totalOriginal = _questionQueue.length;
    _initSpeech();
    _setupAudioCallbacks();
    _prepareCurrentQuestion();
    _onQuestionReady();
  }

  Widget _buildCorrectionPanel() {
    final isCorrect = _feedback.startsWith('🌟');
    final bg = isCorrect ? const Color(0xFFD7FFB8) : const Color(0xFFFFDFE0);
    final border = isCorrect ? const Color(0xFF58CC02) : const Color(0xFFFF4B4B);
    final textColor = isCorrect ? const Color(0xFF58CC02) : const Color(0xFFFF4B4B);
    final icon = isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded;

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 1.0, end: 0.0),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(0, value * 200),
            child: child,
          );
        },
        child: SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                  color: border.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(icon, color: textColor, size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isCorrect ? 'Excellent !' : 'Oops !',
                            style: TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.w900,
                              fontSize: 22,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _feedback,
                            style: TextStyle(
                              color: textColor.withValues(alpha: 0.85),
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _nextQuestion,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: border,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'CONTINUER',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Question> _buildDuolingoExerciseFlow(List<Question> source) {
    final flow = <Question>[];
    for (int i = 0; i < source.length; i++) {
      final q = source[i];

      // If the question already has a specific type (from learning_path),
      // keep it as-is — don't override the author's intent
      if (q.type != QuestionType.multipleChoice || q.pairs != null) {
        flow.add(q);
        continue;
      }

      // For plain multipleChoice questions (from lesson_content),
      // auto-generate varied exercise types
      final distractors = _buildDistractors(q.answer, q.options);
      final mode = i % 6;

      if (mode == 0) {
        flow.add(Question(
          question: q.question,
          answer: q.answer,
          options: distractors,
          emoji: q.emoji,
          type: QuestionType.multipleChoice,
        ));
      } else if (mode == 1) {
        flow.add(Question(
          question: 'Écoute et choisis le bon mot',
          answer: q.answer,
          options: distractors,
          emoji: '🎧',
          type: QuestionType.listening,
        ));
      } else if (mode == 2) {
        // Fill-in-the-blank instead of writing (kids can't type)
        flow.add(Question(
          question: 'Écoute et choisis le bon mot',
          answer: q.answer,
          options: distractors,
          emoji: '🎧',
          type: QuestionType.listening,
        ));
      } else if (mode == 3) {
        flow.add(Question(
          question: 'Dis ce mot en anglais : ${q.answer}',
          answer: q.answer,
          options: distractors,
          emoji: '🗣️',
          type: QuestionType.speaking,
        ));
      } else if (mode == 4) {
        final phrase = q.answer.contains(' ')
            ? q.answer
            : 'I like ${q.answer.toLowerCase()}';
        // Use the original question as a French-style prompt for translation
        final frenchPrompt = q.question.replaceAll(RegExp(r"How do you say '(.+)'.*"), r'$1')
            .replaceAll(RegExp(r"What is .+\?"), q.answer);
        flow.add(Question(
          question: frenchPrompt,
          answer: phrase,
          options: _buildWordOrderOptions(phrase),
          emoji: '🧩',
          type: QuestionType.wordOrder,
        ));
      } else {
        // Auto-generate a matchPairs from nearby questions
        final pairs = <String, String>{};
        final usedAnswers = <String>{};
        for (int j = i; j < source.length && pairs.length < 4; j++) {
          final s = source[j];
          final answer = s.answer.trim();
          if (usedAnswers.contains(answer.toLowerCase())) continue;
          usedAnswers.add(answer.toLowerCase());
          // Extract French label from question (e.g. "How do you say 'chat'?" → "chat")
          final match = RegExp(r"['\u2018\u2019\u00AB\u00BB](.+?)['\u2018\u2019\u00AB\u00BB]").firstMatch(s.question);
          final frLabel = match != null ? '${s.emoji} ${match.group(1)}' : '${s.emoji} ?';
          pairs[frLabel] = answer;
        }
        // Fill up if not enough
        if (pairs.length < 3) {
          if (!usedAnswers.contains('cat')) pairs['🐱 chat'] = 'cat';
          if (!usedAnswers.contains('dog')) pairs['🐶 chien'] = 'dog';
          if (!usedAnswers.contains('fish')) pairs['🐟 poisson'] = 'fish';
        }
        flow.add(Question(
          question: 'Match the pairs',
          answer: 'matched',
          options: [],
          emoji: '🔗',
          type: QuestionType.matchPairs,
          pairs: pairs,
        ));
      }
    }
    return flow;
  }

  List<String> _buildDistractors(String answer, List<String> options) {
    final set = <String>{};
    set.add(answer.toLowerCase());
    for (final option in options) {
      set.add(option.toLowerCase());
    }
    const filler = ['cat', 'dog', 'book', 'blue', 'water', 'school'];
    for (final word in filler) {
      if (set.length >= 4) break;
      set.add(word);
    }
    final result = set.toList();
    result.shuffle();
    return result;
  }

  List<String> _buildWordOrderOptions(String phrase) {
    final words = phrase.split(' ').where((w) => w.trim().isNotEmpty).toList();
    const extras = ['the', 'is', 'very', 'my', 'and'];
    final options = <String>[...words];
    for (final extra in extras) {
      if (options.length >= words.length + 2) break;
      if (!options.contains(extra)) options.add(extra);
    }
    options.shuffle();
    return options;
  }

  void _selectOption(int index) {
    if (_answered) return;
    setState(() {
      _selectedOptionIndex = index;
      for (int i = 0; i < _answerStates.length; i++) {
        _answerStates[i] = i == index ? AnswerState.selected : AnswerState.normal;
      }
    });
  }

  bool _isOptionExercise(QuestionType type) {
    return type == QuestionType.multipleChoice ||
        type == QuestionType.listening ||
        type == QuestionType.reading ||
        type == QuestionType.fillBlank ||
        type == QuestionType.conversation;
  }

  bool _canSubmitExercise(Question question) {
    if (_answered) return false;
    // Speaking & matchPairs: always allow (acts as SKIP)
    if (question.type == QuestionType.speaking) return true;
    if (question.type == QuestionType.matchPairs) return true;
    if (_isOptionExercise(question.type)) return _selectedOptionIndex != null;
    if (question.type == QuestionType.wordOrder || question.type == QuestionType.listenType) return _selectedWords.isNotEmpty;
    if (question.type == QuestionType.writing) return _writingController.text.trim().isNotEmpty;
    return false;
  }

  void _submitCurrentExercise(Question question) {
    if (_answered) return;
    // Speaking: skip if not spoken, otherwise evaluate
    if (question.type == QuestionType.speaking) {
      if (_spokenText.isNotEmpty) {
        _evaluateSpokenAnswer(_spokenText);
      } else {
        setState(() {
          _answered = true;
          _isListening = false;
          _feedback = '\u{1F4A1} Le mot était "${question.answer}"';
          _setMascot(MascotMood.idle, 'Pas grave ! On continue \u{1F680}');
        });
      }
      return;
    }
    // Match pairs: skip if not all matched
    if (question.type == QuestionType.matchPairs) {
      setState(() {
        _answered = true;
        _feedback = '\u{1F4A1} Passé ! Tu réussiras la prochaine fois !';
        _setMascot(MascotMood.idle, 'On continue ! \u{1F680}');
      });
      return;
    }
    if (_isOptionExercise(question.type)) {
      if (_selectedOptionIndex == null) return;
      final idx = _selectedOptionIndex!;
      _checkAnswer(_shuffledOptions[idx], idx);
      return;
    }
    if (question.type == QuestionType.wordOrder || question.type == QuestionType.listenType) {
      _checkWordOrder();
      return;
    }
    if (question.type == QuestionType.writing) {
      _checkWritingAnswer();
    }
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
      _setMascot(MascotMood.listening, 'Écoute bien, $_userName ! \u{1F3A7}');
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) _audio.speak(question.answer);
      });
    } else if (question.type == QuestionType.speaking) {
      _setMascot(MascotMood.speaking, 'Répète après moi, $_userName ! \u{1F5E3}\u{FE0F}');
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) _audio.speak(question.answer);
      });
    } else if (question.type == QuestionType.reading) {
      _setMascot(MascotMood.thinking, 'Lis bien ! \u{1F4D6}');
    } else if (question.type == QuestionType.writing) {
      _setMascot(MascotMood.thinking, 'Écris en anglais ! \u{270F}\u{FE0F}');
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) _audio.speak(question.answer);
      });
    } else if (question.type == QuestionType.wordOrder) {
      _setMascot(MascotMood.thinking, 'Traduis, $_userName ! \u{1F1EB}\u{1F1F7}\u{27A1}\u{FE0F}\u{1F1EC}\u{1F1E7}');
    } else if (question.type == QuestionType.matchPairs) {
      _setMascot(MascotMood.idle, 'Trouve les paires, $_userName ! \u{1F517}');
    } else if (question.type == QuestionType.fillBlank) {
      _setMascot(MascotMood.thinking, 'Complète la phrase ! \u{1F4DD}');
    } else if (question.type == QuestionType.conversation) {
      _setMascot(MascotMood.speaking, 'À toi, $_userName ! \u{1F4AC}');
    } else if (question.type == QuestionType.listenType) {
      _setMascot(MascotMood.listening, 'Écoute et écris ! \u{1F3A7}\u{270D}\u{FE0F}');
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) _audio.speak(question.answer);
      });
    } else {
      _setMascot(MascotMood.idle, 'C\'est parti, $_userName ! \u{1F680}');
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
    _selectedOptionIndex = null;
    _writingController.clear();
    _selectedWords = [];
    _wordPool = [];
    _highlightStart = -1;
    _highlightEnd = -1;
    _listeningTextForHighlight = '';

    // Reset match pairs state
    _pairItems = [];
    _leftPairItems = [];
    _rightPairItems = [];
    _pairMap = {};
    _selectedPairItem = null;
    _matchedPairs = {};
    _wrongPairItems = {};

    if (question.type == QuestionType.matchPairs && question.pairs != null) {
      // Build two independently shuffled columns (FR left, EN right)
      _leftPairItems = question.pairs!.keys.toList()..shuffle();
      _rightPairItems = question.pairs!.values.toList()..shuffle();
      _pairMap = {};
      for (final entry in question.pairs!.entries) {
        _pairMap[entry.key] = entry.value;
        _pairMap[entry.value] = entry.key;
      }
      _pairItems = [..._leftPairItems, ..._rightPairItems];
      _shuffledOptions = [];
      _answerStates = [];
    } else if (question.type == QuestionType.speaking || question.type == QuestionType.writing) {
      _shuffledOptions = [];
      _answerStates = [];
    } else if (question.type == QuestionType.listenType) {
      _listeningTextForHighlight = question.answer;
      // Generate word tiles from answer + distractors (Duolingo style)
      final answerWords = question.answer.split(' ').where((w) => w.trim().isNotEmpty).toList();
      const distractorPool = ['the', 'a', 'is', 'and', 'my', 'it', 'has', 'not', 'can', 'big'];
      final tiles = <String>[...answerWords];
      for (final d in distractorPool) {
        if (tiles.length >= answerWords.length + 3) break;
        if (!tiles.contains(d)) tiles.add(d);
      }
      tiles.shuffle();
      _wordPool = tiles;
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
      question: q.question.replaceFirst('Say this', 'What is this').replaceFirst('out loud:', '?').replaceFirst('Dis ce mot en anglais', 'Quel est ce mot'),
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

  // ── Word tiles: draggable builders ──
  Widget _buildDraggablePoolWord(int index) {
    final word = _wordPool[index];
    return Draggable<String>(
      data: word,
      feedback: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF1CB0F6).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF1CB0F6), width: 2),
          ),
          child: Text(word, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF1CB0F6), decoration: TextDecoration.none)),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200, width: 1.5),
          ),
          child: Text(word, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.grey.shade300)),
        ),
      ),
      onDragCompleted: () {},
      child: GestureDetector(
        onTap: _answered ? null : () {
          setState(() => _selectedWords.add(_wordPool.removeAt(index)));
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300, width: 1.5),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 4, offset: const Offset(0, 2))],
          ),
          child: Text(word, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF333333))),
        ),
      ),
    );
  }

  Widget _buildDraggableSelectedWord(int index) {
    final word = _selectedWords[index];
    return Draggable<_SentenceWord>(
      data: _SentenceWord(word, index),
      feedback: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFFF4B4B).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFFF4B4B), width: 2),
          ),
          child: Text(word, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFFFF4B4B), decoration: TextDecoration.none)),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade200, width: 1.5),
          ),
          child: Text(word, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.grey.shade300)),
        ),
      ),
      child: GestureDetector(
        onTap: _answered ? null : () {
          setState(() => _wordPool.add(_selectedWords.removeAt(index)));
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade400, width: 1.5),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 2, offset: const Offset(0, 1))],
          ),
          child: Text(word, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Color(0xFF333333))),
        ),
      ),
    );
  }

  // ── Match pairs: build a compact tile ──
  Widget _buildPairTile(String item) {
    final isMatched = _matchedPairs.contains(item);
    final isSelected = _selectedPairItem == item;
    final isWrong = _wrongPairItems.contains(item);

    Color bg = Colors.white;
    Color border = Colors.grey.shade300;
    Color textColor = const Color(0xFF333333);

    if (isMatched) {
      bg = const Color(0xFF58CC02).withValues(alpha: 0.15);
      border = const Color(0xFF58CC02);
      textColor = const Color(0xFF58CC02);
    } else if (isWrong) {
      bg = const Color(0xFFFF4B4B).withValues(alpha: 0.15);
      border = const Color(0xFFFF4B4B);
      textColor = const Color(0xFFFF4B4B);
    } else if (isSelected) {
      bg = const Color(0xFF1CB0F6).withValues(alpha: 0.12);
      border = const Color(0xFF1CB0F6);
      textColor = const Color(0xFF1CB0F6);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: isMatched ? null : () => _onPairItemTap(item),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: border, width: 2),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 3, offset: const Offset(0, 2))],
          ),
          child: Text(
            item,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: textColor),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  // ── Match pairs: tap logic ──
  void _onPairItemTap(String item) {
    if (_answered || _matchedPairs.contains(item)) return;

    setState(() {
      if (_selectedPairItem == null) {
        // First tap: select this item
        _selectedPairItem = item;
        _wrongPairItems = {};
      } else if (_selectedPairItem == item) {
        // Tap same item: deselect
        _selectedPairItem = null;
      } else {
        // Second tap: check if it's a match
        final partner = _pairMap[_selectedPairItem!];
        if (partner == item) {
          // Correct match!
          _matchedPairs.add(_selectedPairItem!);
          _matchedPairs.add(item);
          _selectedPairItem = null;
          _wrongPairItems = {};
          _audio.speakCheer();

          // Check if all pairs matched
          if (_matchedPairs.length == _pairItems.length) {
            _answered = true;
            _score += 25;
            _showCelebration = true;
            if (!_isRetryQuestion) _correctOnFirstTry++;
            _feedback = '🌟 Toutes les paires trouvées !';
            _setMascot(MascotMood.happy, 'Parfait ! 🎉');
          }
        } else {
          // Wrong match
          _wrongPairItems = {_selectedPairItem!, item};
          _lives = (_lives - 1).clamp(0, 5);
          _selectedPairItem = null;
          _setMascot(MascotMood.sad, 'Réessaie ! 💪');
          // Clear wrong highlight after a short delay
          Future.delayed(const Duration(milliseconds: 600), () {
            if (mounted) setState(() => _wrongPairItems = {});
          });
        }
      }
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
          _feedback = '🌟 Super ! Bravo !';
        } else {
          _feedback = '🌟 Tu as trouvé cette fois ! Bien joué !';
        }

        _setMascot(MascotMood.happy, 'Génial, $_userName ! 🎉');
        _audio.speakCheer();
      } else {
        _lives = (_lives - 1).clamp(0, 5);
        if (index >= 0 && index < _answerStates.length) {
          _answerStates[index] = AnswerState.wrong;
          final correctIndex = _shuffledOptions
              .indexWhere((opt) => opt.toLowerCase() == correctAnswer);
          if (correctIndex != -1) {
            _answerStates[correctIndex] = AnswerState.correct;
          }
        }
        _feedback = '💡 La réponse est "$correctAnswer".\n${_getExplanation(question)}';
        _setMascot(MascotMood.sad, 'Presque, $_userName ! Réessaie 💪');

        if (!_isRetryQuestion) {
          final retry = _createRetryQuestion(question);
          if (retry != null) {
            _questionQueue.insert(_queueIndex + 1, retry);
          }
        }
      }
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
      _mascotSpeech = 'J\'\u00e9coute... 👂';
    });
    await _speech.listen(
      onResult: (result) {
        if (_answered) return;
        setState(() => _spokenText = result.recognizedWords);
        // Auto-validate: check partial results against expected word
        final expected = _questionQueue[_queueIndex].answer.toLowerCase().trim();
        final said = result.recognizedWords.toLowerCase().trim();
        final similarity = _letterSimilarity(said, expected);
        final isMatch = similarity >= 0.6 || said.contains(expected) || expected.contains(said);
        if (isMatch && said.isNotEmpty) {
          _speech.stop();
          _evaluateSpokenAnswer(result.recognizedWords);
          return;
        }
        if (result.finalResult) {
          _evaluateSpokenAnswer(result.recognizedWords);
        }
      },
      listenFor: const Duration(seconds: 8),
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

  /// Calculate letter similarity between two strings (0.0 to 1.0)
  double _letterSimilarity(String a, String b) {
    if (a.isEmpty || b.isEmpty) return 0.0;
    int matches = 0;
    final bChars = b.split('');
    final used = List.filled(bChars.length, false);
    for (final c in a.split('')) {
      for (int i = 0; i < bChars.length; i++) {
        if (!used[i] && bChars[i] == c) {
          matches++;
          used[i] = true;
          break;
        }
      }
    }
    return matches / b.length;
  }

  void _evaluateSpokenAnswer(String spoken) {
    if (_answered) return;
    final expected = _questionQueue[_queueIndex].answer.toLowerCase().trim();
    final said = spoken.toLowerCase().trim();
    // Accept if 60% of letters match (kids won't pronounce perfectly)
    final similarity = _letterSimilarity(said, expected);
    final isCorrect = similarity >= 0.6 || said.contains(expected) || expected.contains(said);

    setState(() {
      _answered = true;
      _isListening = false;
      if (isCorrect) {
        _score += 25;
        _showCelebration = true;
        if (!_isRetryQuestion) _correctOnFirstTry++;
        _feedback = '🌟 Super prononciation, $_userName !';
        _setMascot(MascotMood.happy, 'Parfait, $_userName ! 🎤✨');
        _audio.speakCheer();
      } else {
        _lives = (_lives - 1).clamp(0, 5);
        _feedback = '💪 Tu as dit "$spoken" \u2014 le mot est "$expected"';
        _setMascot(MascotMood.sad, 'Bien essayé ! Réécoute 🔊');
        _audio.speak(expected);
      }
    });
  }

  Question? _createRetryQuestion(Question original) {
    final a = original.answer;
    String retryQ;
    final q = original.question.toLowerCase();
    if (q.contains('color') || q.contains('colour')) {
      retryQ = 'Réessaie ! Quelle couleur est "$a" ? ${original.emoji}';
    } else if (q.contains('animal') || q.contains('says')) {
      retryQ = 'Encore une fois ! Quel animal est-ce ? ${original.emoji}';
    } else if (q.contains('how many') || q.contains('number')) {
      retryQ = 'Encore un essai ! Quel est le nombre ? ${original.emoji}';
    } else if (q.contains('how do you say')) {
      retryQ = 'Réessaie ! Comment dit-on en anglais ? ${original.emoji}';
    } else {
      retryQ = 'On réessaie ! ${original.question} ${original.emoji}';
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
    if (q.contains('color') || q.contains('colour')) return 'La couleur est $a ! ${question.emoji}';
    if (q.contains('animal') || q.contains('says')) return 'Cet animal est un $a ! ${question.emoji}';
    if (q.contains('how many') || q.contains('number')) return 'Le nombre est $a ! ${question.emoji}';
    if (q.contains('how do you say') || q.contains('comment dit-on')) return 'En anglais on dit "$a" ! ${question.emoji}';
    return 'Le mot correct est "$a" ${question.emoji}';
  }

  void _nextQuestion() {
    setState(() {
      _showCelebration = false;
      if (_queueIndex < _questionQueue.length - 1) {
        _queueIndex++;
        _answered = false;
        _feedback = '';
        _isRetryQuestion = _queueIndex >= _totalOriginal ||
            _questionQueue[_queueIndex].question.startsWith('Réessaie') ||
            _questionQueue[_queueIndex].question.startsWith('Encore') ||
            _questionQueue[_queueIndex].question.startsWith('On réessaie');
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
    }

    if (!mounted) return;

    final mascotEmoji = percentage >= 80 ? '🥳' : (percentage >= 50 ? '🐻' : '💪');
    final mascotText = percentage >= 80
        ? 'Leçon parfaite !'
        : (percentage >= 50 ? 'Bien joué !' : 'Continue comme ça !');

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
            Text('$percentage% de bonnes réponses', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            Text('$_correctOnFirstTry / $_totalOriginal du premier coup', style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
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
                _questionQueue = _buildDuolingoExerciseFlow(widget.questions);
                _questionQueue.shuffle();
                _queueIndex = 0;
                _score = 0;
                _totalOriginal = _questionQueue.length;
                _correctOnFirstTry = 0;
                _lives = 5;
                _isRetryQuestion = false;
                _answered = false;
                _feedback = '';
                _prepareCurrentQuestion();
                _onQuestionReady();
              });
            },
            child: const Text('🔄 Rejouer'),
          ),
          ElevatedButton(
            onPressed: () { Navigator.pop(context); Navigator.pop(context); },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50), foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: Text(widget.unit != null ? 'Continuer ▶' : '🏠 Menu'),
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
    _setMascot(MascotMood.thinking, 'Hmm laisse-moi réfléchir... 🤔');
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
      case QuestionType.matchPairs: return '🔗';
      case QuestionType.fillBlank: return '📝';
      case QuestionType.conversation: return '💬';
      case QuestionType.listenType: return '🎧';
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
    final canSubmit = _canSubmitExercise(question);

    return Scaffold(
      backgroundColor: _themeColor.withValues(alpha: 0.04),
      appBar: AppBar(
        title: Text('${_queueIndex + 1}/${_questionQueue.length}${badge.isNotEmpty ? " $badge" : ""}${_isRetryQuestion ? " 🔁" : ""}'),
        backgroundColor: _themeColor,
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
            child: Center(
              child: Text(
                '${'❤️' * _lives}${'🤍' * (5 - _lives)}',
                style: const TextStyle(fontSize: 16),
              ),
            ),
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
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 260),
                    transitionBuilder: (child, animation) {
                      final slide = Tween<Offset>(
                        begin: const Offset(0.06, 0),
                        end: Offset.zero,
                      ).animate(animation);
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(position: slide, child: child),
                      );
                    },
                    child: KeyedSubtree(
                      key: ValueKey('question_${_queueIndex}_${question.type.name}'),
                      child: _buildQuestionArea(question),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // ── Answer area ──
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 260),
                      transitionBuilder: (child, animation) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                      child: KeyedSubtree(
                        key: ValueKey('answer_${_queueIndex}_${question.type.name}'),
                        child: _buildAnswerArea(question),
                      ),
                    ),
                  ),
                  if (!_answered) ...[
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: canSubmit
                            ? () => _submitCurrentExercise(question)
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1CB0F6),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.grey.shade300,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          (question.type == QuestionType.speaking || question.type == QuestionType.matchPairs) ? 'PASSER' : 'VÉRIFIER',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (_answered && _feedback.isNotEmpty) _buildCorrectionPanel(),
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
            const Text('🎧 Écoute et choisis la bonne réponse',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
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
                  child: Text('Passer l\'\u00e9coute (5 min)', style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
                ),
              ),
          ],
        );

      case QuestionType.speaking:
        return Column(
          children: [
            const Text('🗣️ Dis ce mot en anglais',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
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
                      Text('Écouter', style: TextStyle(fontSize: 14, color: Color(0xFF2196F3))),
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
                      Text('Lent', style: TextStyle(fontSize: 14, color: Color(0xFF2196F3))),
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
                  child: Text('Passer la parole (5 min)', style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
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
            const Text('📖 Lis et réponds',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF4CAF50))),
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
            const Text('✍️ Écris ta réponse en anglais',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFFF8F00))),
            const SizedBox(height: 8),
            Text(question.emoji, style: const TextStyle(fontSize: 40)),
            const SizedBox(height: 4),
            Text(question.question,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
              textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.volume_up_rounded, color: Color(0xFF2196F3), size: 20),
                  onPressed: () => _audio.speak(question.answer),
                ),
                IconButton(
                  icon: const Text('🐢', style: TextStyle(fontSize: 18)),
                  onPressed: () => _audio.speakSlow(question.answer),
                ),
              ],
            ),
          ],
        );

      case QuestionType.wordOrder:
        return Column(
          children: [
            const Text('Traduis en anglais',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF333333))),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1CB0F6).withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(child: Text('👩‍🏫', style: TextStyle(fontSize: 28))),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _audio.speak(question.question),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE0E0E0), width: 1.5),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4, offset: const Offset(0, 2))],
                      ),
                      child: Row(children: [
                        const Icon(Icons.volume_up_rounded, color: Color(0xFF1CB0F6), size: 20),
                        const SizedBox(width: 8),
                        Expanded(child: Text(question.question,
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Color(0xFF333333)))),
                      ]),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );

      case QuestionType.matchPairs:
        return const Column(
          children: [
            Text('🔗 Trouve les paires',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
              textAlign: TextAlign.center),
            SizedBox(height: 4),
            Text('Appuie sur un mot, puis sur son équivalent',
              style: TextStyle(fontSize: 15, color: Colors.black54),
              textAlign: TextAlign.center),
          ],
        );

      case QuestionType.fillBlank:
        return Column(
          children: [
            const Text('📝 Complète la phrase',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFFF8F00))),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFF8F00).withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFF8F00).withValues(alpha: 0.2)),
              ),
              child: Text(question.question,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF333333), height: 1.5),
                textAlign: TextAlign.center),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.volume_up_rounded, color: Color(0xFF2196F3), size: 20),
                  onPressed: () => _audio.speak(question.question.replaceAll('___', question.answer)),
                ),
              ],
            ),
          ],
        );

      case QuestionType.conversation:
        final lines = question.question.split('\n');
        return Column(
          children: [
            const Text('Complète la conversation',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF333333))),
            const SizedBox(height: 16),
            // Character + speech bubble
            for (final line in lines)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF7C4DFF).withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(child: Text('👩‍🏫', style: TextStyle(fontSize: 22))),
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(4), topRight: Radius.circular(16),
                            bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16),
                          ),
                          border: Border.all(color: const Color(0xFFE0E0E0), width: 1.5),
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4, offset: const Offset(0, 2))],
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          GestureDetector(
                            onTap: () => _audio.speak(line.replaceAll(RegExp(r'[🧑🤖]\s*'), '')),
                            child: const Icon(Icons.volume_up_rounded, color: Color(0xFF1CB0F6), size: 18),
                          ),
                          const SizedBox(width: 8),
                          Flexible(child: Text(line,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF333333)))),
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
            // Your turn slot
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF58CC02).withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(child: Text('🧒', style: TextStyle(fontSize: 22))),
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF58CC02).withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFF58CC02).withValues(alpha: 0.3), width: 1.5),
                      ),
                      child: const Text('À toi...',
                        style: TextStyle(fontSize: 16, color: Color(0xFF58CC02), fontStyle: FontStyle.italic, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );

      case QuestionType.listenType:
        return Column(
          children: [
            const Text('Écris ce que tu entends',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF333333))),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1CB0F6).withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(child: Text('👩‍🏫', style: TextStyle(fontSize: 28))),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE0E0E0), width: 1.5),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4, offset: const Offset(0, 2))],
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    GestureDetector(
                      onTap: () => _audio.speak(question.answer),
                      child: Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1CB0F6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.volume_up_rounded, size: 26, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () => _audio.speakSlow(question.answer),
                      child: Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1CB0F6).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.slow_motion_video_rounded, size: 26, color: Color(0xFF1CB0F6)),
                      ),
                    ),
                  ]),
                ),
              ],
            ),
          ],
        );

      case QuestionType.multipleChoice:
        return Column(
          children: [
            Text(question.question,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
              textAlign: TextAlign.center),
            const SizedBox(height: 12),
            Text(question.emoji, style: const TextStyle(fontSize: 72)),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ModernButton(text: '🔊 Écouter', onPressed: _speakQuestion, backgroundColor: const Color(0xFF2196F3), fontSize: 14, isSmall: true),
                const SizedBox(width: 8),
                ModernButton(text: '🐢 Lent', onPressed: () => _audio.speakSlow(_questionQueue[_queueIndex].question), backgroundColor: const Color(0xFF2196F3), fontSize: 14, isSmall: true),
                const SizedBox(width: 8),
                ModernButton(text: '💡 Indice', onPressed: _showHint, backgroundColor: const Color(0xFFFF9800), fontSize: 14, isSmall: true),
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
              child: Text('Tu as dit : "$_spokenText"',
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
            _isListening ? 'J\'\u00e9coute... appuie pour arr\u00eater' : 'Appuie sur le micro et dis le mot !',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          if (!_speechAvailable) ...[
            const SizedBox(height: 12),
            const Text('🎤 Micro non disponible', style: TextStyle(fontSize: 12, color: Colors.red)),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _evaluateSpokenAnswer(question.answer),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF9C27B0), foregroundColor: Colors.white),
              child: const Text('Passer (je l\'ai dit) ▶'),
            ),
          ],
        ],
      );
    }

    // ── Match pairs: two-column layout (FR left, EN right) ──
    if (question.type == QuestionType.matchPairs) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left column: French words
          Expanded(child: Column(
            children: [
              for (final item in _leftPairItems) _buildPairTile(item),
            ],
          )),
          const SizedBox(width: 10),
          // Right column: English words
          Expanded(child: Column(
            children: [
              for (final item in _rightPairItems) _buildPairTile(item),
            ],
          )),
        ],
      );
    }

    // ── Word tiles: wordOrder & listenType (Duolingo style with drag & drop) ──
    if (question.type == QuestionType.wordOrder || question.type == QuestionType.listenType) {
      final expectedWords = question.answer.split(' ').where((w) => w.trim().isNotEmpty).length;
      return Column(
        children: [
          // Sentence build area — DragTarget that accepts words from pool
          DragTarget<String>(
            onWillAcceptWithDetails: (_) => !_answered,
            onAcceptWithDetails: (details) {
              setState(() {
                final word = details.data;
                final idx = _wordPool.indexOf(word);
                if (idx != -1) {
                  _selectedWords.add(_wordPool.removeAt(idx));
                }
              });
            },
            builder: (context, candidateData, rejectedData) {
              final isHovering = candidateData.isNotEmpty;
              return Container(
                width: double.infinity,
                constraints: const BoxConstraints(minHeight: 52),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: BoxDecoration(
                  color: isHovering ? const Color(0xFF1CB0F6).withValues(alpha: 0.06) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (int i = 0; i < _selectedWords.length; i++)
                          _buildDraggableSelectedWord(i),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: double.infinity, height: 2,
                      color: isHovering ? const Color(0xFF1CB0F6) : (_selectedWords.isEmpty ? Colors.grey.shade300 : Colors.grey.shade200),
                    ),
                    if (_selectedWords.length < expectedWords) ...[
                      const SizedBox(height: 10),
                      Container(width: double.infinity, height: 2, color: Colors.grey.shade200),
                    ],
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          // Word pool tiles — DragTarget that accepts words back from sentence
          Expanded(
            child: DragTarget<_SentenceWord>(
              onWillAcceptWithDetails: (_) => !_answered,
              onAcceptWithDetails: (details) {
                setState(() {
                  final idx = details.data.index;
                  if (idx >= 0 && idx < _selectedWords.length) {
                    _wordPool.add(_selectedWords.removeAt(idx));
                  }
                });
              },
              builder: (context, candidateData, rejectedData) {
                return SingleChildScrollView(
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    alignment: WrapAlignment.center,
                    children: [
                      for (int i = 0; i < _wordPool.length; i++)
                        _buildDraggablePoolWord(i),
                    ],
                  ),
                );
              },
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
              hintText: 'Écris ta réponse...',
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 18),
              filled: true, fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFFF8F00), width: 2)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade300, width: 2)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFFF8F00), width: 2)),
            ),
            onSubmitted: (_) => _submitCurrentExercise(question),
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
          text: _shuffledOptions[index],
          onPressed: () => _selectOption(index),
          state: _answerStates[index],
        );
      },
    );
  }
}

/// Data class for dragging a word from the sentence area back to the pool
class _SentenceWord {
  final String word;
  final int index;
  _SentenceWord(this.word, this.index);
}
