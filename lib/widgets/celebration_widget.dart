import 'package:flutter/material.dart';
import 'dart:math';

class CelebrationWidget extends StatefulWidget {
  const CelebrationWidget({super.key});

  @override
  State<CelebrationWidget> createState() => _CelebrationWidgetState();
}

class _CelebrationWidgetState extends State<CelebrationWidget>
    with TickerProviderStateMixin {
  late AnimationController _burstController;
  late AnimationController _flashController;
  final List<_BurstParticle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();

    // Green flash overlay
    _flashController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    // Emoji burst
    _burstController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Generate burst particles from center
    const emojis = ['⭐', '🌟', '✨', '💫', '🎉', '🔥', '💚'];
    for (int i = 0; i < 20; i++) {
      final angle = (i / 20) * 2 * pi + _random.nextDouble() * 0.3;
      final speed = 0.6 + _random.nextDouble() * 0.6;
      _particles.add(_BurstParticle(
        emoji: emojis[_random.nextInt(emojis.length)],
        angle: angle,
        speed: speed,
        size: 24.0 + _random.nextDouble() * 20,
      ));
    }

    _flashController.forward();
    _burstController.forward();
  }

  @override
  void dispose() {
    _burstController.dispose();
    _flashController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final centerX = size.width / 2;
    final centerY = size.height * 0.35;

    return IgnorePointer(
      child: Stack(
        children: [
          // Green flash overlay
          AnimatedBuilder(
            animation: _flashController,
            builder: (context, _) {
              final opacity = (1.0 - _flashController.value).clamp(0.0, 0.3);
              return Container(
                color: const Color(0xFF58CC02).withValues(alpha: opacity),
              );
            },
          ),
          // Burst particles
          AnimatedBuilder(
            animation: _burstController,
            builder: (context, _) {
              final t = _burstController.value;
              return Stack(
                children: _particles.map((p) {
                  final distance = t * p.speed * 300;
                  final dx = cos(p.angle) * distance;
                  final dy = sin(p.angle) * distance - (t * 50); // slight upward drift
                  final opacity = (1.0 - t).clamp(0.0, 1.0);
                  final scale = 1.0 + t * 0.3;

                  return Positioned(
                    left: centerX + dx - p.size / 2,
                    top: centerY + dy - p.size / 2,
                    child: Opacity(
                      opacity: opacity,
                      child: Transform.scale(
                        scale: scale,
                        child: Text(
                          p.emoji,
                          style: TextStyle(fontSize: p.size),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
          // Big checkmark that pops in
          Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 400),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: child,
                );
              },
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFF58CC02),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF58CC02).withValues(alpha: 0.4),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 50,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BurstParticle {
  final String emoji;
  final double angle;
  final double speed;
  final double size;

  _BurstParticle({
    required this.emoji,
    required this.angle,
    required this.speed,
    required this.size,
  });
}
