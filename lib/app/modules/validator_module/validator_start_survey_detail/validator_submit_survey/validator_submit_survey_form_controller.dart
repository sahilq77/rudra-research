import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rudra/app/routes/app_routes.dart';
import 'package:rudra/app/utils/responsive_utils.dart'
    show ResponsiveHelper, AppStyleResponsive;
import 'package:rudra/app/widgets/app_snackbar_styles.dart';

import '../../../../data/network/networkcall.dart';
import '../../../../data/urls.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_images.dart';
import '../../../../utils/app_logger.dart';
import '../../../../utils/app_utility.dart';
import '../../../../utils/location_helper.dart';
import '../../../../widgets/app_button_style.dart';
import '../../../../widgets/app_style.dart';

class ValidatorSubmitSurveyFormController extends GetxController {
  final remark = ''.obs;
  final selectedReport = 'OK'.obs;
  final reports = ['OK', 'NOT OK'];
  final RxBool isSubmitting = false.obs;
  final RxBool isFetchingLocation = false.obs;

  late final String surveyId;
  late final String responseId;
  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    surveyId = args['survey_id']?.toString() ?? '';
    responseId = args['response_id']?.toString() ?? '';
    ResponsiveHelper.init(Get.context!);
  }

  final responsiveHelper = ResponsiveHelper;
  void updateRemark(String value) {
    remark.value = value;
  }

  void updateSelectedReport(String value) {
    selectedReport.value = value;
  }

  void _showConfirmDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ResponsiveHelper.spacing(16)),
        ),
        child: Container(
          padding: ResponsiveHelper.paddingSymmetric(
            horizontal: 24,
            vertical: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                AppImages.thanks,
                width: ResponsiveHelper.spacing(80),
                height: ResponsiveHelper.spacing(80),
                fit: BoxFit.contain,
              ),
              SizedBox(height: ResponsiveHelper.spacing(16)),
              Text(
                'Feedback submitted!',
                style: AppStyle.heading1PoppinsBlack.responsive.copyWith(
                  fontSize: ResponsiveHelper.getResponsiveFontSize(18),
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: ResponsiveHelper.spacing(8)),
              Text(
                'Your feedback was sent successfully.',
                style: AppStyle.bodySmallPoppinsGrey.responsive.copyWith(
                  fontSize: ResponsiveHelper.getResponsiveFontSize(13),
                  color: AppColors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: ResponsiveHelper.spacing(24)),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Get.offNamed(AppRoutes.validatorHome);
                      },
                      style: AppButtonStyles.outlinedMediumBlack(),
                      child: Text(
                        'Dashboard',
                        style: AppStyle.buttonTextSmallPoppinsBlack.responsive
                            .copyWith(
                          fontSize: ResponsiveHelper.getResponsiveFontSize(
                            12,
                          ),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: ResponsiveHelper.spacing(12)),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.offNamed(AppRoutes.validatorHome);
                      },
                      style: AppButtonStyles.elevatedMediumBlack(),
                      child: Text(
                        'Next Validate',
                        style: AppStyle.buttonTextSmallPoppinsWhite.responsive
                            .copyWith(
                          fontSize: ResponsiveHelper.getResponsiveFontSize(
                            12,
                          ),
                          fontWeight: FontWeight.w600,
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
      barrierDismissible: false,
    );
  }

  Future<void> submitRemark() async {
    if (remark.value.isEmpty) {
      AppSnackbarStyles.showError(
        title: 'Error',
        message: 'Please enter a remark.',
      );
      return;
    }

    isSubmitting.value = true;
    isFetchingLocation.value = true;

    try {
      final locationData = await LocationHelper.getCurrentLocation();
      isFetchingLocation.value = false;

      if (locationData == null) {
        AppSnackbarStyles.showError(
          title: 'Error',
          message: 'Unable to fetch location. Please enable location services.',
        );
        isSubmitting.value = false;
        return;
      }

      final validatorStatus = selectedReport.value == 'OK' ? '1' : '0';

      final jsonBody = {
        "survey_id": surveyId,
        "validator_id": AppUtility.userID ?? "",
        "response_id": responseId,
        "validator_remark": remark.value,
        "validator_status": validatorStatus,
        "latitude": locationData['latitude'],
        "longitude": locationData['longitude'],
        "address": locationData['address'],
         "user_id": AppUtility.userID,
      };

      final response = await Networkcall().postMethod(
        Networkutility.finalSubmitSurveyByValidatorApi,
        Networkutility.finalSubmitSurveyByValidator,
        jsonEncode(jsonBody),
        Get.context!,
      );

      if (response != null && response.isNotEmpty) {
        _showConfirmDialog();
        remark.value = '';
        selectedReport.value = 'OK';
      } else {
        AppSnackbarStyles.showError(
          title: 'Error',
          message: 'Failed to submit validation',
        );
      }
    } catch (e) {
      AppLogger.e('Error submitting validation: $e', tag: 'ValidatorSubmit');
      AppSnackbarStyles.showError(
        title: 'Error',
        message: 'An error occurred while submitting',
      );
    } finally {
      isSubmitting.value = false;
      isFetchingLocation.value = false;
    }
  }
}
