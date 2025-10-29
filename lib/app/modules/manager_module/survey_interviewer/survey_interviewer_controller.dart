import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rudra/app/data/models/interviewer_info/get_cast_response.dart';
import 'package:rudra/app/data/models/interviewer_info/get_set_interviewer_info.dart';
import 'package:rudra/app/data/network/exceptions.dart';
import 'package:rudra/app/data/network/networkcall.dart';
import 'package:rudra/app/data/urls.dart';
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

  // --- CAST SELECTION (UNCHANGED) ---
  final RxString selectedCast = ''.obs;
  final RxString selectedCastId = ''.obs;

  // Text controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  // --- AGE: LABEL + ID ---
  final List<String> ageRanges = ['18-25', '26-39', '40-55', '56+'];
  final RxString selectedAgeLabel = ''.obs;   // <-- shown in dropdown
  final RxInt selectedAgeId = 0.obs;         // <-- actual ID (0-3)

  // --- GENDER: LABEL + ID ---
  final List<String> genders = ['Male', 'Female', 'Other'];
  final RxString selectedGenderLabel = ''.obs;
  final RxInt selectedGenderId = 0.obs;

  late String surveyId = "";
  late String surveyAppId = "";

  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    surveyId = args?['survey_id']?.toString() ?? "";
    surveyAppId = args?['survey_app_side_id']?.toString() ?? "";
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.context != null) {
        fetchCast(context: Get.context!, surveyId: surveyId);
      }
    });
  }

  // -----------------------------------------------------------------
  // AGE HELPERS
  // -----------------------------------------------------------------
  void setSelectedAge(String? label) {
    selectedAgeLabel.value = label ?? '';
    selectedAgeId.value = ageRanges.indexOf(label ?? '');
  }

  // -----------------------------------------------------------------
  // GENDER HELPERS
  // -----------------------------------------------------------------
  void setSelectedGender(String? label) {
    selectedGenderLabel.value = label ?? '';
    selectedGenderId.value = genders.indexOf(label ?? '');
  }

  // -----------------------------------------------------------------
  // CAST HELPERS (UNCHANGED)
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

  // -----------------------------------------------------------------
  // FORM SUBMISSION (UNCHANGED)
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
                  onPressed: () {
                    Get.offAllNamed(AppRoutes.home);
                  },
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

    // Reset Age
    selectedAgeLabel.value = '';
    selectedAgeId.value = 0;

    // Reset Gender
    selectedGenderLabel.value = '';
    selectedGenderId.value = 0;

    // Reset Cast
    selectedCast.value = '';
    selectedCastId.value = '';
  }

  Future<void> refreshPage() async {
    await Future.delayed(const Duration(seconds: 1));
    AppSnackbarStyles.showInfo(title: 'Refresh', message: 'Page refreshed');
  }

  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    super.onClose();
  }

  // -----------------------------------------------------------------
  // FETCH CAST (UNCHANGED)
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

      log(
        'Fetch Casts Response: ${response?.isNotEmpty == true ? response![0].toJson() : 'null'}',
      );

      if (response != null && response.isNotEmpty) {
        if (response[0].status == "true") {
          castList.value = response[0].data;
          log(
            'Cast List Loaded: ${castList.map((s) => "${s.castId}: ${s.castName}").toList()}',
          );
        } else {
          errorMessageCast.value = response[0].message;
          AppSnackbarStyles.showError(
            title: 'Error',
            message: response[0].message,
          );
        }
      } else {
        errorMessageCast.value = 'No response from server';
        AppSnackbarStyles.showError(
          title: 'Error',
          message: 'No response from server',
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
        message: '${e.message} (Code: ${e.statusCode})',
      );
    } on ParseException catch (e) {
      errorMessageCast.value = e.message;
      AppSnackbarStyles.showError(title: 'Error', message: e.message);
    } catch (e, stackTrace) {
      errorMessageCast.value = 'Unexpected error: $e';
      log('Fetch Cast Exception: $e, stack: $stackTrace');
      AppSnackbarStyles.showError(
        title: 'Error',
        message: 'Unexpected error: $e',
      );
    } finally {
      isLoadingCast.value = false;
    }
  }

 // ──────────────────────────────────────────────────────────────
// REPLACE ONLY THIS METHOD (keep everything else unchanged)
// ──────────────────────────────────────────────────────────────
Future<String?> setSurvey({required BuildContext context}) async {
  // Validate form first
  if (!formKey.currentState!.validate()) return null;

  try {
    isLoadings.value = true;
    errorMessages.value = '';

    final jsonBody = {
      "survey_app_side_id": surveyAppId,
      "name": nameController.text.trim(),
      "age": selectedAgeId.value.toString(),           // Send Age ID (0-3)
      "gender": selectedGenderId.value.toString(),     // Send Gender ID (0-2)
      "mob_number": phoneController.text.trim(),
      "cast_id": selectedCastId.value,                 // Send Cast ID
    };

    final response = await Networkcall().postMethod(
      Networkutility.setInterviewerInfoApi,
      Networkutility.setInterviewerInfo,
      jsonEncode(jsonBody),
      context,
    ) as List<GetSetInterviewerInfoResponse>?;

    if (response != null &&
        response.isNotEmpty &&
        response[0].status == "true") {
      final newSurveyAppSideId = response[0].data?.surveyAppSideId ?? '';
      AppSnackbarStyles.showSuccess(
        title: 'Success',
        message: "Interviewer Info submitted successfully",
      );
      return newSurveyAppSideId;
    } else {
      final msg = response?[0].message ?? "Interviewer Info submission failed";
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
    AppSnackbarStyles.showError(
      title: 'Error',
      message: '${e.message} (Code: ${e.statusCode})',
    );
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
}
