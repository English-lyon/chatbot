import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';

class VoiceSettingsScreen extends StatefulWidget {
  final bool isOnboarding;
  const VoiceSettingsScreen({super.key, this.isOnboarding = false});

  @override
  State<VoiceSettingsScreen> createState() => _VoiceSettingsScreenState();
}

class _VoiceSettingsScreenState extends State<VoiceSettingsScreen> {
  List<Map<String, String>> _voices = [];
  bool _loading = true;
  String? _selectedVoiceName;
  double _rate = 0.5;
  double _pitch = 1.0;

  @override
  void initState() {
    super.initState();
    _loadVoices();
  }

  Future<void> _loadVoices() async {
    final audio = Provider.of<AppState>(context, listen: false).audioService;
    final voices = await audio.getEnglishVoices();
    if (!mounted) return;
    setState(() {
      _voices = voices;
      _selectedVoiceName = audio.voiceName;
      _rate = audio.rate;
      _pitch = audio.pitch;
      _loading = false;
    });
  }

  void _preview(String name, String locale) {
    final audio = Provider.of<AppState>(context, listen: false).audioService;
    audio.previewVoice(name, locale);
  }

  Future<void> _selectVoice(String name, String locale) async {
    final audio = Provider.of<AppState>(context, listen: false).audioService;
    await audio.applyVoice(name, locale);
    setState(() => _selectedVoiceName = name);
  }

  Future<void> _onRateChanged(double value) async {
    final audio = Provider.of<AppState>(context, listen: false).audioService;
    setState(() => _rate = value);
    await audio.applyRate(value);
  }

  Future<void> _onPitchChanged(double value) async {
    final audio = Provider.of<AppState>(context, listen: false).audioService;
    setState(() => _pitch = value);
    await audio.applyPitch(value);
  }

  void _testCurrentVoice() {
    final audio = Provider.of<AppState>(context, listen: false).audioService;
    audio.speak('Hello! My name is your English teacher. Let\'s learn together!');
  }

  void _done() {
    if (widget.isOnboarding) {
      Navigator.pushReplacementNamed(context, '/placement');
    } else {
      Navigator.pop(context);
    }
  }

  String _rateLabel(double rate) {
    if (rate < 0.35) return 'Very slow';
    if (rate < 0.45) return 'Slow';
    if (rate < 0.55) return 'Normal';
    if (rate < 0.65) return 'Fast';
    return 'Very fast';
  }

  String _pitchLabel(double pitch) {
    if (pitch < 0.8) return 'Deep';
    if (pitch < 0.95) return 'Low';
    if (pitch < 1.05) return 'Normal';
    if (pitch < 1.2) return 'High';
    return 'Very high';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: widget.isOnboarding
          ? null
          : AppBar(
              title: const Text('Voice Settings'),
              backgroundColor: const Color(0xFF1CB0F6),
              foregroundColor: Colors.white,
            ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  if (widget.isOnboarding) ...[
                    const SizedBox(height: 24),
                    const Text('🔊', style: TextStyle(fontSize: 48)),
                    const SizedBox(height: 12),
                    const Text(
                      'Choose your teacher\'s voice',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF333333)),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Tap a voice to hear it, then pick your favorite',
                      style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                  ],
                  // Rate & Pitch sliders
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Text('🐢', style: TextStyle(fontSize: 18)),
                            Expanded(
                              child: Slider(
                                value: _rate,
                                min: 0.2,
                                max: 0.8,
                                divisions: 12,
                                activeColor: const Color(0xFF1CB0F6),
                                label: _rateLabel(_rate),
                                onChanged: _onRateChanged,
                              ),
                            ),
                            const Text('🐇', style: TextStyle(fontSize: 18)),
                            const SizedBox(width: 4),
                            SizedBox(
                              width: 65,
                              child: Text(_rateLabel(_rate),
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF666666)),
                                textAlign: TextAlign.center),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Text('🔈', style: TextStyle(fontSize: 18)),
                            Expanded(
                              child: Slider(
                                value: _pitch,
                                min: 0.5,
                                max: 1.5,
                                divisions: 10,
                                activeColor: const Color(0xFF7C4DFF),
                                label: _pitchLabel(_pitch),
                                onChanged: _onPitchChanged,
                              ),
                            ),
                            const Text('🔊', style: TextStyle(fontSize: 18)),
                            const SizedBox(width: 4),
                            SizedBox(
                              width: 65,
                              child: Text(_pitchLabel(_pitch),
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF666666)),
                                textAlign: TextAlign.center),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        GestureDetector(
                          onTap: _testCurrentVoice,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF58CC02).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFF58CC02), width: 1.5),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.play_arrow_rounded, color: Color(0xFF58CC02), size: 20),
                                SizedBox(width: 4),
                                Text('Test voice', style: TextStyle(color: Color(0xFF58CC02), fontWeight: FontWeight.w700, fontSize: 14)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Available voices (${_voices.length})',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF333333))),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Voice list
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _voices.length,
                      itemBuilder: (context, index) {
                        final voice = _voices[index];
                        final name = voice['name']!;
                        final locale = voice['locale']!;
                        final isSelected = name == _selectedVoiceName;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF1CB0F6).withValues(alpha: 0.08) : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected ? const Color(0xFF1CB0F6) : Colors.grey.shade200,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                            leading: Container(
                              width: 40, height: 40,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFF1CB0F6).withValues(alpha: 0.15)
                                    : Colors.grey.shade100,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isSelected ? Icons.check_circle_rounded : Icons.record_voice_over_rounded,
                                color: isSelected ? const Color(0xFF1CB0F6) : Colors.grey.shade400,
                                size: 22,
                              ),
                            ),
                            title: Text(name,
                              style: TextStyle(
                                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                color: isSelected ? const Color(0xFF1CB0F6) : const Color(0xFF333333),
                                fontSize: 15,
                              )),
                            subtitle: Text(locale,
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Preview button
                                GestureDetector(
                                  onTap: () => _preview(name, locale),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(Icons.play_arrow_rounded, size: 20, color: Colors.grey.shade600),
                                  ),
                                ),
                                if (!isSelected) ...[
                                  const SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: () => _selectVoice(name, locale),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF1CB0F6),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: const Text('Choose',
                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  // Done button
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _selectedVoiceName != null ? _done : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF58CC02),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 3,
                        ),
                        child: Text(
                          widget.isOnboarding ? "Let's Go! 🚀" : 'Done ✅',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
