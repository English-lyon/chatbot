import 'package:flutter/material.dart';

class ModernButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final double? fontSize;
  final IconData? icon;
  final bool isSmall;

  const ModernButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.fontSize,
    this.icon,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? Theme.of(context).primaryColor,
        foregroundColor: textColor ?? Colors.white,
        padding: EdgeInsets.symmetric(
          horizontal: isSmall ? 16 : 24,
          vertical: isSmall ? 12 : 16,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 3,
      ),
      child: icon != null
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: fontSize ?? 20),
                const SizedBox(width: 8),
                Text(
                  text,
                  style: TextStyle(
                    fontSize: fontSize ?? 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            )
          : Text(
              text,
              style: TextStyle(
                fontSize: fontSize ?? 18,
                fontWeight: FontWeight.bold,
              ),
            ),
    );
  }
}
