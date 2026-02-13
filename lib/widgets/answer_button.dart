import 'package:flutter/material.dart';

enum AnswerState { normal, correct, wrong }

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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getBackgroundColor() {
    switch (widget.state) {
      case AnswerState.correct:
        return Colors.green.shade100;
      case AnswerState.wrong:
        return Colors.red.shade100;
      case AnswerState.normal:
        return Colors.white;
    }
  }

  Color _getBorderColor() {
    switch (widget.state) {
      case AnswerState.correct:
        return Colors.green;
      case AnswerState.wrong:
        return Colors.red;
      case AnswerState.normal:
        return Colors.grey.shade300;
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget button = Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getBorderColor(), width: 2),
      ),
      child: Text(
        widget.text,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
        textAlign: TextAlign.center,
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
      onTap: widget.state == AnswerState.normal ? widget.onPressed : null,
      child: button,
    );
  }
}
