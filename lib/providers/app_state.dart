import 'package:flutter/foundation.dart';
import '../models/user_progress.dart';
import '../models/user_profile.dart';
import '../models/learning_path.dart';
import '../services/storage_service.dart';
import '../services/ai_service.dart';
import '../services/audio_service.dart';

class AppState extends ChangeNotifier {
  final StorageService _storageService = StorageService();
  final AIService _aiService = AIService();
  final AudioService _audioService = AudioService();

  UserProgress _progress = UserProgress();
  UserProfile _profile = UserProfile();
  bool _isLoading = true;

  UserProgress get progress => _progress;
  UserProfile get profile => _profile;
  bool get isLoading => _isLoading;
  bool get needsSetup => !_profile.hasCompletedSetup;
  bool get needsPlacement => !_profile.hasCompletedPlacement;
  AIService get aiService => _aiService;
  AudioService get audioService => _audioService;

  AppState() {
    _loadAll();
  }

  Future<void> _loadAll() async {
    _isLoading = true;
    notifyListeners();

    _progress = await _storageService.loadProgress();
    _profile = await _storageService.loadProfile();
    await _applyPlacementFloorIfNeeded();

    _isLoading = false;
    notifyListeners();
  }

  String _normalizeCefrBucket(String cefrLevel) {
    if (cefrLevel.startsWith('A1')) return 'A1';
    if (cefrLevel.startsWith('A2')) return 'A2';
    if (cefrLevel.startsWith('B1')) return 'B1';
    if (cefrLevel.startsWith('B2')) return 'B2';
    if (cefrLevel.startsWith('C1')) return 'C1';
    if (cefrLevel.startsWith('C2')) return 'C2';
    return cefrLevel;
  }

  int _targetPointsForPlacedLevel(String cefrLevel) {
    const levelPoints = {
      'A1': 0,
      'A2': 200,
      'B1': 500,
      'B2': 1000,
      'C1': 2000,
      'C2': 3500,
    };
    return levelPoints[_normalizeCefrBucket(cefrLevel)] ?? 0;
  }

  Future<void> _applyPlacementFloorIfNeeded() async {
    final placedLevel = _profile.placedLevel;
    if (!_profile.hasCompletedPlacement ||
        placedLevel == null ||
        placedLevel.isEmpty) {
      return;
    }

    final skipUnitIds = LearningPath.getUnitsBelowLevel(placedLevel);
    final beforeCount = _progress.completedUnitIds.length;
    final beforePoints = _progress.totalPoints;

    _progress.completedUnitIds.addAll(skipUnitIds);
    final targetPoints = _targetPointsForPlacedLevel(placedLevel);
    if (_progress.totalPoints < targetPoints) {
      _progress.totalPoints = targetPoints;
    }

    final changed = _progress.completedUnitIds.length != beforeCount ||
        _progress.totalPoints != beforePoints;
    if (changed) {
      await _storageService.saveProgress(_progress);
    }
  }

  Future<void> saveProgress() async {
    await _storageService.saveProgress(_progress);
    notifyListeners();
  }

  Future<void> saveProfile() async {
    await _storageService.saveProfile(_profile);
    notifyListeners();
  }

  void updateProfile(
      {String? name, String? avatarEmoji, int? favoriteColorValue}) {
    if (name != null) _profile.name = name;
    if (avatarEmoji != null) _profile.avatarEmoji = avatarEmoji;
    if (favoriteColorValue != null) {
      _profile.favoriteColorValue = favoriteColorValue;
    }
    saveProfile();
  }

  void completeSetup() {
    _profile.hasCompletedSetup = true;
    saveProfile();
  }

  void completePlacement(String cefrLevel, Set<String> unitsToSkip) {
    _profile.hasCompletedPlacement = true;
    _profile.placedLevel = cefrLevel;
    // Mark lower-level units as completed so child starts at the correct level.
    _progress.completedUnitIds
        .addAll(LearningPath.getUnitsBelowLevel(cefrLevel));
    _progress.completedUnitIds.addAll(unitsToSkip);

    // Keep displayed CEFR badge aligned with placement.
    final targetPoints = _targetPointsForPlacedLevel(cefrLevel);
    if (_progress.totalPoints < targetPoints) {
      _progress.totalPoints = targetPoints;
    }
    saveProfile();
    saveProgress();
  }

  void addPoints(int points) {
    _progress.addPoints(points);
    saveProgress();
  }

  // --- Duolingo-style path methods ---

  PathUnit? get currentUnit =>
      LearningPath.getNextUnit(_progress.completedUnitIds);

  Section? get currentSection =>
      LearningPath.getCurrentSection(_progress.completedUnitIds);

  Chapter? get currentChapter =>
      LearningPath.getCurrentChapter(_progress.completedUnitIds);

  bool isUnitUnlocked(String unitId) =>
      LearningPath.isUnitUnlocked(unitId, _progress.completedUnitIds);

  bool isUnitCompleted(String unitId) =>
      _progress.completedUnitIds.contains(unitId);

  double get overallProgress =>
      LearningPath.getOverallProgress(_progress.completedUnitIds);

  int get completedUnitsCount => _progress.completedUnitIds.length;
  int get totalUnitsCount => LearningPath.getTotalUnits();

  void completeUnit(String unitId, int score, {double accuracy = 1.0}) {
    _progress.completeUnit(unitId, score, accuracy: accuracy);
    saveProgress();
  }

  /// Check if child needs re-assessment based on recent accuracy
  bool get needsReassessment {
    final history = _progress.unitAccuracyHistory;
    if (history.length < 3) return false;
    // Check last 3 units' accuracy
    final recent = history.entries.toList()
      ..sort((a, b) => b.key.compareTo(a.key));
    final last3 = recent.take(3).map((e) => e.value).toList();
    final avgAccuracy = last3.reduce((a, b) => a + b) / last3.length;
    return avgAccuracy < 0.5; // Below 50% = needs reassessment
  }

  Future<void> resetProgress() async {
    _progress = UserProgress();
    _profile = UserProfile();
    await saveProgress();
    await saveProfile();
  }

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }
}
