import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _nameController = TextEditingController();
  String _selectedEmoji = '🧒';
  int _selectedColorValue = 0xFFFF8F00;
  int _step = 0; // 0=name, 1=avatar, 2=color

  final _avatarOptions = [
    '🧒', '👦', '👧', '🧒🏽', '👦🏽', '👧🏽',
    '🦸', '🧚', '🐻', '🦊', '🐱', '🐶',
    '🦄', '🐼', '🐸', '🦋', '🌟', '🚀',
  ];

  final _colorOptions = [
    {'name': 'Orange', 'value': 0xFFFF8F00, 'emoji': '🧡'},
    {'name': 'Blue', 'value': 0xFF3366CC, 'emoji': '💙'},
    {'name': 'Green', 'value': 0xFF4CAF50, 'emoji': '💚'},
    {'name': 'Pink', 'value': 0xFFE91E63, 'emoji': '💗'},
    {'name': 'Purple', 'value': 0xFF9C27B0, 'emoji': '💜'},
    {'name': 'Red', 'value': 0xFFF44336, 'emoji': '❤️'},
    {'name': 'Yellow', 'value': 0xFFFFC107, 'emoji': '💛'},
    {'name': 'Cyan', 'value': 0xFF00BCD4, 'emoji': '🩵'},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_step == 0 && _nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your name! 😊')),
      );
      return;
    }
    if (_step < 2) {
      setState(() => _step++);
    } else {
      _finishSetup();
    }
  }

  void _finishSetup() {
    final appState = Provider.of<AppState>(context, listen: false);
    appState.updateProfile(
      name: _nameController.text.trim(),
      avatarEmoji: _selectedEmoji,
      favoriteColorValue: _selectedColorValue,
    );
    appState.completeSetup();
    Navigator.pushReplacementNamed(context, '/voice-setup');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(_selectedColorValue).withValues(alpha: 0.08),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Progress dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (i) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: i == _step ? 32 : 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: i <= _step
                          ? Color(_selectedColorValue)
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 30),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _step == 0
                      ? _buildNameStep()
                      : _step == 1
                          ? _buildAvatarStep()
                          : _buildColorStep(),
                ),
              ),
              const SizedBox(height: 20),
              // Navigation buttons
              Row(
                children: [
                  if (_step > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => setState(() => _step--),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          side: BorderSide(color: Color(_selectedColorValue)),
                        ),
                        child: Text(
                          '← Back',
                          style: TextStyle(
                            fontSize: 18,
                            color: Color(_selectedColorValue),
                          ),
                        ),
                      ),
                    ),
                  if (_step > 0) const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _nextStep,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(_selectedColorValue),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 3,
                      ),
                      child: Text(
                        _step < 2 ? 'Next →' : "Let's Go! 🚀",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNameStep() {
    return Column(
      key: const ValueKey('name'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('🌟', style: TextStyle(fontSize: 60)),
        const SizedBox(height: 16),
        const Text(
          "What's your name?",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          "Tell us so we can call you by name!",
          style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        TextField(
          controller: _nameController,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            hintText: 'Your name...',
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 22),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 20,
            ),
          ),
          textCapitalization: TextCapitalization.words,
        ),
      ],
    );
  }

  Widget _buildAvatarStep() {
    return Column(
      key: const ValueKey('avatar'),
      children: [
        Text(_selectedEmoji, style: const TextStyle(fontSize: 70)),
        const SizedBox(height: 12),
        Text(
          'Choose your avatar, ${_nameController.text.trim()}!',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Pick the one that looks like you!',
          style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
            ),
            itemCount: _avatarOptions.length,
            itemBuilder: (context, index) {
              final emoji = _avatarOptions[index];
              final isSelected = emoji == _selectedEmoji;
              return GestureDetector(
                onTap: () => setState(() => _selectedEmoji = emoji),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Color(_selectedColorValue).withValues(alpha: 0.15)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? Color(_selectedColorValue)
                          : Colors.grey.shade300,
                      width: isSelected ? 3 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: Color(_selectedColorValue).withValues(alpha: 0.2),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ]
                        : [],
                  ),
                  child: Center(
                    child: Text(
                      emoji,
                      style: TextStyle(fontSize: isSelected ? 32 : 28),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildColorStep() {
    return Column(
      key: const ValueKey('color'),
      children: [
        Text(_selectedEmoji, style: const TextStyle(fontSize: 60)),
        const SizedBox(height: 12),
        const Text(
          "What's your favorite color?",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          "We'll make the app your color!",
          style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.9,
            ),
            itemCount: _colorOptions.length,
            itemBuilder: (context, index) {
              final option = _colorOptions[index];
              final colorValue = option['value'] as int;
              final isSelected = colorValue == _selectedColorValue;
              return GestureDetector(
                onTap: () => setState(() => _selectedColorValue = colorValue),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: Color(colorValue).withValues(alpha: isSelected ? 0.2 : 0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? Color(colorValue) : Colors.grey.shade300,
                      width: isSelected ? 3 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        option['emoji'] as String,
                        style: const TextStyle(fontSize: 30),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        option['name'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: Color(colorValue),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
