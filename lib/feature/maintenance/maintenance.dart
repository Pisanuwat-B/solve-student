import 'package:flutter/material.dart';

import '../../constants/theme.dart';

class MaintenancePage extends StatelessWidget {
  const MaintenancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: InkWell(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: const Icon(
            Icons.chevron_left,
            color: Colors.black,
          ),
        ),
        title: const Text(
          "Maintenance",
          style: TextStyle(
            color: appTextPrimaryColor,
          ),
        ),
      ),
      body: const Center(
        child: Text(
          'ขออภัย อยู่ในระหว่างปรับปรุง',
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
