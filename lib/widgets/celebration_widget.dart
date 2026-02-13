import 'package:flutter/material.dart';
import 'dart:math';

class CelebrationWidget extends StatefulWidget {
  const CelebrationWidget({super.key});

  @override
  State<CelebrationWidget> createState() => _CelebrationWidgetState();
}

class _CelebrationWidgetState extends State<CelebrationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_FallingEmoji> _emojis = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    for (int i = 0; i < 30; i++) {
      _emojis.add(_FallingEmoji(
        emoji: ['⭐', '🌟', '✨', '💫'][_random.nextInt(4)],
        startX: _random.nextDouble(),
        duration: 1.5 + _random.nextDouble() * 1.5,
        delay: _random.nextDouble() * 0.5,
      ));
    }

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            children: _emojis.map((emoji) {
              double progress = (_controller.value - emoji.delay / 3)
                  .clamp(0.0, 1.0);
              
              return Positioned(
                left: MediaQuery.of(context).size.width * emoji.startX,
                top: -50 + (MediaQuery.of(context).size.height + 100) * progress,
                child: Opacity(
                  opacity: 1.0 - progress,
                  child: Text(
                    emoji.emoji,
                    style: const TextStyle(fontSize: 40),
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

class _FallingEmoji {
  final String emoji;
  final double startX;
  final double duration;
  final double delay;

  _FallingEmoji({
    required this.emoji,
    required this.startX,
    required this.duration,
    required this.delay,
  });
}
