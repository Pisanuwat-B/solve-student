import 'package:flutter/material.dart';

class Dialogs {
  static void showSnackbar(
      BuildContext context,
      String msg, {
        Color? bg,                       // <- optional
        SnackBarBehavior behavior = SnackBarBehavior.floating,
        Duration? duration,
      }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: bg ?? Colors.blue.withOpacity(.8), // default unchanged
        behavior: behavior,
        duration: duration ?? const Duration(seconds: 3),
      ),
    );
  }

  static void showProgressBar(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
  }
}