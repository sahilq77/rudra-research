import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rudra/app/modules/validator_module/validator_start_survey_detail/validator_start_survey_controller.dart';
import 'package:rudra/app/routes/app_routes.dart';
import 'package:rudra/app/utils/responsive_utils.dart'
    show ResponsiveHelper, AppStyleResponsive;
import 'package:rudra/app/widgets/app_snackbar_styles.dart';

import '../../../../utils/app_colors.dart';
import '../../../../utils/app_images.dart';
import '../../../../widgets/app_button_style.dart';
import '../../../../widgets/app_style.dart';

class ValidatorSubmitSurveyFormController extends GetxController {
  final remark = ''.obs;
  final selectedReport = 'OK'.obs;
  final reports = ['OK', 'Issue', 'Pending'];
  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
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

  void submitRemark() {
    if (remark.value.isNotEmpty) {
      // Handle submission logic here (e.g., API call)
      print('Remark: ${remark.value}, Report: ${selectedReport.value}');
      // AppSnackbarStyles.showSuccess(
      //   title: 'Success',
      //   message: 'Remark submitted successfully',
      // );
      _showConfirmDialog();
      // Reset form or navigate back
      remark.value = '';
      selectedReport.value = 'OK';
      Get.find<ValidatorStartSurveyController>().currentPage.value =
          0; // Reset to first step
    } else {
      AppSnackbarStyles.showError(
        title: 'Error',
        message: 'Please enter a remark.',
      );
    }
  }
}
