// lib/app/modules/survey_question/survey_question_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rudra/app/data/models/survey_question/get_survey_questions_response.dart';
import '../../../utils/app_colors.dart';
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
        // ------------------- LOADING / ERROR -------------------
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

        // ------------------- CURRENT QUESTION -------------------
        final Question current =
            controller.questionDetail[controller.currentIndex.value];

        // ------------------- PROGRESS (optional) -------------------
        final int total = controller.questionDetail.length;
        final int progress = controller.currentIndex.value + 1;

        return Column(
          children: [
            // ---- progress bar (nice touch) ----
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
                          // ---- USER INFO ----
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: AppColors.grey.withOpacity(
                                  0.2,
                                ),
                                child: const Icon(
                                  Icons.person,
                                  color: AppColors.grey,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Survey Poster',
                                    style: AppStyle
                                        .bodyBoldPoppinsBlack
                                        .responsive,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    DateTime.now().toString().substring(0, 10),
                                    style: AppStyle
                                        .labelSecondaryPoppinsGrey
                                        .responsive,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // ---- QUESTION NUMBER ----
                          Text(
                            '$progress / $total',
                            style: AppStyle.bodySmallPoppinsGrey.responsive,
                          ),
                          const SizedBox(height: 8),

                          // ---- QUESTION TEXT ----

                          //         Html(
                          //   data: ins[0].instructionDescription.replaceAll(
                          //     r'\r\n',
                          //     '<br>',
                          //   ),
                          //   style: TextDesign.commonStyles,
                          // ),
                          Text(
                            controller.removeHtmlTags(current.question),
                            style: AppStyle.bodyRegularPoppinsBlack.responsive,
                          ),
                          const SizedBox(height: 16),

                          // ---- RADIO OPTIONS ----
                          ...current.options.map((opt) {
                            final String optionText = opt.choiceText;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: InkWell(
                                onTap: () => controller.selectedAnswer.value =
                                    optionText,
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4,
                                    horizontal: 0,
                                  ),
                                  child: Row(
                                    children: [
                                      Radio<String>(
                                        value: optionText,
                                        groupValue:
                                            controller.selectedAnswer.value,
                                        onChanged: (v) =>
                                            controller.selectedAnswer.value =
                                                v!,
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
                                          optionText,
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
                          }).toList(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ------------------- BUTTON BAR -------------------
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
                  // ---- PREVIOUS ----
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

                  // ---- NEXT / SUBMIT ----
                  Expanded(
                    child: ElevatedButton(
                      onPressed: controller.nextPage,
                      style: AppButtonStyles.elevatedLargeBlack(),
                      child: Text(
                        controller.currentIndex.value ==
                                controller.questionDetail.length - 1
                            ? 'Submit'
                            : 'Next',
                        style: AppStyle.buttonTextPoppinsWhite.responsive,
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
}
