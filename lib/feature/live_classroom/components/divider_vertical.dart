import 'package:flutter/material.dart';
import '../../calendar/constants/custom_colors.dart';

class DividerVer extends StatelessWidget {
  const DividerVer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 32,
      color: CustomColors.grayCFCFCF,
    );
  }
}
