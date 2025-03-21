import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/colors.dart';

class MyTextField extends StatelessWidget {
  final String hintText;
  final String? labelText;
  final bool obscureText;
  final TextEditingController controller;
  final FocusNode? focusNode;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? errorText;
  final String? helperText;
  final int? maxLength;
  final int? maxLines;
  final bool? enabled;
  final List<TextInputFormatter>? inputFormatters;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final EdgeInsetsGeometry? padding;
  final bool autofocus;
  final bool showCounter;

  const MyTextField({
    super.key,
    required this.hintText,
    this.labelText,
    this.obscureText = false,
    required this.controller,
    this.focusNode,
    this.keyboardType,
    this.textInputAction,
    this.prefixIcon,
    this.suffixIcon,
    this.errorText,
    this.helperText,
    this.maxLength,
    this.maxLines = 1,
    this.enabled = true,
    this.inputFormatters,
    this.onChanged,
    this.onSubmitted,
    this.padding = const EdgeInsets.symmetric(horizontal: 24.0),
    this.autofocus = false,
    this.showCounter = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding!,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (labelText != null) ...[
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 8),
              child: Text(
                labelText!,
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
          TextField(
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(
                color: subtleTextColor,
                fontSize: 15,
              ),
              errorText: errorText,
              errorStyle: TextStyle(
                color: errorColor,
                fontSize: 12,
              ),
              helperText: helperText,
              helperStyle: TextStyle(
                color: subtleTextColor,
                fontSize: 12,
              ),
              helperMaxLines: 2,
              errorMaxLines: 2,
              filled: true,
              fillColor: enabled! ? surfaceColor : backgroundColor,
              prefixIcon: prefixIcon != null
                ? IconTheme(
                    data: IconThemeData(
                      color: enabled! ? subtleTextColor : subtleTextColor.withOpacity(0.5),
                      size: 20,
                    ),
                    child: prefixIcon!,
                  )
                : null,
              suffixIcon: suffixIcon != null
                ? IconTheme(
                    data: IconThemeData(
                      color: enabled! ? subtleTextColor : subtleTextColor.withOpacity(0.5),
                      size: 20,
                    ),
                    child: suffixIcon!,
                  )
                : null,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
              counter: !showCounter ? const SizedBox.shrink() : null,
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: dividerColor,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: primaryColor.withOpacity(0.7),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              errorBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: errorColor.withOpacity(0.7),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: errorColor,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              disabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: dividerColor.withOpacity(0.5),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            style: TextStyle(
              color: enabled! ? textColor : textColor.withOpacity(0.7),
              fontSize: 15,
            ),
            obscureText: obscureText,
            controller: controller,
            focusNode: focusNode,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            maxLength: maxLength,
            maxLines: maxLines,
            enabled: enabled,
            inputFormatters: inputFormatters,
            onChanged: onChanged,
            onSubmitted: onSubmitted,
            autofocus: autofocus,
            cursorColor: primaryColor,
            cursorWidth: 2,
            cursorRadius: const Radius.circular(4),
          ),
        ],
      ),
    );
  }
}
