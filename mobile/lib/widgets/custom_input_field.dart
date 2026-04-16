import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomInputField extends StatefulWidget {
  final String labelText;
  final String hintText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final Color? backgroundColor;
  final bool obscureText;
  final bool boxShadow;
  final TextEditingController? controller;
  final double radius;
  final double fontsize;
  final TextInputType keyboardType;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final int? maxLines;
  final TextAlign textAlign;
  final FocusNode? focusNode;
  final String? initialValue;
  final TextCapitalization textCapitalization;
  final Widget? icon;
  final String? errorText;
  final bool? isEnabled;
  final VoidCallback? onSuffixTap;

  const CustomInputField({
    super.key,
    this.labelText = '',
    this.errorText,
    this.isEnabled = true,
    required this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.onChanged,
    this.validator,
    this.radius = 10,
    this.inputFormatters,
    this.boxShadow = true,
    this.backgroundColor = Colors.white,
    this.maxLength,
    this.textAlign = TextAlign.start,
    this.focusNode,
    this.fontsize = 16,
    this.initialValue,
    this.textCapitalization = TextCapitalization.none,
    this.maxLines = 1,
    this.icon,
    this.onSuffixTap,
  });

  @override
  State<CustomInputField> createState() => _CustomInputFieldState();
}

class _CustomInputFieldState extends State<CustomInputField> {
  String? _validatorError;

  @override
  Widget build(BuildContext context) {
    final finalErrorText = widget.errorText ?? _validatorError;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.labelText.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              widget.labelText,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

        Container(
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(widget.radius),
            boxShadow: [
              if (widget.boxShadow)
                BoxShadow(
                  color: Colors.grey.withAlpha(80),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
            ],
          ),
          child: TextFormField(
            enabled: widget.isEnabled,
            maxLines: widget.maxLines,
            focusNode: widget.focusNode,
            maxLength: widget.maxLength,
            textAlign: widget.textAlign,
            controller: widget.controller,
            obscureText: widget.obscureText,
            keyboardType: widget.keyboardType,
            onChanged: widget.onChanged,
            initialValue: widget.initialValue,
            inputFormatters: widget.inputFormatters,
            validator: (value) {
              final error = widget.validator?.call(value);

              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted && error != _validatorError) {
                  setState(() {
                    _validatorError = error;
                  });
                }
              });

              return error;
            },
            decoration: InputDecoration(
              icon: widget.icon,
              hintTextDirection: TextDirection.ltr,
              hintText: widget.hintText,
              hintStyle: TextStyle(
                color: Colors.black45,
                fontSize: widget.fontsize,
              ),

              errorStyle: const TextStyle(height: 0, fontSize: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              prefixIcon:
                  widget.prefixIcon != null ? Icon(widget.prefixIcon) : null,
              suffixIcon:
                  widget.suffixIcon != null
                      ? GestureDetector(
                        onTap: widget.onSuffixTap,
                        child: Icon(widget.suffixIcon),
                      )
                      : null,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ),

        if (finalErrorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 12),
            child: Text(
              finalErrorText,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }
}
