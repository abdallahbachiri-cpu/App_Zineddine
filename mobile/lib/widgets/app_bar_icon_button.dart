import 'package:flutter/material.dart';

class AppBarIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final EdgeInsetsGeometry padding;

  const AppBarIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.padding = const EdgeInsets.all(10),
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      style: IconButton.styleFrom(
        backgroundColor: Colors.white,
        padding: padding,
      ),
      iconSize: 25,
      icon: Icon(icon, color: Colors.black),
      onPressed: onPressed,
    );
  }
}
