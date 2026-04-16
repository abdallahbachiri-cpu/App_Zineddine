import 'package:flutter/material.dart';

class SimpleHeader extends StatelessWidget {
  final String pageName;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final Color backgroundColor;
  final Color textColor;
  final TextStyle? textStyle;
  final double elevation;
  final IconData backIcon;

  const SimpleHeader({
    super.key,
    required this.pageName,
    this.showBackButton = false,
    this.onBackPressed,
    this.backgroundColor = Colors.white,
    this.textColor = Colors.black,
    this.textStyle,
    this.elevation = 4.0,
    this.backIcon = Icons.arrow_back_ios,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, bottom: 16, left: 16, right: 16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: elevation,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,

        children: [
          Text(
            pageName,
            style:
                textStyle ??
                TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          if (showBackButton)
            Positioned(
              left: 0,
              child: IconButton(
                icon: Icon(backIcon, color: textColor),
                onPressed: onBackPressed ?? () => Navigator.pop(context),
              ),
            ),
        ],
      ),
    );
  }
}
