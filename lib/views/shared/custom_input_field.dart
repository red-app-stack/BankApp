import 'package:flutter/material.dart';

class CustomInputField extends StatelessWidget {
  final TextEditingController? controller;
  final String label;
  final String? hint;
  final IconData? prefixIcon;
  final String? suffix;
  final Widget? suffixWidget;
  final bool enabled;
  final bool readOnly;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final VoidCallback? onTap;
  final void Function(String)? onChanged;
  final int? maxLength;
  final bool filled;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final void Function(String)? onSubmitted;

  const CustomInputField({
    super.key,
    this.controller,
    required this.label,
    this.hint,
    this.prefixIcon,
    this.suffix,
    this.suffixWidget,
    this.enabled = true,
    this.readOnly = false,
    this.keyboardType,
    this.validator,
    this.onTap,
    this.onChanged,
    this.maxLength,
    this.filled = false,
    this.focusNode,
    this.textInputAction,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    // final theme = Theme.of(context);

    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      enabled: enabled,
      readOnly: readOnly,
      maxLength: maxLength,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        suffixText: suffix,
        suffix: suffixWidget,
        filled: filled || !enabled,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      validator: validator,
      onTap: onTap,
      onChanged: onChanged,
      onFieldSubmitted:
          onSubmitted ?? (_) => FocusScope.of(context).nextFocus(),
    );
  }
}
