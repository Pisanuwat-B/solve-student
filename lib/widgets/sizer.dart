import 'package:flutter/material.dart';

class Sizer {
  Sizer(this.context);
  BuildContext context;
  double get h => MediaQuery.of(context).size.height;
  double get w => MediaQuery.of(context).size.width;
}
