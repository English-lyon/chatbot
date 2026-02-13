import 'dart:convert';

class UserProgress {
  int level;
  int totalPoints;
  List<String> completedLessons;
  Set<String> completedUnitIds;
  Map<String, double> unitAccuracyHistory; // unitId -> accuracy (0.0 to 1.0)
  int currentStreak;
  int bestStreak;
  String? lastActivity;
  Map<String, ModuleProgress> moduleProgress;
  List<String> achievements;

  UserProgress({
    this.level = 1,
    this.totalPoints = 0,
    List<String>? completedLessons,
    Set<String>? completedUnitIds,
    Map<String, double>? unitAccuracyHistory,
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.lastActivity,
    Map<String, ModuleProgress>? moduleProgress,
    List<String>? achievements,
  })  : completedLessons = completedLessons ?? [],
        completedUnitIds = completedUnitIds ?? {},
        unitAccuracyHistory = unitAccuracyHistory ?? {},
        moduleProgress = moduleProgress ?? {},
        achievements = achievements ?? [];

  String get cefrLevel {
    if (totalPoints < 200) return 'A1';
    if (totalPoints < 500) return 'A2';
    if (totalPoints < 1000) return 'B1';
    if (totalPoints < 2000) return 'B2';
    if (totalPoints < 3500) return 'C1';
    return 'C2';
  }

  void addPoints(int points) {
    totalPoints += points;
    checkLevelUp();
  }

  bool checkLevelUp() {
    bool leveledUp = false;
    while (totalPoints >= level * 100) {
      level++;
      leveledUp = true;
    }
    return leveledUp;
  }

  void completeLesson(String lessonId, String moduleId, int score) {
    if (!completedLessons.contains(lessonId)) {
      completedLessons.add(lessonId);
    }

    if (!moduleProgress.containsKey(moduleId)) {
      moduleProgress[moduleId] = ModuleProgress();
    }

    moduleProgress[moduleId]!.completed++;
    moduleProgress[moduleId]!.totalScore += score;
    if (score > moduleProgress[moduleId]!.bestScore) {
      moduleProgress[moduleId]!.bestScore = score;
    }

    updateStreak();
    addPoints(score);
    checkAchievements();
  }

  void completeUnit(String unitId, int score, {double accuracy = 1.0}) {
    completedUnitIds.add(unitId);
    unitAccuracyHistory[unitId] = accuracy;
    updateStreak();
    addPoints(score);
    checkAchievements();
  }

  double get recentAccuracy {
    if (unitAccuracyHistory.isEmpty) return 1.0;
    final values = unitAccuracyHistory.values.toList();
    final recent = values.length > 3 ? values.sublist(values.length - 3) : values;
    return recent.reduce((a, b) => a + b) / recent.length;
  }

  void updateStreak() {
    String today = DateTime.now().toIso8601String().split('T')[0];
    if (lastActivity == today) return;

    if (lastActivity != null) {
      final lastDate = DateTime.parse(lastActivity!);
      final todayDate = DateTime.parse(today);
      final diff = todayDate.difference(lastDate).inDays;

      if (diff == 1) {
        currentStreak++;
      } else {
        currentStreak = 1;
      }
    } else {
      currentStreak = 1;
    }

    if (currentStreak > bestStreak) {
      bestStreak = currentStreak;
    }
    lastActivity = today;
  }

  String? checkAchievements() {
    List<Map<String, dynamic>> achievementsList = [
      {
        'id': 'first_lesson',
        'name': 'Premier pas',
        'condition': completedLessons.isNotEmpty
      },
      {
        'id': 'five_lessons',
        'name': 'Apprenant motivé',
        'condition': completedLessons.length >= 5
      },
      {
        'id': 'ten_lessons',
        'name': 'Super élève',
        'condition': completedLessons.length >= 10
      },
      {'id': 'streak_3', 'name': 'Régularité', 'condition': currentStreak >= 3},
      {
        'id': 'streak_7',
        'name': 'Une semaine parfaite',
        'condition': currentStreak >= 7
      },
      {
        'id': 'level_5',
        'name': 'Niveau 5 atteint',
        'condition': level >= 5
      },
    ];

    for (var achievement in achievementsList) {
      if (achievement['condition'] as bool &&
          !achievements.contains(achievement['id'])) {
        achievements.add(achievement['id'] as String);
        return achievement['name'] as String;
      }
    }
    return null;
  }

  Map<String, dynamic> toJson() => {
        'level': level,
        'totalPoints': totalPoints,
        'completedLessons': completedLessons,
        'completedUnitIds': completedUnitIds.toList(),
        'unitAccuracyHistory': unitAccuracyHistory,
        'currentStreak': currentStreak,
        'bestStreak': bestStreak,
        'lastActivity': lastActivity,
        'moduleProgress': moduleProgress.map(
          (key, value) => MapEntry(key, value.toJson()),
        ),
        'achievements': achievements,
      };

  factory UserProgress.fromJson(Map<String, dynamic> json) {
    return UserProgress(
      level: json['level'] ?? 1,
      totalPoints: json['totalPoints'] ?? 0,
      completedLessons: List<String>.from(json['completedLessons'] ?? []),
      completedUnitIds: Set<String>.from(json['completedUnitIds'] ?? []),
      unitAccuracyHistory: (json['unitAccuracyHistory'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, (value as num).toDouble()),
          ) ??
          {},
      currentStreak: json['currentStreak'] ?? 0,
      bestStreak: json['bestStreak'] ?? 0,
      lastActivity: json['lastActivity'],
      moduleProgress: (json['moduleProgress'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(
              key,
              ModuleProgress.fromJson(value as Map<String, dynamic>),
            ),
          ) ??
          {},
      achievements: List<String>.from(json['achievements'] ?? []),
    );
  }

  String toJsonString() => jsonEncode(toJson());

  factory UserProgress.fromJsonString(String jsonString) {
    return UserProgress.fromJson(jsonDecode(jsonString));
  }
}

class ModuleProgress {
  int completed;
  int totalScore;
  int bestScore;

  ModuleProgress({
    this.completed = 0,
    this.totalScore = 0,
    this.bestScore = 0,
  });

  Map<String, dynamic> toJson() => {
        'completed': completed,
        'totalScore': totalScore,
        'bestScore': bestScore,
      };

  factory ModuleProgress.fromJson(Map<String, dynamic> json) {
    return ModuleProgress(
      completed: json['completed'] ?? 0,
      totalScore: json['totalScore'] ?? 0,
      bestScore: json['bestScore'] ?? 0,
    );
  }
}
