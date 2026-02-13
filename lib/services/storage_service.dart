import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_progress.dart';
import '../models/user_profile.dart';

class StorageService {
  static const String _progressKey = 'user_progress';
  static const String _profileKey = 'user_profile';

  Future<UserProgress> loadProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_progressKey);
      
      if (jsonString != null) {
        return UserProgress.fromJsonString(jsonString);
      }
    } catch (e) {
      print('Error loading progress: $e');
    }
    
    return UserProgress();
  }

  Future<void> saveProgress(UserProgress progress) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_progressKey, progress.toJsonString());
    } catch (e) {
      print('Error saving progress: $e');
    }
  }

  Future<void> clearProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_progressKey);
    } catch (e) {
      print('Error clearing progress: $e');
    }
  }

  Future<UserProfile> loadProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_profileKey);
      if (jsonString != null) {
        return UserProfile.fromJsonString(jsonString);
      }
    } catch (e) {
      print('Error loading profile: $e');
    }
    return UserProfile();
  }

  Future<void> saveProfile(UserProfile profile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_profileKey, profile.toJsonString());
    } catch (e) {
      print('Error saving profile: $e');
    }
  }

  Future<void> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_progressKey);
      await prefs.remove(_profileKey);
    } catch (e) {
      print('Error clearing all data: $e');
    }
  }
}
