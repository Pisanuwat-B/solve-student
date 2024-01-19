import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:solve_student/feature/question/models/question_search_model.dart';

import '../../../firebase/database.dart';

class QuestionController extends ChangeNotifier {
  QuestionController(this.context, this.courseId, this.chapterId, this.page,
      {this.questionList, this.questionSelected});
  BuildContext context;
  final String courseId;
  final String chapterId;
  final int page;
  List<QuestionSearchModel>? questionList;
  QuestionSearchModel? questionSelected;
  TextEditingController searchText = TextEditingController();
  bool confirmSpeech = false;
  bool notFound = false;
  bool sendQuestion = false;
  FirebaseService dbService = FirebaseService();

  selectQuestion(QuestionSearchModel data) {
    questionSelected = data;
    notifyListeners();
  }

  setConfirmSpeech() async {
    var result = await dbService.getQuestionList(courseId, chapterId, page);
    if (result['questions']!.isEmpty) {
      log('query empty');
      confirmSpeech = true;
      notFound = true;
      notifyListeners();
    } else {
      List<String> questions = result['questions'] ?? [];
      List<String> groupIds = result['groupIds'] ?? [];
      log('query found');
      log(questions.toString());
      log(groupIds.toString());

      checkNLPResponse(searchText.text, questions, groupIds);
    }
    // check question from db and NLP
    notifyListeners();
  }

  setSearchText(String text) {
    searchText.text = text;
    notifyListeners();
  }

  sendQuestionSuccess() {
    sendQuestion = true;
    notifyListeners();
  }

  Future<void> checkNLPResponse(String questionText, List<String> dbQuestions,
      List<String> groupIds) async {
    log('try checkNLPResponse');

    final response = await http.post(
      Uri.parse('http://34.143.240.238:8080/nlp'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'question': questionText,
        'db_question': dbQuestions,
        'question_group_ids': groupIds,
      }),
    );

    if (response.statusCode == 200) {
      log('NLP Response: ${response.body}');
      List<dynamic> responseData = jsonDecode(response.body);
      if (responseData.isNotEmpty) {
        log('NLP Response not empty');
        questionList = [];
        for (var item in responseData) {
          var answer = await dbService.getSolvepadAnswer(item['group']);
          questionList?.add(QuestionSearchModel(
            id: 1,
            showTime: 21,
            questionText: item['text'],
            videoPath: answer['solvepad'],
            soundPath: answer['voice'],
            lecturePath: "a1",
          ));
        }
        confirmSpeech = true;
        notifyListeners();
      } else {
        log('NLP response empty');
        confirmSpeech = true;
        notFound = true;
        notifyListeners();
      }
    } else {
      log('NLP fail - Status code: ${response.statusCode}');
    }
  }
}
