import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rudra/app/modules/manager_module/myreport/my_report_survey_view.dart/my_report_survey_chart_controller.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../utils/app_colors.dart';
import '../../../../utils/responsive_utils.dart'
    show ResponsiveHelper, AppStyleResponsive;
import '../../../../widgets/app_style.dart';

class MyReportSurveyView extends StatelessWidget {
  const MyReportSurveyView({super.key});

  @override
  Widget build(BuildContext context) {
    ResponsiveHelper.init(context);
    final MyReportSurveyChartController controller = Get.put(
      MyReportSurveyChartController(),
    );
    return Scaffold(
      appBar: _buildAppbar('Obc Survey Report'),
      body: RefreshIndicator(
        onRefresh: controller.refreshData,
        backgroundColor: AppColors.white,
        child: Obx(
          () => ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: controller.surveyData.length,
            itemBuilder: (context, index) {
              final data = controller.surveyData[index];
              final total = data.sections.fold(0.0, (sum, s) => sum + s.value);
              return Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  color: Colors.black,
                                  margin: const EdgeInsets.only(right: 8),
                                  child: Center(
                                    child: Text(
                                      '${index + 1}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                Text(
                                  data.title,
                                  style: AppStyle.reportCardTitle.responsive
                                      .copyWith(
                                        fontSize:
                                            ResponsiveHelper.getResponsiveFontSize(
                                              16,
                                            ),
                                      ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Total Count',
                                  style: AppStyle.reportCardRowCount.responsive
                                      .copyWith(
                                        fontSize:
                                            ResponsiveHelper.getResponsiveFontSize(
                                              12,
                                            ),
                                      ),
                                ),
                                Text(
                                  '$total',
                                  style: AppStyle.reportCardRowCount.responsive
                                      .copyWith(
                                        fontSize:
                                            ResponsiveHelper.getResponsiveFontSize(
                                              12,
                                            ),
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Divider(),
                        SizedBox(
                          height: 200,
                          child: PieChart(
                            PieChartData(
                              sections: data.sections.asMap().entries.map((
                                entry,
                              ) {
                                final idx = entry.key;
                                final section = entry.value;
                                return PieChartSectionData(
                                  color: section.color,
                                  value: section.value,
                                  radius: 60,
                                  titleStyle: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                );
                              }).toList(),
                              sectionsSpace: 2,
                              centerSpaceRadius: 30,
                              pieTouchData: PieTouchData(
                                touchCallback:
                                    (FlTouchEvent event, pieTouchResponse) {
                                      // Optional: Handle touch interactions
                                    },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...data.sections.map(
                          (section) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  color: section.color,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  section.label,
                                  style: AppStyle.reportCardRowCount.responsive
                                      .copyWith(
                                        fontSize:
                                            ResponsiveHelper.getResponsiveFontSize(
                                              12,
                                            ),
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerEffect(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: 3, // Show 3 shimmer cards as placeholders
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 24.0),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 150,
                              height: 16,
                              color: Colors.white,
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              width: 80,
                              height: 12,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 4),
                            Container(
                              width: 50,
                              height: 12,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Divider(),
                    Container(height: 200, color: Colors.white),
                    const SizedBox(height: 16),
                    ...List.generate(
                      3, // Simulate 3 section labels
                      (index) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 100,
                              height: 12,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  AppBar _buildAppbar(String title) {
    return AppBar(
      iconTheme: const IconThemeData(color: Colors.black),
      backgroundColor: AppColors.white,
      elevation: 0,
      centerTitle: false,
      title: Text(
        title,
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
}
