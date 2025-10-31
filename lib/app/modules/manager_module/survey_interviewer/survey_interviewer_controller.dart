// lib/app/modules/survey_interviewer/survey_interviewer_controller.dart
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http_parser/http_parser.dart' as http_parser;
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;

import 'package:rudra/app/data/models/interviewer_info/get_cast_response.dart';
import 'package:rudra/app/data/models/interviewer_info/get_set_interviewer_info.dart';
import 'package:rudra/app/data/network/exceptions.dart';
import 'package:rudra/app/data/network/networkcall.dart';
import 'package:rudra/app/data/urls.dart';
import 'package:rudra/app/utils/app_utility.dart';
import 'package:rudra/app/utils/responsive_utils.dart';
import '../../../routes/app_routes.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_logger.dart';
import '../../../widgets/app_snackbar_styles.dart';
import '../../../widgets/app_style.dart';

class SurveyInterviewerController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  RxList<CastData> castList = <CastData>[].obs;
  var isLoadings = false.obs;
  var errorMessages = ''.obs;
  var isLoadingCast = false.obs;
  var errorMessageCast = ''.obs;
  var isLoading = false.obs;

  final RxString selectedCast = ''.obs;
  final RxString selectedCastId = ''.obs;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  final List<String> ageRanges = ['18-25', '26-39', '40-55', '56+'];
  final RxString selectedAgeLabel = ''.obs;
  final RxInt selectedAgeId = 0.obs;

  final List<String> genders = ['Male', 'Female', 'Other'];
  final RxString selectedGenderLabel = ''.obs;
  final RxInt selectedGenderId = 0.obs;

  late String surveyId = "";
  late String surveyAppId = "";

  // -----------------------------------------------------------------
  //  AUDIO RECORDING - FIXED: Use WAV (Reliable)
  // -----------------------------------------------------------------
  final AudioRecorder _audioRecorder = AudioRecorder();
  RxBool isRecording = false.obs;
  RxString recordingPath = ''.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    surveyId = args?['survey_id']?.toString() ?? "";
    surveyAppId = args?['survey_app_side_id']?.toString() ?? "";

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.context != null) {
        fetchCast(context: Get.context!, surveyId: surveyId);
      }
      _startRecordingAutomatically();
    });
  }

  // -----------------------------------------------------------------
  //  AUTO START RECORDING (WAV)
  // -----------------------------------------------------------------
  Future<void> _startRecordingAutomatically() async {
    if (isRecording.value) return;

    final path = await _startRecording();
    if (path != null) {
      recordingPath.value = path;
      isRecording.value = true;
      AppSnackbarStyles.showInfo(
        title: 'Recording',
        message: 'Recording started automatically (WAV)',
      );
    } else {
      isRecording.value = false;
    }
  }

  // -----------------------------------------------------------------
  //  PERMISSION + START/STOP (WAV)
  // -----------------------------------------------------------------
  Future<bool> _requestMicPermission() async {
    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      AppSnackbarStyles.showError(
        title: 'Permission Denied',
        message: 'Microphone access is required.',
      );
      return false;
    }
    return true;
  }

  Future<String?> _startRecording() async {
    if (!await _requestMicPermission()) return null;

    try {
      final dir = await getTemporaryDirectory();
      final path =
          '${dir.path}/survey_recording_${DateTime.now().millisecondsSinceEpoch}.wav';

      final config = RecordConfig(
        encoder: AudioEncoder.wav,
        bitRate: 128000,
        sampleRate: 44100,
      );

      await _audioRecorder.start(config, path: path);
      log('Recording STARTED (WAV): $path');
      return path;
    } catch (e) {
      log('Start error: $e');
      AppSnackbarStyles.showError(
        title: 'Failed',
        message: 'Could not start recording',
      );
      return null;
    }
  }

  Future<String?> _stopRecording() async {
    try {
      final path = await _audioRecorder.stop();
      log('Recording STOPPED: $path');
      return path;
    } catch (e) {
      log('Stop error: $e');
      return null;
    }
  }

  // -----------------------------------------------------------------
  //  TOGGLE (MANUAL STOP / RESTART)
  // -----------------------------------------------------------------
  Future<void> toggleRecording() async {
    if (isRecording.value) {
      final path = await _stopRecording();
      if (path != null) {
        recordingPath.value = path;
        AppSnackbarStyles.showSuccess(
          title: 'Saved',
          message: 'Recording saved',
        );
      }
    } else {
      final path = await _startRecording();
      if (path != null) recordingPath.value = path;
    }
    isRecording.value = !isRecording.value;
  }

  // -----------------------------------------------------------------
  //  CAST HELPERS (UNCHANGED)
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
  //  FORM SUBMISSION
  // -----------------------------------------------------------------
  void submitSurvey() {
    if (formKey.currentState!.validate()) {
      AppLogger.d('Survey submitted', tag: 'SurveyInterviewerController');
      showSuccessDialog();
    }
  }

  void discardSurvey() {
    _showDiscardDialog(Get.context!);
  }

  void showSuccessDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.sentiment_satisfied_alt,
              size: 48,
              color: AppColors.blue,
            ),
            const SizedBox(height: 16),
            const Text('THANKS!'),
            const SizedBox(height: 8),
            const Text('Response Submitted'),
            const SizedBox(height: 8),
            const Text('Your response has been submitted successfully.'),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  style: TextButton.styleFrom(minimumSize: const Size(100, 40)),
                  onPressed: () => Get.offAllNamed(AppRoutes.home),
                  child: const Text('Dashboard'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(100, 40),
                  ),
                  onPressed: () {
                    resetForm();
                    Get.offAllNamed(AppRoutes.surveyDetails);
                  },
                  child: const Text('Next Survey'),
                ),
              ],
            ),
          ],
        ),
      ),
      barrierDismissible: false,
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
                        Get.back();
                        Get.back();
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
  }

  Future<void> refreshPage() async {
    await Future.delayed(const Duration(seconds: 1));
    AppSnackbarStyles.showInfo(title: 'Refresh', message: 'Page refreshed');
  }

  // -----------------------------------------------------------------
  //  FETCH CAST
  // -----------------------------------------------------------------
  Future<void> fetchCast({
    required BuildContext context,
    bool forceFetch = false,
    required String? surveyId,
  }) async {
    if (!forceFetch && castList.isNotEmpty) return;

    try {
      isLoadingCast.value = true;
      errorMessageCast.value = '';
      castList.clear();
      selectedCast.value = "";
      selectedCastId.value = "";

      final jsonBody = {"survey_id": surveyId};

      List<GeCastResponse>? response =
          await Networkcall().postMethod(
                Networkutility.getCastApi,
                Networkutility.getCast,
                jsonEncode(jsonBody),
                context,
              )
              as List<GeCastResponse>?;

      if (response != null &&
          response.isNotEmpty &&
          response[0].status == "true") {
        castList.value = response[0].data;
      } else {
        errorMessageCast.value = response?[0].message ?? 'No casts found';
        AppSnackbarStyles.showError(
          title: 'Error',
          message: errorMessageCast.value,
        );
      }
    } on NoInternetException catch (e) {
      errorMessageCast.value = e.message;
      AppSnackbarStyles.showError(title: 'Error', message: e.message);
    } on TimeoutException catch (e) {
      errorMessageCast.value = e.message;
      AppSnackbarStyles.showError(title: 'Error', message: e.message);
    } on HttpException catch (e) {
      errorMessageCast.value = '${e.message} (Code: ${e.statusCode})';
      AppSnackbarStyles.showError(
        title: 'Error',
        message: errorMessageCast.value,
      );
    } on ParseException catch (e) {
      errorMessageCast.value = e.message;
      AppSnackbarStyles.showError(title: 'Error', message: e.message);
    } catch (e, stackTrace) {
      errorMessageCast.value = 'Unexpected error: $e';
      log('Fetch Cast Exception: $e', stackTrace: stackTrace);
      AppSnackbarStyles.showError(
        title: 'Error',
        message: errorMessageCast.value,
      );
    } finally {
      isLoadingCast.value = false;
    }
  }

  // -----------------------------------------------------------------
  //  SET INTERVIEWER INFO + UPLOAD RECORDING
  // -----------------------------------------------------------------
  Future<String?> setSurvey({required BuildContext context}) async {
    if (!formKey.currentState!.validate()) return null;

    try {
      isLoadings.value = true;
      errorMessages.value = '';

      final jsonBody = {
        "survey_app_side_id": surveyAppId,
        "name": nameController.text.trim(),
        "age": selectedAgeId.value.toString(),
        "gender": selectedGenderId.value.toString(),
        "mob_number": phoneController.text.trim(),
        "cast_id": selectedCastId.value,
      };

      final response =
          await Networkcall().postMethod(
                Networkutility.setInterviewerInfoApi,
                Networkutility.setInterviewerInfo,
                jsonEncode(jsonBody),
                context,
              )
              as List<GetSetInterviewerInfoResponse>?;

      if (response != null &&
          response.isNotEmpty &&
          response[0].status == "true") {
        AppSnackbarStyles.showSuccess(
          title: 'Success',
          message: "Info submitted",
        );
        await uploadRecording();
        return response[0].data?.surveyAppSideId ?? '';
      } else {
        final msg = response?[0].message ?? "Submission failed";
        errorMessages.value = msg;
        AppSnackbarStyles.showError(title: 'Failed', message: msg);
        return null;
      }
    } on NoInternetException catch (e) {
      errorMessages.value = e.message;
      AppSnackbarStyles.showError(title: 'Error', message: e.message);
    } on TimeoutException catch (e) {
      errorMessages.value = e.message;
      AppSnackbarStyles.showError(title: 'Error', message: e.message);
    } on HttpException catch (e) {
      errorMessages.value = '${e.message} (Code: ${e.statusCode})';
      AppSnackbarStyles.showError(title: 'Error', message: errorMessages.value);
    } on ParseException catch (e) {
      errorMessages.value = e.message;
      AppSnackbarStyles.showError(title: 'Error', message: e.message);
    } catch (e, s) {
      errorMessages.value = 'Unexpected error: $e';
      log('setSurvey error: $e', stackTrace: s);
      AppSnackbarStyles.showError(title: 'Error', message: errorMessages.value);
    } finally {
      isLoadings.value = false;
    }
    return null;
  }

  // -----------------------------------------------------------------
  //  HELPER: Log File Size
  // -----------------------------------------------------------------
  void _logRecordingFileSize(String path) async {
    final file = File(path);
    if (await file.exists()) {
      final bytes = await file.length();
      final sizeInKB = (bytes / 1024).toStringAsFixed(2);
      final sizeInMB = (bytes / (1024 * 1024)).toStringAsFixed(2);
      log('Recording file size: $bytes bytes | $sizeInKB KB | $sizeInMB MB');
    } else {
      log('Recording file does not exist: $path');
    }
  }

  // -----------------------------------------------------------------
  //  UPLOAD WAV AUDIO FILE (FIXED: Use audio/x-wav MIME)
  // -----------------------------------------------------------------
  Future<void> uploadRecording() async {
    if (recordingPath.value.isEmpty) {
      AppSnackbarStyles.showError(
        title: 'No Recording',
        message: 'Please record audio first',
      );
      return;
    }

    final file = File(recordingPath.value);
    if (!await file.exists()) {
      AppSnackbarStyles.showError(
        title: 'Error',
        message: 'Audio file not found',
      );
      return;
    }

    _logRecordingFileSize(recordingPath.value);

    try {
      isLoading.value = true;

      final bytes = await file.readAsBytes();
      final originalName = file.uri.pathSegments.last;

      // Force .wav extension
      final filename = originalName.endsWith('.mp3')
          ? originalName
          : '${originalName.split('.').first}.mp3';

      final request = http.MultipartRequest(
        'POST',
        Uri.parse(Networkutility.uploadAudio),
      );

      request.fields['survey_app_side_id'] = surveyAppId;
      request.fields['completed_by'] = AppUtility.userID.toString();

      // CRITICAL FIX: Use 'audio/x-wav' – CodeIgniter accepts this for .wav
      const String contentType = 'audio/x-wav';

      request.files.add(
        http.MultipartFile(
          'recorded_audio',
          http.ByteStream.fromBytes(bytes),
          bytes.length,
          filename: filename,
          //contentType: http_parser.MediaType.parse(contentType),
        ),
      );

      log('Uploading to: ${request.url}');
      log('Fields: ${request.fields}');
      log('File: $filename | Type: $contentType | Size: ${bytes.length} bytes');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      log('Status: ${response.statusCode} | Raw Body: ${response.body}');

      // Clean response body
      String body = response.body.trim();
      if (body.endsWith('null')) {
        body = body.substring(0, body.lastIndexOf('null')).trim();
      }

      if (response.statusCode == 200) {
        try {
          final json = jsonDecode(body);
          if (json['status'] == 'true') {
            AppSnackbarStyles.showSuccess(
              title: 'Success',
              message: 'Audio uploaded successfully',
            );
            recordingPath.value = '';
          } else {
            AppSnackbarStyles.showError(
              title: 'Failed',
              message: json['message'] ?? 'Upload failed',
            );
          }
        } catch (e) {
          log('JSON Parse Failed: $e');
          // Fallback: if "status":"true" exists in body
          if (response.body.contains('"status":"true"')) {
            AppSnackbarStyles.showSuccess(
              title: 'Success',
              message: 'Audio uploaded',
            );
            recordingPath.value = '';
          } else {
            AppSnackbarStyles.showError(
              title: 'Error',
              message: 'Invalid response from server',
            );
          }
        }

        // Delete temp file after success
        try {
          await file.delete();
          log('Temp recording file deleted: ${file.path}');
        } catch (e) {
          log('Failed to delete temp file: $e');
        }
      } else {
        AppSnackbarStyles.showError(
          title: 'Error',
          message: 'Server error: ${response.statusCode}',
        );
      }
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
    } catch (e, s) {
      log('uploadRecording error: $e', stackTrace: s);
      AppSnackbarStyles.showError(title: 'Error', message: 'Upload failed');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    if (isRecording.value) _stopRecording();
    _audioRecorder.dispose();
    nameController.dispose();
    phoneController.dispose();
    super.onClose();
  }
}
