import 'package:flutter/material.dart';
import '../../calendar/constants/custom_colors.dart';

class DividerLine extends StatelessWidget {
  const DividerLine({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(height: 2, color: CustomColors.grayCFCFCF);
  }
}
