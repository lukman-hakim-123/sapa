import 'package:double_tap_to_exit/double_tap_to_exit.dart';
import 'package:flutter/material.dart';

import 'custom_text.dart';

class MyDoubleTapExit extends StatelessWidget {
  final Widget child;

  const MyDoubleTapExit({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return DoubleTapToExit(
      snackBar: SnackBar(
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.grey[100],
        elevation: 6,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        content: CustomText(
          text: 'Tekan sekali lagi untuk keluar aplikasi',
          fontWeight: FontWeight.w500,
        ),
      ),
      child: child,
    );
  }
}
