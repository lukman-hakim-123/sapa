import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'custom_text.dart';

class CustomButton extends StatelessWidget {
  final String? text;
  final void Function()? onPressed;
  final double height;
  final double borderRadius;
  final Color? backgroundColor;
  final TextStyle? textStyle;
  final bool isLoading;
  final Widget? child;

  const CustomButton({
    super.key,
    this.text,
    this.onPressed,
    this.height = 50,
    this.borderRadius = 12,
    this.backgroundColor,
    this.textStyle,
    this.child,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          elevation: 6,
          shadowColor: Color(0xFFBDBDBD),
        ),
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(
                width: 20.0,
                height: 20.0,
                child: CircularProgressIndicator(color: Colors.white),
              )
            : child ??
                  CustomText(
                    text: text ?? '',
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
      ),
    );
  }
}
