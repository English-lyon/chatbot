import 'package:flutter/material.dart';

enum MascotMood {
  idle,       // 🐻 neutral, waiting
  happy,      // 🐻 celebrating correct answer
  sad,        // 🐻 wrong answer, encouraging
  thinking,   // 🐻 hint mode
  cheering,   // 🐻 end of quiz, great score
  listening,  // 🐻 listening exercise
  speaking,   // 🐻 speaking exercise
}

class MascotWidget extends StatefulWidget {
  final MascotMood mood;
  final double size;
  final String? speechBubble;

  const MascotWidget({
    super.key,
    this.mood = MascotMood.idle,
    this.size = 80,
    this.speechBubble,
  });

  @override
  State<MascotWidget> createState() => _MascotWidgetState();
}

class _MascotWidgetState extends State<MascotWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _bounceController;
  late Animation<double> _bounceAnim;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _bounceAnim = Tween<double>(begin: 0, end: -8).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(MascotWidget old) {
    super.didUpdateWidget(old);
    if (widget.mood != old.mood) {
      _bounceController.forward().then((_) => _bounceController.reverse());
    }
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  String _mascotFace() {
    switch (widget.mood) {
      case MascotMood.idle:
        return '🐻';
      case MascotMood.happy:
        return '🥳';
      case MascotMood.sad:
        return '🐻';
      case MascotMood.thinking:
        return '🤔';
      case MascotMood.cheering:
        return '🎉';
      case MascotMood.listening:
        return '🐻';
      case MascotMood.speaking:
        return '🐻';
    }
  }

  Color _bubbleColor() {
    switch (widget.mood) {
      case MascotMood.happy:
      case MascotMood.cheering:
        return const Color(0xFFE8F5E9);
      case MascotMood.sad:
        return const Color(0xFFFFF3E0);
      case MascotMood.thinking:
        return const Color(0xFFE3F2FD);
      default:
        return const Color(0xFFF3E5F5);
    }
  }

  Color _bubbleBorder() {
    switch (widget.mood) {
      case MascotMood.happy:
      case MascotMood.cheering:
        return const Color(0xFF4CAF50);
      case MascotMood.sad:
        return const Color(0xFFFF9800);
      case MascotMood.thinking:
        return const Color(0xFF2196F3);
      default:
        return const Color(0xFF9C27B0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _bounceAnim,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _bounceAnim.value),
          child: child,
        );
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Mascot emoji
          Text(
            _mascotFace(),
            style: TextStyle(fontSize: widget.size),
          ),
          // Speech bubble
          if (widget.speechBubble != null && widget.speechBubble!.isNotEmpty)
            Flexible(
              child: Container(
                margin: const EdgeInsets.only(left: 8, bottom: 16),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: _bubbleColor(),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                    bottomLeft: Radius.circular(4),
                  ),
                  border: Border.all(color: _bubbleBorder(), width: 1.5),
                ),
                child: Text(
                  widget.speechBubble!,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _bubbleBorder(),
                    height: 1.3,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
