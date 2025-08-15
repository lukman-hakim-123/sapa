import 'package:flutter/material.dart';

import 'app_colors.dart';

class CustomTextFormField extends StatelessWidget {
  final String? hintText;
  final String? labelText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final int? maxLines;
  const CustomTextFormField({
    super.key,
    this.hintText,
    this.labelText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.validator,
    this.keyboardType,
    required this.controller,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      cursorColor: AppColors.secondary,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        filled: true,
        fillColor: Colors.white,
        prefixIcon: prefixIcon != null
            ? Icon(
                prefixIcon,
                // color: Theme.of(context).colorScheme.primary,
              )
            : null,
        suffixIcon: suffixIcon,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: Colors.grey, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: AppColors.secondary, width: 2),
        ),
      ),
    );
  }
}
