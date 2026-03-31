// lib/app/modules/survey_question/survey_question_controller.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:record/record.dart';
import 'package:rudra/app/data/local/survey_local_repository.dart';
import 'package:rudra/app/data/models/survey_question/get_survey_questions_response.dart';
import 'package:rudra/app/routes/app_routes.dart';
import 'package:rudra/app/utils/app_logger.dart';
import 'package:rudra/app/widgets/connctivityservice.dart';

import '../../../../utils/app_utility.dart';
import '../../../../widgets/app_snackbar_styles.dart';
import '../../../audio_recorder/audio_recorder_controller.dart';

class ExecutiveSurveyQuestionController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // -----------------------------------------------------------------
  //  ALL QUESTIONS FROM API
  // -----------------------------------------------------------------
  RxList<Question> questionDetail = <Question>[].obs;
  List<Question> allQuestions = []; // Store all questions including contingency
  RxList<Question> visibleQuestions =
      <Question>[].obs; // Questions to show based on answers

  // -----------------------------------------------------------------
  //  UI STATE
  // -----------------------------------------------------------------
  RxInt currentIndex = 0.obs;
  RxString selectedAnswerId = ''.obs;
  RxList<String> selectedAnswerIds = <String>[].obs;
  final Map<String, String> answers = {};
  final Map<String, TextEditingController> textControllers = {};

  RxBool isLoadingq = true.obs;
  var errorMessageq = ''.obs;
  RxBool isSubmitting = false.obs;
  late String surveyId = "";
  late String surveyAppId = "";
  late String languageId = "0";
  late String villageAreaId = "";
  String? zpWardId;

  // -----------------------------------------------------------------
  //  AUDIO RECORDING
  // -----------------------------------------------------------------
 final AudioRecorder _audioRecorder = AudioRecorder();
  RxBool isRecording = false.obs;
  RxString recordingPath = ''.obs;
  late AudioRecorderController audioRecorder;

  final SurveyLocalRepository _localRepo = SurveyLocalRepository();
  final ConnectivityService _connectivityService =
      Get.find<ConnectivityService>();

  // -----------------------------------------------------------------
  //  INIT
  // -----------------------------------------------------------------
  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    surveyId = args?['survey_id']?.toString() ?? "";
    surveyAppId = args?['survey_app_side_id']?.toString() ?? "";
    languageId = args?['language_id']?.toString() ?? "0";
    zpWardId = args?['zp_ward_id']?.toString();
    villageAreaId = args?['village_area_id']?.toString() ?? "";

    // Get audio recorder instance
    if (Get.isRegistered<AudioRecorderController>()) {
      audioRecorder = Get.find<AudioRecorderController>();
    }

    AppLogger.i(
      '📋 Survey Question Init:\n'
      '   survey_id: $surveyId\n'
      '   survey_app_side_id: $surveyAppId\n'
      '   language_id: $languageId\n'
      '   zp_ward_id: $zpWardId\n'
      '   village_area_id: $villageAreaId',
      tag: 'ExecutiveSurveyQuestionController',
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadQuestionsFromCache();
    });
  }

  // -----------------------------------------------------------------
  //  LOAD QUESTIONS FROM CACHE
  // -----------------------------------------------------------------
  Future<void> _loadQuestionsFromCache() async {
    try {
      isLoadingq.value = true;
      errorMessageq.value = '';

      AppLogger.i(
          'Loading questions from cache for survey: $surveyId, language: $languageId',
          tag: 'ExecutiveSurveyQuestionController');

      final questions =
          await _localRepo.getSurveyQuestions(surveyId, languageId);

      if (questions.isNotEmpty) {
        questionDetail.clear();
        allQuestions.clear();
        visibleQuestions.clear();
        answers.clear();
        currentIndex.value = 0;
        selectedAnswerId.value = '';
        selectedAnswerIds.clear();

        for (var q in questions) {
          allQuestions.add(
            Question(
              surveyQuestionId: q['question_id'],
              questionId: q['question_id'],
              sequenceNumber: q['sequence_number'],
              question: q['question'],
              questionType: q['question_type'],
              parentQuestionId: q['parent_question_id'],
              parentOptionId: q['parent_option_id'],
              options: (q['options'] as List)
                  .map((o) => Option(
                        optionId: o['option_id'],
                        choiceText: o['choice_text'],
                        textFieldType: o['text_field_type'],
                      ))
                  .toList(),
            ),
          );
        }

        _filterOrphanedQuestions();
        _buildVisibleQuestions();

        AppLogger.i(
            '✅ Loaded ${allQuestions.length} questions, ${questionDetail.length} visible',
            tag: 'ExecutiveSurveyQuestionController');
      } else {
        AppLogger.w('⚠️ No cached questions found',
            tag: 'ExecutiveSurveyQuestionController');
        errorMessageq.value = 'No questions available';
        AppSnackbarStyles.showError(
          title: 'No Questions',
          message: 'No questions found for this survey.',
        );
      }
    } catch (e, stackTrace) {
      AppLogger.e('Error loading questions from cache',
          error: e,
          stackTrace: stackTrace,
          tag: 'ExecutiveSurveyQuestionController');
      errorMessageq.value = 'Failed to load questions';
      AppSnackbarStyles.showError(
        title: 'Error',
        message: 'Failed to load questions',
      );
    } finally {
      isLoadingq.value = false;
    }
  }

  // -----------------------------------------------------------------
  //  NAVIGATION & ANSWER LOGIC
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

    final bool hasAnswer = isTextField
        ? (textControllers[questionDetail[currentIndex.value].questionId]
                ?.text
                .trim()
                .isNotEmpty ??
            false)
        : isMultiSelect
            ? selectedAnswerIds.isNotEmpty
            : selectedAnswerId.value.isNotEmpty;

    if (!hasAnswer) {
      AppSnackbarStyles.showError(
        title: 'Error',
        message: 'Please provide an answer',
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

  void _saveCurrentAnswer() {
    final q = questionDetail[currentIndex.value];
    if (isTextField) {
      final textAnswer = textControllers[q.questionId]?.text.trim() ?? '';
      answers[q.surveyQuestionId] = textAnswer;
    } else if (isMultiSelect) {
      answers[q.surveyQuestionId] = jsonEncode(selectedAnswerIds);
    } else {
      answers[q.surveyQuestionId] = selectedAnswerId.value;
    }

    // Rebuild visible questions if this is a contingency parent
    if (isContingency || q.questionType == "4") {
      _buildVisibleQuestions();
    }
  }

  void _loadAnswerForCurrentQuestion() {
    final q = questionDetail[currentIndex.value];
    final saved = answers[q.surveyQuestionId];

    if (isTextField) {
      if (!textControllers.containsKey(q.questionId)) {
        textControllers[q.questionId] = TextEditingController();
      }
      textControllers[q.questionId]!.text = saved ?? '';
    } else if (isMultiSelect) {
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

  bool get isTextField {
    if (questionDetail.isEmpty) return false;
    return questionDetail[currentIndex.value].questionType == "2";
  }

  bool get isBoolean {
    if (questionDetail.isEmpty) return false;
    return questionDetail[currentIndex.value].questionType == "3";
  }

  bool get isContingency {
    if (questionDetail.isEmpty) return false;
    return questionDetail[currentIndex.value].questionType == "4";
  }

  // Filter out orphaned questions (child questions whose parent doesn't exist)
  void _filterOrphanedQuestions() {
    final validQuestionIds = allQuestions.map((q) => q.questionId).toSet();

    allQuestions.removeWhere((q) {
      // Keep root questions (no parent)
      if (q.parentQuestionId == null || q.parentQuestionId!.isEmpty) {
        return false;
      }

      // Remove if parent question doesn't exist
      final hasParent = validQuestionIds.contains(q.parentQuestionId);
      if (!hasParent) {
        AppLogger.w(
          '🚫 Filtering orphaned question: ${q.questionId} (parent: ${q.parentQuestionId} not found)',
          tag: 'ExecutiveSurveyQuestionController',
        );
      }
      return !hasParent;
    });
  }

  // Build visible questions based on answers
  void _buildVisibleQuestions() {
    visibleQuestions.clear();

    // Add root questions (no parent)
    for (var q in allQuestions) {
      if (q.parentQuestionId == null || q.parentQuestionId!.isEmpty) {
        visibleQuestions.add(q);
        _addChildQuestions(q.questionId);
      }
    }

    questionDetail.assignAll(visibleQuestions);
  }

  // Recursively add child questions if parent option is selected
  void _addChildQuestions(String parentQuestionId) {
    final parentAnswer = answers.entries
        .firstWhere(
          (e) => allQuestions.any((q) =>
              q.surveyQuestionId == e.key && q.questionId == parentQuestionId),
          orElse: () => const MapEntry('', ''),
        )
        .value;

    if (parentAnswer.isEmpty) return;

    // Handle multiple select (JSON array)
    List<String> selectedOptions = [];
    if (parentAnswer.startsWith('[')) {
      selectedOptions = List<String>.from(jsonDecode(parentAnswer));
    } else {
      selectedOptions = [parentAnswer];
    }

    // Find and add child questions
    for (var q in allQuestions) {
      if (q.parentQuestionId == parentQuestionId &&
          selectedOptions.contains(q.parentOptionId)) {
        visibleQuestions.add(q);
        _addChildQuestions(q.questionId); // Recursive for nested contingency
      }
    }
  }

  Future<void> _submitAllAnswers() async {
    if (isSubmitting.value) {
      AppLogger.w('⚠️ Already submitting, ignoring duplicate call',
          tag: 'ExecutiveSurveyQuestionController');
      return;
    }
    isSubmitting.value = true;

    try {
      AppLogger.i('🚀 Starting survey submission (offline-first)',
          tag: 'ExecutiveSurveyQuestionController');

      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      final List<Map<String, dynamic>> payloadQuestions = [];

      for (var q in questionDetail) {
        final answer = answers[q.surveyQuestionId];
        if (answer == null || answer.isEmpty) continue;

        if (q.questionType == "2") {
          // Text field type
          final textFieldType =
              q.options.isNotEmpty ? q.options.first.textFieldType : "0";
          payloadQuestions.add({
            "question_id": q.questionId,
            "question_type": "2",
            "text_field_type": textFieldType ?? "0",
            "answer": answer,
          });
        } else if (q.questionType == "1") {
          // Multi-select - answer is JSON array string
          final List<dynamic> answerIds = jsonDecode(answer);
          payloadQuestions.add({
            "question_id": q.questionId,
            "answer_id": answerIds,
          });
        } else {
          // Single select (Boolean, Contingency) - answer is single ID
          payloadQuestions.add({
            "question_id": q.questionId,
            "answer_id": answer,
          });
        }
      }

      AppLogger.d('Prepared ${payloadQuestions.length} answers',
          tag: 'ExecutiveSurveyQuestionController');

      // Always save locally first (offline-first approach)
      await _saveSubmissionLocally(payloadQuestions);

      // Close dialog BEFORE navigation
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      // Small delay to ensure dialog closes
      await Future.delayed(const Duration(milliseconds: 100));
    } catch (e, stackTrace) {
      AppLogger.e('Error during submission',
          error: e,
          stackTrace: stackTrace,
          tag: 'ExecutiveSurveyQuestionController');
      Get.back();
      AppSnackbarStyles.showError(
        title: 'Error',
        message: 'Failed to save survey',
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> _saveSubmissionLocally(
      List<Map<String, dynamic>> payloadQuestions) async {
    try {
      AppLogger.i(
        '\n${'💾 ' * 20}\n💾 SAVING OFFLINE SUBMISSION\n${'💾 ' * 20}',
        tag: 'ExecutiveSurveyQuestionController',
      );

      // Get audio path from AudioRecorderController
      String audioPath = '';
      if (Get.isRegistered<AudioRecorderController>()) {
        final recorder = Get.find<AudioRecorderController>();
        audioPath = recorder.recordingPath.value;
      }

      final submission = {
        'survey_app_side_id': '',
        'offline_survey_id': surveyAppId,
        'survey_id': surveyId,
        'survey_language_id': languageId,
        'village_area_id': villageAreaId,
        'zp_ward_id': zpWardId,
        'user_id': AppUtility.userID ?? '',
        'interviewer_name': '',
        'interviewer_age': '',
        'interviewer_gender': '',
        'interviewer_phone': '',
        'interviewer_cast': '',
        'answers': jsonEncode(payloadQuestions),
        'audio_path': audioPath,
        'completion_stage': 'interviewer_info',
      };

      await _localRepo.savePendingSubmission(submission);

      AppLogger.i(
        '✅ Submission saved locally',
        tag: 'ExecutiveSurveyQuestionController',
      );

      // Navigate to interviewer page
      Get.offNamed(
        AppRoutes.executiveSurveyInterviewer,
        arguments: {'survey_id': surveyId, 'survey_app_side_id': surveyAppId},
      );
    } catch (e, stackTrace) {
      AppLogger.e(
        '❌ Failed to save submission locally',
        error: e,
        stackTrace: stackTrace,
        tag: 'ExecutiveSurveyQuestionController',
      );
      rethrow;
    }
  }

  Future<void> refreshPage() async {
    await Future.delayed(const Duration(seconds: 1));
    await _loadQuestionsFromCache();
    AppSnackbarStyles.showInfo(title: 'Refresh', message: 'Page refreshed');
  }

  String removeHtmlTags(String htmlString) {
    final RegExp exp = RegExp(r'<[^>]*>', multiLine: true, caseSensitive: true);
    return htmlString.replaceAll(exp, '');
  }

  bool get isLastQuestion => currentIndex.value == questionDetail.length - 1;
}
