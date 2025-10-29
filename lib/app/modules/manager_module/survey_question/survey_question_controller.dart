// lib/app/modules/survey_question/survey_question_controller.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rudra/app/data/models/survey_question/get_survey_questions_response.dart';
import 'package:rudra/app/data/network/networkcall.dart';
import 'package:rudra/app/data/urls.dart';

import '../../../routes/app_routes.dart';
import '../../../widgets/app_snackbar_styles.dart';

class SurveyQuestionController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // <-- REAL DATA FROM API
  RxList<Question> questionDetail = <Question>[].obs;

  RxBool isLoadingq = true.obs;
  var errorMessageq = ''.obs;
  late String language;

  // <-- answer selected by the user
  final RxString selectedAnswer = ''.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    language = args?['language'] ?? 'Marathi';

    // <-- FETCH QUESTIONS AS SOON AS THE SCREEN OPENS
    fetchallQestions(
      context: Get.context!,
      testId: "1", // <-- adjust if you need a real testId
      surveyId: "1",
    );
  }
  String removeHtmlTags(String htmlString) {
  final RegExp exp = RegExp(r'<[^>]*>', multiLine: true, caseSensitive: true);
  return htmlString.replaceAll(exp, '');
}
  // -----------------------------------------------------------------
  //  FETCH QUESTIONS FROM SERVER
  // -----------------------------------------------------------------
  Future<void> fetchallQestions({
    required BuildContext context,
    bool reset = false,
    bool isPagination = false,
    bool forceFetch = false,
    String surveyId = "6",
    required String testId,
  }) async {
    try {
      isLoadingq.value = true;
      errorMessageq.value = '';

      final jsonBody = {
        "survey_app_side_id": surveyId,
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
        // clear previous data (useful for refresh)
        if (reset) questionDetail.clear();

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

  // -----------------------------------------------------------------
  //  NAVIGATE TO NEXT SCREEN
  // -----------------------------------------------------------------
  void nextPage() {
    if (formKey.currentState!.validate() && selectedAnswer.value.isNotEmpty) {
      Get.toNamed(
        AppRoutes.surveyInterviewer,
        arguments: {
          'language': language,
          'answer': selectedAnswer.value,
          // you can also pass the whole Question object if you need it later
        },
      );
    } else {
      AppSnackbarStyles.showError(
        title: 'Error',
        message: 'Please select an answer',
      );
    }
  }

  Future<void> refreshPage() async {
    await Future.delayed(const Duration(seconds: 1));
    await fetchallQestions(
      context: Get.context!,
      reset: true,
      testId: "1",
      surveyId: "1",
    );
    AppSnackbarStyles.showInfo(title: 'Refresh', message: 'Page refreshed');
  }
}
