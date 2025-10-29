import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rudra/app/data/models/survey_question/get_submit_answers_response.dart';
import 'package:rudra/app/data/models/survey_question/get_survey_questions_response.dart';
import 'package:rudra/app/data/network/networkcall.dart';
import 'package:rudra/app/data/urls.dart';
import 'package:rudra/app/routes/app_routes.dart';

import '../../../widgets/app_snackbar_styles.dart';

class SurveyQuestionController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // -----------------------------------------------------------------
  //  ALL QUESTIONS FROM API
  // -----------------------------------------------------------------
  RxList<Question> questionDetail = <Question>[].obs;

  // -----------------------------------------------------------------
  //  UI STATE
  // -----------------------------------------------------------------
  RxInt currentIndex = 0.obs; // <-- NEW
  RxString selectedAnswer = ''.obs; // answer for the *current* question
  final Map<String, String> answers = {}; // <-- store every answer

  RxBool isLoadingq = true.obs;
  var errorMessageq = ''.obs;
  RxBool isLoading = true.obs;
  var errorMessage = ''.obs;
  late String app;
  String surveyId = "";
  // -----------------------------------------------------------------
  //  INIT
  // -----------------------------------------------------------------
  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    surveyId = args?['survey_app_side_id']?.toString() ?? "";

    fetchallQestions(context: Get.context!, appSideId: surveyId);
  }

  // -----------------------------------------------------------------
  //  FETCH QUESTIONS
  // -----------------------------------------------------------------
  Future<void> fetchallQestions({
    required BuildContext context,
    bool reset = false,
    bool isPagination = false,
    bool forceFetch = false,
    required String appSideId,
  }) async {
    try {
      isLoadingq.value = true;
      errorMessageq.value = '';

      final jsonBody = {
        "survey_app_side_id": appSideId,
        "limit": "",
        "offset": "",
      };

      final response =
          await Networkcall().postMethod(
                Networkutility.getQustionsApi,
                Networkutility.getQustions,
                jsonEncode(jsonBody),
                context,
              )
              as List<GetSurveyQuestionsResponse>?;

      if (response != null &&
          response.isNotEmpty &&
          response[0].status == "true") {
        if (reset) {
          questionDetail.clear();
          answers.clear();
          currentIndex.value = 0;
          selectedAnswer.value = '';
        }

        for (var que in response[0].data.questions) {
          questionDetail.add(
            Question(
              surveyQuestionId: que.surveyQuestionId,
              questionId: que.questionId,
              sequenceNumber: que.sequenceNumber,
              question: que.question,
              questionType: que.questionType,
              options: que.options,
            ),
          );
        }
      } else {
        errorMessageq.value = 'No response from server';
        AppSnackbarStyles.showError(
          title: 'Error',
          message: errorMessageq.value,
        );
      }
    } catch (e) {
      errorMessageq.value = 'Unexpected error: $e';
      AppSnackbarStyles.showError(title: 'Error', message: errorMessageq.value);
    } finally {
      isLoadingq.value = false;
    }
  }

  Future<void> submitAnswers({
    required BuildContext context,
    bool reset = false,
    bool isPagination = false,
    bool forceFetch = false,
    String surveyId = "6",
    required String testId,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final jsonBody = {
        "survey_app_side_id": surveyId,
        "questions": [
          {"question_id": "3", "answer_id": "11"},
          {
            "question_id": "5",
            "answer_id": [
              "17",
              "18",
            ], //  if option multi selection questionDetail.first.questionType=="1"
          },
        ],
      };

      final response =
          await Networkcall().postMethod(
                Networkutility.submitQuestionAnswerApi,
                Networkutility.submitQuestionAnswer,
                jsonEncode(jsonBody),
                context,
              )
              as List<GetSubmitAnswersResponse>?;

      if (response != null &&
          response.isNotEmpty &&
          response[0].status == "true") {
        AppSnackbarStyles.showSuccess(
          title: 'Success',
          message: "Answers submitted successfully",
        );
      } else if (response![0].status == "true") {
        AppSnackbarStyles.showError(
          title: 'Failed',
          message: "Answers submission failed",
        );
      } else {
        errorMessage.value = 'No response from server';
        AppSnackbarStyles.showError(
          title: 'Error',
          message: errorMessage.value,
        );
      }
    } catch (e) {
      errorMessage.value = 'Unexpected error: $e';
      AppSnackbarStyles.showError(title: 'Error', message: errorMessageq.value);
    } finally {
      isLoading.value = false;
    }
  }

  // -----------------------------------------------------------------
  //  NAVIGATION LOGIC
  // -----------------------------------------------------------------
  void goPrevious() {
    if (currentIndex.value > 0) {
      // save current answer before leaving
      _saveCurrentAnswer();

      currentIndex.value--;
      _loadAnswerForCurrentQuestion();
    }
  }

  void nextPage() {
    if (!formKey.currentState!.validate()) return;

    // ---- 1. Must select something
    if (selectedAnswer.value.isEmpty) {
      AppSnackbarStyles.showError(
        title: 'Error',
        message: 'Please select an answer',
      );
      return;
    }

    // ---- 2. Store answer
    _saveCurrentAnswer();

    // ---- 3. Last question? → finish
    if (currentIndex.value == questionDetail.length - 1) {
      // OPTIONAL: send all answers to server here
      // await submitAllAnswers();

      Get.toNamed(
        AppRoutes.surveyInterviewer,
        arguments: {
          'survey_app_side_id': surveyId,
          
        },
      );
      return;
    }

    // ---- 4. Move to next question
    currentIndex.value++;
    selectedAnswer.value = ''; // clear radio for next question
    _loadAnswerForCurrentQuestion(); // restore if user came back
  }

  void _saveCurrentAnswer() {
    final q = questionDetail[currentIndex.value];
    answers[q.surveyQuestionId] = selectedAnswer.value;
  }

  void _loadAnswerForCurrentQuestion() {
    final q = questionDetail[currentIndex.value];
    selectedAnswer.value = answers[q.surveyQuestionId] ?? '';
  }

  // -----------------------------------------------------------------
  //  REFRESH
  // -----------------------------------------------------------------
  Future<void> refreshPage() async {
    await Future.delayed(const Duration(seconds: 1));
    await fetchallQestions(context: Get.context!, reset: true, appSideId: "");
    AppSnackbarStyles.showInfo(title: 'Refresh', message: 'Page refreshed');
  }

  // -----------------------------------------------------------------
  //  HELPERS
  // -----------------------------------------------------------------
  String removeHtmlTags(String htmlString) {
    final RegExp exp = RegExp(r'<[^>]*>', multiLine: true, caseSensitive: true);
    return htmlString.replaceAll(exp, '');
  }
}
