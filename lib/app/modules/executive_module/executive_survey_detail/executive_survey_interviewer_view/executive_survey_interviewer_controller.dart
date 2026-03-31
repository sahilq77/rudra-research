// lib/app/modules/executive_module/executive_survey_detail/executive_survey_interviewer_view/executive_survey_interviewer_controller.dart
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:rudra/app/data/models/interviewer_info/get_cast_response.dart';
import 'package:rudra/app/data/urls.dart';
import 'package:rudra/app/modules/audio_recorder/audio_recorder_controller.dart';
import 'package:rudra/app/utils/app_images.dart';
import 'package:rudra/app/utils/responsive_utils.dart';

import '../../../../data/local/database_helper.dart';
import '../../../../data/local/survey_local_repository.dart';
import '../../../../routes/app_routes.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_logger.dart';
import '../../../../widgets/app_snackbar_styles.dart';
import '../../../../widgets/app_style.dart';
import '../../../../widgets/connctivityservice.dart';
import '../executive_survey_question/executive_survey_question_controller.dart';

class _WavHeader {
  final int sampleRate;
  final int channels;
  final int dataOffset;

  _WavHeader(this.sampleRate, this.channels, this.dataOffset);

  factory _WavHeader.fromBytes(Uint8List bytes) {
    final view = ByteData.sublistView(bytes);

    if (String.fromCharCodes(bytes, 0, 4) != 'RIFF') {
      throw Exception('Not a WAV file');
    }

    final fmtPos = _findChunk(bytes, [0x66, 0x6D, 0x74, 0x20]);
    if (fmtPos == -1) throw Exception('fmt chunk missing');

    final audioFormat = view.getUint16(fmtPos + 8, Endian.little);
    if (audioFormat != 1) throw Exception('Only PCM supported');
    final channels = view.getUint16(fmtPos + 10, Endian.little);
    final sampleRate = view.getUint32(fmtPos + 12, Endian.little);

    final dataPos = _findChunk(bytes, [0x64, 0x61, 0x74, 0x61]);
    if (dataPos == -1) throw Exception('data chunk missing');

    final dataOffset = dataPos + 8;
    return _WavHeader(sampleRate, channels, dataOffset);
  }
}

int _findChunk(Uint8List bytes, List<int> signature) {
  for (int i = 0; i <= bytes.length - 4; i++) {
    bool match = true;
    for (int j = 0; j < 4; j++) {
      if (bytes[i + j] != signature[j]) {
        match = false;
        break;
      }
    }
    if (match) return i;
  }
  return -1;
}

class ExecutiveSurveyInterviewerController extends GetxController {
  RxList<CastData> castList = <CastData>[].obs;
  var isLoadings = false.obs;
  var errorMessages = ''.obs;
  var isLoadingCast = false.obs;
  var errorMessageCast = ''.obs;
  var isLoading = false.obs;
  final RxBool isSubmitting = false.obs;

  final RxString selectedCast = ''.obs;
  final RxString selectedCastId = ''.obs;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  final List<String> ageRanges = ['18-25', '26-39', '40-60', '60+'];
  final RxString selectedAgeLabel = ''.obs;
  final RxInt selectedAgeId = 0.obs;

  final List<String> genders = ['Male', 'Female', 'Other'];
  final RxString selectedGenderLabel = ''.obs;
  final RxInt selectedGenderId = 0.obs;

  late String surveyId = "";
  late String surveyAppId = "";
  late String villageAreaId = "";

  final RxBool isNameRequired = true.obs;
  final RxBool isAgeRequired = true.obs;
  final RxBool isGenderRequired = true.obs;
  final RxBool isPhoneRequired = true.obs;
  final RxBool isCasteRequired = true.obs;

  late final AudioRecorderController audioRecorder;

  @override
  void onInit() {
    super.onInit();

    audioRecorder = Get.put(AudioRecorderController());

    final args = Get.arguments as Map<String, dynamic>?;
    surveyId = args?['survey_id']?.toString() ?? "";
    surveyAppId = args?['survey_app_side_id']?.toString() ?? "";
    villageAreaId = args?['village_area_id']?.toString() ?? "";

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadValidationSettings();
      await _loadCastsFromCache();
    });
  }

  Future<void> _loadValidationSettings() async {
    try {
      final db = await DatabaseHelper.instance.database;
      final result = await db.query(
        'survey_details',
        where: 'survey_id = ?',
        whereArgs: [surveyId],
        limit: 1,
      );

      if (result.isNotEmpty) {
        final data = result.first;
        isNameRequired.value = (data['validation_name'] ?? '1') == '1';
        isAgeRequired.value = (data['validation_age'] ?? '1') == '1';
        isGenderRequired.value = (data['validation_gender'] ?? '1') == '1';
        isPhoneRequired.value = (data['validation_phone'] ?? '1') == '1';
        isCasteRequired.value = (data['validation_caste'] ?? '1') == '1';
        AppLogger.i(
          'Validation settings loaded: name=$isNameRequired, age=$isAgeRequired, gender=$isGenderRequired, phone=$isPhoneRequired, caste=$isCasteRequired',
          tag: 'ExecutiveSurveyInterviewerController',
        );
      }
    } catch (e) {
      AppLogger.e('Error loading validation settings: $e',
          tag: 'ExecutiveSurveyInterviewerController');
    }
  }

  List<String> getCastNames() {
    return castList.map((s) => s.castName).toSet().toList();
  }

  String? getCastId(String? castName) {
    if (castName == null) return '';
    return castList
            .firstWhereOrNull((cast) => cast.castName == castName)
            ?.castId ??
        '';
  }

  void setSelectedCast(String? castName) {
    selectedCast.value = castName ?? '';
    selectedCastId.value = getCastId(castName) ?? '';
  }

  void setSelectedAge(String? label) {
    selectedAgeLabel.value = label ?? '';
    selectedAgeId.value = ageRanges.indexOf(label ?? '');
  }

  void setSelectedGender(String? label) {
    selectedGenderLabel.value = label ?? '';
    selectedGenderId.value = genders.indexOf(label ?? '');
  }

  Future<String?> setSurvey({
    required BuildContext context,
    required formKey,
  }) async {
    if (!formKey.currentState!.validate()) return null;

    // Prevent double submission
    if (isSubmitting.value) {
      AppLogger.w('Submission already in progress',
          tag: 'ExecutiveSurveyInterviewerController');
      return null;
    }

    if (audioRecorder.isRecording.value) {
      final stoppedPath = await audioRecorder.stopRecording();
      if (stoppedPath != null) {
        AppLogger.i('Recording stopped: $stoppedPath',
            tag: 'ExecutiveSurveyInterviewerController');
      }
    }

    try {
      isSubmitting.value = true;
      isLoadings.value = true;
      errorMessages.value = '';

      await _saveInterviewerInfoLocally();

      _showSuccessDialog(Get.context!);

      return surveyAppId;
    } catch (e, s) {
      AppLogger.e('Error saving interviewer info',
          error: e, stackTrace: s, tag: 'ExecutiveSurveyInterviewerController');
      AppSnackbarStyles.showError(
        title: 'Error',
        message: 'Failed to save interviewer info',
      );
      return null;
    } finally {
      isLoadings.value = false;
      isSubmitting.value = false;
    }
  }

  Future<void> _saveInterviewerInfoLocally() async {
    try {
      AppLogger.i(
        '\n${'💾 ' * 20}\n💾 UPDATING PENDING SUBMISSION WITH INTERVIEWER INFO\n${'💾 ' * 20}',
        tag: 'ExecutiveSurveyInterviewerController',
      );

      final db = await DatabaseHelper.instance.database;

      var results = await db.query(
        'pending_submissions',
        where: 'offline_survey_id = ? AND synced = 0',
        whereArgs: [surveyAppId],
        limit: 1,
      );

      if (results.isEmpty) {
        AppLogger.w(
          '⚠️ No pending submission found for offline_survey_id: $surveyAppId',
          tag: 'ExecutiveSurveyInterviewerController',
        );

        // Try to find most recent unsynced submission for this survey
        results = await db.query(
          'pending_submissions',
          where: 'survey_id = ? AND synced = 0',
          whereArgs: [surveyId],
          orderBy: 'created_at DESC',
          limit: 1,
        );

        if (results.isEmpty) {
          AppLogger.e(
            '❌ No pending submission found for survey_id: $surveyId',
            tag: 'ExecutiveSurveyInterviewerController',
          );
          throw Exception('No pending submission found');
        }

        AppLogger.i(
          '✅ Found fallback submission (ID: ${results.first['id']}) for survey_id: $surveyId',
          tag: 'ExecutiveSurveyInterviewerController',
        );
      }

      final submissionId = results.first['id'];

      // Capture actual completion time
      final completionTime = DateTime.now().toIso8601String();

      await db.update(
        'pending_submissions',
        {
          'interviewer_name': nameController.text.trim(),
          'interviewer_age': selectedAgeId.value.toString(),
          'interviewer_gender': selectedGenderId.value.toString(),
          'interviewer_phone': phoneController.text.trim(),
          'interviewer_cast': selectedCastId.value,
          'audio_path': audioRecorder.recordingPath.value,
          'completion_stage': 'completed',
          'actual_completion_time': completionTime,
          'updated_at': completionTime,
        },
        where: 'id = ?',
        whereArgs: [submissionId],
      );

      final updatedSubmission = await db.query(
        'pending_submissions',
        where: 'id = ?',
        whereArgs: [submissionId],
      );

      if (updatedSubmission.isNotEmpty) {
        final data = updatedSubmission.first;

        AppLogger.i(
          '\n${'🔥' * 40}\n'
          '📤 API REQUEST FORMAT (Form-Data):\n'
          '${'🔥' * 40}\n'
          'URL: ${Networkutility.setCompleteSurvey}\n'
          '\nFORM FIELDS:\n'
          '  survey_id: ${data['survey_id']}\n'
          '  survey_language_id: ${data['survey_language_id']}\n'
          '  zp_ward_id: ${data['zp_ward_id']}\n'
          '  village_area_id: ${data['village_area_id']}\n'
          '  survey_done_by: ${data['user_id']}\n'
          '  questions: ${data['answers']}\n'
          '  name: ${data['interviewer_name']}\n'
          '  age: ${data['interviewer_age']}\n'
          '  gender: ${data['interviewer_gender']}\n'
          '  mob_number: ${data['interviewer_phone']}\n'
          '  cast_id: ${data['interviewer_cast']}\n'
          '  created_on: ${data['created_at']}\n'
          '  updated_on: ${data['updated_at']}\n'
          '  recorded_audio: ${data['audio_path']}\n'
          '${'🔥' * 40}',
          tag: 'ExecutiveSurveyInterviewerController',
        );

        _connectivityService.checkConnectivity().then((isConnected) {
          if (isConnected) {
            _testApiCall(data);
          } else {
            AppLogger.i(
              '⚠️ Offline mode - Survey saved locally and will be uploaded when online',
              tag: 'ExecutiveSurveyInterviewerController',
            );
          }
        });
      }

      AppLogger.i('✅ Interviewer info saved successfully',
          tag: 'ExecutiveSurveyInterviewerController');

      if (Get.isRegistered<ExecutiveSurveyQuestionController>()) {
        final questionController =
            Get.find<ExecutiveSurveyQuestionController>();
        questionController.questionDetail.clear();
        questionController.answers.clear();
        questionController.currentIndex.value = 0;
        questionController.selectedAnswerId.value = '';
        questionController.selectedAnswerIds.clear();
      }

      AppSnackbarStyles.showSuccess(
        title: 'Survey Saved',
        message: 'Survey saved successfully!',
      );
    } catch (e, stackTrace) {
      AppLogger.e('Error saving interviewer info locally',
          error: e,
          stackTrace: stackTrace,
          tag: 'ExecutiveSurveyInterviewerController');
      rethrow;
    }
  }

  void discardSurvey() {
    _showDiscardDialog(Get.context!);
  }

  void _showDiscardDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Discard Survey',
                  style: AppStyle.heading1PoppinsBlack.responsive,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Are you sure you want to discard this survey?',
                  style: AppStyle.bodySmallPoppinsGrey.responsive,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        minimumSize: const Size(100, 40),
                        side: const BorderSide(color: AppColors.primary),
                      ),
                      child: Text(
                        'No',
                        style: AppStyle.buttonTextSmallPoppinsBlack.responsive
                            .copyWith(color: AppColors.primary),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        resetForm();
                        Get.back(); // Close dialog
                        Get.offAllNamed(AppRoutes.executiveHome);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        elevation: 0,
                        minimumSize: const Size(100, 40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Yes',
                        style: AppStyle.buttonTextSmallPoppinsWhite.responsive,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void resetForm() {
    nameController.clear();
    phoneController.clear();
    selectedAgeLabel.value = '';
    selectedAgeId.value = 0;
    selectedGenderLabel.value = '';
    selectedGenderId.value = 0;
    selectedCast.value = '';
    selectedCastId.value = '';
    audioRecorder.reset();
  }

  Future<void> refreshPage() async {
    await Future.delayed(const Duration(seconds: 1));
    AppSnackbarStyles.showInfo(title: 'Refresh', message: 'Page refreshed');
  }

  Future<void> _testApiCall(Map<String, dynamic> data) async {
    try {
      AppLogger.i(
        '\n${'🚀' * 40}\n'
        '🚀 TESTING API CALL (Immediate Response)\n'
        '${'🚀' * 40}',
        tag: 'ExecutiveSurveyInterviewerController',
      );

      final request = http.MultipartRequest(
        'POST',
        Uri.parse(Networkutility.setCompleteSurvey),
      );

      request.fields['survey_id'] = data['survey_id']?.toString() ?? '';
      request.fields['survey_language_id'] =
          data['survey_language_id']?.toString() ?? '';
      request.fields['zp_ward_id'] = data['zp_ward_id']?.toString() ?? '';
      request.fields['village_area_id'] =
          data['village_area_id']?.toString() ?? '';
      request.fields['survey_done_by'] = data['user_id']?.toString() ?? '';
      request.fields['questions'] = data['answers']?.toString() ?? '[]';
      request.fields['name'] = data['interviewer_name']?.toString() ?? '';
      request.fields['age'] = data['interviewer_age']?.toString() ?? '0';
      request.fields['gender'] = data['interviewer_gender']?.toString() ?? '';
      request.fields['mob_number'] =
          data['interviewer_phone']?.toString() ?? '';
      request.fields['cast_id'] = data['interviewer_cast']?.toString() ?? '';
      request.fields['created_on'] = data['created_at']?.toString() ?? '';
      request.fields['updated_on'] = data['updated_at']?.toString() ?? '';

      final audioPath = data['audio_path']?.toString();
      if (audioPath != null && audioPath.isNotEmpty) {
        final file = File(audioPath);
        if (await file.exists()) {
          request.files.add(
            await http.MultipartFile.fromPath(
              'recorded_audio',
              audioPath,
              filename: audioPath.split('/').last,
            ),
          );
          AppLogger.i('📎 Audio file attached',
              tag: 'ExecutiveSurveyInterviewerController');
        }
      }

      final response = await http.Response.fromStream(await request.send());

      AppLogger.i(
        '\n${'✅' * 40}\n'
        '📥 API RESPONSE\n'
        '${'✅' * 40}\n'
        'Status Code: ${response.statusCode}\n'
        'Response Body:\n${response.body}\n'
        '${'✅' * 40}',
        tag: 'ExecutiveSurveyInterviewerController',
      );

      // If successful, delete the pending submission
      if (response.statusCode == 200) {
        try {
          final jsonResponse = jsonDecode(response.body);
          if (jsonResponse['status'] == 'true' ||
              jsonResponse['status'] == true) {
            final submissionId = data['id'];
            await _localRepo.deletePendingSubmission(submissionId);
            AppLogger.i(
              '✅ Survey synced and deleted from local database',
              tag: 'ExecutiveSurveyInterviewerController',
            );
          }
        } catch (e) {
          AppLogger.w('Could not parse response or delete submission: $e',
              tag: 'ExecutiveSurveyInterviewerController');
        }
      }
    } catch (e, stackTrace) {
      AppLogger.e('Test API call failed',
          error: e,
          stackTrace: stackTrace,
          tag: 'ExecutiveSurveyInterviewerController');
    }
  }

  final SurveyLocalRepository _localRepo = SurveyLocalRepository();
  final ConnectivityService _connectivityService =
      Get.find<ConnectivityService>();

  Future<void> _loadCastsFromCache() async {
    try {
      isLoadingCast.value = true;
      castList.clear();
      selectedCast.value = "";
      selectedCastId.value = "";

      final casts = await _localRepo.getCasts(surveyId);
      if (casts.isNotEmpty) {
        castList.value = casts
            .map((c) => CastData(
                  castId: c['cast_id'],
                  castName: c['cast_name'],
                ))
            .toList();
        AppLogger.i('✅ Loaded ${casts.length} casts from cache',
            tag: 'ExecutiveSurveyInterviewer');
      } else {
        AppLogger.w('⚠️ No cached casts found',
            tag: 'ExecutiveSurveyInterviewer');
      }
    } catch (e) {
      AppLogger.e('Error loading casts from cache: $e',
          tag: 'ExecutiveSurveyInterviewer');
    } finally {
      isLoadingCast.value = false;
    }
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(AppImages.thanks, width: 80, height: 80),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade400,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'THANKS',
                    style: AppStyle.buttonTextSmallPoppinsWhite.responsive,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Response Submitted',
                  style: AppStyle.heading1PoppinsBlack.responsive,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Your response has been submitted\nsuccessfully.',
                  style: AppStyle.bodySmallPoppinsGrey.responsive,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          resetForm();
                          Get.back();
                          Get.offAllNamed(AppRoutes.executiveHome);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.defaultBlack,
                          side: const BorderSide(
                            color: AppColors.defaultBlack,
                            width: 1.5,
                          ),
                          minimumSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'Dashboard',
                            style:
                                AppStyle.buttonTextSmallPoppinsBlack.responsive,
                            maxLines: 1,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: isSubmitting.value
                            ? null
                            : () {
                                resetForm();
                                Get.back();
                                Get.offAllNamed(
                                  AppRoutes.executiveSurveyDetail,
                                  arguments: {'survey_id': surveyId},
                                );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.defaultBlack,
                          foregroundColor: AppColors.white,
                          elevation: 0,
                          minimumSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'Next Survey',
                            style:
                                AppStyle.buttonTextSmallPoppinsWhite.responsive,
                            maxLines: 1,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void onClose() {
    audioRecorder.stopRecording();
    nameController.dispose();
    phoneController.dispose();
    super.onClose();
  }
}
