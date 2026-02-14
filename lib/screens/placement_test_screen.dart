import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/lesson_content.dart';
import '../models/learning_path.dart';

class PlacementTestScreen extends StatefulWidget {
  const PlacementTestScreen({super.key});

  @override
  State<PlacementTestScreen> createState() => _PlacementTestScreenState();
}

class _PlacementTestScreenState extends State<PlacementTestScreen> {
  int _currentIndex = 0;
  int _correctCount = 0;
  bool _answered = false;
  String _feedback = '';
  int? _selectedOptionIndex;
  final List<bool> _results = [];
  List<String> _shuffledOptions = [];

  // Word-order state
  List<String> _wordPool = [];
  List<String> _selectedWords = [];

  late final List<_PlacementQuestion> _questions;

  @override
  void initState() {
    super.initState();
    _questions = _buildPlacementQuestions();
    _initCurrentQuestion();
    _speakIfNeeded();
  }

  void _initCurrentQuestion() {
    final q = _questions[_currentIndex].question;
    _selectedWords = [];
    _selectedOptionIndex = null;
    if (q.type == QuestionType.wordOrder) {
      _wordPool = List<String>.from(q.options)..shuffle();
      _shuffledOptions = [];
    } else {
      _wordPool = [];
      _shuffledOptions = List<String>.from(q.options)..shuffle();
    }
  }

  void _speakIfNeeded() {
    final q = _questions[_currentIndex].question;
    if (q.type == QuestionType.listening) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          Provider.of<AppState>(context, listen: false).audioService.speak(q.answer);
        }
      });
    }
  }

  List<_PlacementQuestion> _buildPlacementQuestions() {
    final questions = [
      // ── A1: Basics ──
      _PlacementQuestion(
        question: Question(question: "Comment dit-on « bonjour » ?", answer: 'hello', options: ['hello', 'goodbye', 'sorry'], emoji: '👋'),
        level: 'A1',
      ),
      _PlacementQuestion(
        question: Question(question: 'Bonjour', answer: 'hello', options: ['hello', 'hi', 'good', 'cat', 'the'], emoji: '🧩', type: QuestionType.wordOrder),
        level: 'A1',
      ),
      _PlacementQuestion(
        question: Question(question: 'Écoute et choisis le bon mot', answer: 'blue', options: ['blue', 'red', 'green'], emoji: '🎧', type: QuestionType.listening),
        level: 'A1',
      ),
      _PlacementQuestion(
        question: Question(question: 'The sky is ___.', answer: 'blue', options: ['blue', 'cat', 'happy'], emoji: '📝', type: QuestionType.fillBlank),
        level: 'A1',
      ),
      _PlacementQuestion(
        question: Question(question: '🧑 Hello! How are you?', answer: "I'm fine, thank you!", options: ["I'm fine, thank you!", "The cat is blue.", "It's Monday."], emoji: '💬', type: QuestionType.conversation),
        level: 'A1',
      ),
      _PlacementQuestion(
        question: Question(question: 'Je suis un garçon', answer: 'I am a boy', options: ['I', 'am', 'a', 'boy', 'cat', 'the'], emoji: '🧩', type: QuestionType.wordOrder),
        level: 'A1',
      ),

      // ── A2: Vocabulary ──
      _PlacementQuestion(
        question: Question(question: "Comment dit-on « eau » ?", answer: 'water', options: ['water', 'bread', 'milk'], emoji: '💧'),
        level: 'A2',
      ),
      _PlacementQuestion(
        question: Question(question: "J'aime le lait", answer: 'I like milk', options: ['I', 'like', 'milk', 'water', 'the', 'is'], emoji: '🧩', type: QuestionType.wordOrder),
        level: 'A2',
      ),
      _PlacementQuestion(
        question: Question(question: 'Écoute et choisis le bon mot', answer: 'banana', options: ['banana', 'apple', 'orange'], emoji: '🎧', type: QuestionType.listening),
        level: 'A2',
      ),
      _PlacementQuestion(
        question: Question(question: 'I drink ___ when I am thirsty.', answer: 'water', options: ['water', 'bread', 'dog'], emoji: '📝', type: QuestionType.fillBlank),
        level: 'A2',
      ),
      _PlacementQuestion(
        question: Question(question: '🧑 Do you have a pet?', answer: 'Yes, I have a dog!', options: ['Yes, I have a dog!', 'The sky is blue.', 'Good morning!'], emoji: '🐶', type: QuestionType.conversation),
        level: 'A2',
      ),
      _PlacementQuestion(
        question: Question(question: 'Elle aime manger des pommes', answer: 'She likes to eat apples', options: ['She', 'likes', 'to', 'eat', 'apples', 'drink', 'cars'], emoji: '🧩', type: QuestionType.wordOrder),
        level: 'A2',
      ),
    ];
    questions.shuffle();
    return questions;
  }

  void _selectAnswer(int index) {
    if (_answered) return;
    final question = _questions[_currentIndex];
    final selectedAnswer = _shuffledOptions[index];
    final isCorrect = selectedAnswer.toLowerCase() == question.question.answer.toLowerCase();

    setState(() {
      _answered = true;
      _selectedOptionIndex = index;
      _results.add(isCorrect);
      if (isCorrect) {
        _correctCount++;
        _feedback = '🌟 Bravo !';
        Provider.of<AppState>(context, listen: false).audioService.speakCheer();
      } else {
        _feedback = '💡 La réponse est "${question.question.answer}"';
      }
    });
  }

  void _goToNext() {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _answered = false;
        _feedback = '';
      });
      _initCurrentQuestion();
      _speakIfNeeded();
    } else {
      _finishTest();
    }
  }

  void _checkWordOrder() {
    if (_answered) return;
    final question = _questions[_currentIndex];
    final builtSentence = _selectedWords.join(' ');
    final isCorrect = builtSentence.toLowerCase() == question.question.answer.toLowerCase();

    setState(() {
      _answered = true;
      _results.add(isCorrect);
      if (isCorrect) {
        _correctCount++;
        _feedback = '🌟 Phrase parfaite !';
        Provider.of<AppState>(context, listen: false).audioService.speakCheer();
      } else {
        _feedback = '💡 La réponse est "${question.question.answer}"';
      }
    });
  }

  void _finishTest() {
    final appState = Provider.of<AppState>(context, listen: false);
    Set<String> unitsToSkip = {};

    final a1Correct = _countCorrectForLevel('A1');
    final a2Correct = _countCorrectForLevel('A2');
    final totalCorrect = a1Correct + a2Correct;

    // Proportional placement across all available levels
    // Levels ordered: A1-, A1, A1+, A2-, A2, A2+
    final allLevels = LearningPath.getSections().map((s) => s.cefrLevel).toList();
    String placedLevel;
    List<String> levelsToSkip = [];

    if (totalCorrect <= 2) {
      // Very low score → absolute beginner
      placedLevel = allLevels.isNotEmpty ? allLevels.first : 'A1-';
    } else if (a1Correct >= 3 && a2Correct < 2) {
      // A1 mastered, A2 weak → place at A1+ (skip A1- and A1)
      placedLevel = 'A1+';
      levelsToSkip = ['A1-', 'A1'];
    } else if (a1Correct >= 3 && a2Correct >= 2 && a2Correct < 4) {
      // A1 mastered, A2 partial → place at A2- (skip A1-, A1, A1+)
      placedLevel = 'A2-';
      levelsToSkip = ['A1-', 'A1', 'A1+'];
    } else if (a1Correct >= 3 && a2Correct >= 4 && a2Correct < 6) {
      // A1 mastered, A2 mostly correct → place at A2 (skip through A2-)
      placedLevel = 'A2';
      levelsToSkip = ['A1-', 'A1', 'A1+', 'A2-'];
    } else if (a1Correct >= 3 && a2Correct >= 6) {
      // Perfect or near-perfect → place at A2+ (skip through A2)
      placedLevel = 'A2+';
      levelsToSkip = ['A1-', 'A1', 'A1+', 'A2-', 'A2'];
    } else if (a1Correct >= 1) {
      // Some A1 correct → place at A1 (skip A1-)
      placedLevel = 'A1';
      levelsToSkip = ['A1-'];
    } else {
      placedLevel = 'A1-';
    }

    // Skip all units in the levels below the placed level
    for (final section in LearningPath.getSections()) {
      if (levelsToSkip.contains(section.cefrLevel)) {
        for (final chapter in section.chapters) {
          for (final unit in chapter.units) {
            unitsToSkip.add(unit.id);
          }
        }
      }
    }

    appState.completePlacement(placedLevel, unitsToSkip);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final name = appState.profile.name;
        final emoji = appState.profile.avatarEmoji;
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 60)),
              const SizedBox(height: 8),
              Text('Bienvenue, $name !', textAlign: TextAlign.center, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('$_correctCount/${_questions.length} bonnes réponses', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF58CC02).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF58CC02).withValues(alpha: 0.3)),
                ),
                child: Column(
                  children: [
                    const Text('Ton niveau de départ :', style: TextStyle(fontSize: 14, color: Colors.grey)),
                    const SizedBox(height: 4),
                    Text(placedLevel, style: const TextStyle(fontSize: 42, fontWeight: FontWeight.w900, color: Color(0xFF58CC02))),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                unitsToSkip.isEmpty ? "On commence depuis le début ! \u{1F680}" : "On a passé les leçons faciles pour toi ! \u{1F3AF}",
                style: const TextStyle(fontSize: 15), textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () { Navigator.pop(context); Navigator.pushReplacementNamed(context, '/'); },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF58CC02), foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('C\'est parti ! \u{1F389}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              ),
            ),
          ],
        );
      },
    );
  }

  int _countCorrectForLevel(String level) {
    int count = 0;
    for (int i = 0; i < _results.length; i++) {
      if (_questions[i].level == level && _results[i]) count++;
    }
    return count;
  }

  Widget _buildQuestionArea(_PlacementQuestion pq) {
    final q = pq.question;
    switch (q.type) {
      case QuestionType.listening:
        return Column(children: [
          GestureDetector(
            onTap: () => Provider.of<AppState>(context, listen: false).audioService.speak(q.answer),
            child: Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFF2196F3).withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF2196F3), width: 3),
              ),
              child: const Icon(Icons.volume_up_rounded, size: 50, color: Color(0xFF2196F3)),
            ),
          ),
          const SizedBox(height: 12),
          const Text('🎧 Quel mot entends-tu ?', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF333333)), textAlign: TextAlign.center),
        ]);
      case QuestionType.fillBlank:
        return Column(children: [
          const Text('📝 Complète la phrase', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFFF8F00))),
          const SizedBox(height: 12),
          Container(
            width: double.infinity, padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFF8F00).withValues(alpha: 0.06), borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFF8F00).withValues(alpha: 0.2)),
            ),
            child: Text(q.question, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF333333), height: 1.5), textAlign: TextAlign.center),
          ),
        ]);
      case QuestionType.conversation:
        final lines = q.question.split('\n');
        return Column(children: [
          const Text('Complète la conversation', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF333333))),
          const SizedBox(height: 14),
          for (final line in lines) Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(width: 36, height: 36,
                decoration: BoxDecoration(color: const Color(0xFF7C4DFF).withValues(alpha: 0.12), shape: BoxShape.circle),
                child: const Center(child: Text('👩‍🏫', style: TextStyle(fontSize: 20)))),
              const SizedBox(width: 8),
              Flexible(child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(color: Colors.white, borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4), topRight: Radius.circular(14), bottomLeft: Radius.circular(14), bottomRight: Radius.circular(14)),
                  border: Border.all(color: const Color(0xFFE0E0E0), width: 1.5)),
                child: Text(line, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF333333))))),
            ]),
          ),
          Padding(padding: const EdgeInsets.only(top: 4), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(width: 36, height: 36,
              decoration: BoxDecoration(color: const Color(0xFF58CC02).withValues(alpha: 0.12), shape: BoxShape.circle),
              child: const Center(child: Text('�', style: TextStyle(fontSize: 20)))),
            const SizedBox(width: 8),
            Flexible(child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(color: const Color(0xFF58CC02).withValues(alpha: 0.06), borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF58CC02).withValues(alpha: 0.3), width: 1.5)),
              child: const Text('À toi...', style: TextStyle(fontSize: 16, color: Color(0xFF58CC02), fontStyle: FontStyle.italic, fontWeight: FontWeight.w600)))),
          ])),
        ]);
      case QuestionType.reading:
        final parts = q.question.split(' — ');
        final sentence = parts.length > 1 ? parts[0].replaceFirst('Read: ', '') : q.question;
        final comprehensionQ = parts.length > 1 ? parts[1] : '';
        return Column(children: [
          const Text('📖 Lis et réponds', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF4CAF50))),
          const SizedBox(height: 8),
          Container(
            width: double.infinity, padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withValues(alpha: 0.06), borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF4CAF50).withValues(alpha: 0.2)),
            ),
            child: Text(sentence, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF333333), height: 1.4), textAlign: TextAlign.center),
          ),
          if (comprehensionQ.isNotEmpty) ...[const SizedBox(height: 12), Text(comprehensionQ, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF333333)), textAlign: TextAlign.center)],
        ]);
      case QuestionType.wordOrder:
        return Column(children: [
          const Text('Traduis en anglais', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF333333))),
          const SizedBox(height: 12),
          Container(
            width: double.infinity, padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: const Color(0xFF1CB0F6).withValues(alpha: 0.08), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFF1CB0F6).withValues(alpha: 0.3))),
            child: Row(children: [
              const Icon(Icons.volume_up_rounded, color: Color(0xFF1CB0F6), size: 22),
              const SizedBox(width: 10),
              Expanded(child: Text(q.question, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF333333)))),
            ]),
          ),
        ]);
      default:
        return Column(children: [
          Text(q.emoji, style: const TextStyle(fontSize: 64)),
          const SizedBox(height: 12),
          Text(q.question, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF333333)), textAlign: TextAlign.center),
        ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final q = _questions[_currentIndex];
    final isOptionType = q.question.type == QuestionType.multipleChoice || q.question.type == QuestionType.listening || q.question.type == QuestionType.reading || q.question.type == QuestionType.fillBlank || q.question.type == QuestionType.conversation;

    final appState = Provider.of<AppState>(context, listen: false);
    final themeColor = Color(appState.profile.favoriteColorValue);
    final userName = appState.profile.name;

    return Scaffold(
      backgroundColor: themeColor.withValues(alpha: 0.04),
      appBar: AppBar(
        title: Text('${_currentIndex + 1}/${_questions.length}', style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: themeColor,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: (_currentIndex + 1) / _questions.length,
                      minHeight: 8,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(themeColor),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Voyons ce que tu sais, $userName ! 🔍', style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                  const SizedBox(height: 20),
                  _buildQuestionArea(q),
                  const SizedBox(height: 20),
                  if (q.question.type == QuestionType.wordOrder) ...[
                    Container(
                      width: double.infinity, constraints: const BoxConstraints(minHeight: 56), padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: _answered ? (_feedback.startsWith('🌟') ? const Color(0xFF58CC02) : const Color(0xFFFF4B4B)) : Colors.grey.shade300, width: 2)),
                      child: Wrap(spacing: 8, runSpacing: 8, children: [
                        for (int i = 0; i < _selectedWords.length; i++)
                          GestureDetector(
                            onTap: _answered ? null : () => setState(() => _wordPool.add(_selectedWords.removeAt(i))),
                            child: Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(color: const Color(0xFF3366CC).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFF3366CC), width: 1.5)),
                              child: Text(_selectedWords[i], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF3366CC)))),
                          ),
                        if (_selectedWords.isEmpty) Text('Appuie sur les mots ci-dessous...', style: TextStyle(fontSize: 16, color: Colors.grey.shade400, fontStyle: FontStyle.italic)),
                      ]),
                    ),
                    const SizedBox(height: 16),
                    Expanded(child: SingleChildScrollView(child: Wrap(spacing: 10, runSpacing: 10, alignment: WrapAlignment.center, children: [
                      for (int i = 0; i < _wordPool.length; i++)
                        GestureDetector(
                          onTap: _answered ? null : () => setState(() => _selectedWords.add(_wordPool.removeAt(i))),
                          child: Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey.shade300, width: 1.5), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 4, offset: const Offset(0, 2))]),
                            child: Text(_wordPool[i], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF333333)))),
                        ),
                    ]))),
                    if (!_answered) SizedBox(width: double.infinity, child: ElevatedButton(
                      onPressed: _selectedWords.isEmpty ? null : _checkWordOrder,
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF58CC02), foregroundColor: Colors.white, disabledBackgroundColor: Colors.grey.shade300, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                      child: const Text('VÉRIFIER', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: 0.8)),
                    )),
                  ] else if (isOptionType) ...[
                    Expanded(child: ListView.separated(
                      itemCount: _shuffledOptions.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        Color bg = Colors.white;
                        Color border = Colors.grey.shade300;
                        Color textCol = const Color(0xFF333333);
                        IconData? icon;
                        if (_answered && _selectedOptionIndex != null) {
                          final isCorrect = _shuffledOptions[index].toLowerCase() == q.question.answer.toLowerCase();
                          if (isCorrect) { bg = const Color(0xFFD7FFB8); border = const Color(0xFF58CC02); textCol = const Color(0xFF58CC02); icon = Icons.check_circle_rounded; }
                          else if (index == _selectedOptionIndex) { bg = const Color(0xFFFFDFE0); border = const Color(0xFFFF4B4B); textCol = const Color(0xFFFF4B4B); icon = Icons.cancel_rounded; }
                        }
                        return GestureDetector(
                          onTap: _answered ? null : () => _selectAnswer(index),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16), border: Border.all(color: border, width: 2.5)),
                            child: Row(children: [
                              Expanded(child: Text(_shuffledOptions[index], style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: textCol), textAlign: TextAlign.center)),
                              if (icon != null) Icon(icon, color: border, size: 26),
                            ]),
                          ),
                        );
                      },
                    )),
                  ],
                ],
              ),
            ),
          ),
          // Duolingo-style correction panel
          if (_answered && _feedback.isNotEmpty) _buildCorrectionPanel(),
        ],
      ),
    );
  }

  Widget _buildCorrectionPanel() {
    final isCorrect = _feedback.startsWith('🌟');
    final bg = isCorrect ? const Color(0xFFD7FFB8) : const Color(0xFFFFDFE0);
    final border = isCorrect ? const Color(0xFF58CC02) : const Color(0xFFFF4B4B);
    final textColor = isCorrect ? const Color(0xFF58CC02) : const Color(0xFFFF4B4B);
    final icon = isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded;

    return Positioned(
      left: 0, right: 0, bottom: 0,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 1.0, end: 0.0),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) => Transform.translate(offset: Offset(0, value * 200), child: child),
        child: SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [BoxShadow(color: border.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, -4))],
            ),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Row(children: [
                Icon(icon, color: textColor, size: 32),
                const SizedBox(width: 12),
                Expanded(child: Text(_feedback, style: TextStyle(color: textColor, fontWeight: FontWeight.w800, fontSize: 16))),
              ]),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity, height: 52,
                child: ElevatedButton(
                  onPressed: _goToNext,
                  style: ElevatedButton.styleFrom(backgroundColor: border, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  child: const Text('CONTINUER', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 1.0)),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

class _PlacementQuestion {
  final Question question;
  final String level;

  _PlacementQuestion({required this.question, required this.level});
}
