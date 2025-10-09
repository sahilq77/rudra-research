// lib/app/modules/survey_interviewer/survey_interviewer_view.dart
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../common/custominputformatters/number_input_formatter.dart';
import '../../../common/custominputformatters/securetext_input_formatter.dart';
import '../../../common/customvalidators/text_validator.dart';
import '../../../routes/app_routes.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_images.dart';
import '../../../utils/responsive_utils.dart';
import '../../../widgets/app_button_style.dart';
import '../../../widgets/app_style.dart';
import 'survey_interviewer_controller.dart';

class SurveyInterviewerView extends StatefulWidget {
  const SurveyInterviewerView({super.key});

  @override
  State<SurveyInterviewerView> createState() => _SurveyInterviewerViewState();
}

class _SurveyInterviewerViewState extends State<SurveyInterviewerView> {
  final SurveyInterviewerController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    ResponsiveHelper.init(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.defaultBlack),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Interviewer Information',
          style: AppStyle.heading1PoppinsBlack.responsive,
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
        surfaceTintColor: AppColors.white,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(0),
          child: Divider(
            color: AppColors.grey.withOpacity(0.5),
            // thickness: 2,
            height: 0,
          ),
        ),
      ),
      backgroundColor: AppColors.white,
      body: Obx(
        () => Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: controller.refreshPage,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: ResponsiveHelper.paddingSymmetric(
                    horizontal: 16,
                    vertical: 20,
                  ),
                  child: Form(
                    key: controller.formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Please Enter Details',
                          style: AppStyle.heading1PoppinsBlack.responsive,
                        ),
                        const SizedBox(height: 24),
                        _buildTextField(
                          label: 'Name',
                          controller: controller.nameController,
                          validator: TextValidator.isEmpty,
                        ),
                        const SizedBox(height: 20),
                        _buildDropdownField(
                          label: 'Age',
                          value: controller.selectedAge.value,
                          items: controller.ageRanges,
                          onChanged: (value) =>
                              controller.selectedAge.value = value ?? '',
                          validator: TextValidator.isEmpty,
                        ),
                        const SizedBox(height: 20),
                        _buildDropdownField(
                          label: 'Gender',
                          value: controller.selectedGender.value,
                          items: controller.genders,
                          onChanged: (value) =>
                              controller.selectedGender.value = value ?? '',
                          validator: TextValidator.isEmpty,
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          label: 'Phone Number',
                          controller: controller.phoneController,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            NumberInputFormatter(),
                            SecureTextInputFormatter.deny(),
                            LengthLimitingTextInputFormatter(10),
                          ],
                          validator: TextValidator.isMobileNumber,
                        ),
                        const SizedBox(height: 20),
                        _buildDropdownField(
                          label: 'Cast',
                          value: controller.selectedCast.value,
                          items: controller.casts,
                          onChanged: (value) =>
                              controller.selectedCast.value = value ?? '',
                          validator: TextValidator.isEmpty,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Bottom Buttons
            Container(
              padding: ResponsiveHelper.paddingSymmetric(
                horizontal: 16,
                vertical: 16,
              ),
              decoration: BoxDecoration(
                color: AppColors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: controller.discardSurvey,
                      style: AppButtonStyles.outlinedLargeBlack(),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'Discard Survey',
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
                      onPressed: () {
                        if (controller.formKey.currentState?.validate() ??
                            false) {
                          _showSuccessDialog(context);
                        }
                      },
                      style: AppButtonStyles.elevatedLargeBlack(),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'Submit Survey',
                          style:
                              AppStyle.buttonTextSmallPoppinsWhite.responsive,
                          maxLines: 1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
                          controller.resetForm();
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
                        onPressed: () {
                          controller.resetForm();
                          Get.back(); // Close dialog
                          Get.offAllNamed(
                            AppRoutes.surveyDetails,
                          ); // Navigate to next survey
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

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppStyle.labelPrimaryPoppinsBlack.responsive),
        const SizedBox(height: 10),
        DropdownSearch<String>(
          selectedItem: value.isEmpty ? null : value,
          items: items,
          onChanged: onChanged,
          validator: validator,
          dropdownDecoratorProps: DropDownDecoratorProps(
            dropdownSearchDecoration: InputDecoration(
              hintText: 'Select $label',
              hintStyle: AppStyle.bodySmallPoppinsGrey.responsive,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: AppColors.grey.withOpacity(0.3),
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: AppColors.grey.withOpacity(0.3),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 1.5,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.red, width: 1),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              filled: true,
              fillColor: AppColors.white,
            ),
          ),
          popupProps: PopupProps.menu(
            showSearchBox: true,
            searchFieldProps: TextFieldProps(
              decoration: InputDecoration(
                hintText: 'Search...',
                hintStyle: AppStyle.bodySmallPoppinsGrey.responsive,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
            containerBuilder: (context, popupWidget) {
              return Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: popupWidget,
              );
            },
          ),
          dropdownButtonProps: const DropdownButtonProps(
            icon: Icon(
              Icons.keyboard_arrow_down,
              color: AppColors.defaultBlack,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppStyle.labelPrimaryPoppinsBlack.responsive),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters ?? [SecureTextInputFormatter.deny()],
          validator: validator,
          style: AppStyle.bodySmallPoppinsBlack.responsive,
          decoration: InputDecoration(
            hintText: 'Enter $label',
            hintStyle: AppStyle.bodySmallPoppinsGrey.responsive,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: AppColors.grey.withOpacity(0.3),
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: AppColors.grey.withOpacity(0.3),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            filled: true,
            fillColor: AppColors.white,
          ),
        ),
      ],
    );
  }
}
