import 'package:flutter/material.dart';
import 'package:solve_student/feature/question/models/question_search_model.dart';

class QuestionController extends ChangeNotifier {
  QuestionController(this.context, {required this.initQuestion});
  BuildContext context;
  List<QuestionSearchModel> initQuestion;
  List<QuestionSearchModel> questionList = [];
  QuestionSearchModel? questionSelected;
  TextEditingController searchText = TextEditingController();
  bool notFound = true;
  bool sendQuestion = false;
  init() {
    questionList = [];
    questionList = initQuestion;
    notFound = true;
    notifyListeners();
  }

  selectQuestion(QuestionSearchModel data) {
    questionSelected = data;
    notifyListeners();
  }

  setSearchText(String text) {
    notFound = false;
    if (searchText.text.isEmpty) {
      notFound = true;
    }
    notifyListeners();
  }

  sendQuestionSuccess() {
    sendQuestion = true;
    notifyListeners();
  }
}
