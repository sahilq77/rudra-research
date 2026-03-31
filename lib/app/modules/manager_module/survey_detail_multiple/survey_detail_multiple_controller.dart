import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/my_survey/get_survey_detail_response.dart';
import '../../../data/network/exceptions.dart';
import '../../../data/network/networkcall.dart';
import '../../../data/urls.dart';
import '../../../utils/app_logger.dart';
import '../../../utils/app_utility.dart';
import '../../../widgets/app_snackbar_styles.dart';

class SurveyDetailMultipleController extends GetxController {
  final PageController pageController = PageController();
  final RxInt currentPage = 0.obs;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final RxBool isLoading = false.obs;
  final AudioPlayer audioPlayer = AudioPlayer();
  final RxBool isPlaying = false.obs;
  final RxDouble currentPosition = 0.0.obs;
  final RxDouble totalDuration = 0.0.obs;

  late final String surveyId;
  late final String userId;
  late final String peopleDetailsId;

  Rx<SurveyDetailData?> surveyDetailData = Rx<SurveyDetailData?>(null);

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    surveyId = args['surveyId']?.toString() ?? '';
    userId = args['userId']?.toString() ?? '';
    peopleDetailsId = args['peopleDetailsId']?.toString() ?? '';

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
    super.onClose();
  }

  Future<void> refreshPage() async {
    await fetchSurveyDetails();
  }

  Future<void> fetchSurveyDetails() async {
    isLoading.value = true;
    try {
      final jsonBody = {
        "survey_id": surveyId,
        "user_id": userId,
        "offset": "0",
        "limit": "10",
        "people_details_id": peopleDetailsId,
        "logged_in_user_id": AppUtility.userID,
      };

      final response = await Networkcall().postMethod(
        Networkutility.getSurveyDetailAccToPeopleIdApi,
        Networkutility.getSurveyDetailAccToPeopleId,
        jsonEncode(jsonBody),
        Get.context!,
      ) as List<GetSurveyDetailResponse>?;

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
      AppLogger.d('Survey details loaded successfully', tag: 'SurveyDetail');
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
      AppLogger.e('Error: $e', tag: 'SurveyDetail');
    } finally {
      isLoading.value = false;
    }
  }

  void nextPage() {
    final totalSteps = _getTotalSteps();
    if (currentPage.value < totalSteps - 1) {
      currentPage.value++;
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
        // Handle both URL and local file paths for .wav files
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

  void exitToResponseList() {
    Get.back();
  }
}
