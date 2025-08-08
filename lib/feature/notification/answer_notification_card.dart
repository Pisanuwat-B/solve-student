import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../firebase/database.dart';
import '../calendar/controller/create_course_controller.dart';
import '../calendar/model/course_model.dart';
import '../calendar/model/student_model.dart';

class AnswerNotificationCard extends StatelessWidget {
  final String questionText;
  final String courseId;
  final int lesson;

  const AnswerNotificationCard({
    super.key,
    required this.questionText,
    required this.courseId,
    required this.lesson,
  });

  @override
  Widget build(BuildContext context) {
    final courseController = Provider.of<CourseController>(context, listen: false);

    return FutureBuilder<CourseModel>(
      future: courseController.getCourseById(courseId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox(height: 100, child: Center(child: CircularProgressIndicator()));
        }

        final course = snapshot.data!;
        final courseImage = course.thumbnailUrl ?? 'assets/images/default_course.png';
        final courseName = course.courseName ?? 'Unknown Course';
        final lessonNumber = lesson ?? '1';
        FirebaseService dbService = FirebaseService();

        return FutureBuilder<String?>(
            future: dbService.getUserNameById(course.tutorId),
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              final tutorName = snapshot.data ?? 'Unknown Tutor';
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
                  ],
                ),
                child: Row(
                  children: [
                    // Left: Image
                    Container(
                      width: MediaQuery.of(context).size.width * 0.3,
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          bottomLeft: Radius.circular(12),
                        ),
                        image: DecorationImage(
                          image: NetworkImage(courseImage),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                    // Right: Info
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              questionText,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Text("Tutor: $tutorName"),
                            Text("Course: $courseName"),
                            Text("Lesson: $lessonNumber"),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
        );
      },
    );
  }
}
