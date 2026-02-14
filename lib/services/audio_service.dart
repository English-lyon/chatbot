import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'storage_service.dart';

class AudioService {
  final FlutterTts _flutterTts = FlutterTts();
  final AudioPlayer _sfxPlayer = AudioPlayer();
  final StorageService _storage = StorageService();

  // Default voice settings
  static const double defaultRate = 0.5;
  static const double defaultPitch = 1.0;

  double _rate = defaultRate;
  double _pitch = defaultPitch;
  double get rate => _rate;
  double get pitch => _pitch;

  bool _isSlow = false;
  bool get isSlow => _isSlow;

  // Current voice
  String? _voiceName;
  String? _voiceLocale;
  String? get voiceName => _voiceName;
  String? get voiceLocale => _voiceLocale;

  // Whether user has chosen a voice
  bool _hasUserVoice = false;
  bool get hasUserVoice => _hasUserVoice;

  // Word progress callback for real-time highlighting
  void Function(int wordStart, int wordEnd)? onWordSpoken;
  void Function()? onSpeakComplete;

  AudioService() {
    _initTts();
    _initSfx();
  }

  Future<void> _initSfx() async {
    await _sfxPlayer.setReleaseMode(ReleaseMode.stop);
    if (!kIsWeb) {
      await _sfxPlayer.setPlayerMode(PlayerMode.lowLatency);
    }
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setVolume(1.0);

    // Try to load saved voice preferences
    final saved = await _storage.loadVoiceSettings();
    if (saved['name'] != null) {
      _voiceName = saved['name'] as String;
      _voiceLocale = saved['locale'] as String? ?? 'en-US';
      _rate = (saved['rate'] as double?) ?? defaultRate;
      _pitch = (saved['pitch'] as double?) ?? defaultPitch;
      _hasUserVoice = true;
      await _flutterTts.setVoice({"name": _voiceName!, "locale": _voiceLocale!});
      print('TTS: Loaded saved voice: $_voiceName ($_voiceLocale) rate=$_rate pitch=$_pitch');
    } else {
      // No saved voice — auto-select best one
      if (kIsWeb) {
        await _selectBestWebVoice();
      } else {
        final isApple = defaultTargetPlatform == TargetPlatform.iOS ||
                         defaultTargetPlatform == TargetPlatform.macOS;
        if (isApple) {
          await _flutterTts.setSharedInstance(true);
          await _flutterTts.setIosAudioCategory(
            IosTextToSpeechAudioCategory.playback,
            [
              IosTextToSpeechAudioCategoryOptions.allowBluetooth,
              IosTextToSpeechAudioCategoryOptions.defaultToSpeaker,
            ],
          );
          _voiceName = 'Samantha';
          _voiceLocale = 'en-US';
          await _flutterTts.setVoice({"name": "Samantha", "locale": "en-US"});
        }
      }
    }

    await _flutterTts.setSpeechRate(_rate);
    await _flutterTts.setPitch(_pitch);

    _flutterTts.setProgressHandler((String text, int start, int end, String word) {
      onWordSpoken?.call(start, end);
    });
    _flutterTts.setCompletionHandler(() {
      onSpeakComplete?.call();
    });
  }

  /// Select the best English voice available in the browser.
  /// Chrome loads voices asynchronously, so we retry a few times.
  Future<void> _selectBestWebVoice() async {
    for (int attempt = 0; attempt < 5; attempt++) {
      try {
        final voices = await _flutterTts.getVoices;
        if (voices == null || (voices as List).isEmpty) {
          print('TTS voice attempt $attempt: no voices yet, retrying...');
          await Future.delayed(const Duration(milliseconds: 300));
          continue;
        }
        final voiceList = List<Map>.from(voices);

        // Print all English voices for debugging
        final enVoices = voiceList.where((v) {
          final locale = (v['locale'] ?? v['lang'] ?? '').toString();
          return locale.startsWith('en');
        }).toList();
        print('TTS: Found ${enVoices.length} English voices:');
        for (final v in enVoices) {
          print('  - ${v['name']} (${v['locale'] ?? v['lang']})');
        }

        Map? selected;
        int bestScore = 0;
        for (final v in enVoices) {
          final name = (v['name'] ?? '').toString().toLowerCase();
          int score = 1; // base score for any English voice

          // ── Top tier: natural Apple female voices (warm, clear for kids) ──
          if (name == 'samantha') score += 50;          // Best: natural US female
          if (name.startsWith('shelley')) score += 45;  // Modern Apple, expressive
          if (name.startsWith('sandy')) score += 40;    // Modern Apple, friendly
          if (name == 'karen') score += 38;             // Australian, very clear
          if (name.startsWith('flo')) score += 35;      // Apple, gentle
          if (name == 'moira') score += 33;             // Irish, warm
          if (name == 'kathy') score += 30;             // US female, decent

          // ── Mid tier: Google voices (robotic but reliable fallback) ──
          if (name.contains('google uk english female')) score += 20;
          if (name.contains('google us english')) score += 15;

          // ── Prefer US/GB locale ──
          final locale = (v['locale'] ?? v['lang'] ?? '').toString();
          if (locale == 'en-US' || locale == 'en_US') score += 2;
          if (locale == 'en-GB' || locale == 'en_GB') score += 1;

          // ── Avoid novelty/joke voices ──
          const avoid = ['albert', 'bahh', 'boing', 'bulles', 'cloches', 'fred',
            'junior', 'ralph', 'zarvox', 'wobble', 'superstar', 'orgue',
            'murmure', 'bouffon', 'violoncelles', 'mauvaises', 'bonnes', 'trinoïdes'];
          if (avoid.any((a) => name.contains(a))) score = 0;

          // ── Avoid male voices (Grandpa, Reed, Rocko, Daniel, Rishi, etc.) ──
          const maleVoices = ['grandpa', 'reed', 'rocko', 'daniel', 'rishi', 'eddy',
            'google uk english male'];
          if (maleVoices.any((m) => name.contains(m))) score = (score * 0.3).round();

          if (score > bestScore) {
            bestScore = score;
            selected = v;
          }
        }

        if (selected != null) {
          final voiceName = selected['name'].toString();
          final voiceLocale = (selected['locale'] ?? selected['lang'] ?? 'en-US').toString();
          print('TTS: Selected voice: $voiceName ($voiceLocale) score=$bestScore');
          _voiceName = voiceName;
          _voiceLocale = voiceLocale;
          await _flutterTts.setVoice({"name": voiceName, "locale": voiceLocale});
          return;
        } else {
          print('TTS: No suitable English voice found');
        }
      } catch (e) {
        print('Web voice selection attempt $attempt: $e');
      }
      await Future.delayed(const Duration(milliseconds: 300));
    }
  }

  void toggleSlow() {
    _isSlow = !_isSlow;
  }

  /// Re-apply selected voice before each utterance (Chrome can reset it)
  Future<void> _ensureVoice() async {
    if (_voiceName != null) {
      await _flutterTts.setVoice({"name": _voiceName!, "locale": _voiceLocale ?? 'en-US'});
    }
  }

  Future<void> speak(String text) async {
    try {
      await _ensureVoice();
      if (_isSlow) {
        await _speakWordByWord(text);
      } else {
        await _flutterTts.setSpeechRate(_rate);
        await _flutterTts.setPitch(_pitch);
        await _flutterTts.speak(text);
      }
    } catch (e) {
      print('TTS Error: $e');
    }
  }

  /// Slow mode à la Duolingo: same voice, same words,
  /// but spoken one word at a time with pauses between them
  Future<void> _speakWordByWord(String text) async {
    final words = text.split(RegExp(r'\s+'));
    await _flutterTts.setSpeechRate(_rate * 0.7);
    await _flutterTts.setPitch(_pitch);

    int charOffset = 0;
    for (int i = 0; i < words.length; i++) {
      final word = words[i];
      // Notify highlight callback
      onWordSpoken?.call(charOffset, charOffset + word.length);
      await _flutterTts.speak(word);
      // Wait for the word to finish + pause
      await Future.delayed(Duration(milliseconds: 450 + (word.length * 60)));
      charOffset += word.length + 1; // +1 for space
    }
    onSpeakComplete?.call();
  }

  /// Slow button: always speaks word-by-word regardless of toggle
  Future<void> speakSlow(String text) async {
    try {
      await _speakWordByWord(text);
    } catch (e) {
      print('TTS Slow Error: $e');
    }
  }

  /// Play the great.mp3 sound effect on correct answer
  Future<void> playCorrectSound() async {
    try {
      await _flutterTts.stop(); // Stop TTS so sound is clearly audible
      await _sfxPlayer.stop();  // Reset player state
      await _sfxPlayer.play(AssetSource('sounds/great.mp3'));
    } catch (e) {
      print('SFX Error: $e');
    }
  }

  Future<void> speakCheer() async {
    try {
      await playCorrectSound();
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

  // ── Public API for voice settings ──

  /// Get all available English voices for the picker
  Future<List<Map<String, String>>> getEnglishVoices() async {
    for (int attempt = 0; attempt < 5; attempt++) {
      try {
        final voices = await _flutterTts.getVoices;
        if (voices == null || (voices as List).isEmpty) {
          await Future.delayed(const Duration(milliseconds: 300));
          continue;
        }
        final voiceList = List<Map>.from(voices);
        final result = <Map<String, String>>[];
        const avoid = ['albert', 'bahh', 'boing', 'bulles', 'cloches',
          'junior', 'ralph', 'zarvox', 'wobble', 'superstar', 'orgue',
          'murmure', 'bouffon', 'violoncelles', 'mauvaises', 'bonnes',
          'trinoïdes', 'trinoids'];
        for (final v in voiceList) {
          final name = (v['name'] ?? '').toString();
          final locale = (v['locale'] ?? v['lang'] ?? '').toString();
          if (!locale.startsWith('en')) continue;
          if (avoid.any((a) => name.toLowerCase().contains(a))) continue;
          result.add({'name': name, 'locale': locale});
        }
        result.sort((a, b) => a['name']!.compareTo(b['name']!));
        return result;
      } catch (e) {
        await Future.delayed(const Duration(milliseconds: 300));
      }
    }
    return [];
  }

  /// Apply and save a voice choice
  Future<void> applyVoice(String name, String locale) async {
    _voiceName = name;
    _voiceLocale = locale;
    _hasUserVoice = true;
    await _flutterTts.setVoice({"name": name, "locale": locale});
    await _storage.saveVoiceSettings(name: name, locale: locale, rate: _rate, pitch: _pitch);
    print('TTS: Applied voice: $name ($locale)');
  }

  /// Update speech rate and save
  Future<void> applyRate(double newRate) async {
    _rate = newRate;
    await _flutterTts.setSpeechRate(_rate);
    if (_voiceName != null) {
      await _storage.saveVoiceSettings(name: _voiceName!, locale: _voiceLocale ?? 'en-US', rate: _rate, pitch: _pitch);
    }
  }

  /// Update pitch and save
  Future<void> applyPitch(double newPitch) async {
    _pitch = newPitch;
    await _flutterTts.setPitch(_pitch);
    if (_voiceName != null) {
      await _storage.saveVoiceSettings(name: _voiceName!, locale: _voiceLocale ?? 'en-US', rate: _rate, pitch: _pitch);
    }
  }

  /// Preview a voice with sample text
  Future<void> previewVoice(String name, String locale) async {
    await _flutterTts.stop();
    await _flutterTts.setVoice({"name": name, "locale": locale});
    await _flutterTts.setSpeechRate(_rate);
    await _flutterTts.setPitch(_pitch);
    await _flutterTts.speak('Hello! I will help you learn English.');
  }

  void dispose() {
    onWordSpoken = null;
    onSpeakComplete = null;
    _flutterTts.stop();
    _sfxPlayer.dispose();
  }
}
