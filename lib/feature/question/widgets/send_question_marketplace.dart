import 'package:flutter/material.dart';
import 'package:solve_student/constants/theme.dart';

class SendQuestionMarketplace extends StatelessWidget {
  const SendQuestionMarketplace({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              color: getMaterialColor(primaryColor).shade200,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "ส่งคำถามให้ติวเตอร์แล้ว",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "กรุณารอคำตอบจากติวเตอร์ ระบบจะส่งแจ้งเตือนเมื่อมีติวเตอร์ตอบคำถามของคุณ",
            style: TextStyle(
              color: appTextSecondaryColor,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            height: 45,
            width: 200,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.keyboard_arrow_left,
                  color: Colors.white,
                ),
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "กลับไปที่ห้องเรียน",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
