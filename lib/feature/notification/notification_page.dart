import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:solve_student/constants/theme.dart';
import 'package:solve_student/widgets/sizer.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({Key? key}) : super(key: key);

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'แจ้งเตือน',
          style: TextStyle(
            color: appTextPrimaryColor,
          ),
        ),
      ),
      body: Container(
        width: Sizer(context).w,
        height: Sizer(context).h,
        child: Column(
          children: [
            SizedBox(height: Sizer(context).h * 0.35),
            Icon(
              CupertinoIcons.cube_box,
              size: 50,
              color: Colors.grey,
            ),
            SizedBox(height: 10),
            Text("ไม่มีแจ้งเตือน")
          ],
        ),
      ),
    );
  }
}
