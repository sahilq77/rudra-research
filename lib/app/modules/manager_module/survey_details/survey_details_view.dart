import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart'; // ← Added for debugPrint

import '../../../common/customvalidators/text_validator.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/responsive_utils.dart';
import '../../../widgets/app_button_style.dart';
import '../../../widgets/app_style.dart';
import 'survey_details_controller.dart';

class SurveyDetailsView extends StatefulWidget {
  const SurveyDetailsView({super.key});

  @override
  State<SurveyDetailsView> createState() => _SurveyDetailsViewState();
}

class _SurveyDetailsViewState extends State<SurveyDetailsView> {
  final SurveyDetailsController controller = Get.find();

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
          'Select Section',
          style: AppStyle.heading1PoppinsBlack.responsive,
        ),
        backgroundColor: AppColors.white,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(0),
          child: Divider(color: AppColors.grey.withOpacity(0.5), height: 0),
        ),
      ),
      backgroundColor: AppColors.white,
      // ---------------------------------------------------------------
      // UPDATED: Show CircularProgressIndicator while fetchSurveyDetail
      // ---------------------------------------------------------------
      body: Obx(() {
        // Show loading spinner when fetching survey details
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        // Normal UI when data is loaded
        return RefreshIndicator(
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

                  // LANGUAGE DROPDOWN - LOGGED (with ID)
                  _buildDropdownField(
                    label: 'Select Language',
                    selectedValueObs: controller.selectedLanguage,
                    items: controller.languages,
                    onChanged: (value) {
                      if (value != null) {
                        controller.selectedLanguage.value = value;
                        debugPrint(
                          'Selected Language: $value  →  ID: ${controller.selectedLanguageId.value}',
                        );
                      }
                    },
                    validator: TextValidator.isEmpty,
                  ),

                  const SizedBox(height: 16),
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
                  _buildReadOnlyField(
                    label: 'Select Ward/Zp',
                    value: controller.surveyDetailList.first.wardName,
                  ),
                  const SizedBox(height: 16),

                  // AREA DROPDOWN - LOGGED (with ID)
                  _buildDropdownField(
                    label: 'Select Area/Village',
                    selectedValueObs: controller.selectedAreaVal,
                    items: controller.getAreaNames(),
                    onChanged: (value) {
                      controller.setSelectedArea(value); // <-- NEW helper
                      debugPrint(
                        'Selected Area/Village: $value  →  ID: ${controller.selectedAreaId.value}',
                      );
                    },
                    validator: TextValidator.isEmpty,
                  ),

                  const SizedBox(height: 32),

                  // UPDATED BUTTON: Shows loading + disabled during API call
                  Obx(
                    () => ElevatedButton(
                      onPressed: controller.isLoadings.value
                          ? null
                          : controller.nextPage,
                      style: AppButtonStyles.elevatedLargeBlack(),
                      child: controller.isLoadings.value
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
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  // UPDATED: Now accepts RxString? and uses Obx internally
  Widget _buildDropdownField({
    required String label,
    required RxString? selectedValueObs,
    required List<String> items,
    required Function(String?) onChanged,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppStyle.labelPrimaryPoppinsGrey.responsive),
        const SizedBox(height: 8),
        Obx(
          () => DropdownSearch<String>(
            selectedItem: selectedValueObs?.value ?? '',
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
        ),
      ],
    );
  }

  // YOUR ORIGINAL READ-ONLY FIELD - UNCHANGED
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
