import 'package:flutter/material.dart';

import 'custom_button.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String buttonText;
  final VoidCallback onPressed;
  final Color textColor;
  final Color buttonTextColor;

  const SectionHeader({
    super.key,
    required this.title,
    required this.buttonText,
    required this.onPressed,
    this.textColor = Colors.black,
    this.buttonTextColor = const Color(0xFFDC1D27),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          if (buttonText.isNotEmpty)
            CustomButton(
              type: ButtonType.text,
              size: ButtonSize.medium,
              shape: ButtonShape.circular,
              text: buttonText,
              onPressed: onPressed,
              textColor: buttonTextColor,
            ),
        ],
      ),
    );
  }
}
