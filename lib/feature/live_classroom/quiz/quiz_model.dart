class SelectQuizModel {
  String quiz, choice;
  bool isSelected;

  SelectQuizModel(this.quiz, this.choice, this.isSelected);
}

class QuizQuestion {
  final String questionText;
  final List<String> choices;
  final String correctChoice;

  QuizQuestion({
    required this.questionText,
    required this.choices,
    required this.correctChoice,
  });
}

class QuizSet {
  final String quizSetName;
  final List<QuizQuestion> quizQuestions;

  QuizSet({
    required this.quizSetName,
    required this.quizQuestions,
  });
}
