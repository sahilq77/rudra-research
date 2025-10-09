import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:easy_stepper/easy_stepper.dart';

import '../../common/customvalidators/text_validator.dart';
import '../../utils/app_colors.dart';
import '../../utils/responsive_utils.dart';
import '../../widgets/app_button_style.dart';
import '../../widgets/app_style.dart';
import 'survey_detail_multiple_controller.dart';

class SurveyScreen extends StatelessWidget {
  final SurveyDetailMultipleController controller = Get.put(
    SurveyDetailMultipleController(),
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
      body: Obx(
        () => RefreshIndicator(
          onRefresh: controller.refreshPage,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              scrollDirection: Axis.vertical,
              padding: ResponsiveHelper.paddingSymmetric(
                horizontal: 16,
                vertical: 16,
              ),
              children: [
                Obx(
                  () => EasyStepper(
                    activeStepBackgroundColor: AppColors.defaultBlack,
                    showScrollbar: false,
                    disableScroll: true,
                    activeStep: controller.currentPage.value,
                    lineStyle: LineStyle(
                      lineType: LineType.normal,
                      defaultLineColor: AppColors.grey.withOpacity(0.5),
                      activeLineColor: AppColors.defaultBlack,
                      lineThickness: 2,
                    ),
                    stepShape: StepShape.circle,
                    stepBorderRadius: 15,
                    activeStepTextColor: AppColors.defaultBlack,
                    finishedStepTextColor: AppColors.defaultBlack,
                    internalPadding: 20,
                    stepRadius: 15,
                    showLoadingAnimation: false,
                    steps: [
                      EasyStep(
                        customStep: _buildStepWidget(0, '1'),
                        topTitle: true,
                      ),
                      EasyStep(
                        customStep: _buildStepWidget(1, '2'),
                        topTitle: true,
                      ),
                      EasyStep(
                        customStep: _buildStepWidget(2, '3'),
                        topTitle: true,
                      ),
                      EasyStep(
                        customStep: _buildStepWidget(3, '4'),
                        topTitle: true,
                      ),
                      EasyStep(
                        customStep: _buildStepWidget(4, '5'),
                        topTitle: true,
                      ),
                    ],
                    onStepReached: (index) {
                      if (index <= controller.currentPage.value) {
                        controller.currentPage.value = index;
                      }
                    },
                  ),
                ),
                _buildStepContent(controller.currentPage.value),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildControls(context),
    );
  }

  Widget _buildStepWidget(int stepIndex, String stepNumber) {
    bool isCompleted = controller.currentPage.value > stepIndex;
    bool isActive = controller.currentPage.value >= stepIndex;

    return CircleAvatar(
      backgroundColor: isActive ? AppColors.defaultBlack : AppColors.grey,
      child: isCompleted
          ? Icon(Icons.check, color: AppColors.white, size: 20)
          : Text(
              stepNumber,
              style: TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
    );
  }

  Widget _buildStepContent(int index) {
    switch (index) {
      case 0:
        return _buildSectionScreen();
      case 1:
        return _buildQuestionScreen(0);
      case 2:
        return _buildQuestionScreen(1);
      case 3:
        return _buildQuestionScreen(2);
      case 4:
        return _buildInterviewerScreen();
      default:
        return Container();
    }
  }

  Widget _buildControls(BuildContext context) {
    return Obx(
      () => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '00:45',
                  style: AppStyle.labelPrimaryPoppinsGrey.responsive,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Slider(
                    activeColor: AppColors.buttonColor,
                    value: 45,
                    max: 150,
                    onChanged: (val) {}, // Disabled slider
                  ),
                ),
                SizedBox(width: 10),
                Text(
                  '02:30',
                  style: AppStyle.labelPrimaryPoppinsGrey.responsive,
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(
                    size: 30,
                    Icons.replay_5,
                    color: AppColors.buttonColor,
                  ),
                  onPressed: () {
                    // Handle rewind 5 seconds
                  },
                ),
                SizedBox(width: 20),
                Container(
                  width: ResponsiveHelper.screenWidth * 0.23,
                  height: ResponsiveHelper.screenHeight * 0.07,
                  decoration: BoxDecoration(
                    color: AppColors.buttonColor,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Icon(Icons.play_arrow, color: Colors.white, size: 40),
                ),
                SizedBox(width: 20),
                IconButton(
                  icon: Icon(
                    size: 30,
                    Icons.forward_5,
                    color: AppColors.buttonColor,
                  ),
                  onPressed: () {
                    // Handle fast-forward 5 seconds
                  },
                ),
              ],
            ),
            SizedBox(height: ResponsiveHelper.screenHeight * 0.03),
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primary),
                color: AppColors.accentOrangeFaded,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                'Comment : Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut.',
                style: AppStyle.myteamCardRowTitle.responsive,
              ),
            ),
            SizedBox(height: ResponsiveHelper.screenHeight * 0.03),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (controller.currentPage.value > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: controller.previousPage,
                      style: AppButtonStyles.outlinedLargeBlack(),
                      child: Text(
                        'Previous',
                        style: AppStyle.buttonTextPoppinsBlack.responsive,
                      ),
                    ),
                  ),
                if (controller.currentPage.value > 0 &&
                    controller.currentPage.value < 4)
                  SizedBox(width: ResponsiveHelper.screenWidth * 0.02),
                if (controller.currentPage.value < 4)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: controller.nextPage,
                      style: AppButtonStyles.elevatedLargeBlack(),
                      child: Text(
                        'Next',
                        style: AppStyle.buttonTextPoppinsWhite.responsive,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionScreen() {
    return Form(
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
            onChanged: null, // Disable dropdown
            validator: null,
          ),
          const SizedBox(height: 16),
          _buildReadOnlyField(
            label: 'Select State',
            value: controller.surveyModel.value.state ?? 'Maharashtra',
          ),
          const SizedBox(height: 16),
          _buildReadOnlyField(
            label: 'Region',
            value: controller.surveyModel.value.region ?? 'Western',
          ),
          const SizedBox(height: 16),
          _buildReadOnlyField(
            label: 'Select District',
            value: controller.surveyModel.value.district ?? 'Kolhapur',
          ),
          const SizedBox(height: 16),
          _buildReadOnlyField(
            label: 'Select Loksabha',
            value: controller.surveyModel.value.loksabha ?? 'Kolhapur',
          ),
          const SizedBox(height: 16),
          _buildDropdownField(
            label: 'Select Assembly',
            value: controller.selectedAssembly.value,
            items: controller.assemblies,
            onChanged: null, // Disable dropdown
            validator: null,
          ),
          const SizedBox(height: 16),
          _buildDropdownField(
            label: 'Select Ward/ZP',
            value: controller.selectedWardZp.value,
            items: controller.wardsZp,
            onChanged: null, // Disable dropdown
            validator: null,
          ),
          const SizedBox(height: 16),
          _buildDropdownField(
            label: 'Select Area/Village',
            value: controller.selectedArea.value,
            items: controller.areas,
            onChanged: null, // Disable dropdown
            validator: null,
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionScreen(int index) {
    return Card(
      child: Padding(
        padding: ResponsiveHelper.paddingSymmetric(
          horizontal: 16,
          vertical: 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'आपल्या प्रभागातील माजी नगरसेविका श्रीमती लक्ष्मीउदयकांत आंदेकर यांची कामगिरी कशी वाटते?',
              style: AppStyle.headingSmallPoppinsBlack.responsive,
            ),
            ...[
              'चांगली कामगिरी',
              'सर्वसाधारण कामगिरी',
              'खराब कामगिरी',
              'सांगता येत नाही',
            ].map((option) {
              return Obx(
                () => RadioListTile<String>(
                  title: Text(
                    option,
                    style: AppStyle.labelPrimaryPoppinsGrey.responsive,
                  ),
                  value: option,
                  groupValue:
                      controller.surveyModel.value.questionAnswers?[index],
                  onChanged: null, // Disable radio buttons
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildInterviewerScreen() {
    return Padding(
      padding: ResponsiveHelper.paddingSymmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Interviewer Information',
            style: AppStyle.heading1PoppinsBlack.responsive,
          ),
          SizedBox(height: ResponsiveHelper.screenHeight * 0.02),
          Text(
            'Please Enter Details',
            style: AppStyle.headingSmallPoppinsBlack.responsive,
          ),
          const SizedBox(height: 24),
          _buildReadOnlyField(label: 'Name', value: 'Sakshi'),
          const SizedBox(height: 16),
          _buildDropdownField(
            label: 'Age',

            value: '26-39',
            items: ['18-39', '40-59', '60+'],
            onChanged: null, // Disable dropdown
            validator: null,
          ),
          const SizedBox(height: 16),
          _buildDropdownField(
            label: 'Gender',
            value: 'Female',
            items: ['Male', 'Female', 'Other'],
            onChanged: null, // Disable dropdown
            validator: null,
          ),
          const SizedBox(height: 16),
          _buildReadOnlyField(label: 'Phone Number', value: '9874561230'),
          const SizedBox(height: 16),
          _buildReadOnlyField(label: 'Cast', value: 'General'),
        ],
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
          enabled: onChanged != null, // Disable if onChanged is null
          dropdownDecoratorProps: DropDownDecoratorProps(
            dropdownSearchDecoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              filled:
                  onChanged == null, // Optional: fill background for disabled
              fillColor: onChanged == null ? Colors.grey[200] : null,
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
        Text(label, style: AppStyle.reportCardRowCount.responsive),
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
            filled: true, // Optional: fill background for consistency
            fillColor:
                Colors.grey[200], // Optional: grey background for read-only
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    String? initialValue,
    required Function(String) onChanged,
  }) {
    return _buildReadOnlyField(label: label, value: initialValue ?? '');
  }
}
