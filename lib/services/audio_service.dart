import 'package:flutter_tts/flutter_tts.dart';

class AudioService {
  final FlutterTts _flutterTts = FlutterTts();

  // Normal = kid-friendly cartoon pace, Slow = turtle mode
  static const double normalRate = 0.35;
  static const double slowRate = 0.25;
  static const double cartoonPitch = 1.35; // higher pitch → cartoon feel

  bool _isSlow = false;
  bool get isSlow => _isSlow;

  // Word progress callback for real-time highlighting
  void Function(int wordStart, int wordEnd)? onWordSpoken;
  void Function()? onSpeakComplete;

  AudioService() {
    _initTts();
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setSpeechRate(normalRate);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(cartoonPitch);

    _flutterTts.setProgressHandler((String text, int start, int end, String word) {
      onWordSpoken?.call(start, end);
    });
    _flutterTts.setCompletionHandler(() {
      onSpeakComplete?.call();
    });
  }

  void toggleSlow() {
    _isSlow = !_isSlow;
    _flutterTts.setSpeechRate(_isSlow ? slowRate : normalRate);
  }

  Future<void> speak(String text) async {
    try {
      await _flutterTts.speak(text);
    } catch (e) {
      print('TTS Error: $e');
    }
  }

  Future<void> speakSlow(String text) async {
    try {
      await _flutterTts.setSpeechRate(slowRate);
      await _flutterTts.speak(text);
      // Restore after speaking
      if (!_isSlow) {
        Future.delayed(const Duration(seconds: 3), () {
          _flutterTts.setSpeechRate(normalRate);
        });
      }
    } catch (e) {
      print('TTS Slow Error: $e');
    }
  }

  Future<void> speakCheer() async {
    try {
      // Enthusiastic cartoon cheer
      await _flutterTts.setPitch(1.55);
      await _flutterTts.setSpeechRate(0.38);
      await _flutterTts.speak('Greeaat!');
      Future.delayed(const Duration(milliseconds: 1200), () {
        _flutterTts.setPitch(cartoonPitch);
        _flutterTts.setSpeechRate(_isSlow ? slowRate : normalRate);
      });
    } catch (e) {
      print('TTS Cheer Error: $e');
    }
  }

  Future<void> stop() async {
    try {
      await _flutterTts.stop();
    } catch (e) {
      print('TTS Stop Error: $e');
    }
  }

  void dispose() {
    onWordSpoken = null;
    onSpeakComplete = null;
    _flutterTts.stop();
  }
}
