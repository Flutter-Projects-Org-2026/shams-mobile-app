import 'package:flutter/material.dart';

class CustomOutlinedButton extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;
  final Widget? icon;

  const CustomOutlinedButton({
    super.key,
    required this.title,
    required this.onPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final buttonStyle = OutlinedButton.styleFrom(
      foregroundColor: colorScheme.secondary,
      side: BorderSide(color: colorScheme.secondary, width: 1.5),
    );

    if (icon != null) {
      return OutlinedButton.icon(
        onPressed: onPressed,
        icon: icon!,
        label: Text(title),
        style: buttonStyle,
      );
    }
    return OutlinedButton(
      onPressed: onPressed,
      style: buttonStyle,
      child: Text(title),
    );
  }
}