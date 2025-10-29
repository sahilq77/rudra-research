// To parse this JSON data, do
//
//     final getSurveyQuestionsResponse = getSurveyQuestionsResponseFromJson(jsonString);

import 'dart:convert';

List<GetSurveyQuestionsResponse> getSurveyQuestionsResponseFromJson(
  String str,
) => List<GetSurveyQuestionsResponse>.from(
  json.decode(str).map((x) => GetSurveyQuestionsResponse.fromJson(x)),
);

String getSurveyQuestionsResponseToJson(
  List<GetSurveyQuestionsResponse> data,
) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetSurveyQuestionsResponse {
  String status;
  String message;
  QuestionData data;

  GetSurveyQuestionsResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory GetSurveyQuestionsResponse.fromJson(Map<String, dynamic> json) =>
      GetSurveyQuestionsResponse(
        status: json["status"],
        message: json["message"],
        data: QuestionData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data.toJson(),
  };
}

class QuestionData {
  String surveyId;
  String languageId;
  List<Question> questions;

  QuestionData({
    required this.surveyId,
    required this.languageId,
    required this.questions,
  });

  factory QuestionData.fromJson(Map<String, dynamic> json) => QuestionData(
    surveyId: json["survey_id"],
    languageId: json["language_id"],
    questions: List<Question>.from(
      json["questions"].map((x) => Question.fromJson(x)),
    ),
  );

  Map<String, dynamic> toJson() => {
    "survey_id": surveyId,
    "language_id": languageId,
    "questions": List<dynamic>.from(questions.map((x) => x.toJson())),
  };
}

class Question {
  String surveyQuestionId;
  String questionId;
  String sequenceNumber;
  String question;
  String questionType;
  List<Option> options;

  Question({
    required this.surveyQuestionId,
    required this.questionId,
    required this.sequenceNumber,
    required this.question,
    required this.questionType,
    required this.options,
  });

  factory Question.fromJson(Map<String, dynamic> json) => Question(
    surveyQuestionId: json["survey_question_id"],
    questionId: json["question_id"],
    sequenceNumber: json["sequence_number"],
    question: json["question"],
    questionType: json["question_type"],
    options: List<Option>.from(json["options"].map((x) => Option.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "survey_question_id": surveyQuestionId,
    "question_id": questionId,
    "sequence_number": sequenceNumber,
    "question": question,
    "question_type": questionType,
    "options": List<dynamic>.from(options.map((x) => x.toJson())),
  };
}

class Option {
  String optionId;
  String choiceText;

  Option({required this.optionId, required this.choiceText});

  factory Option.fromJson(Map<String, dynamic> json) =>
      Option(optionId: json["option_id"], choiceText: json["choice_text"]);

  Map<String, dynamic> toJson() => {
    "option_id": optionId,
    "choice_text": choiceText,
  };
}
