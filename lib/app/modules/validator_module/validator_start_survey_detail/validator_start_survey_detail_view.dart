import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:easy_stepper/easy_stepper.dart';
import 'package:rudra/app/modules/validator_module/validator_start_survey_detail/validator_start_survey_controller.dart';

import '../../../common/customvalidators/text_validator.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/responsive_utils.dart';
import '../../../widgets/app_button_style.dart';
import '../../../widgets/app_style.dart';

class ValidatorStartSurveyDetailView extends StatelessWidget {
  final ValidatorStartSurveyController controller = Get.put(
    ValidatorStartSurveyController(),
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
            //commets text field
            _buildTextField(
              label: 'Add Comments',
              initialValue: "",
              onChanged: (value) {
                // controller.surveyModel.value.comments = value;
              },
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
            onChanged: (value) {
              if (value != null) controller.selectedLanguage.value = value;
            },
            validator: null,
          ),
          const SizedBox(height: 16),
          _buildTextFormField(
            label: 'Select State',
            initialValue: controller.surveyModel.value.state ?? 'Maharashtra',
            onChanged: (value) {
              controller.surveyModel.update((val) => val?.state = value);
            },
          ),
          const SizedBox(height: 16),
          _buildTextFormField(
            label: 'Region',
            initialValue: controller.surveyModel.value.region ?? 'Western',
            onChanged: (value) {
              controller.surveyModel.update((val) => val?.region = value);
            },
          ),
          const SizedBox(height: 16),
          _buildTextFormField(
            label: 'Select District',
            initialValue: controller.surveyModel.value.district ?? 'Kolhapur',
            onChanged: (value) {
              controller.surveyModel.update((val) => val?.district = value);
            },
          ),
          const SizedBox(height: 16),
          _buildTextFormField(
            label: 'Select Loksabha',
            initialValue: controller.surveyModel.value.loksabha ?? 'Kolhapur',
            onChanged: (value) {
              controller.surveyModel.update((val) => val?.loksabha = value);
            },
          ),
          const SizedBox(height: 16),
          _buildDropdownField(
            label: 'Select Assembly',
            value: controller.selectedAssembly.value,
            items: controller.assemblies,
            onChanged: (value) {
              if (value != null) controller.selectedAssembly.value = value;
            },
            validator: null,
          ),
          const SizedBox(height: 16),
          _buildDropdownField(
            label: 'Select Ward/ZP',
            value: controller.selectedWardZp.value,
            items: controller.wardsZp,
            onChanged: (value) {
              if (value != null) controller.selectedWardZp.value = value;
            },
            validator: null,
          ),
          const SizedBox(height: 16),
          _buildDropdownField(
            label: 'Select Area/Village',
            value: controller.selectedArea.value,
            items: controller.areas,
            onChanged: (value) {
              if (value != null) controller.selectedArea.value = value;
            },
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
                  onChanged: (value) {
                    if (value != null)
                      controller.updateQuestionAnswer(index, value);
                  },
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
          _buildTextFormField(
            label: 'Name',
            initialValue: 'Sakshi',
            onChanged: (value) {
              controller.updateInterviewerDetails(name: value);
            },
          ),
          const SizedBox(height: 16),
          _buildDropdownField(
            label: 'Age',
            value:
                controller.surveyModel.value.interviewerAge?.toString() ??
                '26-39',
            items: ['18-39', '40-59', '60+'],
            onChanged: (value) {
              if (value != null)
                controller.updateInterviewerDetails(
                  age: int.tryParse(value.split('-').first),
                );
            },
            validator: null,
          ),
          const SizedBox(height: 16),
          _buildDropdownField(
            label: 'Gender',
            value: controller.surveyModel.value.interviewerGender ?? 'Female',
            items: ['Male', 'Female', 'Other'],
            onChanged: (value) {
              if (value != null)
                controller.updateInterviewerDetails(gender: value);
            },
            validator: null,
          ),
          const SizedBox(height: 16),
          _buildTextFormField(
            label: 'Phone Number',
            initialValue: '9874561230',
            onChanged: (value) {
              controller.updateInterviewerDetails(phone: value);
            },
          ),
          const SizedBox(height: 16),
          _buildTextFormField(
            label: 'Cast',
            initialValue: 'General',
            onChanged: (value) {
              controller.updateInterviewerDetails(cast: value);
            },
          ),
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
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    String? initialValue,
    required Function(String) onChanged,
  }) {
    return _buildTextFormField(
      label: label,
      initialValue: initialValue ?? '',
      onChanged: onChanged,
    );
  }
}
