import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rudra/app/modules/validator_module/validator_start_survey_detail/validator_submit_survey/validator_submit_survey_form_controller.dart';
import 'package:rudra/app/utils/app_colors.dart';
import 'package:rudra/app/utils/responsive_utils.dart';
import 'package:rudra/app/widgets/app_button_style.dart';
import 'package:rudra/app/widgets/app_style.dart';

class ValidatorSubmitSurveyFormView extends StatelessWidget {
  final ValidatorSubmitSurveyFormController controller = Get.put(
    ValidatorSubmitSurveyFormController(),
  );

  @override
  Widget build(BuildContext context) {
    ResponsiveHelper.init(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Submit Remark',
          style: AppStyle.heading1PoppinsBlack.responsive,
        ),
        backgroundColor: AppColors.white,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(0),
          child: Divider(color: AppColors.grey.withOpacity(0.5), height: 0),
        ),
      ),
      body: Padding(
        padding: ResponsiveHelper.paddingSymmetric(
          horizontal: 16,
          vertical: 16,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Please Enter Details',
                style: AppStyle.headingSmallPoppinsBlack.responsive,
              ),
              SizedBox(height: ResponsiveHelper.screenHeight * 0.02),
              _buildTextFormField(
                label: 'Remark',
                initialValue: controller.remark.value,
                onChanged: (value) {
                  controller.updateRemark(value);
                },
              ),
              SizedBox(height: ResponsiveHelper.screenHeight * 0.02),
              _buildDropdownField(
                label: 'Select Report',
                value: controller.selectedReport.value,
                items: controller.reports,
                onChanged: (value) {
                  if (value != null) controller.updateSelectedReport(value);
                },
                validator: null,
              ),
              SizedBox(height: ResponsiveHelper.screenHeight * 0.02),
              Obx(() {
                if (controller.isFetchingLocation.value) {
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.accentOrangeFaded,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.primary),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Fetching your location...',
                          style: AppStyle.labelPrimaryPoppinsBlack.responsive,
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),
              SizedBox(height: ResponsiveHelper.screenHeight * 0.03),
              Center(
                child: Obx(() => ElevatedButton(
                      onPressed: controller.isSubmitting.value
                          ? null
                          : controller.submitRemark,
                      style: AppButtonStyles.elevatedLargeBlack(),
                      child: controller.isSubmitting.value
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'Submit Feedback',
                              style: AppStyle.buttonTextPoppinsWhite.responsive,
                            ),
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?)? onChanged,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppStyle.reportCardRowCount.responsive),
        const SizedBox(height: 8),
        DropdownSearch<String>(
          selectedItem: value.isNotEmpty ? value : null,
          items: items,
          onChanged: onChanged,
          validator: validator,
          enabled: onChanged != null,
          dropdownDecoratorProps: DropDownDecoratorProps(
            dropdownSearchDecoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              filled: onChanged == null,
              fillColor: onChanged == null ? Colors.grey[200] : null,
            ),
          ),
          popupProps: const PopupProps.menu(showSearchBox: true),
        ),
      ],
    );
  }

  Widget _buildTextFormField({
    required String label,
    required String initialValue,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppStyle.reportCardRowCount.responsive),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: initialValue,
          onChanged: onChanged,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          maxLines: 3,
        ),
      ],
    );
  }
}
