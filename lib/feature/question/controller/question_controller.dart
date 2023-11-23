import 'package:flutter/material.dart';
import 'package:solve_student/feature/question/models/question_search_model.dart';

class QuestionController extends ChangeNotifier {
  QuestionController(this.context, {this.questionList, this.questionSelected});
  BuildContext context;
  List<QuestionSearchModel>? questionList;
  QuestionSearchModel? questionSelected;
  TextEditingController searchText = TextEditingController();
  bool confirmSpeech = false;
  bool notFound = true;
  bool sendQuestion = false;

  selectQuestion(QuestionSearchModel data) {
    questionSelected = data;
    notifyListeners();
  }

  setConfirmSpeech() {
    confirmSpeech = true;
    // check question from db and NLP
    // update notFound value
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
}
