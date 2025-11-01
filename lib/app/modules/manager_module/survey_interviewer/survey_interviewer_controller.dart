// lib/app/modules/survey_interviewer/survey_interviewer_controller.dart
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;

import 'package:rudra/app/data/models/interviewer_info/get_cast_response.dart';
import 'package:rudra/app/data/models/interviewer_info/get_set_interviewer_info.dart';
import 'package:rudra/app/data/network/exceptions.dart';
import 'package:rudra/app/data/network/networkcall.dart';
import 'package:rudra/app/data/urls.dart';
import 'package:rudra/app/modules/audio_recorder/audio_recorder_controller.dart';
import 'package:rudra/app/utils/app_images.dart' show AppImages;
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
  //  AUDIO RECORDING – DELEGATED TO SEPARATE CONTROLLER
  // -----------------------------------------------------------------
  late final AudioRecorderController audioRecorder;

  @override
  void onInit() {
    super.onInit();

    // Initialize the separate audio controller
    audioRecorder = Get.put(AudioRecorderController());

    final args = Get.arguments as Map<String, dynamic>?;
    surveyId = args?['survey_id']?.toString() ?? "";
    surveyAppId = args?['survey_app_side_id']?.toString() ?? "";

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (Get.context != null) {
        // await audioRecorder.autoStartRecording(); // Auto-start using new controller
        await fetchCast(context: Get.context!, surveyId: surveyId);
      }
    });
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
  Future<String?> setSurvey({required BuildContext context}) async {
    if (!formKey.currentState!.validate()) return null;

    // STOP RECORDING AUTOMATICALLY using new controller
    if (audioRecorder.isRecording.value) {
      final stoppedPath = await audioRecorder.stopRecording();
      if (stoppedPath != null) {
        AppSnackbarStyles.showInfo(
          title: 'Recording',
          message: 'Recording stopped automatically',
        );
      } else {
        AppSnackbarStyles.showError(
          title: 'Warning',
          message: 'Failed to stop recording – will try to upload anyway',
        );
      }
    }

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
        // AppSnackbarStyles.showSuccess(
        //   title: 'Success',
        //   message: "Interviewer info submitted",
        // );
        log("Interviwer info submitted success");
        // UPLOAD AUDIO AFTER INFO IS SAVED
        if (audioRecorder.recordingPath.value.isNotEmpty) {
          await uploadRecording();
        } else {
          AppSnackbarStyles.showInfo(
            title: 'No Audio',
            message: 'No recording to upload',
          );
        }

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
                    Get.offAllNamed(
                      AppRoutes.surveyDetails,
                      arguments: {'survey_id': surveyId},
                    );
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
    audioRecorder.reset(); // Reset audio state
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
  //  UPLOAD AUDIO (Uses audioRecorder.recordingPath)
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

    try {
      isLoading.value = true;

      final bytes = await file.readAsBytes();
      final originalName = file.uri.pathSegments.last;
      final filename = originalName.endsWith('.wav')
          ? originalName
          : '${originalName.split('.').first}.wav';

      final request = http.MultipartRequest(
        'POST',
        Uri.parse(Networkutility.uploadAudio),
      );

      request.fields['survey_app_side_id'] = surveyAppId;
      request.fields['completed_by'] = AppUtility.userID.toString();

      request.files.add(
        http.MultipartFile.fromBytes(
          'recorded_audio',
          bytes,
          filename: filename,
          contentType: MediaType('audio', 'wav'),
        ),
      );

      log(
        'Uploading → ${request.url} | File: $filename | Size: ${bytes.length} bytes',
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
            // AppSnackbarStyles.showSuccess(
            //   title: 'Uploaded',
            //   message: 'Audio uploaded successfully',
            // );
            AppSnackbarStyles.showSuccess(
              title: 'Success',
              message: "Interviewer info submitted successfully",
            );
            _showSuccessDialog(Get.context!);
            await audioRecorder.deleteRecording(); // Delete after success
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
                        onPressed: () async {
                          resetForm();
                          Get.back();
                          Get.offAllNamed(
                            AppRoutes.surveyDetails,
                            arguments: {"survey_id": surveyId},
                          );
                          await audioRecorder.startRecording();
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
    // Ensure recording is stopped and disposed
    audioRecorder.stopRecording();
    nameController.dispose();
    phoneController.dispose();
    super.onClose();
  }
}
