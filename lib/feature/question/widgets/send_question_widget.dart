import 'package:flutter/material.dart';
import 'package:solve_student/constants/theme.dart';

class SendQuestionWidget extends StatelessWidget {
  const SendQuestionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
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
            child: Icon(
              Icons.check,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "ส่งคำถามให้ติวเตอร์แล้ว",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
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
                Icon(
                  Icons.keyboard_arrow_left,
                  color: Colors.white,
                ),
                Text(
                  "กลับไปที่ห้องเรียน",
                  style: TextStyle(
                    color: Colors.white,
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
