import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../utils/app_colors.dart';
import '../../utils/responsive_utils.dart';
import '../../widgets/app_style.dart';
import 'profile_details_controller.dart';

class ProfileDetailsView extends StatefulWidget {
  const ProfileDetailsView({super.key});

  @override
  State<ProfileDetailsView> createState() => _ProfileDetailsViewState();
}

class _ProfileDetailsViewState extends State<ProfileDetailsView> {
  final ProfileDetailsController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    ResponsiveHelper.init(context);
    return Scaffold(
      backgroundColor: AppColors.white,
      body: RefreshIndicator(
        onRefresh: controller.onRefresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            _buildAppBar(),
            SliverToBoxAdapter(
              child: Column(
                children: [
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

  Widget _buildAppBar() {
    return SliverAppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      pinned: false,
      floating: false,
      expandedHeight: 0,
      toolbarHeight: ResponsiveHelper.spacing(56),
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: AppColors.defaultBlack,
          size: ResponsiveHelper.spacing(24),
        ),
        onPressed: () => Get.back(),
      ),
      title: Text(
        'Profile',
        style: AppStyle.heading1PoppinsBlack.responsive.copyWith(
          fontSize: ResponsiveHelper.getResponsiveFontSize(18),
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: false,
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              width: double.infinity,
              height: ResponsiveHelper.spacing(140),
              margin: ResponsiveHelper.paddingSymmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.faded,
                borderRadius: BorderRadius.circular(
                  ResponsiveHelper.spacing(16),
                ),
              ),
            ),
            Positioned(
              bottom: -ResponsiveHelper.spacing(50),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.white,
                        width: 4,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: ResponsiveHelper.spacing(50),
                          backgroundColor: AppColors.lightGrey,
                          child: Icon(
                            Icons.person,
                            size: ResponsiveHelper.spacing(55),
                            color: AppColors.grey,
                          ),
                        ),
                        Positioned(
                          bottom: ResponsiveHelper.spacing(4),
                          right: ResponsiveHelper.spacing(4),
                          child: InkWell(
                            onTap: controller.onEditProfile,
                            child: Container(
                              width: ResponsiveHelper.spacing(32),
                              height: ResponsiveHelper.spacing(32),
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.edit,
                                size: ResponsiveHelper.spacing(16),
                                color: AppColors.defaultBlack,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: ResponsiveHelper.spacing(60)),
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
            _buildInfoItem('Joining Date', profile.joiningDate),
            _buildDivider(),
            _buildInfoItem('DOB', profile.dob),
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
      padding: ResponsiveHelper.paddingSymmetric(
        horizontal: 16,
        vertical: 20,
      ),
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
              Obx(() => Container(
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
                        style:
                            AppStyle.bodySmallPoppinsBlack.responsive.copyWith(
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
                  )),
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
              Obx(() => Text(
                    controller.currentMonth.value,
                    style: AppStyle.bodyRegularPoppinsBlack.responsive.copyWith(
                      fontSize: ResponsiveHelper.getResponsiveFontSize(14),
                      fontWeight: FontWeight.w500,
                    ),
                  )),
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
          Obx(() => _buildPerformanceChart()),
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
          minY: 75,
          maxY: 95,
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

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: ResponsiveHelper.spacing(12),
          height: ResponsiveHelper.spacing(12),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
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
