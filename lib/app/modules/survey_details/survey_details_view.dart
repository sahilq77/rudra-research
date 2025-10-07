// lib/app/modules/survey_details/survey_details_view.dart
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../common/customvalidators/text_validator.dart';
import '../../utils/app_colors.dart';
import '../../utils/responsive_utils.dart';
import '../../widgets/app_button_style.dart';
import '../../widgets/app_style.dart';
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
      ),
      backgroundColor: AppColors.white,
      body: Obx(
        () => RefreshIndicator(
          onRefresh: controller.refreshPage,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding:
                ResponsiveHelper.paddingSymmetric(horizontal: 16, vertical: 16),
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
                    items: controller.languages,
                    onChanged: (value) =>
                        controller.selectedLanguage.value = value ?? 'Marathi',
                    validator: TextValidator.isEmpty,
                  ),
                  const SizedBox(height: 16),
                  _buildReadOnlyField(
                      label: 'Select State', value: controller.state),
                  const SizedBox(height: 16),
                  _buildReadOnlyField(
                      label: 'Region', value: controller.region),
                  const SizedBox(height: 16),
                  _buildReadOnlyField(
                      label: 'Select District', value: controller.district),
                  const SizedBox(height: 16),
                  _buildReadOnlyField(
                      label: 'Select Loksabha', value: controller.loksabha),
                  const SizedBox(height: 16),
                  _buildReadOnlyField(
                      label: 'Select Assembly', value: controller.assembly),
                  const SizedBox(height: 16),
                  _buildReadOnlyField(
                      label: 'Select Ward/Zp', value: controller.wardZp),
                  const SizedBox(height: 16),
                  _buildDropdownField(
                    label: 'Select Area/Village',
                    value: controller.selectedArea.value,
                    items: controller.areas,
                    onChanged: (value) =>
                        controller.selectedArea.value = value ?? 'Mallewadi',
                    validator: TextValidator.isEmpty,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: controller.nextPage,
                    style: AppButtonStyles.elevatedLargeBlack(),
                    child: Text(
                      'Start Survey',
                      style: AppStyle.buttonTextPoppinsWhite.responsive,
                    ),
                  ),
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
    required Function(String?) onChanged,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppStyle.labelPrimaryPoppinsGrey.responsive,
        ),
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
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          popupProps: const PopupProps.menu(
            showSearchBox: true,
          ),
        ),
      ],
    );
  }

  Widget _buildReadOnlyField({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppStyle.labelPrimaryPoppinsGrey.responsive,
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: value,
          readOnly: true,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }
}
