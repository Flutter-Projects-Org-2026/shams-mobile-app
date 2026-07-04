import 'package:flutter/material.dart';

class CustomSolidButton extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;

  const CustomSolidButton({
    super.key,
    required this.title,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.secondary,
        foregroundColor: colorScheme.onSecondary,
      ),
      child: Text(title),
    );
  }
}