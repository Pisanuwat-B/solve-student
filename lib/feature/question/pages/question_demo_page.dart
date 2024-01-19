import 'package:flutter/material.dart';
import 'package:solve_student/feature/question/models/question_search_model.dart';
import 'package:solve_student/feature/question/pages/question_page.dart';

class QuestionDemoPage extends StatefulWidget {
  const QuestionDemoPage({super.key});

  @override
  State<QuestionDemoPage> createState() => _QuestionDemoPageState();
}

class _QuestionDemoPageState extends State<QuestionDemoPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "demo",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              showModal(null);
            },
            child: const Text("question"),
          ),
        ],
      ),
    );
  }

  showModal(QuestionSearchModel? selectedQuestion) {
    showGeneralDialog(
      context: context,
      barrierLabel: "",
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 700),
      pageBuilder: (context, anim1, anim2) {
        QuestionSearchModel q1 = QuestionSearchModel(
          id: 1,
          showTime: 1,
          questionText: "คำถาม1",
          videoPath: "",
          soundPath: "",
          lecturePath: "a1",
        );
        QuestionSearchModel q2 = QuestionSearchModel(
          id: 2,
          showTime: 1,
          questionText: "คำถาม2",
          videoPath: "",
          soundPath: "",
          lecturePath: "a1",
        );
        QuestionSearchModel q3 = QuestionSearchModel(
          id: 3,
          showTime: 1,
          questionText: "คำถาม3",
          videoPath: "",
          soundPath: "",
          lecturePath: "a1",
        );
        List<QuestionSearchModel> data = [
          q1,
          q2,
          q3,
        ];
        return const Text('');
        // return QuestionDialog(
        //   questionText: 'test',
        //   questionList: data,
        //   selectedQuestion: selectedQuestion,
        // );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position: Tween(begin: const Offset(0, 1), end: const Offset(0, 0))
              .animate(anim1),
          child: child,
        );
      },
    ).then((value) async {
      if (value != null) {
        QuestionSearchModel selectedQuestion = value as QuestionSearchModel;
        await Future.delayed(Duration(seconds: selectedQuestion.showTime ?? 0));
        showModal(selectedQuestion);
      }
    });
  }
}
