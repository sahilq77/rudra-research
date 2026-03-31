// lib/app/modules/survey_details/survey_details_view.dart
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rudra/app/modules/executive_module/executive_survey_detail/executive_survey_detail_controller.dart';
import 'package:rudra/bottom_navigation/bottom_navigation_controller.dart';

import '../../../common/customvalidators/text_validator.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/responsive_utils.dart';
import '../../../widgets/app_button_style.dart';
import '../../../widgets/app_style.dart';

class ExecutiveSurveyDetailView extends StatefulWidget {
  const ExecutiveSurveyDetailView({super.key});

  @override
  State<ExecutiveSurveyDetailView> createState() =>
      _ExecutiveSurveyDetailViewState();
}

class _ExecutiveSurveyDetailViewState extends State<ExecutiveSurveyDetailView> {
  final ExecutiveSurveyDetailController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    ResponsiveHelper.init(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Get.find<BottomNavigationController>().goToHome();
          },
        ),
        title: Text(
          'Select Section',
          style: AppStyle.heading1PoppinsBlack.responsive,
        ),
        backgroundColor: AppColors.white,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0),
          child: Divider(
            color: AppColors.grey.withOpacity(0.5),
            // thickness: 2,
            height: 0,
          ),
        ),
      ),
      backgroundColor: AppColors.white,
      body: Obx(
        () => RefreshIndicator(
          onRefresh: controller.refreshPage,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: ResponsiveHelper.paddingSymmetric(
              horizontal: 16,
              vertical: 16,
            ),
            child: Form(
              key: controller.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Please Enter Details',
                    style: AppStyle.headingSmallPoppinsBlack.responsive,
                  ),
                  const SizedBox(height: 24),
                  _buildDropdownField(
                    label: 'Select Language',
                    value: controller.selectedLanguage.value,
                    items: controller.availableLanguages,
                    onChanged: (value) =>
                        controller.selectedLanguage.value = value ?? 'Marathi',
                    validator: TextValidator.isEmpty,
                  ),
                  const SizedBox(height: 16),
                  if (controller.surveyDetailList.isNotEmpty) ...[
                    _buildReadOnlyField(
                      label: 'Select State',
                      value: controller.surveyDetailList.first.stateName,
                    ),
                    const SizedBox(height: 16),
                    _buildReadOnlyField(
                      label: 'Region',
                      value: controller.surveyDetailList.first.region,
                    ),
                    const SizedBox(height: 16),
                    _buildReadOnlyField(
                      label: 'Select District',
                      value: controller.surveyDetailList.first.districtName,
                    ),
                    const SizedBox(height: 16),
                    _buildReadOnlyField(
                      label: 'Select Loksabha',
                      value: controller.surveyDetailList.first.loksabhaName,
                    ),
                    const SizedBox(height: 16),
                    _buildReadOnlyField(
                      label: 'Select Assembly',
                      value: controller.surveyDetailList.first.assemblyName,
                    ),
                    const SizedBox(height: 16),
                  ] else
                    ...[],
                  // WARD DROPDOWN
                  Obx(() => _buildDropdownField(
                        label: 'Select Ward/ZP',
                        value: controller.selectedWardName.value,
                        items: controller.getWardNames(),
                        onChanged: (value) {
                          controller.setSelectedWard(value);
                          debugPrint(
                            'Selected Ward: $value  →  ID: ${controller.selectedWardId.value}',
                          );
                        },
                        validator: TextValidator.isEmpty,
                      )),
                  const SizedBox(height: 16),
                  // AREA DROPDOWN (Filtered by Ward)
                  Obx(() => _buildAreaDropdown()),
                  const SizedBox(height: 32),
                  // SUBMIT BUTTON WITH LOADING
                  Obx(() {
                    final isLoading = controller.isLoadings.value;

                    return ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () => controller.nextPage(controller.formKey),
                      style: AppButtonStyles.elevatedLargeBlack(),
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              'Start Survey',
                              style: AppStyle.buttonTextPoppinsWhite.responsive,
                            ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppStyle.labelPrimaryPoppinsGrey.responsive),
        const SizedBox(height: 8),
        DropdownSearch<String>(
          selectedItem: value,
          items: items,
          onChanged: onChanged,
          validator: validator,
          dropdownDecoratorProps: DropDownDecoratorProps(
            dropdownSearchDecoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
          popupProps: const PopupProps.menu(showSearchBox: true),
        ),
      ],
    );
  }

  Widget _buildAreaDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Select Area/Village',
            style: AppStyle.labelPrimaryPoppinsGrey.responsive),
        const SizedBox(height: 8),
        DropdownSearch<String>(
          selectedItem: controller.selectedAreaVal?.value ?? '',
          items: controller.getAreaNames(),
          onChanged: (value) {
            controller.setSelectedArea(value);
            debugPrint(
              'Selected Area/Village: $value  →  ID: ${controller.selectedAreaId.value}',
            );
          },
          validator: TextValidator.isEmpty,
          dropdownDecoratorProps: DropDownDecoratorProps(
            dropdownSearchDecoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
          popupProps: const PopupProps.menu(showSearchBox: true),
        ),
      ],
    );
  }

  Widget _buildReadOnlyField({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppStyle.labelPrimaryPoppinsGrey.responsive),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: value,
          readOnly: true,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }
}
