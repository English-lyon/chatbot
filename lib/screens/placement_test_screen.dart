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
  final List<bool> _results = []; // track correct/wrong per question

  // Word-order state
  List<String> _wordPool = [];
  List<String> _selectedWords = [];

  // Mix of questions from different levels to assess the child
  late final List<_PlacementQuestion> _questions;

  @override
  void initState() {
    super.initState();
    _questions = _buildPlacementQuestions();
    _initCurrentQuestion();
    _speakIfAudio();
  }

  void _initCurrentQuestion() {
    final q = _questions[_currentIndex].question;
    _selectedWords = [];
    if (q.type == QuestionType.wordOrder) {
      _wordPool = List<String>.from(q.options)..shuffle();
    } else {
      _wordPool = [];
    }
  }

  void _speakIfAudio() {
    final q = _questions[_currentIndex];
    if (q.question.isAudio) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          final appState = Provider.of<AppState>(context, listen: false);
          appState.audioService.speak(q.question.answer);
        }
      });
    }
  }

  List<_PlacementQuestion> _buildPlacementQuestions() {
    return [
      // A1: Multiple choice
      _PlacementQuestion(
        question: Question(
          question: "How do you say 'bonjour' in English?",
          answer: 'hello', options: ['hello', 'goodbye', 'sorry'], emoji: '👋',
        ),
        level: 'A1',
      ),
      // A1: Listening — hear "blue"
      _PlacementQuestion(
        question: Question(
          question: 'Listen and pick the right word',
          answer: 'blue', options: ['blue', 'red', 'green'], emoji: '🔊',
          type: QuestionType.listening,
        ),
        level: 'A1',
      ),
      // A1: Reading comprehension
      _PlacementQuestion(
        question: Question(
          question: 'Read: "I have two eyes." — How many eyes?',
          answer: 'two', options: ['two', 'one', 'three'], emoji: '�',
          type: QuestionType.reading,
        ),
        level: 'A1',
      ),
      // A2: Multiple choice
      _PlacementQuestion(
        question: Question(
          question: 'What is the king of the jungle?',
          answer: 'lion', options: ['lion', 'tiger', 'bear'], emoji: '🦁',
        ),
        level: 'A2',
      ),
      // A2: Listening — hear "banana"
      _PlacementQuestion(
        question: Question(
          question: 'Listen and pick the right word',
          answer: 'banana', options: ['banana', 'apple', 'orange'], emoji: '🔊',
          type: QuestionType.listening,
        ),
        level: 'A2',
      ),
      // A2: Reading comprehension
      _PlacementQuestion(
        question: Question(
          question: 'Read: "My heart is in my chest." — What is in your chest?',
          answer: 'heart', options: ['heart', 'brain', 'stomach'], emoji: '📖',
          type: QuestionType.reading,
        ),
        level: 'A2',
      ),
      // A1: Word order — build a sentence (Duolingo-style)
      _PlacementQuestion(
        question: Question(
          question: 'Build the sentence:',
          answer: 'I am a boy',
          options: ['I', 'am', 'a', 'boy', 'cat', 'the'],
          emoji: '🧩',
          type: QuestionType.wordOrder,
        ),
        level: 'A1',
      ),
      // A2: Word order — build a sentence (Duolingo-style)
      _PlacementQuestion(
        question: Question(
          question: 'Build the sentence:',
          answer: 'She likes to eat apples',
          options: ['She', 'likes', 'to', 'eat', 'apples', 'drink', 'cars'],
          emoji: '🧩',
          type: QuestionType.wordOrder,
        ),
        level: 'A2',
      ),
    ];
  }

  void _selectAnswer(int index) {
    if (_answered) return;

    final question = _questions[_currentIndex];
    final selectedAnswer = question.question.options[index];
    final isCorrect =
        selectedAnswer.toLowerCase() == question.question.answer.toLowerCase();

    setState(() {
      _answered = true;
      _selectedOptionIndex = index;
      _results.add(isCorrect);
      if (isCorrect) {
        _correctCount++;
        _feedback = '🌟 Great job!';
      } else {
        _feedback = '💡 The answer is "${question.question.answer}"';
      }
    });

    Future.delayed(const Duration(milliseconds: 1800), () {
      if (!mounted) return;
      _goToNextOrFinish();
    });
  }

  void _goToNextOrFinish() {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _answered = false;
        _feedback = '';
        _selectedOptionIndex = null;
      });
      _initCurrentQuestion();
      _speakIfAudio();
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
        _feedback = '🌟 Perfect sentence!';
      } else {
        _feedback = '💡 The answer is "${question.question.answer}"';
      }
    });

    Future.delayed(const Duration(milliseconds: 1800), () {
      if (!mounted) return;
      _goToNextOrFinish();
    });
  }

  void _finishTest() {
    final appState = Provider.of<AppState>(context, listen: false);

    // Determine placement based on score
    // A1 questions: indices 0-2, A2 questions: indices 3-5
    String placedLevel;
    Set<String> unitsToSkip = {};

    final a1Correct = _countCorrectForLevel('A1');
    final a2Correct = _countCorrectForLevel('A2');

    if (a1Correct >= 3 && a2Correct >= 3) {
      // Knows A2 level well → skip all A1-/A1/A1+ sections
      placedLevel = 'A2';
      final sections = LearningPath.getSections();
      for (final section in sections) {
        if (section.cefrLevel.startsWith('A1')) {
          for (final chapter in section.chapters) {
            for (final unit in chapter.units) {
              unitsToSkip.add(unit.id);
            }
          }
        }
      }
    } else if (a1Correct >= 3) {
      // Knows A1 basics → skip A1- section
      placedLevel = 'A1';
      final sections = LearningPath.getSections();
      for (final section in sections) {
        if (section.cefrLevel == 'A1-') {
          for (final chapter in section.chapters) {
            for (final unit in chapter.units) {
              unitsToSkip.add(unit.id);
            }
          }
        }
      }
    } else {
      // Beginner → start from the very beginning
      placedLevel = 'A1';
    }

    appState.completePlacement(placedLevel, unitsToSkip);

    // Show result dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final name = appState.profile.name;
        final emoji = appState.profile.avatarEmoji;
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            '$emoji Welcome, $name!',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 22),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Score: $_correctCount/${_questions.length}',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Your starting level:',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      placedLevel,
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                unitsToSkip.isEmpty
                    ? "Let's start from the beginning! 🚀"
                    : "We skipped some easy lessons for you! 🎯",
                style: const TextStyle(fontSize: 15),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                "Don't worry, we'll check your level regularly!",
                style: TextStyle(fontSize: 13, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3366CC),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  "Start Learning! 🎉",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
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
      if (_questions[i].level == level && _results[i]) {
        count++;
      }
    }
    return count;
  }

  @override
  Widget build(BuildContext context) {
    final q = _questions[_currentIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FF),
      appBar: AppBar(
        title: Text(
          'Question ${_currentIndex + 1}/${_questions.length}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF3366CC),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: (_currentIndex + 1) / _questions.length,
                  minHeight: 8,
                  backgroundColor: Colors.grey.shade200,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Level Test — Let\'s see what you know! 🔍',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 30),
              if (q.question.type == QuestionType.wordOrder) ...[
                const Text('🧩 Tap the words to build the sentence!',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF3366CC)),
                  textAlign: TextAlign.center),
                const SizedBox(height: 16),
              ] else if (q.question.type == QuestionType.listening) ...[
                GestureDetector(
                  onTap: () {
                    final appState = Provider.of<AppState>(context, listen: false);
                    appState.audioService.speak(q.question.answer);
                  },
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2196F3).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF2196F3), width: 3),
                    ),
                    child: const Icon(Icons.volume_up_rounded, size: 60, color: Color(0xFF2196F3)),
                  ),
                ),
                const SizedBox(height: 12),
                const Text('Tap to listen again', style: TextStyle(fontSize: 14, color: Color(0xFF2196F3))),
                const SizedBox(height: 16),
                const Text('🎧 What word do you hear?',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
                  textAlign: TextAlign.center),
              ] else if (q.question.type == QuestionType.reading) ...[
                () {
                  final parts = q.question.question.split(' — ');
                  final sentence = parts.length > 1 ? parts[0].replaceFirst('Read: ', '') : q.question.question;
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
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFF4CAF50).withValues(alpha: 0.2)),
                        ),
                        child: Text(sentence,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF333333), height: 1.4),
                          textAlign: TextAlign.center),
                      ),
                      if (comprehensionQ.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(comprehensionQ,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
                          textAlign: TextAlign.center),
                      ],
                    ],
                  );
                }(),
              ] else ...[
                Text(q.question.emoji, style: const TextStyle(fontSize: 80)),
                const SizedBox(height: 16),
                Text(q.question.question,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
                  textAlign: TextAlign.center),
              ],
              const SizedBox(height: 24),
              if (_feedback.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: _feedback.startsWith('🌟')
                        ? Colors.green.shade50
                        : Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _feedback,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _feedback.startsWith('🌟')
                          ? Colors.green.shade700
                          : Colors.orange.shade800,
                    ),
                  ),
                ),
              if (q.question.type == QuestionType.wordOrder) ...[
                // Built sentence area
                Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(minHeight: 56),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _answered
                        ? (_feedback.startsWith('🌟') ? Colors.green : Colors.red)
                        : Colors.grey.shade300, width: 2),
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
                        Text('Tap the words below...',
                          style: TextStyle(fontSize: 16, color: Colors.grey.shade400, fontStyle: FontStyle.italic)),
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
                        backgroundColor: const Color(0xFF4CAF50),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey.shade300,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('CHECK', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1)),
                    ),
                  ),
              ] else ...[
                Expanded(
                  child: ListView.separated(
                    itemCount: q.question.options.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      Color bgColor = Colors.white;
                      Color borderColor = Colors.grey.shade300;
                      if (_answered && _selectedOptionIndex != null) {
                        final isCorrect = q.question.options[index].toLowerCase() ==
                            q.question.answer.toLowerCase();
                        if (isCorrect) {
                          bgColor = Colors.green.shade50;
                          borderColor = Colors.green;
                        } else if (index == _selectedOptionIndex) {
                          bgColor = Colors.red.shade50;
                          borderColor = Colors.red;
                        }
                      }
                      return GestureDetector(
                        onTap: () => _selectAnswer(index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 20),
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: borderColor, width: 2),
                          ),
                          child: Center(
                            child: Text(
                              q.question.options[index].toUpperCase(),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF333333),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
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
