import 'package:flutter/material.dart';

class TextFieldInput extends StatelessWidget {
  final TextEditingController textEditingController;
  final bool isPass;
  final String hintText;
  final TextInputType textInputType;

  const TextFieldInput({
    Key? key,
    required this.hintText,
    this.isPass = false,
    required this.textEditingController,
    required this.textInputType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextField(
      controller: textEditingController,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: theme.textTheme.bodyMedium?.copyWith(
          color:
              theme.colorScheme.onSurface.withOpacity(0.6), // Subtle hint color
        ),
        filled: true,
        fillColor: theme.colorScheme.surfaceVariant, // Use theme for background
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide(
            color: theme.colorScheme.primary,
            width: 2.5,
          ),
        ),
      ),
      keyboardType: textInputType,
      obscureText: isPass,
      style: theme.textTheme.bodyLarge?.copyWith(
        color: theme.colorScheme.onSurface, // Dynamic text color
      ),
    );
  }
}
