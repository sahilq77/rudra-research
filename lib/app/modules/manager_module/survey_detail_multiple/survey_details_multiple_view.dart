import 'package:easy_stepper/easy_stepper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../../../routes/app_routes.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/responsive_utils.dart';
import '../../../widgets/app_button_style.dart';
import '../../../widgets/app_style.dart';
import 'survey_detail_multiple_controller.dart';

class SurveyDetailsMultipleView extends StatefulWidget {
  const SurveyDetailsMultipleView({super.key});

  @override
  State<SurveyDetailsMultipleView> createState() =>
      _SurveyDetailsMultipleViewState();
}

class _SurveyDetailsMultipleViewState extends State<SurveyDetailsMultipleView> {
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
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Get.offAllNamed(AppRoutes.home);
            }
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
      body: Obx(
        () {
          if (controller.isLoading.value) {
            return _buildShimmer();
          }

          if (controller.surveyDetailData.value == null) {
            return const Center(child: Text('No data available'));
          }

          return RefreshIndicator(
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
                      steps: _buildDynamicSteps(),
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
          );
        },
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
          ? const Icon(Icons.check, color: AppColors.white, size: 20)
          : Text(
              stepNumber,
              style: const TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
    );
  }

  List<EasyStep> _buildDynamicSteps() {
    final data = controller.surveyDetailData.value;
    if (data == null) return [];

    List<EasyStep> steps = [
      EasyStep(customStep: _buildStepWidget(0, '1'), topTitle: true),
    ];

    for (int i = 0; i < data.questionsAndAnswers.length; i++) {
      steps.add(
        EasyStep(
          customStep: _buildStepWidget(i + 1, '${i + 2}'),
          topTitle: true,
        ),
      );
    }

    steps.add(
      EasyStep(
        customStep: _buildStepWidget(
          data.questionsAndAnswers.length + 1,
          '${data.questionsAndAnswers.length + 2}',
        ),
        topTitle: true,
      ),
    );

    return steps;
  }

  Widget _buildStepContent(int index) {
    final data = controller.surveyDetailData.value;
    if (data == null) return Container();

    if (index == 0) {
      return _buildSectionScreen();
    } else if (index <= data.questionsAndAnswers.length) {
      return _buildQuestionScreen(index - 1);
    } else {
      return _buildInterviewerScreen();
    }
  }

  int _getTotalSteps() {
    final data = controller.surveyDetailData.value;
    if (data == null) return 2;
    return 2 + data.questionsAndAnswers.length;
  }

  Widget _buildControls(BuildContext context) {
    return Obx(() {
      final data = controller.surveyDetailData.value;
      final currentIndex = controller.currentPage.value;
      String? audioPath;
      String? comment;

      if (data != null) {
        // Audio is available on all pages
        audioPath = data.audioDetails.audioUrl ?? data.audioDetails.audio;

        // Validator comment is available on question pages
        if (currentIndex > 0 &&
            currentIndex <= data.questionsAndAnswers.length) {
          final qa = data.questionsAndAnswers[currentIndex - 1];
          comment = qa.validatorComment;
        }
      }

      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (audioPath != null && audioPath.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    controller.formatDuration(controller.currentPosition.value),
                    style: AppStyle.labelPrimaryPoppinsGrey.responsive,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Slider(
                      activeColor: AppColors.buttonColor,
                      value: controller.currentPosition.value,
                      max: controller.totalDuration.value > 0
                          ? controller.totalDuration.value
                          : 1,
                      onChanged: (val) => controller.seekAudio(val),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    controller.formatDuration(controller.totalDuration.value),
                    style: AppStyle.labelPrimaryPoppinsGrey.responsive,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(
                      size: 30,
                      Icons.replay_5,
                      color: AppColors.buttonColor,
                    ),
                    onPressed: controller.rewind5Seconds,
                  ),
                  const SizedBox(width: 20),
                  GestureDetector(
                    onTap: () => controller.playPauseAudio(audioPath),
                    child: Container(
                      width: ResponsiveHelper.screenWidth * 0.23,
                      height: ResponsiveHelper.screenHeight * 0.07,
                      decoration: BoxDecoration(
                        color: AppColors.buttonColor,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Icon(
                        controller.isPlaying.value
                            ? Icons.pause
                            : Icons.play_arrow,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  IconButton(
                    icon: const Icon(
                      size: 30,
                      Icons.forward_5,
                      color: AppColors.buttonColor,
                    ),
                    onPressed: controller.forward5Seconds,
                  ),
                ],
              ),
              SizedBox(height: ResponsiveHelper.screenHeight * 0.03),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.grey),
                  color: AppColors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  'No audio file available',
                  style: AppStyle.labelPrimaryPoppinsGrey.responsive,
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: ResponsiveHelper.screenHeight * 0.03),
            ],
            if (comment != null && comment.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.primary),
                  color: AppColors.accentOrangeFaded,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  'Comment : $comment',
                  style: AppStyle.myteamCardRowTitle.responsive,
                ),
              ),
              SizedBox(height: ResponsiveHelper.screenHeight * 0.03),
            ],
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
                if (controller.currentPage.value > 0)
                  SizedBox(width: ResponsiveHelper.screenWidth * 0.02),
                if (controller.currentPage.value < _getTotalSteps() - 1)
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
                if (controller.currentPage.value == _getTotalSteps() - 1)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: controller.exitToResponseList,
                      style: AppButtonStyles.elevatedLargeBlack(),
                      child: Text(
                        'Exit',
                        style: AppStyle.buttonTextPoppinsWhite.responsive,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSectionScreen() {
    final data = controller.surveyDetailData.value;
    if (data == null) return Container();

    final info = data.surveyInfo;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Survey Details',
          style: AppStyle.headingSmallPoppinsBlack.responsive,
        ),
        const SizedBox(height: 24),
        _buildReadOnlyField(label: 'Language', value: info.surveyLanguage),
        const SizedBox(height: 16),
        _buildReadOnlyField(label: 'State', value: info.state),
        const SizedBox(height: 16),
        _buildReadOnlyField(label: 'Region', value: info.region),
        const SizedBox(height: 16),
        _buildReadOnlyField(label: 'District', value: info.district),
        const SizedBox(height: 16),
        _buildReadOnlyField(label: 'Loksabha', value: info.loksabha),
        const SizedBox(height: 16),
        _buildReadOnlyField(label: 'Assembly', value: info.assembly),
        const SizedBox(height: 16),
        _buildReadOnlyField(label: 'Ward/ZP', value: info.ward),
        const SizedBox(height: 16),
        _buildReadOnlyField(label: 'Area/Village', value: info.villageArea),
        const SizedBox(height: 16),
        _buildReadOnlyField(label: 'Team', value: info.team),
      ],
    );
  }

  Widget _buildQuestionScreen(int index) {
    final data = controller.surveyDetailData.value;
    if (data == null || index >= data.questionsAndAnswers.length) {
      return Container();
    }

    final qa = data.questionsAndAnswers[index];
    return Card(
      child: Padding(
        padding: ResponsiveHelper.paddingSymmetric(
          horizontal: 16,
          vertical: 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Html(
              data: qa.question,
              style: {
                "p": Style(
                  fontSize: FontSize(14),
                  fontWeight: FontWeight.w500,
                  color: AppColors.defaultBlack,
                ),
              },
            ),
            const SizedBox(height: 16),
            ...qa.allOptions.map((option) {
              final isSelected = option.optionId == qa.answerId;
              return RadioListTile<String>(
                title: Text(
                  option.choiceText,
                  style: AppStyle.labelPrimaryPoppinsGrey.responsive,
                ),
                value: option.optionId,
                groupValue: qa.answerId,
                onChanged: null,
                selected: isSelected,
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildInterviewerScreen() {
    final data = controller.surveyDetailData.value;
    if (data == null) return Container();

    final people = data.peopleDetails;
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
            'Details',
            style: AppStyle.headingSmallPoppinsBlack.responsive,
          ),
          const SizedBox(height: 24),
          _buildReadOnlyField(
            label: 'Name',
            value: people.name.isEmpty ? 'N/A' : people.name,
          ),
          const SizedBox(height: 16),
          _buildReadOnlyField(
            label: 'Age',
            value: _getAgeLabel(people.age),
          ),
          const SizedBox(height: 16),
          _buildReadOnlyField(
            label: 'Gender',
            value: _getGenderLabel(people.gender),
          ),
          const SizedBox(height: 16),
          _buildReadOnlyField(
            label: 'Phone Number',
            value: people.mobileNo.isEmpty ? 'N/A' : people.mobileNo,
          ),
          const SizedBox(height: 16),
          _buildReadOnlyField(
            label: 'Cast',
            value: people.castName ?? 'N/A',
          ),
          const SizedBox(height: 16),
          _buildReadOnlyField(
            label: 'Submitted At',
            value: people.submittedAt,
          ),
        ],
      ),
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

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Padding(
        padding:
            ResponsiveHelper.paddingSymmetric(horizontal: 16, vertical: 16),
        child: Column(
          children: [
            Container(height: 80, color: Colors.white),
            const SizedBox(height: 20),
            Container(height: 200, color: Colors.white),
          ],
        ),
      ),
    );
  }

  String _getAgeLabel(String ageId) {
    if (ageId.isEmpty) return 'N/A';
    const ageRanges = ['18-25', '26-39', '40-60', '60+'];
    final index = int.tryParse(ageId) ?? -1;
    if (index >= 0 && index < ageRanges.length) {
      return ageRanges[index];
    }
    return ageId;
  }

  String _getGenderLabel(String genderId) {
    if (genderId.isEmpty) return 'N/A';
    const genders = ['Male', 'Female', 'Other'];
    final index = int.tryParse(genderId) ?? -1;
    if (index >= 0 && index < genders.length) {
      return genders[index];
    }
    return genderId;
  }
}
