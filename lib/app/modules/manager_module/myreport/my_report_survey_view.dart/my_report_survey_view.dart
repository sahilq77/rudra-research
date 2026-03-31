import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rudra/app/modules/manager_module/myreport/my_report_survey_view.dart/my_report_survey_chart_controller.dart';

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
      appBar: _buildAppbar('Survey Report'),
      body: RefreshIndicator(
        onRefresh: controller.refreshData,
        backgroundColor: AppColors.white,
        child: Obx(
          () => controller.surveyData.isEmpty
              ? _buildNoReportScreen()
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: controller.surveyData.length,
                  itemBuilder: (context, index) {
                    final data = controller.surveyData[index];
                    final total =
                        data.sections.fold(0.0, (sum, s) => sum + s.value);
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                        style: AppStyle
                                            .reportCardTitle.responsive
                                            .copyWith(
                                          fontSize: ResponsiveHelper
                                              .getResponsiveFontSize(16),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        'Total Count',
                                        style: AppStyle
                                            .reportCardRowCount.responsive
                                            .copyWith(
                                          fontSize: ResponsiveHelper
                                              .getResponsiveFontSize(12),
                                        ),
                                      ),
                                      Text(
                                        '$total',
                                        style: AppStyle
                                            .reportCardRowCount.responsive
                                            .copyWith(
                                          fontSize: ResponsiveHelper
                                              .getResponsiveFontSize(12),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const Divider(),
                              SizedBox(
                                height: 200,
                                child: PieChart(
                                  PieChartData(
                                    sections: data.sections
                                        .asMap()
                                        .entries
                                        .map((entry) {
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
                                      touchCallback: (FlTouchEvent event,
                                          pieTouchResponse) {},
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              ...data.sections.map(
                                (section) => Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4.0),
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
                                        style: AppStyle
                                            .reportCardRowCount.responsive
                                            .copyWith(
                                          fontSize: ResponsiveHelper
                                              .getResponsiveFontSize(12),
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

  Widget _buildNoReportScreen() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: SizedBox(
        height: Get.height - 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.bar_chart, size: 80, color: AppColors.grey),
              SizedBox(height: ResponsiveHelper.spacing(16)),
              Text(
                'No Report Data Available',
                style: AppStyle.heading1PoppinsGrey.responsive,
              ),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppbar(String title) {
    return AppBar(
      backgroundColor: AppColors.primary,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.white),
        onPressed: () => Get.back(),
      ),
      title: Text(
        title,
        style: AppStyle.heading1PoppinsWhite.responsive,
      ),
    );
  }
}
