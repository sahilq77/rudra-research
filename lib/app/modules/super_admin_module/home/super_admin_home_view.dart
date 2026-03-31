import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:rudra/bottom_navigation/bottom_navigation_controller.dart';
import 'package:rudra/bottom_navigation/bottom_navigation_view.dart';

import '../../../routes/app_routes.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_images.dart';
import '../../../utils/responsive_utils.dart';
import '../../../widgets/app_style.dart';
import 'super_admin_home_controller.dart';

class SuperAdminHomeView extends StatefulWidget {
  const SuperAdminHomeView({super.key});

  @override
  State<SuperAdminHomeView> createState() => _SuperAdminHomeViewState();
}

class _SuperAdminHomeViewState extends State<SuperAdminHomeView> {
  final SuperAdminHomeController controller = Get.put(
    SuperAdminHomeController(),
  );
  final BottomNavigationController bottomController = Get.put(
    BottomNavigationController(),
  );

  @override
  Widget build(BuildContext context) {
    ResponsiveHelper.init(context);
    return WillPopScope(
      onWillPop: () => bottomController.onWillPop(),
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              await Future.delayed(const Duration(seconds: 1));
              controller.refreshData();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: ResponsiveHelper.paddingSymmetric(
                horizontal: 16,
                vertical: 12,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  SizedBox(height: ResponsiveHelper.spacing(24)),
                  ResponsiveHelper.safeText(
                    'Dashboard Overview',
                    style: AppStyle.heading1PoppinsBlack.responsive.copyWith(
                      fontSize: ResponsiveHelper.getResponsiveFontSize(17),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: ResponsiveHelper.spacing(16)),
                  _buildDashboardGrid(),
                  SizedBox(height: ResponsiveHelper.spacing(24)),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: const CustomBottomBar(),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: ResponsiveHelper.spacing(44),
          height: ResponsiveHelper.spacing(44),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.white,
            border: Border.all(
              color: AppColors.lightGrey.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Center(
            child: Image.asset(
              AppImages.appLogo,
              height: ResponsiveHelper.spacing(24),
              width: ResponsiveHelper.spacing(24),
              fit: BoxFit.contain,
            ),
          ),
        ),
        SizedBox(width: ResponsiveHelper.spacing(12)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              ResponsiveHelper.safeText(
                controller.userName,
                style: AppStyle.bodyBoldPoppinsBlack.responsive.copyWith(
                  fontSize: ResponsiveHelper.getResponsiveFontSize(16),
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
              ),
              ResponsiveHelper.safeText(
                'Super Admin',
                style: AppStyle.bodySmallPoppinsPrimary.responsive.copyWith(
                  fontSize: ResponsiveHelper.getResponsiveFontSize(13),
                  color: AppColors.primary,
                ),
                maxLines: 1,
              ),
            ],
          ),
        ),
        SizedBox(width: ResponsiveHelper.spacing(12)),
        Container(
          width: ResponsiveHelper.spacing(40),
          height: ResponsiveHelper.spacing(40),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.white,
            border: Border.all(
              color: AppColors.lightGrey.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: IconButton(
            padding: EdgeInsets.zero,
            icon: SvgPicture.asset(
              AppImages.autoRefresh,
              width: ResponsiveHelper.spacing(20),
              height: ResponsiveHelper.spacing(20),
              fit: BoxFit.contain,
            ),
            onPressed: () async {
              await Future.delayed(const Duration(seconds: 1));
              controller.refreshData();
            },
          ),
        ),
        SizedBox(width: ResponsiveHelper.spacing(8)),
        Container(
          width: ResponsiveHelper.spacing(40),
          height: ResponsiveHelper.spacing(40),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.white,
            border: Border.all(
              color: AppColors.lightGrey.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: IconButton(
            padding: EdgeInsets.zero,
            icon: SvgPicture.asset(
              AppImages.myNotification,
              width: ResponsiveHelper.spacing(20),
              height: ResponsiveHelper.spacing(20),
              fit: BoxFit.contain,
            ),
            onPressed: () {
              Get.toNamed(AppRoutes.notifications);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDashboardGrid() {
    return Obx(() {
      final stats = controller.dashboardStats;

      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildDashboardCard(stats[0]),
              ),
              SizedBox(width: ResponsiveHelper.spacing(12)),
              Expanded(
                child: _buildDashboardCard(stats[1]),
              ),
            ],
          ),
          SizedBox(height: ResponsiveHelper.spacing(12)),
          _buildDashboardCard(stats[2]),
        ],
      );
    });
  }

  Widget _buildDashboardCard(Map<String, dynamic> stat) {
    return Container(
      padding: ResponsiveHelper.paddingSymmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: stat['color'],
        borderRadius: BorderRadius.circular(ResponsiveHelper.spacing(16)),
        border: Border.all(
          color: stat['borderColor'],
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: ResponsiveHelper.safeText(
                  stat['value'],
                  style: AppStyle.heading1PoppinsBlack.responsive.copyWith(
                    color: stat['textColor'],
                    fontSize: ResponsiveHelper.getResponsiveFontSize(20),
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                ),
              ),
              Container(
                width: ResponsiveHelper.spacing(50),
                height: ResponsiveHelper.spacing(50),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    ResponsiveHelper.spacing(12),
                  ),
                ),
                padding: EdgeInsets.all(ResponsiveHelper.spacing(8)),
                child: Image.asset(stat['imagePath'], fit: BoxFit.contain),
              ),
            ],
          ),
          SizedBox(height: ResponsiveHelper.spacing(8)),
          ResponsiveHelper.safeText(
            stat['title'],
            style: AppStyle.bodySmallPoppinsBlack.responsive.copyWith(
              color: stat['textColor'],
              fontSize: ResponsiveHelper.getResponsiveFontSize(12),
              height: 1.3,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
