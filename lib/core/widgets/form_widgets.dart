import 'package:flutter/material.dart';
import 'package:gaspul/core/theme/theme.dart';

/// ================= Custom TextFormField =================
class CustomTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;
  final int maxLines;
  final TextInputType keyboardType;
  final bool readOnly;
  final Widget? suffixIcon;
  final Color? backgroundColor;
  final String? helperText;
  final void Function(String)? onFieldSubmitted; // ✅ Tambahkan

  const CustomTextFormField({
    super.key,
    required this.controller,
    required this.label,
    this.validator,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
    this.readOnly = false,
    this.suffixIcon,
    this.backgroundColor,
    this.helperText,
    this.onFieldSubmitted, // ✅ Tambahkan
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isHighContrast = theme.brightness == Brightness.dark;
    final inputBgColor = backgroundColor ?? (isHighContrast ? Colors.black : Colors.white);
    final inputTextColor = theme.textTheme.bodyLarge!.color!;
    final inputBorderColor = isHighContrast ? Colors.white : Colors.grey[400]!;

    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      readOnly: readOnly,
      style: theme.textTheme.bodyLarge!.copyWith(color: inputTextColor),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: theme.textTheme.bodyLarge!.copyWith(color: inputTextColor),
        filled: true,
        fillColor: inputBgColor,
        suffixIcon: suffixIcon,
        helperText: helperText,
        border: OutlineInputBorder(
          borderSide: BorderSide(color: inputBorderColor),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      validator: validator,
      onFieldSubmitted: onFieldSubmitted, // ✅ Sambungkan
    );
  }
}


/// ================= Custom DropdownFormField =================
class CustomDropdownFormField<T> extends StatelessWidget {
  final T? value;
  final String label;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?)? onChanged;
  final String? Function(T?)? validator;
  final double? menuMaxHeight;

  const CustomDropdownFormField({
    super.key,
    required this.value,
    required this.label,
    required this.items,
    this.onChanged,
    this.validator,
    this.menuMaxHeight,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isHighContrast = theme.brightness == Brightness.dark;
    final inputBgColor = isHighContrast ? Colors.black : Colors.white;
    final inputTextColor = theme.textTheme.bodyLarge!.color!;
    final inputBorderColor = isHighContrast ? Colors.white : Colors.grey[400]!;

    return DropdownButtonFormField<T>(
      value: value,
      isExpanded: true,
      isDense: false,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: theme.textTheme.bodyLarge!.copyWith(color: inputTextColor),
        filled: true,
        fillColor: inputBgColor,
        border: OutlineInputBorder(
          borderSide: BorderSide(color: inputBorderColor),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      items: items,
      onChanged: onChanged,
      validator: validator,
      menuMaxHeight: menuMaxHeight ?? 300,
    );
  }
}
