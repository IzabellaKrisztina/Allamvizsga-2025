import 'package:flutter/material.dart';

class SurveyProvider with ChangeNotifier {
  final Map<String, dynamic> _answers = {};

  void saveAnswer(String question, dynamic answer) {
    _answers[question] = answer;
    notifyListeners();
  }

  dynamic getAnswer(String question) {
    return _answers[question];
  }

  Map<String, dynamic> getAllAnswers() => _answers;

  void clearAnswers() {
    _answers.clear();
    notifyListeners();
  }
}
