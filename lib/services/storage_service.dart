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

  // Voice settings keys
  static const String _voiceNameKey = 'voice_name';
  static const String _voiceLocaleKey = 'voice_locale';
  static const String _voiceRateKey = 'voice_rate';
  static const String _voicePitchKey = 'voice_pitch';

  Future<Map<String, dynamic>> loadVoiceSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return {
        'name': prefs.getString(_voiceNameKey),
        'locale': prefs.getString(_voiceLocaleKey),
        'rate': prefs.getDouble(_voiceRateKey),
        'pitch': prefs.getDouble(_voicePitchKey),
      };
    } catch (e) {
      print('Error loading voice settings: $e');
      return {};
    }
  }

  Future<void> saveVoiceSettings({
    required String name,
    required String locale,
    required double rate,
    required double pitch,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_voiceNameKey, name);
      await prefs.setString(_voiceLocaleKey, locale);
      await prefs.setDouble(_voiceRateKey, rate);
      await prefs.setDouble(_voicePitchKey, pitch);
    } catch (e) {
      print('Error saving voice settings: $e');
    }
  }

  Future<bool> hasVoiceSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey(_voiceNameKey);
    } catch (e) {
      return false;
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
