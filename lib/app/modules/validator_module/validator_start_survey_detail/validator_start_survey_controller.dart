import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rudra/app/widgets/app_snackbar_styles.dart';

import '../../../data/models/validator/get_validator_survey_response.dart';
import '../../../data/models/validator/save_validator_comment_response.dart';
import '../../../data/network/exceptions.dart';
import '../../../data/network/networkcall.dart';
import '../../../data/urls.dart';
import '../../../utils/app_logger.dart';
import '../../../utils/app_utility.dart';

class ValidatorStartSurveyController extends GetxController {
  final PageController pageController = PageController();
  final RxInt currentPage = 0.obs;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final RxBool isLoading = false.obs;
  final AudioPlayer audioPlayer = AudioPlayer();
  final RxBool isPlaying = false.obs;
  final RxDouble currentPosition = 0.0.obs;
  final RxDouble totalDuration = 0.0.obs;

  String surveyId = '';
  String responseId = '';

  Rx<ValidatorSurveyData?> surveyDetailData = Rx<ValidatorSurveyData?>(null);
  final RxMap<String, TextEditingController> commentControllers =
      <String, TextEditingController>{}.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    surveyId = args['survey_id']?.toString() ?? '';
    responseId = args['response_id']?.toString() ?? '';
    _setupAudioListeners();
    fetchSurveyDetails();
  }

  void _setupAudioListeners() {
    audioPlayer.onPlayerStateChanged.listen((state) {
      isPlaying.value = state == PlayerState.playing;
    });

    audioPlayer.onDurationChanged.listen((duration) {
      totalDuration.value = duration.inSeconds.toDouble();
    });

    audioPlayer.onPositionChanged.listen((position) {
      currentPosition.value = position.inSeconds.toDouble();
    });
  }

  @override
  void onClose() {
    audioPlayer.dispose();
    for (var controller in commentControllers.values) {
      controller.dispose();
    }
    commentControllers.clear();
    super.onClose();
  }

  void clearAllComments() {
    for (var controller in commentControllers.values) {
      controller.clear();
    }
  }

  Future<void> refreshPage() async {
    await fetchSurveyDetails();
  }

  Future<void> fetchSurveyDetails() async {
    isLoading.value = true;
    try {
      final jsonBody = {
        "survey_id": surveyId,
        "validator_id": AppUtility.userID ?? "",
        "response_id": responseId,
        "user_id": AppUtility.userID,
      };

      final response = await Networkcall().postMethod(
        Networkutility.viewQuestionsDetailsForValidatorApi,
        Networkutility.viewQuestionsDetailsForValidator,
        jsonEncode(jsonBody),
        Get.context!,
      ) as List<GetValidatorSurveyResponse>?;

      if (response == null || response.isEmpty) {
        AppSnackbarStyles.showError(
          title: 'Error',
          message: 'No response from server',
        );
        return;
      }

      final apiResponse = response.first;
      if (apiResponse.status != "true") {
        AppSnackbarStyles.showError(
          title: 'Error',
          message: apiResponse.message,
        );
        return;
      }

      surveyDetailData.value = apiResponse.data;

      // Initialize empty comment controllers for each question
      for (var qa in apiResponse.data.questionsAndAnswers) {
        commentControllers[qa.questionId] = TextEditingController();
      }

      AppLogger.d('Survey details loaded successfully', tag: 'ValidatorSurvey');
    } on NoInternetException catch (e) {
      AppSnackbarStyles.showError(title: 'Error', message: e.message);
    } on TimeoutException catch (e) {
      AppSnackbarStyles.showError(title: 'Error', message: e.message);
    } on HttpException catch (e) {
      AppSnackbarStyles.showError(
        title: 'Error',
        message: '${e.message} (Code: ${e.statusCode})',
      );
    } on ParseException catch (e) {
      AppSnackbarStyles.showError(title: 'Error', message: e.message);
    } catch (e) {
      AppSnackbarStyles.showError(
        title: 'Error',
        message: 'Unexpected error: $e',
      );
      AppLogger.e('Error: $e', tag: 'ValidatorSurvey');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> nextPage(BuildContext context) async {
    final data = surveyDetailData.value;
    if (data == null) return;

    final totalSteps = _getTotalSteps();
    if (currentPage.value < totalSteps - 1) {
      // Save comment if provided (optional)
      if (currentPage.value > 0 &&
          currentPage.value <= data.questionsAndAnswers.length) {
        final questionIndex = currentPage.value - 1;
        final qa = data.questionsAndAnswers[questionIndex];
        final comment = commentControllers[qa.questionId]?.text.trim() ?? '';

        if (comment.isNotEmpty) {
          await saveQuestionComment(qa.questionId, comment);
        }
      }
      currentPage.value++;
    }
  }

  Future<void> saveQuestionComment(String questionId, String comment) async {
    try {
      final jsonBody = {
        "survey_id": surveyId,
        "validator_id": AppUtility.userID ?? "",
        "response_id": responseId,
        "question_id": questionId,
        "validator_comment": comment,
        "user_id": AppUtility.userID,
      };

      final response = await Networkcall().postMethod(
        Networkutility.saveQuestionCommentOfValidatorApi,
        Networkutility.saveQuestionCommentOfValidator,
        jsonEncode(jsonBody),
        Get.context!,
      );

      if (response != null && response.isNotEmpty) {
        final apiResponse = response.first as SaveValidatorCommentResponse;
        if (apiResponse.status == 'true') {
          commentControllers[questionId]?.clear();
          AppSnackbarStyles.showSuccess(
            title: 'Success',
            message: apiResponse.message,
          );
          AppLogger.d('Comment saved successfully', tag: 'ValidatorSurvey');
        } else {
          AppSnackbarStyles.showError(
            title: 'Error',
            message: apiResponse.message,
          );
        }
      }
    } catch (e) {
      AppLogger.e('Error saving comment: $e', tag: 'ValidatorSurvey');
      AppSnackbarStyles.showError(
        title: 'Error',
        message: 'Failed to save comment',
      );
    }
  }

  int _getTotalSteps() {
    if (surveyDetailData.value == null) return 2;
    return 2 + surveyDetailData.value!.questionsAndAnswers.length;
  }

  void previousPage() {
    if (currentPage.value > 0) {
      currentPage.value--;
    }
  }

  Future<void> playPauseAudio(String? audioPath) async {
    if (audioPath == null || audioPath.isEmpty) {
      AppSnackbarStyles.showError(
        title: 'No Audio',
        message: 'No audio file available',
      );
      return;
    }

    try {
      if (isPlaying.value) {
        await audioPlayer.pause();
      } else {
        if (audioPath.startsWith('http')) {
          await audioPlayer.play(UrlSource(audioPath));
        } else {
          await audioPlayer.play(DeviceFileSource(audioPath));
        }
      }
    } catch (e) {
      AppLogger.e('Error playing audio: $e', tag: 'AudioPlayer');
      AppSnackbarStyles.showError(
        title: 'Audio Error',
        message: 'Failed to play audio file',
      );
    }
  }

  Future<void> seekAudio(double seconds) async {
    await audioPlayer.seek(Duration(seconds: seconds.toInt()));
  }

  Future<void> rewind5Seconds() async {
    final newPosition =
        (currentPosition.value - 5).clamp(0.0, totalDuration.value);
    await seekAudio(newPosition);
  }

  Future<void> forward5Seconds() async {
    final newPosition =
        (currentPosition.value + 5).clamp(0.0, totalDuration.value);
    await seekAudio(newPosition);
  }

  String formatDuration(double seconds) {
    final duration = Duration(seconds: seconds.toInt());
    final minutes = duration.inMinutes;
    final secs = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}
