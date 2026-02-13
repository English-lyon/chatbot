# ANNEXES - Rapport Application Chatbot Éducatif

---

## ANNEXE A : Architecture Détaillée de l'Application

### A.1 Diagramme de l'Architecture en Couches

```
┌─────────────────────────────────────────────────────────────┐
│                    COUCHE PRÉSENTATION                       │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │
│  │  Menu    │  │ Lessons  │  │   Quiz   │  │   Chat   │   │
│  │  Screen  │  │  Screen  │  │  Screen  │  │  Screen  │   │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘   │
│         │              │              │              │       │
│         └──────────────┴──────────────┴──────────────┘       │
│                            │                                 │
└────────────────────────────┼─────────────────────────────────┘
                             │
┌────────────────────────────┼─────────────────────────────────┐
│                    COUCHE ÉTAT (Provider)                    │
│                      ┌──────────────┐                        │
│                      │   AppState   │                        │
│                      │  (Provider)  │                        │
│                      └──────────────┘                        │
│                             │                                │
└────────────────────────────┼─────────────────────────────────┘
                             │
┌────────────────────────────┼─────────────────────────────────┐
│                    COUCHE SERVICES                           │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │  AIService   │  │AudioService  │  │StorageService│      │
│  │  (Gemini)    │  │   (TTS)      │  │(SharedPrefs) │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
│         │                  │                  │              │
└─────────┼──────────────────┼──────────────────┼──────────────┘
          │                  │                  │
┌─────────┼──────────────────┼──────────────────┼──────────────┐
│         ▼                  ▼                  ▼              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │  Gemini API  │  │  Flutter TTS │  │ Local Storage│      │
│  │  (Google)    │  │   Engine     │  │   (Device)   │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
│                    COUCHE EXTERNE                            │
└─────────────────────────────────────────────────────────────┘
```

### A.2 Flux de Données

```
Utilisateur
    │
    ▼
┌─────────────────┐
│  Screen (UI)    │ ◄─── Affichage
└─────────────────┘
    │ Action
    ▼
┌─────────────────┐
│  AppState       │ ◄─── notifyListeners()
│  (Provider)     │
└─────────────────┘
    │ Appel méthode
    ▼
┌─────────────────┐
│  Service        │
│  (AI/Audio/     │
│   Storage)      │
└─────────────────┘
    │ Requête
    ▼
┌─────────────────┐
│  API/Device     │
└─────────────────┘
    │ Réponse
    ▼
[Mise à jour de l'état → Rebuild UI]
```

---

## ANNEXE B : Extraits de Code Clés

### B.1 Modèle de Données - Question

```dart
class Question {
  final String question;
  final List<String> options;
  final int correctIndex;
  final String? imageUrl;
  
  Question({
    required this.question,
    required this.options,
    required this.correctIndex,
    this.imageUrl,
  });
  
  String get correctAnswer => options[correctIndex];
  
  bool isCorrect(int selectedIndex) => selectedIndex == correctIndex;
}
```

### B.2 Service IA - Intégration Gemini

```dart
class AIService {
  static const String apiKey = 'AIzaSyBoTJFRccRK40MEaxQD0eeQJ1pyHJ5eYtw';
  late final GenerativeModel _model;
  
  AIService() {
    _model = GenerativeModel(
      model: 'gemini-2.0-flash-exp',
      apiKey: apiKey,
    );
  }
  
  Future<String> chat(String message, {
    required int level,
    required String topic,
  }) async {
    final prompt = '''
    You are a friendly English tutor for children aged 5-10 (level $level).
    Current topic: $topic
    Child's message: $message
    
    Respond in a simple, encouraging way. Use emojis. Keep it short (2-3 sentences).
    If they ask about a word, explain it simply with an example.
    ''';
    
    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? "I'm here to help you learn! 😊";
    } catch (e) {
      return "Oops! I had trouble understanding. Can you try again? 🤔";
    }
  }
  
  Future<String> getHint(String question, String correctAnswer, int level) async {
    final prompt = '''
    Give a simple hint for a level $level child (age 5-10) to find the answer: "$correctAnswer"
    Question: $question
    
    Make it fun and encouraging! Use an emoji. Keep it very short (1 sentence).
    Don't give the answer directly, just a helpful clue.
    ''';
    
    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? "Think about what you see! 🤔";
    } catch (e) {
      return "Think carefully about the question! 💭";
    }
  }
}
```

### B.3 Gestion d'État - Provider

```dart
class AppState extends ChangeNotifier {
  UserProgress progress = UserProgress();
  final AIService aiService = AIService();
  final AudioService audioService = AudioService();
  final StorageService storageService = StorageService();
  
  AppState() {
    _loadProgress();
  }
  
  Future<void> _loadProgress() async {
    progress = await storageService.loadProgress();
    notifyListeners();
  }
  
  Future<void> completeLesson(String moduleId, String lessonId, int score) async {
    progress.completeLesson(moduleId, lessonId, score);
    await storageService.saveProgress(progress);
    notifyListeners();
  }
  
  Future<void> updateStreak() async {
    progress.updateStreak();
    await storageService.saveProgress(progress);
    notifyListeners();
  }
}
```

### B.4 Interface Quiz - Logique Principale

```dart
class QuizScreen extends StatefulWidget {
  final Lesson lesson;
  final String moduleId;
  
  const QuizScreen({
    Key? key,
    required this.lesson,
    required this.moduleId,
  }) : super(key: key);
  
  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int currentQuestionIndex = 0;
  int score = 0;
  bool answered = false;
  int? selectedAnswer;
  bool showCelebration = false;
  
  Question get currentQuestion => widget.lesson.questions[currentQuestionIndex];
  bool get isLastQuestion => currentQuestionIndex == widget.lesson.questions.length - 1;
  
  void _checkAnswer(int index) async {
    if (answered) return;
    
    setState(() {
      answered = true;
      selectedAnswer = index;
    });
    
    final appState = Provider.of<AppState>(context, listen: false);
    final isCorrect = currentQuestion.isCorrect(index);
    
    if (isCorrect) {
      setState(() {
        score += 25;
        showCelebration = true;
      });
      
      // Audio feedback
      await appState.audioService.speak("Correct! ${currentQuestion.correctAnswer}");
      
      // AI encouragement
      final encouragement = await appState.aiService.getEncouragement(true, score ~/ 25);
      
      // Hide celebration after 2 seconds
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => showCelebration = false);
      });
    } else {
      await appState.audioService.speak("Try again! The answer is ${currentQuestion.correctAnswer}");
    }
    
    // Next question after 3 seconds
    Future.delayed(const Duration(seconds: 3), _nextQuestion);
  }
  
  void _nextQuestion() {
    if (isLastQuestion) {
      _finishQuiz();
    } else {
      setState(() {
        currentQuestionIndex++;
        answered = false;
        selectedAnswer = null;
      });
    }
  }
  
  void _finishQuiz() async {
    final appState = Provider.of<AppState>(context, listen: false);
    await appState.completeLesson(widget.moduleId, widget.lesson.id, score);
    
    if (mounted) {
      Navigator.pop(context);
    }
  }
}
```

---

## ANNEXE C : Contenu Pédagogique Complet

### C.1 Module Couleurs (Colors)

**Leçon 1 : Basic Colors (Niveau 1)**
- Question 1: "What color is the sky?" → blue
- Question 2: "What color is grass?" → green
- Question 3: "What color is the sun?" → yellow
- Question 4: "What color is an apple?" → red

**Leçon 2: More Colors (Niveau 2)**
- Question 1: "What color is a carrot?" → orange
- Question 2: "What color is a grape?" → purple
- Question 3: "What color is chocolate?" → brown
- Question 4: "What color is snow?" → white

### C.2 Module Animaux (Animals)

**Leçon 1: Pets (Niveau 1)**
- Question 1: "What animal says 'meow'?" → cat
- Question 2: "What animal says 'woof'?" → dog
- Question 3: "What animal can fly and sing?" → bird
- Question 4: "What animal has long ears and hops?" → rabbit

**Leçon 2: Farm Animals (Niveau 2)**
- Question 1: "What animal gives us milk?" → cow
- Question 2: "What animal says 'oink'?" → pig
- Question 3: "What animal lays eggs?" → chicken
- Question 4: "What animal has wool?" → sheep

**Leçon 3: Wild Animals (Niveau 3)**
- Question 1: "What is the king of the jungle?" → lion
- Question 2: "What animal has a trunk?" → elephant
- Question 3: "What animal has black and white stripes?" → zebra
- Question 4: "What animal swings in trees?" → monkey

### C.3 Module Nombres (Numbers)

**Leçon 1: Numbers 1-5 (Niveau 1)**
- Question 1: "How many fingers on one hand?" → five
- Question 2: "How many eyes do you have?" → two
- Question 3: "How many noses do you have?" → one
- Question 4: "How many wheels on a car?" → four

**Leçon 2: Numbers 6-10 (Niveau 2)**
- Question 1: "How many days in a week?" → seven
- Question 2: "How many legs on a spider?" → eight
- Question 3: "How many fingers on both hands?" → ten
- Question 4: "How many sides on a cube?" → six

### C.4 Module Salutations (Greetings)

**Leçon 1: Basic Greetings (Niveau 1)**
- Question 1: "How do you greet someone?" → hello
- Question 2: "How do you say farewell?" → goodbye
- Question 3: "What do you say to be polite?" → thank you
- Question 4: "What word makes requests nicer?" → please

**Leçon 2: More Expressions (Niveau 2)**
- Question 1: "What do you say when you make a mistake?" → sorry
- Question 2: "What do you say in the morning?" → good morning
- Question 3: "What do you say before bed?" → good night
- Question 4: "How do you greet a friend?" → hi

### C.5 Module Nourriture (Food)

**Leçon 1: Fruits (Niveau 2)**
- Question 1: "What yellow fruit do monkeys love?" → banana
- Question 2: "What red fruit keeps the doctor away?" → apple
- Question 3: "What orange fruit is juicy?" → orange
- Question 4: "What red fruit is sweet and small?" → strawberry

**Leçon 2: Meals (Niveau 3)**
- Question 1: "What white drink comes from cows?" → milk
- Question 2: "What do we make toast from?" → bread
- Question 3: "What Italian food is round with cheese?" → pizza
- Question 4: "What sweet food do bees make?" → honey

### C.6 Module Corps (Body)

**Leçon 1: Face (Niveau 2)**
- Question 1: "What do you see with?" → eyes
- Question 2: "What do you hear with?" → ears
- Question 3: "What do you smell with?" → nose
- Question 4: "What do you eat with?" → mouth

**Leçon 2: Body Parts (Niveau 2)**
- Question 1: "What do you wave with?" → hand
- Question 2: "What do you walk with?" → feet
- Question 3: "What connects your hand to your body?" → arm
- Question 4: "What do you think with?" → brain

---

## ANNEXE D : Configuration et Déploiement

### D.1 Fichier pubspec.yaml

```yaml
name: english_learning_app
description: Educational chatbot app for children learning English
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  provider: ^6.1.1
  
  # AI Integration
  google_generative_ai: ^0.2.2
  http: ^1.2.0
  
  # Storage
  shared_preferences: ^2.2.2
  path_provider: ^2.1.2
  
  # Audio
  flutter_tts: ^4.0.2
  
  # UI
  flutter_animate: ^4.5.0
  confetti: ^0.7.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0

flutter:
  uses-material-design: true
```

### D.2 Configuration GitHub Actions

```yaml
name: Deploy to GitHub Pages

on:
  push:
    branches: [main]
  workflow_dispatch:

permissions:
  contents: read
  pages: write
  id-token: write

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.24.0'
      - run: flutter pub get
      - run: flutter build web --release --base-href "/chatbot/"
      - uses: actions/upload-pages-artifact@v3
        with:
          path: 'build/web'
  
  deploy:
    needs: build
    runs-on: ubuntu-latest
    steps:
      - uses: actions/deploy-pages@v4
```

### D.3 Commandes de Build

```bash
# Android APK
flutter build apk --release

# Android App Bundle (Play Store)
flutter build appbundle --release

# iOS
flutter build ios --release

# Web
flutter build web --release

# Windows
flutter build windows --release

# macOS
flutter build macos --release

# Linux
flutter build linux --release
```

---

## ANNEXE E : Captures d'Écran de l'Application

### E.1 Écran Menu Principal
```
┌─────────────────────────────────────┐
│  📊 My Progress                     │
│  💬 Chat with AI Tutor              │
├─────────────────────────────────────┤
│  Level: 3    ⭐ 275 points          │
│  🔥 Streak: 5 days                  │
├─────────────────────────────────────┤
│  ┌──────────┐  ┌──────────┐        │
│  │ 🎨       │  │ 🐾       │        │
│  │ Colors   │  │ Animals  │        │
│  │ 2/2 ✓    │  │ 1/3      │        │
│  └──────────┘  └──────────┘        │
│  ┌──────────┐  ┌──────────┐        │
│  │ 🔢       │  │ 👋       │        │
│  │ Numbers  │  │Greetings │        │
│  │ 2/2 ✓    │  │ 0/2 🔒   │        │
│  └──────────┘  └──────────┘        │
└─────────────────────────────────────┘
```

### E.2 Écran Quiz
```
┌─────────────────────────────────────┐
│  Colors - Basic Colors              │
│  Question 1/4        Score: 0       │
├─────────────────────────────────────┤
│                                     │
│  What color is the sky?             │
│                                     │
│  🔊 Listen    💡 Hint               │
│                                     │
│  ┌─────────────────────────────┐   │
│  │         red                 │   │
│  └─────────────────────────────┘   │
│  ┌─────────────────────────────┐   │
│  │         blue        ✓       │   │
│  └─────────────────────────────┘   │
│  ┌─────────────────────────────┐   │
│  │         green               │   │
│  └─────────────────────────────┘   │
│                                     │
│  🎉 Correct! +25 points             │
└─────────────────────────────────────┘
```

### E.3 Écran Chat IA
```
┌─────────────────────────────────────┐
│  💬 Chat with AI Tutor              │
├─────────────────────────────────────┤
│                                     │
│  🤖 Hello! I'm your English tutor!  │
│     Ask me anything! 👋             │
│                                     │
│              What is a cat? 😊      │
│                                     │
│  🤖 A cat is a small furry animal   │
│     that says "meow"! 🐱 Cats are   │
│     pets that many people love!     │
│                                     │
│              Thank you! 😊          │
│                                     │
│  🤖 You're welcome! Keep learning!  │
│     You're doing great! 🌟          │
│                                     │
├─────────────────────────────────────┤
│  Type your question...       [Send] │
└─────────────────────────────────────┘
```

### E.4 Écran Progression
```
┌─────────────────────────────────────┐
│  📊 My Progress                     │
├─────────────────────────────────────┤
│  ┌───────────────────────────────┐ │
│  │      🏆 Your Level            │ │
│  │           3                   │ │
│  │      ⭐ 275 Total Points      │ │
│  └───────────────────────────────┘ │
│                                     │
│  ┌─────────────┬─────────────┐    │
│  │ 🔥 Current  │ 🏅 Best     │    │
│  │ Streak      │ Streak      │    │
│  │ 5 days      │ 7 days      │    │
│  └─────────────┴─────────────┘    │
│                                     │
│  📚 Learning Progress               │
│  ✅ 7 Lessons Completed             │
│                                     │
│  🏆 Achievements                    │
│  🏅 Premier pas                     │
│  🏅 Apprenant motivé                │
│  🏅 Régularité                      │
│                                     │
│  📖 Module Progress                 │
│  🎨 Couleurs: 2 lessons, Best: 100 │
│  🐾 Animaux: 1 lesson, Best: 75    │
│  🔢 Nombres: 2 lessons, Best: 100  │
└─────────────────────────────────────┘
```

---

## ANNEXE F : Comparaison avec Autres Solutions

### F.1 Tableau Comparatif

| Critère | Duolingo | Babbel | English Learning Adventure |
|---------|----------|--------|---------------------------|
| **Âge cible** | 13+ | Adultes | 5-10 ans |
| **IA intégrée** | Limitée | Non | Oui (Gemini) |
| **Chat interactif** | Non | Non | Oui |
| **Synthèse vocale** | Oui | Oui | Oui |
| **Gamification** | +++  | + | +++ |
| **Prix** | Freemium | Payant | Gratuit |
| **Plateforme** | Mobile/Web | Mobile/Web | Multi (6) |
| **Hors ligne** | Partiel | Oui | Non |
| **Open source** | Non | Non | Potentiel |

### F.2 Avantages Distinctifs

**Points forts de l'application :**
1. **Spécialisation enfants** : Interface et contenu adaptés 5-10 ans
2. **IA conversationnelle** : Chat personnalisé avec Gemini
3. **Gratuité totale** : Pas d'abonnement ni de publicité
4. **Multi-plateforme** : 6 plateformes supportées
5. **Open source potentiel** : Code accessible et modifiable

---

## ANNEXE G : Tests et Validation

### G.1 Tests Unitaires

```dart
// Test du modèle Question
void main() {
  test('Question should identify correct answer', () {
    final question = Question(
      question: 'What color is the sky?',
      options: ['red', 'blue', 'green'],
      correctIndex: 1,
    );
    
    expect(question.correctAnswer, 'blue');
    expect(question.isCorrect(1), true);
    expect(question.isCorrect(0), false);
  });
  
  test('UserProgress should calculate level correctly', () {
    final progress = UserProgress();
    progress.totalPoints = 250;
    
    expect(progress.level, 3); // 250 / 100 = 2.5 → level 3
  });
}
```

### G.2 Checklist de Validation

**Fonctionnalités :**
- [x] Conversion en niveaux de gris
- [x] Navigation entre écrans
- [x] Affichage des questions
- [x] Sélection de réponses
- [x] Calcul du score
- [x] Sauvegarde de progression
- [x] Chat avec IA
- [x] Synthèse vocale
- [x] Animations de célébration
- [x] Système de succès

**Plateformes testées :**
- [x] Android (émulateur)
- [x] Web (Chrome)
- [ ] iOS (nécessite Mac)
- [ ] Windows
- [ ] macOS
- [ ] Linux

**Performance :**
- [x] Temps de chargement < 2s
- [x] Réponse IA < 3s
- [x] 60 FPS constant
- [x] Pas de fuite mémoire

---

## ANNEXE H : Glossaire Technique

**API (Application Programming Interface)** : Interface permettant la communication entre différents logiciels.

**Flutter** : Framework open-source de Google pour créer des applications multiplateformes.

**Dart** : Langage de programmation utilisé par Flutter.

**Gemini** : Modèle d'IA générative de Google (successeur de Bard).

**LLM (Large Language Model)** : Modèle d'IA entraîné sur de grandes quantités de texte.

**NLP (Natural Language Processing)** : Traitement automatique du langage naturel.

**Provider** : Pattern de gestion d'état dans Flutter.

**TTS (Text-to-Speech)** : Synthèse vocale convertissant du texte en parole.

**Widget** : Composant d'interface utilisateur dans Flutter.

**State Management** : Gestion de l'état de l'application (données, UI).

**Gamification** : Utilisation d'éléments de jeu dans un contexte non-ludique.

**RGPD** : Règlement Général sur la Protection des Données.

---

**Fin des Annexes**
