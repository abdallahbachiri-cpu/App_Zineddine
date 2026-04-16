import 'package:cuisinous/generated/l10n.dart';
import 'package:flutter/material.dart';

class CallNowButton extends StatelessWidget {
  final bool visible;
  final bool isLoading;
  final VoidCallback? onPressed;
  final EdgeInsetsGeometry? margin;
  final String? label;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool isDisabled;

  const CallNowButton({
    super.key,
    required this.visible,
    required this.onPressed,
    this.isLoading = false,
    this.margin,
    this.label,
    this.backgroundColor,
    this.foregroundColor,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    if (!visible) {
      return const SizedBox.shrink();
    }

    final resolvedForegroundColor =
        foregroundColor ?? Theme.of(context).colorScheme.onPrimary;

    final button = ElevatedButton(
      onPressed: (isLoading || isDisabled) ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor:
            (isDisabled)
                ? Colors.grey
                : (backgroundColor ?? Theme.of(context).colorScheme.primary),
        foregroundColor: resolvedForegroundColor,
        minimumSize: const Size.fromHeight(48),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLoading)
            SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  resolvedForegroundColor,
                ),
              ),
            )
          else
            const Icon(Icons.phone),
          const SizedBox(width: 12),
          Text(label ?? S.of(context).callNowButton),
        ],
      ),
    );

    if (margin != null) {
      return Container(width: double.infinity, margin: margin, child: button);
    }

    return SizedBox(width: double.infinity, child: button);
  }
}
