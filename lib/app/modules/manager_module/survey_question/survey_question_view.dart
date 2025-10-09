// lib/app/modules/survey_question/survey_question_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
    final questionData = controller.questions[controller.language]!;
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
          preferredSize: Size.fromHeight(0),
          child: Divider(
            color: AppColors.grey.withOpacity(0.5),
            // thickness: 2,
            height: 0,
          ),
        ),
      ),
      backgroundColor: AppColors.white,
      body: Obx(
        () => Column(
          children: [
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
                          // User Info Section
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
                                    questionData['posterName'],
                                    style: AppStyle
                                        .bodyBoldPoppinsBlack
                                        .responsive,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    questionData['date'],
                                    style: AppStyle
                                        .labelSecondaryPoppinsGrey
                                        .responsive,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Question Text
                          Text(
                            questionData['question'],
                            style: AppStyle.bodyRegularPoppinsBlack.responsive,
                          ),
                          const SizedBox(height: 16),

                          // Radio Options
                          ...List.generate(
                            questionData['options'].length,
                            (index) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: InkWell(
                                onTap: () {
                                  controller.selectedAnswer.value =
                                      questionData['options'][index];
                                },
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4,
                                    horizontal: 0,
                                  ),
                                  child: Row(
                                    children: [
                                      Radio<String>(
                                        value: questionData['options'][index],
                                        groupValue:
                                            controller.selectedAnswer.value,
                                        onChanged: (value) {
                                          controller.selectedAnswer.value =
                                              value!;
                                        },
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
                                          questionData['options'][index],
                                          style: AppStyle
                                              .bodySmallPoppinsBlack
                                              .responsive,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Bottom Button
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
      ),
    );
  }
}
