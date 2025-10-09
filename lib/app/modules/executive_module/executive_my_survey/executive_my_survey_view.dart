import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rudra/app/modules/executive_module/executive_my_survey/executive_my_survey_controller.dart';
import 'package:rudra/app/modules/manager_module/my_survey/my_survey_controller.dart';

import 'package:rudra/app/routes/app_routes.dart';
import 'package:shimmer/shimmer.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/responsive_utils.dart';
import '../../../widgets/app_button_style.dart';
import '../../../widgets/app_style.dart';

class ExecutiveMySurveyView extends StatelessWidget {
  const ExecutiveMySurveyView({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize the controller
    final ExecutiveMySurveyController controller = Get.put(
      ExecutiveMySurveyController(),
    );
    ResponsiveHelper.init(context);

    return Scaffold(
      appBar: _buildAppbar(),
      body: RefreshIndicator(
        onRefresh: controller.refreshData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: ResponsiveHelper.paddingSymmetric(
            horizontal: 16,
            vertical: 16,
          ),
          child: Column(
            children: [
              _buildSerachField(controller),
              const SizedBox(height: 16),
              Obx(
                () => controller.isLoading.value
                    ? _buildShimmerEffect()
                    : controller.filteredSurveyList.isEmpty
                    ? const Center(child: Text('No reports found'))
                    : Column(
                        children: controller.filteredSurveyList.asMap().entries.map((
                          entry,
                        ) {
                          final report = entry.value;
                          return GestureDetector(
                            onTap: () {
                              //    Get.toNamed(
                              //   AppRoutes.mySurveyDetailList,
                              //   arguments: {'report': report},
                              // ),
                            },
                            child: Card(
                              margin: const EdgeInsets.only(bottom: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          report.title,
                                          style: AppStyle
                                              .reportCardTitle
                                              .responsive
                                              .copyWith(
                                                fontSize:
                                                    ResponsiveHelper.getResponsiveFontSize(
                                                      16,
                                                    ),
                                              ),
                                        ),
                                        SizedBox(
                                          height: ResponsiveHelper.spacing(5),
                                        ),
                                        Text(
                                          report.subtitle,
                                          style: AppStyle
                                              .reportCardSubTitle
                                              .responsive
                                              .copyWith(
                                                fontSize:
                                                    ResponsiveHelper.getResponsiveFontSize(
                                                      13,
                                                    ),
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: AppColors.grey.withOpacity(0.1),
                                      borderRadius: const BorderRadius.only(
                                        bottomRight: Radius.circular(10),
                                        bottomLeft: Radius.circular(10),
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'Survey ID',
                                                style: AppStyle
                                                    .reportCardRowTitle
                                                    .responsive
                                                    .copyWith(
                                                      fontSize:
                                                          ResponsiveHelper.getResponsiveFontSize(
                                                            13,
                                                          ),
                                                    ),
                                              ),
                                              Text(
                                                report.surveyId,
                                                style: AppStyle
                                                    .reportCardRowCount
                                                    .responsive
                                                    .copyWith(
                                                      fontSize:
                                                          ResponsiveHelper.getResponsiveFontSize(
                                                            13,
                                                          ),
                                                    ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: ResponsiveHelper.spacing(1),
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'Response',
                                                style:
                                                    AppStyle.reportCardRowTitle,
                                              ),
                                              Text(
                                                report.responseCount,
                                                style:
                                                    AppStyle.reportCardRowCount,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  TextFormField _buildSerachField(ExecutiveMySurveyController controller) {
    return TextFormField(
      controller: controller.searchController,
      decoration: InputDecoration(
        hintText: 'Search....',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        suffixIcon: const Icon(Icons.search),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      onChanged: controller.searchSurveys,
    );
  }

  Widget _buildShimmerEffect() {
    return Column(children: List.generate(3, (index) => _buildShimmerCard()));
  }

  Widget _buildShimmerCard() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 20,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    height: 16,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: AppColors.grey.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  bottomRight: Radius.circular(10),
                  bottomLeft: Radius.circular(10),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(width: 100, height: 16, color: Colors.white),
                        Container(width: 50, height: 16, color: Colors.white),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(width: 100, height: 16, color: Colors.white),
                        Container(width: 50, height: 16, color: Colors.white),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppbar() {
    return AppBar(
      iconTheme: const IconThemeData(color: Colors.black),
      backgroundColor: AppColors.white,
      elevation: 0,
      centerTitle: false,
      title: Text(
        'My Survey',
        style: AppStyle.heading1PoppinsBlack.responsive.copyWith(
          fontSize: ResponsiveHelper.getResponsiveFontSize(18),
          fontWeight: FontWeight.w600,
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(0),
        child: Divider(color: AppColors.grey.withOpacity(0.5), height: 0),
      ),
    );
  }

  Widget _buildReadOnlyField({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
