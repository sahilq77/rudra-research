// lib/app/modules/survey_interviewer/survey_interviewer_controller.dart
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
// -----------------------------------------------------------------
//  ORIGINAL IMPORTS (unchanged)
// -----------------------------------------------------------------
import 'package:rudra/app/data/models/interviewer_info/get_cast_response.dart';
import 'package:rudra/app/data/network/exceptions.dart';
import 'package:rudra/app/data/urls.dart';
import 'package:rudra/app/modules/audio_recorder/audio_recorder_controller.dart';
import 'package:rudra/app/utils/app_images.dart';
import 'package:rudra/app/utils/app_utility.dart';
import 'package:rudra/app/utils/responsive_utils.dart';

import '../../../data/local/database_helper.dart';
import '../../../data/local/survey_local_repository.dart';
import '../../../routes/app_routes.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_logger.dart';
import '../../../widgets/app_snackbar_styles.dart';
import '../../../widgets/app_style.dart';
import '../../../widgets/connctivityservice.dart';
import '../survey_question/survey_question_controller.dart';

// -----------------------------------------------------------------
//  WAV HEADER PARSER – top-level class (fixed indexOf)
// -----------------------------------------------------------------
class _WavHeader {
  final int sampleRate;
  final int channels;
  final int dataOffset;

  _WavHeader(this.sampleRate, this.channels, this.dataOffset);

  factory _WavHeader.fromBytes(Uint8List bytes) {
    final view = ByteData.sublistView(bytes);

    // ---- RIFF check ----
    if (String.fromCharCodes(bytes, 0, 4) != 'RIFF') {
      throw Exception('Not a WAV file');
    }

    // ---- Find "fmt " chunk ----
    final fmtPos = _findChunk(bytes, [0x66, 0x6D, 0x74, 0x20]); // "fmt "
    if (fmtPos == -1) throw Exception('fmt chunk missing');

    // ---- Read fmt fields ----
    final audioFormat = view.getUint16(fmtPos + 8, Endian.little);
    if (audioFormat != 1) throw Exception('Only PCM supported');
    final channels = view.getUint16(fmtPos + 10, Endian.little);
    final sampleRate = view.getUint32(fmtPos + 12, Endian.little);

    // ---- Find "data" chunk ----
    final dataPos = _findChunk(bytes, [0x64, 0x61, 0x74, 0x61]); // "data"
    if (dataPos == -1) throw Exception('data chunk missing');

    final dataOffset = dataPos + 8;
    return _WavHeader(sampleRate, channels, dataOffset);
  }
}

/// Search for a 4-byte chunk identifier in the WAV file.
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

// -----------------------------------------------------------------
//  CONTROLLER
// -----------------------------------------------------------------
class SurveyInterviewerController extends GetxController {
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
          tag: 'SurveyInterviewerController',
        );
      }
    } catch (e) {
      AppLogger.e(
        'Error loading validation settings: $e',
        tag: 'SurveyInterviewerController',
      );
    }
  }

  // -----------------------------------------------------------------
  //  CAST HELPERS
  // -----------------------------------------------------------------
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

  // -----------------------------------------------------------------
  //  SUBMIT SURVEY – STOPS RECORDING + UPLOADS AUDIO
  // -----------------------------------------------------------------
  Future<String?> setSurvey({
    required BuildContext context,
    required formKey,
  }) async {
    if (!formKey.currentState!.validate()) return null;

    // Prevent double submission
    if (isSubmitting.value) {
      AppLogger.w(
        'Submission already in progress',
        tag: 'SurveyInterviewerController',
      );
      return null;
    }

    // Stop recording
    if (audioRecorder.isRecording.value) {
      final stoppedPath = await audioRecorder.stopRecording();
      if (stoppedPath != null) {
        AppLogger.i(
          'Recording stopped: $stoppedPath',
          tag: 'SurveyInterviewerController',
        );
      }
    }

    try {
      isSubmitting.value = true;
      isLoadings.value = true;
      errorMessages.value = '';

      // Save interviewer info locally with actual completion time
      await _saveInterviewerInfoLocally();

      // Show success dialog
      _showSuccessDialog(Get.context!);

      return surveyAppId;
    } catch (e, s) {
      AppLogger.e(
        'Error saving interviewer info',
        error: e,
        stackTrace: s,
        tag: 'SurveyInterviewerController',
      );
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
        tag: 'SurveyInterviewerController',
      );

      final db = await DatabaseHelper.instance.database;

      AppLogger.d(
        '🔍 Searching for offline_survey_id: $surveyAppId',
        tag: 'SurveyInterviewerController',
      );

      // Log ALL pending submissions BEFORE update
      final allBefore = await db.query(
        'pending_submissions',
        where: 'synced = 0',
      );
      AppLogger.d(
        '📊 ALL PENDING SUBMISSIONS BEFORE UPDATE (${allBefore.length}):\n${allBefore.map((s) => '  ID: ${s['id']}, offline_survey_id: ${s['offline_survey_id']}, name: ${s['interviewer_name']}, created: ${s['created_at']}').join('\n')}',
        tag: 'SurveyInterviewerController',
      );

      // Find the latest pending submission by offline_survey_id
      var results = await db.query(
        'pending_submissions',
        where: 'offline_survey_id = ? AND synced = 0',
        whereArgs: [surveyAppId],
        orderBy: 'created_at DESC',
        limit: 1,
      );

      if (results.isEmpty) {
        AppLogger.w(
          '⚠️ No pending submission found for offline_survey_id: $surveyAppId',
          tag: 'SurveyInterviewerController',
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
            tag: 'SurveyInterviewerController',
          );
          throw Exception('No pending submission found');
        }

        AppLogger.i(
          '✅ Found fallback submission (ID: ${results.first['id']}) for survey_id: $surveyId',
          tag: 'SurveyInterviewerController',
        );
      }

      final submissionId = results.first['id'];

      AppLogger.i(
        '✅ Found pending submission ID: $submissionId',
        tag: 'SurveyInterviewerController',
      );

      // Capture actual completion time
      final completionTime = DateTime.now().toIso8601String();

      // Update with interviewer info and mark as completed
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

      // Log the complete submission data
      final updatedSubmission = await db.query(
        'pending_submissions',
        where: 'id = ?',
        whereArgs: [submissionId],
      );

      if (updatedSubmission.isNotEmpty) {
        final data = updatedSubmission.first;

        // Log database data
        AppLogger.i(
          '\n${'=' * 80}\n'
          '📋 FINAL SUBMISSION DATA (Database):\n'
          '${'=' * 80}\n'
          'ID: ${data['id']}\n'
          'offline_survey_id: ${data['offline_survey_id']}\n'
          'survey_id: ${data['survey_id']}\n'
          'survey_language_id: ${data['survey_language_id']}\n'
          'zp_ward_id: ${data['zp_ward_id']}\n'
          'village_area_id: ${data['village_area_id']}\n'
          'user_id: ${data['user_id']}\n'
          'interviewer_name: ${data['interviewer_name']}\n'
          'interviewer_age: ${data['interviewer_age']}\n'
          'interviewer_gender: ${data['interviewer_gender']}\n'
          'interviewer_phone: ${data['interviewer_phone']}\n'
          'interviewer_cast: ${data['interviewer_cast']}\n'
          'answers: ${data['answers']}\n'
          'audio_path: ${data['audio_path']}\n'
          'synced: ${data['synced']}\n'
          'created_at: ${data['created_at']}\n'
          'updated_at: ${data['updated_at']}\n'
          '${'=' * 80}',
          tag: 'SurveyInterviewerController',
        );

        // Log API request format
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
          tag: 'SurveyInterviewerController',
        );

        // Test API call only if online
        _connectivityService.checkConnectivity().then((isConnected) {
          if (isConnected) {
            _testApiCall(data);
          } else {
            AppLogger.i(
              '⚠️ Offline mode - Survey saved locally and will be uploaded when online',
              tag: 'SurveyInterviewerController',
            );
          }
        });
      }

      AppLogger.i(
        '✅ Interviewer info saved successfully',
        tag: 'SurveyInterviewerController',
      );

      // Clear question controller data after successful save
      if (Get.isRegistered<SurveyQuestionController>()) {
        final questionController = Get.find<SurveyQuestionController>();
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
      AppLogger.e(
        'Error saving interviewer info locally',
        error: e,
        stackTrace: stackTrace,
        tag: 'SurveyInterviewerController',
      );
      rethrow;
    }
  }

  void submitSurvey(formKey) {
    if (formKey.currentState!.validate()) {
      AppLogger.d('Survey submitted', tag: 'SurveyInterviewerController');
      showSuccessDialog(Get.context!);
    }
  }

  void discardSurvey() {
    _showDiscardDialog(Get.context!);
  }

  void showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevents closing by tapping outside
      builder: (BuildContext dialogContext) {
        return PopScope(
          canPop: false, // This disables back navigation
          onPopInvoked: (didPop) {
            if (didPop) return;
            // Optional: Show a confirmation dialog if needed later
            debugPrint('Back navigation blocked');
          },
          child: Dialog(
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
                            Get.back(); // Close dialog
                            Get.offAllNamed(AppRoutes.home);
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
                              style: AppStyle
                                  .buttonTextSmallPoppinsBlack
                                  .responsive,
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
                                  Get.back(); // Close dialog
                                  Get.offAllNamed(
                                    AppRoutes.surveyDetails,
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
                              style: AppStyle
                                  .buttonTextSmallPoppinsWhite
                                  .responsive,
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
          ),
        );
      },
    );
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
                        Get.offAllNamed(AppRoutes.home);
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
        tag: 'SurveyInterviewerController',
      );

      final request = http.MultipartRequest(
        'POST',
        Uri.parse(Networkutility.setCompleteSurvey),
      );

      // Add form fields
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

      // Add audio file if exists
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
          AppLogger.i(
            '📎 Audio file attached',
            tag: 'SurveyInterviewerController',
          );
        }
      }

      // Send request
      final response = await http.Response.fromStream(await request.send());

      AppLogger.i(
        '\n${'✅' * 40}\n'
        '📥 API RESPONSE\n'
        '${'✅' * 40}\n'
        'Status Code: ${response.statusCode}\n'
        'Response Body:\n${response.body}\n'
        '${'✅' * 40}',
        tag: 'SurveyInterviewerController',
      );

      // If successful, mark as synced and delete
      if (response.statusCode == 200) {
        try {
          final jsonResponse = jsonDecode(response.body);
          if (jsonResponse['status'] == 'true' ||
              jsonResponse['status'] == true) {
            final submissionId = data['id'];
            await _localRepo.deletePendingSubmission(submissionId);
            AppLogger.i(
              '✅ Survey synced and deleted from local database',
              tag: 'SurveyInterviewerController',
            );
          }
        } catch (e) {
          AppLogger.w(
            'Could not parse response or delete submission: $e',
            tag: 'SurveyInterviewerController',
          );
        }
      }
    } catch (e, stackTrace) {
      AppLogger.e(
        'Test API call failed',
        error: e,
        stackTrace: stackTrace,
        tag: 'SurveyInterviewerController',
      );
    }
  }

  // -----------------------------------------------------------------
  //  FETCH CAST
  // -----------------------------------------------------------------
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
            .map(
              (c) => CastData(castId: c['cast_id'], castName: c['cast_name']),
            )
            .toList();
        AppLogger.i(
          '✅ Loaded ${casts.length} casts from cache',
          tag: 'SurveyInterviewer',
        );
      } else {
        AppLogger.w('⚠️ No cached casts found', tag: 'SurveyInterviewer');
      }
    } catch (e) {
      AppLogger.e(
        'Error loading casts from cache: $e',
        tag: 'SurveyInterviewer',
      );
    } finally {
      isLoadingCast.value = false;
    }
  }

  // -----------------------------------------------------------------
  //  MAXIMUM COMPRESSION: 16 kHz mono 16-bit + gzip
  // -----------------------------------------------------------------
  Future<String> _compressWavMax(String wavPath) async {
    // 1. Read original file
    final wavFile = File(wavPath);
    final wavBytes = await wavFile.readAsBytes();

    // 2. Parse header
    final header = _WavHeader.fromBytes(wavBytes);
    final pcmData = wavBytes.sublist(header.dataOffset);

    // 3. Convert to Int16List (16-bit PCM)
    final int16Samples = Int16List(pcmData.length ~/ 2);
    for (int i = 0; i < pcmData.length; i += 2) {
      int16Samples[i ~/ 2] = pcmData[i] | (pcmData[i + 1] << 8);
    }

    // 4. Resample to 16 kHz
    const targetRate = 16000;
    final resampled = _resampleInt16(
      samples: int16Samples,
      srcRate: header.sampleRate,
      dstRate: targetRate,
      channels: header.channels,
    );

    // 5. Force mono (average channels)
    final mono = _forceMono(resampled);

    // 6. Build new WAV header
    final newHeader = _buildWavHeader(
      sampleRate: targetRate,
      channels: 1,
      sampleCount: mono.length,
    );

    // 7. Write down-sampled PCM to temporary file
    final tempDir = await getTemporaryDirectory();
    final pcmPath = p.join(
      tempDir.path,
      '${p.basenameWithoutExtension(wavPath)}_cmp.wav',
    );
    final outFile = File(pcmPath);
    await outFile.writeAsBytes(newHeader);
    final sink = outFile.openWrite(mode: FileMode.writeOnlyAppend);
    sink.add(mono.buffer.asUint8List());
    sink.close(); // <-- NO await (returns void)

    // 8. Gzip the PCM file
    final gzPath = '$pcmPath.gz';
    final gzipSink = gzip.encoder.startChunkedConversion(
      File(gzPath).openWrite(),
    );
    await for (final chunk in outFile.openRead()) {
      gzipSink.add(chunk);
    }
    gzipSink.close(); // <-- NO await (returns void)

    // Clean intermediate PCM file
    await outFile.delete();

    return gzPath;
  }

  // Linear resampler (good enough for speech)
  List<Int16List> _resampleInt16({
    required Int16List samples,
    required int srcRate,
    required int dstRate,
    required int channels,
  }) {
    if (srcRate == dstRate) {
      final perChannel = samples.length ~/ channels;
      final out = <Int16List>[];
      for (int ch = 0; ch < channels; ch++) {
        final channel = Int16List(perChannel);
        for (int i = 0; i < perChannel; i++) {
          channel[i] = samples[i * channels + ch];
        }
        out.add(channel);
      }
      return out;
    }

    final ratio = dstRate / srcRate;
    final srcFrames = samples.length ~/ channels;
    final dstFrames = (srcFrames * ratio).floor();

    final out = <Int16List>[];
    for (int ch = 0; ch < channels; ch++) {
      final channelOut = Int16List(dstFrames);
      for (int i = 0; i < dstFrames; i++) {
        final srcIdx = (i / ratio).floor();
        channelOut[i] = samples[srcIdx * channels + ch];
      }
      out.add(channelOut);
    }
    return out;
  }

  // Force mono by averaging channels
  Int16List _forceMono(List<Int16List> channels) {
    final frames = channels[0].length;
    final mono = Int16List(frames);
    for (int i = 0; i < frames; i++) {
      int sum = 0;
      for (final ch in channels) {
        sum += ch[i];
      }
      mono[i] = (sum ~/ channels.length);
    }
    return mono;
  }

  // Build minimal WAV header (16-bit PCM)
  Uint8List _buildWavHeader({
    required int sampleRate,
    required int channels,
    required int sampleCount,
  }) {
    final byteRate = sampleRate * channels * 2;
    final blockAlign = channels * 2;
    final dataSize = sampleCount * blockAlign;
    final fileSize = 36 + dataSize;

    final buffer = BytesBuilder();
    buffer.add([0x52, 0x49, 0x46, 0x46]); // RIFF
    buffer.add(_int32ToBytes(fileSize - 8));
    buffer.add([0x57, 0x41, 0x56, 0x45]); // WAVE
    buffer.add([0x66, 0x6D, 0x74, 0x20]); // fmt
    buffer.add(_int32ToBytes(16));
    buffer.add(_int16ToBytes(1)); // PCM
    buffer.add(_int16ToBytes(channels));
    buffer.add(_int32ToBytes(sampleRate));
    buffer.add(_int32ToBytes(byteRate));
    buffer.add(_int16ToBytes(blockAlign));
    buffer.add(_int16ToBytes(16)); // 16-bit
    buffer.add([0x64, 0x61, 0x74, 0x61]); // data
    buffer.add(_int32ToBytes(dataSize));
    return buffer.toBytes();
  }

  Uint8List _int32ToBytes(int value) {
    final b = Uint8List(4);
    final view = ByteData.sublistView(b);
    view.setUint32(0, value, Endian.little);
    return b;
  }

  Uint8List _int16ToBytes(int value) {
    final b = Uint8List(2);
    final view = ByteData.sublistView(b);
    view.setUint16(0, value, Endian.little);
    return b;
  }

  // -----------------------------------------------------------------
  //  UPLOAD AUDIO – uses the new compressor + gzip
  // -----------------------------------------------------------------
  Future<void> uploadRecording() async {
    final recordingPath = audioRecorder.recordingPath.value;
    if (recordingPath.isEmpty) {
      AppSnackbarStyles.showError(
        title: 'No Recording',
        message: 'Please record audio first.',
      );
      return;
    }

    final file = File(recordingPath);
    if (!await file.exists()) {
      AppSnackbarStyles.showError(
        title: 'Error',
        message: 'Audio file not found on disk.',
      );
      return;
    }

    await _logFileSize(recordingPath);

    String uploadPath;
    bool useGzip = false;

    try {
      uploadPath = await _compressWavMax(recordingPath);
      useGzip = true;
      await _logFileSize(uploadPath);
    } catch (e, s) {
      log('Compression failed: $e', stackTrace: s);
      uploadPath = recordingPath;
    }

    final uploadFile = File(uploadPath);
    final bytes = await uploadFile.readAsBytes();
    final filename = p.basename(uploadPath);

    try {
      isLoading.value = true;

      final request = http.MultipartRequest(
        'POST',
        Uri.parse(Networkutility.uploadAudio),
      );

      request.fields['survey_app_side_id'] = surveyAppId;
      request.fields['completed_by'] = AppUtility.userID.toString();

      if (useGzip) {
        request.headers['Content-Encoding'] = 'gzip';
      }

      request.files.add(
        http.MultipartFile.fromBytes(
          'recorded_audio',
          bytes,
          filename: filename,
          contentType: MediaType.parse('audio/wav'),
        ),
      );

      log(
        'Uploading to ${request.url} | File: $filename | Size: ${bytes.length} bytes${useGzip ? " (gzipped)" : ""}',
      );

      final streamed = await request.send();
      final resp = await http.Response.fromStream(streamed);

      String body = resp.body.trim();
      if (body.endsWith('null')) {
        body = body.substring(0, body.lastIndexOf('null')).trim();
      }

      if (resp.statusCode == 200) {
        try {
          final json = jsonDecode(body);
          if (json['status'] == 'true' || json['status'] == true) {
            log(resp.body);
            AppSnackbarStyles.showSuccess(
              title: 'Success',
              message: "Interviewer info submitted successfully",
            );
            // AppSnackbarStyles.showSuccess(
            //   title: 'Uploaded',
            //   message: 'Audio uploaded successfully',
            // );
            _showSuccessDialog(Get.context!);
            await audioRecorder.deleteRecording();
          } else {
            AppSnackbarStyles.showError(
              title: 'Upload failed',
              message: json['message'] ?? 'Unknown error',
            );
          }
        } catch (_) {
          if (resp.body.contains('"status":"true"')) {
            AppSnackbarStyles.showSuccess(
              title: 'Uploaded',
              message: 'Audio uploaded',
            );
            await audioRecorder.deleteRecording();
          } else {
            AppSnackbarStyles.showError(
              title: 'Invalid response',
              message: 'Server returned unexpected data.',
            );
          }
        }
      } else {
        AppSnackbarStyles.showError(
          title: 'Server error',
          message: 'HTTP ${resp.statusCode}',
        );
      }
    } on NoInternetException catch (e) {
      AppSnackbarStyles.showError(title: 'No Internet', message: e.message);
    } on TimeoutException catch (e) {
      AppSnackbarStyles.showError(title: 'Timeout', message: e.message);
    } on HttpException catch (e) {
      AppSnackbarStyles.showError(
        title: 'HTTP error',
        message: '${e.message} (${e.statusCode})',
      );
    } catch (e, s) {
      log('uploadRecording EXCEPTION: $e', stackTrace: s);
      AppSnackbarStyles.showError(title: 'Error', message: 'Upload failed');
    } finally {
      isLoading.value = false;

      if (uploadPath.endsWith('.gz') || uploadPath.contains('_cmp')) {
        try {
          await File(uploadPath).delete();
        } catch (_) {}
      }
    }
  }

  Future<void> _logFileSize(String path) async {
    final file = File(path);
    if (await file.exists()) {
      final bytes = await file.length();
      final kb = (bytes / 1024).toStringAsFixed(2);
      final mb = (bytes / (1024 * 1024)).toStringAsFixed(2);
      log('File size: $bytes B | $kb KB | $mb MB');
    } else {
      log('File NOT found: $path');
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
                // Thanks Badge
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
                // Title
                Text(
                  'Response Submitted',
                  style: AppStyle.heading1PoppinsBlack.responsive,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                // Message
                Text(
                  'Your response has been submitted\nsuccessfully.',
                  style: AppStyle.bodySmallPoppinsGrey.responsive,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          resetForm();
                          Get.back();
                          Get.offAllNamed(AppRoutes.home);
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
                                Get.back(); // Close dialog
                                Get.offAllNamed(
                                  AppRoutes.surveyDetails,
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

  // -----------------------------------------------------------------
  //  CLEAN-UP
  // -----------------------------------------------------------------
  @override
  void onClose() {
    if (audioRecorder.isRecording.value) {
      audioRecorder.stopRecording();
    }
    nameController.dispose();
    phoneController.dispose();
    super.onClose();
  }
}
