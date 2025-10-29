// lib/app/modules/survey_question/survey_question_controller.dart

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
  RxInt currentIndex = 0.obs;

  // CHANGED: Store IDs instead of text
  RxString selectedAnswerId = ''.obs; // single-select ID
  RxList<String> selectedAnswerIds = <String>[].obs; // multi-select IDs

  final Map<String, String> answers =
      {}; // <surveyQuestionId, answer_id or json list>

  RxBool isLoadingq = true.obs;
  var errorMessageq = ''.obs;
  RxBool isSubmitting = false.obs;
  late String surveyId = "";
  late String surveyAppId = "";

  // -----------------------------------------------------------------
  //  INIT
  // -----------------------------------------------------------------
  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    surveyId = args?['survey_id']?.toString() ?? "";
    surveyAppId = args?['survey_app_side_id']?.toString() ?? "";

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.context != null) {
        fetchallQestions(context: Get.context!, appSideId: surveyAppId);
      }
    });
  }

  // -----------------------------------------------------------------
  //  FETCH QUESTIONS
  // -----------------------------------------------------------------
  Future<void> fetchallQestions({
    required BuildContext context,
    bool reset = false,
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
          selectedAnswerId.value = '';
          selectedAnswerIds.clear();
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

  // -----------------------------------------------------------------
  //  NAVIGATION LOGIC
  // -----------------------------------------------------------------
  void goPrevious() {
    if (currentIndex.value > 0) {
      _saveCurrentAnswer();
      currentIndex.value--;
      _loadAnswerForCurrentQuestion();
    }
  }

  void nextPage() {
    if (!formKey.currentState!.validate()) return;

    final bool hasAnswer = _isMultiSelect
        ? selectedAnswerIds.isNotEmpty
        : selectedAnswerId.value.isNotEmpty;

    if (!hasAnswer) {
      AppSnackbarStyles.showError(
        title: 'Error',
        message: 'Please select an answer',
      );
      return;
    }

    _saveCurrentAnswer();

    if (currentIndex.value == questionDetail.length - 1) {
      _submitAllAnswers();
      return;
    }

    currentIndex.value++;
    selectedAnswerId.value = '';
    selectedAnswerIds.clear();
    _loadAnswerForCurrentQuestion();
  }

  // -----------------------------------------------------------------
  //  ANSWER STORAGE
  // -----------------------------------------------------------------
  void _saveCurrentAnswer() {
    final q = questionDetail[currentIndex.value];
    if (_isMultiSelect) {
      answers[q.surveyQuestionId] = jsonEncode(selectedAnswerIds);
    } else {
      answers[q.surveyQuestionId] = selectedAnswerId.value;
    }
  }

  void _loadAnswerForCurrentQuestion() {
    final q = questionDetail[currentIndex.value];
    final saved = answers[q.surveyQuestionId];

    if (_isMultiSelect) {
      selectedAnswerIds.clear();
      if (saved != null) {
        final List<dynamic> decoded = jsonDecode(saved);
        selectedAnswerIds.addAll(decoded.cast<String>());
      }
    } else {
      selectedAnswerId.value = saved ?? '';
    }
  }

  bool get isMultiSelect {
    if (questionDetail.isEmpty) return false;
    return questionDetail[currentIndex.value].questionType == "1";
  }

  // -----------------------------------------------------------------
  //  SUBMIT ALL ANSWERS
  // -----------------------------------------------------------------
  Future<void> _submitAllAnswers() async {
    if (isSubmitting.value) return;
    isSubmitting.value = true;

    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      final List<Map<String, String>> payloadQuestions = answers.entries.map((
        e,
      ) {
        return {
          "question_id": e.key,
          "answer_id": e.value, // <-- This is now choice_id or JSON list of IDs
        };
      }).toList();

      final jsonBody = {
        "survey_app_side_id": surveyId,
        "questions": payloadQuestions,
      };

      final response =
          await Networkcall().postMethod(
                Networkutility.submitQuestionAnswerApi,
                Networkutility.submitQuestionAnswer,
                jsonEncode(jsonBody),
                Get.context!,
              )
              as List<GetSubmitAnswersResponse>?;

      Get.back();

      if (response != null &&
          response.isNotEmpty &&
          response[0].status == "true") {
        AppSnackbarStyles.showSuccess(
          title: 'Success',
          message: "Survey submitted successfully!",
        );

        questionDetail.clear();
        answers.clear();
        currentIndex.value = 0;
        selectedAnswerId.value = '';
        selectedAnswerIds.clear();

        Get.offNamed(
          AppRoutes.surveyInterviewer,
          arguments: {'survey_id': surveyId, 'survey_app_side_id': surveyAppId},
        );
      } else {
        final msg = response?[0].message ?? "Submission failed";
        AppSnackbarStyles.showError(title: 'Failed', message: msg);
      }
    } catch (e) {
      Get.back();
      AppSnackbarStyles.showError(
        title: 'Error',
        message: 'Submission failed: $e',
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  // -----------------------------------------------------------------
  //  REFRESH
  // -----------------------------------------------------------------
  Future<void> refreshPage() async {
    await Future.delayed(const Duration(seconds: 1));
    await fetchallQestions(
      context: Get.context!,
      reset: true,
      appSideId: surveyId,
    );
    AppSnackbarStyles.showInfo(title: 'Refresh', message: 'Page refreshed');
  }

  // -----------------------------------------------------------------
  //  HELPERS
  // -----------------------------------------------------------------
  String removeHtmlTags(String htmlString) {
    final RegExp exp = RegExp(r'<[^>]*>', multiLine: true, caseSensitive: true);
    return htmlString.replaceAll(exp, '');
  }

  bool get _isMultiSelect {
    if (questionDetail.isEmpty) return false;
    return questionDetail[currentIndex.value].questionType == "1";
  }

  bool get isLastQuestion => currentIndex.value == questionDetail.length - 1;
}
