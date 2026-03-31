import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../bottom_navigation/bottom_navigation_controller.dart';
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
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

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
          child: Divider(color: AppColors.grey.withOpacity(0.5), height: 0),
        ),
      ),
      backgroundColor: AppColors.white,
      // ---------------------------------------------------------------
      // UPDATED: Show CircularProgressIndicator while fetchSurveyDetail
      // ---------------------------------------------------------------
      body: Obx(() {
        // Show loading spinner when fetching survey details
        if (controller.isLoading.value && controller.surveyDetailList.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        // Handle case when list is empty but not loading (e.g. API failed or no data)
        if (controller.surveyDetailList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  'No survey details available',
                  style: AppStyle.bodySmallPoppinsBlack.responsive,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: controller.refreshPage,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        // SAFE: Now we know there's at least one item
        final detail = controller.surveyDetailList.first;

        return RefreshIndicator(
          onRefresh: controller.refreshPage,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: ResponsiveHelper.paddingSymmetric(
              horizontal: 16,
              vertical: 16,
            ),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Please Enter Details',
                    style: AppStyle.headingSmallPoppinsBlack.responsive,
                  ),
                  const SizedBox(height: 24),

                  // LANGUAGE DROPDOWN
                  Obx(() => _buildDropdownField(
                        label: 'Select Language',
                        selectedValueObs: controller.selectedLanguage,
                        items: controller.availableLanguages.isNotEmpty
                            ? controller.availableLanguages
                            : controller.allLanguages,
                        onChanged: (value) {
                          if (value != null) {
                            controller.selectedLanguage.value = value;
                            debugPrint(
                              'Selected Language: $value  →  ID: ${controller.selectedLanguageId.value}',
                            );
                          }
                        },
                        validator: TextValidator.isEmpty,
                      )),

                  const SizedBox(height: 16),
                  _buildReadOnlyField(
                    label: 'Select State',
                    value: detail.stateName,
                  ),
                  const SizedBox(height: 16),
                  _buildReadOnlyField(label: 'Region', value: detail.region),
                  const SizedBox(height: 16),
                  _buildReadOnlyField(
                    label: 'Select District',
                    value: detail.districtName,
                  ),
                  const SizedBox(height: 16),
                  _buildReadOnlyField(
                    label: 'Select Loksabha',
                    value: detail.loksabhaName,
                  ),
                  const SizedBox(height: 16),
                  _buildReadOnlyField(
                    label: 'Select Assembly',
                    value: detail.assemblyName,
                  ),
                  const SizedBox(height: 16),

                  // WARD DROPDOWN
                  Obx(() => _buildDropdownField(
                        label: 'Select Ward/ZP',
                        selectedValueObs: controller.selectedWardName,
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
                  Obx(
                    () => _buildDropdownField(
                      label: 'Select Area/Village',
                      selectedValueObs: controller.selectedAreaVal,
                      items: controller.getAreaNames(),
                      onChanged: (value) {
                        controller.setSelectedArea(value);
                        debugPrint(
                          'Selected Area/Village: $value  →  ID: ${controller.selectedAreaId.value}',
                        );
                      },
                      validator: TextValidator.isEmpty,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // SUBMIT BUTTON WITH LOADING
                  // Inside your widget tree (e.g. a Column)
                  Obx(() {
                    final isLoading = controller.isLoadings.value;

                    return ElevatedButton(
                      onPressed:
                          isLoading ? null : () => controller.nextPage(formKey),
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
