// lib/app/modules/survey_question/survey_question_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rudra/app/common/custominputformatters/securetext_input_formatter.dart';
import 'package:rudra/app/data/models/survey_question/get_survey_questions_response.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/app_utility.dart';
import '../../../utils/responsive_utils.dart';
import '../../../widgets/app_button_style.dart';
import '../../../widgets/app_style.dart';
import 'survey_question_controller.dart';

class SurveyQuestionView extends StatefulWidget {
  const SurveyQuestionView({super.key});

  @override
  State<SurveyQuestionView> createState() => _SurveyQuestionViewState();
}

class _SurveyQuestionViewState extends State<SurveyQuestionView> {
  final SurveyQuestionController controller = Get.find();

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
          'Select Section',
          style: AppStyle.heading1PoppinsBlack.responsive,
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
        surfaceTintColor: AppColors.white,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0),
          child: Divider(color: AppColors.grey.withOpacity(0.5), height: 0),
        ),
      ),
      backgroundColor: AppColors.white,
      body: Obx(() {
        if (controller.isLoadingq.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.errorMessageq.value.isNotEmpty) {
          return Center(
            child: Text(
              controller.errorMessageq.value,
              style: const TextStyle(color: Colors.red),
            ),
          );
        }
        if (controller.questionDetail.isEmpty) {
          return const Center(child: Text('No questions available'));
        }

        final Question current =
            controller.questionDetail[controller.currentIndex.value];
        final int total = controller.questionDetail.length;
        final int progress = controller.currentIndex.value + 1;

        return Column(
          children: [
            const SizedBox(height: 8),

            Expanded(
              child: RefreshIndicator(
                onRefresh: controller.refreshPage,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: ResponsiveHelper.paddingSymmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  child: Form(
                    key: controller.formKey,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // USER INFO
                          Row(
                            children: [
                              Obx(() => CircleAvatar(
                                    radius: 24,
                                    backgroundColor:
                                        AppColors.grey.withOpacity(0.2),
                                    backgroundImage:
                                        AppUtility.userImage.value.isNotEmpty
                                            ? NetworkImage(
                                                AppUtility.userImage.value)
                                            : null,
                                    child: AppUtility.userImage.value.isEmpty
                                        ? const Icon(Icons.person,
                                            color: AppColors.grey, size: 28)
                                        : null,
                                  )),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppUtility.fullName ?? 'Survey Poster',
                                    style: AppStyle
                                        .bodyBoldPoppinsBlack.responsive,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    DateTime.now().toString().substring(0, 10),
                                    style: AppStyle
                                        .labelSecondaryPoppinsGrey.responsive,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // PROGRESS
                          Text(
                            '$progress / $total',
                            style: AppStyle.bodySmallPoppinsGrey.responsive,
                          ),
                          const SizedBox(height: 8),
                          // Html(
                          //   data: current.question,
                          //   // style: TextDesign.commonStyles,
                          // ),
                          // QUESTION TEXT
                          Text(
                            controller.removeHtmlTags(current.question),
                            style: AppStyle.bodyRegularPoppinsBlack.responsive,
                          ),
                          const SizedBox(height: 16),

                          // OPTIONS: TEXT FIELD, SINGLE, MULTI, or BOOLEAN
                          if (controller.isTextField)
                            _buildTextField(current, controller)
                          else if (controller.isBoolean)
                            _buildBooleanOptions(current, controller)
                          else if (!controller.isMultiSelect)
                            ...current.options.map((opt) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: InkWell(
                                  onTap: () => controller
                                      .selectedAnswerId.value = opt.optionId,
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 4,
                                      horizontal: 0,
                                    ),
                                    child: Row(
                                      children: [
                                        Radio<String>(
                                          value: opt.optionId,
                                          groupValue:
                                              controller.selectedAnswerId.value,
                                          onChanged: (v) => controller
                                              .selectedAnswerId.value = v!,
                                          activeColor: AppColors.primary,
                                          materialTapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                          visualDensity: const VisualDensity(
                                            horizontal: -4,
                                            vertical: -4,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            opt.choiceText ?? '',
                                            style: AppStyle
                                                .bodySmallPoppinsBlack
                                                .responsive,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            })
                          else
                            ...current.options.map((opt) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: CheckboxListTile(
                                  value: controller.selectedAnswerIds
                                      .contains(opt.optionId),
                                  onChanged: (bool? checked) {
                                    if (checked == true) {
                                      controller.selectedAnswerIds.add(
                                        opt.optionId,
                                      );
                                    } else {
                                      controller.selectedAnswerIds.remove(
                                        opt.optionId,
                                      );
                                    }
                                  },
                                  title: Text(
                                    opt.choiceText ?? '',
                                    style: AppStyle
                                        .bodySmallPoppinsBlack.responsive,
                                  ),
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
                                  activeColor: AppColors.primary,
                                  dense: true,
                                ),
                              );
                            }),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // BUTTON BAR
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
                  if (controller.currentIndex.value > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: controller.goPrevious,
                        style: AppButtonStyles.outlinedLargeBlack(),
                        child: const Text('Previous'),
                      ),
                    ),
                  if (controller.currentIndex.value > 0)
                    const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: controller.isSubmitting.value
                          ? null
                          : controller.nextPage,
                      style: AppButtonStyles.elevatedLargeBlack(),
                      child: Obx(
                        () => Text(
                          controller.isLastQuestion
                              ? (controller.isSubmitting.value
                                  ? 'Submitting...'
                                  : 'Submit')
                              : 'Next',
                          style: AppStyle.buttonTextPoppinsWhite.responsive,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildTextField(
      Question question, SurveyQuestionController controller) {
    if (!controller.textControllers.containsKey(question.questionId)) {
      controller.textControllers[question.questionId] = TextEditingController();
    }

    final textFieldType = question.options.isNotEmpty
        ? question.options.first.textFieldType
        : "0";
    final isRemark = textFieldType == "1";

    return TextFormField(
      controller: controller.textControllers[question.questionId],
      maxLines: isRemark ? 5 : 1,
      inputFormatters: [SecureTextInputFormatter.deny()],
      decoration: InputDecoration(
        hintText: isRemark ? 'Enter your remarks...' : 'Enter your answer...',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'This field is required';
        }
        return null;
      },
    );
  }

  Widget _buildBooleanOptions(
      Question question, SurveyQuestionController controller) {
    return Column(
      children: question.options.map((opt) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () => controller.selectedAnswerId.value = opt.optionId,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
              child: Row(
                children: [
                  Radio<String>(
                    value: opt.optionId,
                    groupValue: controller.selectedAnswerId.value,
                    onChanged: (v) => controller.selectedAnswerId.value = v!,
                    activeColor: AppColors.primary,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: const VisualDensity(
                      horizontal: -4,
                      vertical: -4,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      opt.choiceText ?? '',
                      style: AppStyle.bodySmallPoppinsBlack.responsive,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
