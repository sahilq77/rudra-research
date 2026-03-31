import 'package:dropdown_search/dropdown_search.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:rudra/app/data/models/profile_details/get_my_survey_response.dart';
import 'package:rudra/app/modules/executive_module/executive_profile_details/executive_profile_detail_controller.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/app_images.dart';
import '../../../utils/responsive_utils.dart';
import '../../../widgets/app_style.dart';
import '../../../widgets/profile_image_widget.dart';

class ExecutiveProfileDetailView extends StatefulWidget {
  const ExecutiveProfileDetailView({super.key});

  @override
  State<ExecutiveProfileDetailView> createState() =>
      _ExecutiveProfileDetailViewState();
}

class _ExecutiveProfileDetailViewState
    extends State<ExecutiveProfileDetailView> {
  final ExecutiveProfileDetailController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    ResponsiveHelper.init(context);
    return Scaffold(
      appBar: _buildAppbar(),
      backgroundColor: AppColors.white,
      body: RefreshIndicator(
        onRefresh: controller.onRefresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  SizedBox(height: ResponsiveHelper.spacing(24)),
                  _buildProfileHeader(),
                  SizedBox(height: ResponsiveHelper.spacing(24)),
                  _buildProfileInfoCard(),
                  SizedBox(height: ResponsiveHelper.spacing(24)),
                  _buildPerformanceCard(),
                  SizedBox(height: ResponsiveHelper.spacing(24)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        SizedBox(
          height: ResponsiveHelper.spacing(140) +
              ResponsiveHelper.spacing(50), // Add extra height for overflow
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: [
              Positioned(
                top: 0,
                left: ResponsiveHelper.spacing(16),
                right: ResponsiveHelper.spacing(16),
                child: Container(
                  width: double.infinity,
                  height: ResponsiveHelper.spacing(140),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      ResponsiveHelper.spacing(16),
                    ),
                    image: const DecorationImage(
                      image: AssetImage(AppImages.profileBg),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0, // Changed from negative to 0
                child: ProfileImageWidget(
                  radius: ResponsiveHelper.spacing(50),
                  showEditIcon: true,
                  onEditTap: controller.onEditProfile,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
            height: ResponsiveHelper.spacing(
                10)), // Reduced spacing since we added height above
        Obx(() {
          final profile = controller.profileDetails.value;
          return Text(
            'Hi , ${profile?.name ?? controller.userName}',
            style: AppStyle.heading1PoppinsBlack.responsive.copyWith(
              fontSize: ResponsiveHelper.getResponsiveFontSize(18),
              fontWeight: FontWeight.w600,
            ),
          );
        }),
        SizedBox(height: ResponsiveHelper.spacing(4)),
        Text(
          controller.greeting,
          style: AppStyle.bodySmallPoppinsGrey.responsive.copyWith(
            fontSize: ResponsiveHelper.getResponsiveFontSize(13),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileInfoCard() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const SizedBox.shrink();
      }
      final profile = controller.profileDetails.value;
      if (profile == null) {
        return const SizedBox.shrink();
      }

      return Container(
        margin: ResponsiveHelper.paddingSymmetric(horizontal: 16),
        padding: ResponsiveHelper.paddingSymmetric(
          horizontal: 16,
          vertical: 16,
        ),
        decoration: BoxDecoration(
          color: AppColors.lightGrey.withOpacity(0.15),
          borderRadius: BorderRadius.circular(ResponsiveHelper.spacing(16)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoItem('Name', profile.name),
            _buildDivider(),
            _buildInfoItem('Phone Number', profile.phoneNumber),
            _buildDivider(),
            _buildInfoItem('Email ID', profile.emailId),
            _buildDivider(),
            _buildInfoItem('Address', profile.address),
            _buildDivider(),
            _buildInfoItem('Designation', profile.designation),
            _buildDivider(),
            _buildInfoItem(
              'Joining Date',
              controller.formatDateTime(profile.joiningDate),
            ),
            _buildDivider(),
            _buildInfoItem('DOB', controller.formatDateTime(profile.dob)),
          ],
        ),
      );
    });
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: ResponsiveHelper.paddingSymmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppStyle.bodySmallPoppinsGrey.responsive.copyWith(
              fontSize: ResponsiveHelper.getResponsiveFontSize(12),
            ),
          ),
          SizedBox(height: ResponsiveHelper.spacing(4)),
          Text(
            value,
            style: AppStyle.bodyRegularPoppinsBlack.responsive.copyWith(
              fontSize: ResponsiveHelper.getResponsiveFontSize(14),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: AppColors.grey.withOpacity(0.15),
    );
  }

  Widget _buildPerformanceCard() {
    return Container(
      margin: ResponsiveHelper.paddingSymmetric(horizontal: 16),
      padding: ResponsiveHelper.paddingSymmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.lightGrey.withOpacity(0.15),
        borderRadius: BorderRadius.circular(ResponsiveHelper.spacing(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Your Performance',
                style: AppStyle.heading1PoppinsBlack.responsive.copyWith(
                  fontSize: ResponsiveHelper.getResponsiveFontSize(16),
                  fontWeight: FontWeight.w600,
                ),
              ),
              Obx(
                () => Container(
                  padding: ResponsiveHelper.paddingSymmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(
                      ResponsiveHelper.spacing(8),
                    ),
                    border: Border.all(
                      color: AppColors.grey.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: controller.selectedPeriod.value,
                      isDense: true,
                      icon: Icon(
                        Icons.keyboard_arrow_down,
                        size: ResponsiveHelper.spacing(20),
                        color: AppColors.defaultBlack,
                      ),
                      style: AppStyle.bodySmallPoppinsBlack.responsive.copyWith(
                        fontSize: ResponsiveHelper.getResponsiveFontSize(12),
                      ),
                      items: controller.periodOptions.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: controller.onPeriodChanged,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveHelper.spacing(16)),
          Obx(() => DropdownSearch<SurveyData>(
                items: controller.surveyList,
                selectedItem: controller.selectedSurvey.value,
                itemAsString: (SurveyData survey) => survey.surveyTitle,
                onChanged: (SurveyData? value) {
                  if (value != null) {
                    controller.selectedSurvey.value = value;
                    controller.fetchPerformanceData();
                  }
                },
                dropdownDecoratorProps: DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(
                    labelText: 'Select Survey',
                    labelStyle: AppStyle.bodySmallPoppinsGrey.responsive,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                ),
                popupProps: PopupProps.menu(
                  showSearchBox: true,
                  searchFieldProps: TextFieldProps(
                    decoration: InputDecoration(
                      hintText: 'Search survey...',
                      hintStyle: AppStyle.bodySmallPoppinsGrey.responsive,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
              )),
          SizedBox(height: ResponsiveHelper.spacing(16)),
          Row(
            children: [
              Expanded(
                child: Obx(() => InkWell(
                      onTap: () => controller.selectFromDate(context),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'From Date',
                          labelStyle: AppStyle.bodySmallPoppinsGrey.responsive,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                        child: Text(
                          controller.fromDate.value != null
                              ? DateFormat('dd MMM yyyy')
                                  .format(controller.fromDate.value!)
                              : 'Select',
                          style: AppStyle.bodySmallPoppinsBlack.responsive,
                        ),
                      ),
                    )),
              ),
              SizedBox(width: ResponsiveHelper.spacing(12)),
              Expanded(
                child: Obx(() => InkWell(
                      onTap: () => controller.selectToDate(context),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'To Date',
                          labelStyle: AppStyle.bodySmallPoppinsGrey.responsive,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                        child: Text(
                          controller.toDate.value != null
                              ? DateFormat('dd MMM yyyy')
                                  .format(controller.toDate.value!)
                              : 'Select',
                          style: AppStyle.bodySmallPoppinsBlack.responsive,
                        ),
                      ),
                    )),
              ),
            ],
          ),
          SizedBox(height: ResponsiveHelper.spacing(20)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(
                  Icons.chevron_left,
                  color: AppColors.defaultBlack,
                  size: ResponsiveHelper.spacing(24),
                ),
                onPressed: controller.onPreviousMonth,
              ),
              Obx(
                () => Text(
                  controller.currentMonth.value,
                  style: AppStyle.bodyRegularPoppinsBlack.responsive.copyWith(
                    fontSize: ResponsiveHelper.getResponsiveFontSize(14),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.chevron_right,
                  color: AppColors.defaultBlack,
                  size: ResponsiveHelper.spacing(24),
                ),
                onPressed: controller.onNextMonth,
              ),
            ],
          ),
          SizedBox(height: ResponsiveHelper.spacing(16)),
          Obx(() {
            if (controller.isPerformanceLoading.value) {
              return SizedBox(
                height: ResponsiveHelper.spacing(200),
                child: const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              );
            }
            return _buildPerformanceChart();
          }),
          SizedBox(height: ResponsiveHelper.spacing(16)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem('Target', AppColors.accentOrange),
              SizedBox(width: ResponsiveHelper.spacing(24)),
              _buildLegendItem('Target Completed', const Color(0xFF5DADE2)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceChart() {
    if (controller.performanceData.isEmpty) {
      return SizedBox(
        height: ResponsiveHelper.spacing(200),
        child: Center(
          child: Text(
            'No performance data available',
            style: AppStyle.bodySmallPoppinsGrey.responsive,
          ),
        ),
      );
    }
    return SizedBox(
      height: ResponsiveHelper.spacing(200),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 5,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: AppColors.grey.withOpacity(0.2),
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 5,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: AppStyle.bodySmallPoppinsGrey.responsive.copyWith(
                      fontSize: ResponsiveHelper.getResponsiveFontSize(10),
                    ),
                  );
                },
                reservedSize: 30,
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() < 0 ||
                      value.toInt() >= controller.performanceData.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: ResponsiveHelper.paddingSymmetric(vertical: 4),
                    child: Text(
                      controller.performanceData[value.toInt()].day,
                      style: AppStyle.bodySmallPoppinsGrey.responsive.copyWith(
                        fontSize: ResponsiveHelper.getResponsiveFontSize(10),
                      ),
                    ),
                  );
                },
                reservedSize: 30,
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: (controller.performanceData.length - 1).toDouble(),
          minY: 0,
          maxY: () {
            double maxTarget = 0;
            double maxCompleted = 0;
            for (var data in controller.performanceData) {
              if (data.target > maxTarget) maxTarget = data.target;
              if (data.targetCompleted > maxCompleted) {
                maxCompleted = data.targetCompleted;
              }
            }
            double maxValue =
                maxTarget > maxCompleted ? maxTarget : maxCompleted;
            return maxValue + (maxValue * 0.2);
          }(),
          lineBarsData: [
            LineChartBarData(
              spots: controller.performanceData
                  .asMap()
                  .entries
                  .map((e) => FlSpot(e.key.toDouble(), e.value.target))
                  .toList(),
              isCurved: true,
              color: AppColors.accentOrange,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: AppColors.accentOrange,
                    strokeWidth: 2,
                    strokeColor: AppColors.white,
                  );
                },
              ),
              belowBarData: BarAreaData(show: false),
            ),
            LineChartBarData(
              spots: controller.performanceData
                  .asMap()
                  .entries
                  .map((e) => FlSpot(e.key.toDouble(), e.value.targetCompleted))
                  .toList(),
              isCurved: true,
              color: const Color(0xFF5DADE2),
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: const Color(0xFF5DADE2),
                    strokeWidth: 2,
                    strokeColor: AppColors.white,
                  );
                },
              ),
              belowBarData: BarAreaData(show: false),
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
        'Profile',
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

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: ResponsiveHelper.spacing(12),
          height: ResponsiveHelper.spacing(12),
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: ResponsiveHelper.spacing(8)),
        Text(
          label,
          style: AppStyle.bodySmallPoppinsGrey.responsive.copyWith(
            fontSize: ResponsiveHelper.getResponsiveFontSize(12),
          ),
        ),
      ],
    );
  }
}
