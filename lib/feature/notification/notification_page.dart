import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:solve_student/feature/notification/view_answer.dart';

import '../../constants/theme.dart';
import '../../widgets/sizer.dart';
import '../calendar/controller/create_course_controller.dart';
import '../calendar/model/course_model.dart';
import '../my_course/controller/my_course_solvepad_detail_controller.dart';
import 'answer_notification_card.dart';
import 'notification_provider.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NotificationProvider>(context, listen: false).markAllAsRead();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<NotificationProvider>(context);
    final notifications = provider.notifications;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'แจ้งเตือน',
          style: TextStyle(
            color: appTextPrimaryColor,
          ),
        ),
      ),
      body: notifications.isEmpty
          ? SizedBox(
        width: Sizer(context).w,
        height: Sizer(context).h,
        child: Column(
          children: [
            SizedBox(height: Sizer(context).h * 0.35),
            const Icon(
              CupertinoIcons.cube_box,
              size: 50,
              color: Colors.grey,
            ),
            const SizedBox(height: 10),
            const Text("ไม่มีแจ้งเตือน"),
          ],
        ),
      )
          : ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final data = notifications[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: InkWell(
              onTap: () async {
                log('tap notification card');
                log(data.toString());
                final courseId = data['courseId'];
                final answerId = data['id'];
                final lessonId = int.tryParse(data['lessonId'].toString()) ?? 0;
                // Get CourseModel from provider
                final courseController = MyCourseSolvepadDetailController(context, courseId: courseId);
                await courseController.init();
                final course = courseController.courseDetail!;
                final lesson = courseController.courseDetail!.lessons![lessonId];

                log(course.toString());

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ViewAnswerPage(
                      course: course,
                      lesson: lesson,
                      answer: answerId,
                    ),
                  ),
                );
              },
              child: AnswerNotificationCard(
                questionText: data['questionText'],
                courseId: data['courseId'],
                lesson: data['lesson'],
              ),
            ),
          );
        },
      ),
    );
  }
}
