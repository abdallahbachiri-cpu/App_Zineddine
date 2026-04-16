import 'package:flutter/material.dart';

enum ButtonType { text, outlined, elevated, icon, iconText }

enum ButtonSize { small, medium, large }

enum ButtonShape { rectangular, rounded, circular }

class CustomButton extends StatelessWidget {
  final ButtonType type;
  final ButtonSize size;
  final ButtonShape shape;
  final String? text;
  final IconData? icon;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color textColor;
  final Color iconColor;
  final Color borderColor;
  final EdgeInsetsGeometry padding;
  final bool isLoading;
  final double? borderRadius;
  final Color? loadingIndicatorColor;

  const CustomButton({
    super.key,
    required this.type,
    required this.size,
    required this.shape,
    this.text,
    this.icon,
    this.onPressed,
    this.backgroundColor = Colors.blue,
    this.textColor = Colors.white,
    this.iconColor = Colors.white,
    this.borderColor = Colors.blue,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    this.isLoading = false,
    this.borderRadius,
    this.loadingIndicatorColor,
  }) : assert(
         (type == ButtonType.icon && text == null) ||
             (type == ButtonType.text && icon == null) ||
             (type == ButtonType.iconText && text != null && icon != null) ||
             (type == ButtonType.outlined && text != null && icon == null) ||
             (type == ButtonType.elevated && text != null && icon == null),
         'Invalid combination of type, text, and icon.',
       );

  @override
  Widget build(BuildContext context) {
    final buttonSize = _getButtonSize(size);
    final buttonShape = _getButtonShape(shape);

    Widget buttonContent;
    switch (type) {
      case ButtonType.text:
        buttonContent = Text(
          text!,
          style: TextStyle(color: textColor, fontSize: buttonSize.textSize),
        );
        break;
      case ButtonType.outlined:
        buttonContent = Text(
          text!,
          style: TextStyle(color: textColor, fontSize: buttonSize.textSize),
        );
        break;
      case ButtonType.elevated:
        buttonContent = Text(
          text!,
          style: TextStyle(color: textColor, fontSize: buttonSize.textSize),
        );
        break;
      case ButtonType.icon:
        buttonContent = Icon(icon, color: iconColor, size: buttonSize.iconSize);
        break;
      case ButtonType.iconText:
        buttonContent = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: iconColor, size: buttonSize.iconSize),
            const SizedBox(width: 8),
            Text(
              text!,
              style: TextStyle(color: textColor, fontSize: buttonSize.textSize),
            ),
          ],
        );
        break;
    }

    switch (type) {
      case ButtonType.text:
        return TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(padding: padding, shape: buttonShape),
          child:
              isLoading
                  ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: loadingIndicatorColor ?? Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                  : buttonContent,
        );
      case ButtonType.outlined:
        return OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            padding: padding,
            shape: buttonShape,
            side: BorderSide(color: borderColor),
          ),
          child:
              isLoading
                  ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: loadingIndicatorColor ?? Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                  : buttonContent,
        );
      case ButtonType.elevated:
        return ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            padding: padding,
            shape: buttonShape,
            backgroundColor: backgroundColor,
          ),
          child:
              isLoading
                  ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: loadingIndicatorColor ?? Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                  : buttonContent,
        );
      case ButtonType.icon:
        return IconButton(
          onPressed: onPressed,
          icon:
              isLoading
                  ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: loadingIndicatorColor ?? Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                  : buttonContent,
          style: IconButton.styleFrom(
            padding: padding,
            shape: buttonShape,
            backgroundColor: backgroundColor,
          ),
        );
      case ButtonType.iconText:
        return ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            padding: padding,
            shape: buttonShape,
            backgroundColor: backgroundColor,
          ),
          child:
              isLoading
                  ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: loadingIndicatorColor ?? Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                  : buttonContent,
        );
    }
  }

  ButtonSizeData _getButtonSize(ButtonSize size) {
    switch (size) {
      case ButtonSize.small:
        return ButtonSizeData(textSize: 14, iconSize: 16);
      case ButtonSize.medium:
        return ButtonSizeData(textSize: 16, iconSize: 20);
      case ButtonSize.large:
        return ButtonSizeData(textSize: 18, iconSize: 24);
    }
  }

  OutlinedBorder _getButtonShape(ButtonShape shape) {
    switch (shape) {
      case ButtonShape.rectangular:
        return RoundedRectangleBorder(borderRadius: BorderRadius.zero);
      case ButtonShape.rounded:
        return RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 25),
        );
      case ButtonShape.circular:
        return const CircleBorder();
    }
  }
}

class ButtonSizeData {
  final double textSize;
  final double iconSize;

  ButtonSizeData({required this.textSize, required this.iconSize});
}
