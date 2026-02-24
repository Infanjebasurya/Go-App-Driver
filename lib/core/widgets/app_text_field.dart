import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    this.label,
    this.controller,
    this.focusNode,
    this.autofocus = false,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.textAlign = TextAlign.start,
    this.maxLength,
    this.textStyle,
    this.filled = true,
    this.borderless = false,
    this.isCollapsed = false,
    this.contentPadding,
    this.leading,
    this.trailing,
    this.borderColor,
    this.hint,
    this.hintStyle,
    this.inputFormatters,
    this.onChanged,
  });

  final String? label;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final bool autofocus;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final TextAlign textAlign;
  final int? maxLength;
  final TextStyle? textStyle;
  final bool filled;
  final bool borderless;
  final bool isCollapsed;
  final EdgeInsetsGeometry? contentPadding;
  final Widget? leading;
  final Widget? trailing;
  final Color? borderColor;
  final String? hint;
  final TextStyle? hintStyle;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final outlineBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: borderColor ?? const Color(0xFFDDDDDD)),
    );

    return TextField(
      controller: controller,
      focusNode: focusNode,
      autofocus: autofocus,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      textAlign: textAlign,
      maxLength: maxLength,
      style: textStyle,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        counterText: '',
        hintText: hint,
        hintStyle: hintStyle,
        isDense: true,
        isCollapsed: isCollapsed,
        contentPadding: contentPadding,
        prefixIcon: leading,
        suffixIcon: trailing,
        border: borderless ? InputBorder.none : outlineBorder,
        enabledBorder: borderless ? InputBorder.none : outlineBorder,
        focusedBorder: borderless
            ? InputBorder.none
            : outlineBorder.copyWith(
                borderSide: BorderSide(
                  color: borderColor ?? const Color(0xFFDDDDDD),
                  width: 1.2,
                ),
              ),
        filled: filled,
        fillColor: Colors.transparent

      ),
    );
  }
}
