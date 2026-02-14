import 'package:flutter/material.dart';

enum AnswerState { normal, selected, correct, wrong }

class AnswerButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final AnswerState state;

  const AnswerButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.state = AnswerState.normal,
  });

  @override
  State<AnswerButton> createState() => _AnswerButtonState();
}

class _AnswerButtonState extends State<AnswerButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _shakeAnimation = TweenSequence<Offset>([
      TweenSequenceItem(
        tween: Tween(begin: Offset.zero, end: const Offset(0.05, 0)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween(begin: const Offset(0.05, 0), end: const Offset(-0.05, 0)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween(begin: const Offset(-0.05, 0), end: Offset.zero),
        weight: 1,
      ),
    ]).animate(_controller);
  }

  @override
  void didUpdateWidget(AnswerButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state != oldWidget.state && widget.state != AnswerState.normal) {
      _controller.forward(from: 0);
    }
  }

  List<BoxShadow> _getShadow() {
    final base = Colors.black.withValues(alpha: 0.08);
    final lift = Colors.black.withValues(alpha: 0.04);
    return [
      BoxShadow(color: base, offset: const Offset(0, 3), blurRadius: 0),
      BoxShadow(color: lift, offset: const Offset(0, 1), blurRadius: 6),
    ];
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getBackgroundColor() {
    switch (widget.state) {
      case AnswerState.selected:
        return const Color(0xFFDDF4FF);
      case AnswerState.correct:
        return const Color(0xFFD7FFB8);
      case AnswerState.wrong:
        return const Color(0xFFFFDFE0);
      case AnswerState.normal:
        return Colors.white;
    }
  }

  Color _getBorderColor() {
    switch (widget.state) {
      case AnswerState.selected:
        return const Color(0xFF1CB0F6);
      case AnswerState.correct:
        return const Color(0xFF58CC02);
      case AnswerState.wrong:
        return const Color(0xFFFF4B4B);
      case AnswerState.normal:
        return Colors.grey.shade300;
    }
  }

  Color _getTextColor() {
    switch (widget.state) {
      case AnswerState.correct:
        return const Color(0xFF58CC02);
      case AnswerState.wrong:
        return const Color(0xFFFF4B4B);
      case AnswerState.selected:
        return const Color(0xFF1CB0F6);
      case AnswerState.normal:
        return Colors.black87;
    }
  }

  IconData? _getIcon() {
    switch (widget.state) {
      case AnswerState.correct:
        return Icons.check_circle_rounded;
      case AnswerState.wrong:
        return Icons.cancel_rounded;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final icon = _getIcon();

    Widget button = Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _getBorderColor(), width: 2.5),
        boxShadow: widget.state == AnswerState.normal
            ? _getShadow()
            : [BoxShadow(color: _getBorderColor().withValues(alpha: 0.25), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              widget.text,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: _getTextColor(),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          if (icon != null) ...[
            const SizedBox(width: 8),
            Icon(icon, color: _getBorderColor(), size: 26),
          ],
        ],
      ),
    );

    if (widget.state == AnswerState.correct) {
      button = ScaleTransition(
        scale: _scaleAnimation,
        child: button,
      );
    } else if (widget.state == AnswerState.wrong) {
      button = SlideTransition(
        position: _shakeAnimation,
        child: button,
      );
    }

    return GestureDetector(
      onTap: (widget.state == AnswerState.normal ||
              widget.state == AnswerState.selected)
          ? widget.onPressed
          : null,
      child: button,
    );
  }
}
