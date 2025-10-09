import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rudra/app/utils/app_colors.dart';
import 'package:rudra/app/utils/responsive_utils.dart';

import '../../../../routes/app_routes.dart';
import '../../../../utils/app_logger.dart';
import '../../../../widgets/app_snackbar_styles.dart';
import '../../../../widgets/app_style.dart';



class ExecutiveSurveyInterviewerController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Text controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  // Rx for dropdowns
  final RxString selectedAge = ''.obs;
  final RxString selectedGender = ''.obs;
  final RxString selectedCast = ''.obs;

  // Lists
  final List<String> ageRanges = ['18-25', '26-39', '40-55', '56+'];
  final List<String> genders = ['Male', 'Female', 'Other'];
  final List<String> casts = ['Hindu Maratha', 'Other']; // Sample

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
            const Icon(Icons.sentiment_satisfied_alt,
                size: 48, color: AppColors.blue),
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
                  style: TextButton.styleFrom(
                    minimumSize: const Size(100, 40),
                  ),
                  onPressed: () {
                    Get.offAllNamed(AppRoutes.executiveHome);
                  },
                  child: const Text('Dashboard'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(100, 40),
                  ),
                  onPressed: () {
                    resetForm();
                    Get.offAllNamed(AppRoutes.executiveSurveyDetail);
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
                // Title
                Text(
                  'Discard Survey',
                  style: AppStyle.heading1PoppinsBlack.responsive,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                // Message
                Text(
                  'Are you sure you want to discard this survey?',
                  style: AppStyle.bodySmallPoppinsGrey.responsive,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                // Buttons Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // No Button
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
                            .copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    // Yes Button
                    ElevatedButton(
                      onPressed: () {
                        resetForm();
                        Get.back(); // Close dialog
                        Get.back(); // Go back to previous screen
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
    selectedAge.value = '';
    selectedGender.value = '';
    selectedCast.value = '';
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
}
