import 'package:flutter/material.dart';

class UtilityHelper {
  static final UtilityHelper _instance = UtilityHelper._internal();
  factory UtilityHelper() => _instance;

  UtilityHelper._internal();

  void hideKeyboard(BuildContext context) {
    try {
      FocusScopeNode currentFocus = FocusScope.of(context);
      if (!currentFocus.hasPrimaryFocus) {
        currentFocus.unfocus();
      }
    } catch (_) {}
  }

  bool isTablet() {
    final data = MediaQueryData.fromWindow(WidgetsBinding.instance.window);
    return data.size.shortestSide > 600 ? true : false;
  }

  double addMinusFontSize(int fontSize) {
    return isTablet() ? fontSize + 2 : fontSize - 3;
  }
}
