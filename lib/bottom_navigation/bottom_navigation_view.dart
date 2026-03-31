import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:rudra/app/utils/app_colors.dart';
import 'package:rudra/app/utils/app_images.dart';
import 'package:rudra/app/utils/app_utility.dart';
import 'package:rudra/app/utils/responsive_utils.dart';
import 'package:rudra/bottom_navigation/bottom_navigation_controller.dart';

class CustomBottomBar extends StatelessWidget {
  const CustomBottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    ResponsiveHelper.init(context);
    final controller = Get.find<BottomNavigationController>();
    return Container(
      height: ResponsiveHelper.spacing(70),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: AppUtility.userRole == 0
          ? _indivisualUser(controller)
          : AppUtility.userRole == 3
              ? _superAdmin(controller)
              : _officer(controller),
    );
  }

  Widget _indivisualUser(BottomNavigationController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildNavItem(
          index: 0,
          assetPath: AppImages.homeIcon,
          label: 'Home',
          controller: controller,
        ),
        _buildNavItem(
          index: 1,
          assetPath: AppImages.reportIcon,
          label: 'Report',
          controller: controller,
        ),
        _buildNavItem(
          index: 2,
          assetPath: AppImages.myTeambIcon,
          label: 'My Team',
          controller: controller,
        ),
        _buildNavItem(
          index: 3,
          assetPath: AppImages.myTeambIcon,
          label: 'My Survey',
          controller: controller,
        ),
        _buildNavItem(
          index: 4,
          assetPath: AppImages.profileIcon,
          label: 'Profile',
          controller: controller,
        ),
      ],
    );
  }

  Widget _officer(BottomNavigationController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildNavItem(
          index: 0,
          assetPath: AppImages.homeIcon,
          label: 'Home',
          controller: controller,
        ),
        _buildNavItem(
          index: 1,
          assetPath: AppImages.myTeambIcon,
          label: 'My Survey',
          controller: controller,
        ),
        _buildNavItem(
          index: 2,
          assetPath: AppImages.profileIcon,
          label: 'Profile',
          controller: controller,
        ),
      ],
    );
  }

  Widget _superAdmin(BottomNavigationController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildNavItem(
          index: 0,
          assetPath: AppImages.homeIcon,
          label: 'Home',
          controller: controller,
        ),
        _buildNavItem(
          index: 1,
          assetPath: AppImages.myTeambIcon,
          label: 'All Surveys',
          controller: controller,
        ),
        _buildNavItem(
          index: 2,
          assetPath: AppImages.reportIcon,
          label: 'Report',
          controller: controller,
        ),
        _buildNavItem(
          index: 3,
          assetPath: AppImages.profileIcon,
          label: 'Profile',
          controller: controller,
        ),
      ],
    );
  }

  Widget _buildNavItem({
    required int index,
    required String assetPath,
    required String label,
    required BottomNavigationController controller,
  }) {
    return Obx(() {
      final isSelected = controller.selectedIndex.value == index;
      final iconColor = isSelected ? AppColors.defaultBlack : Colors.grey;
      final textColor = isSelected ? AppColors.defaultBlack : Colors.grey;
      final fontWeight = isSelected ? FontWeight.w600 : FontWeight.normal;

      return InkWell(
        onTap: () => controller.changeTab(index),
        splashColor: AppColors.primary.withOpacity(0.1),
        highlightColor: AppColors.primary.withOpacity(0.05),
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: ResponsiveHelper.spacing(8),
            horizontal: ResponsiveHelper.spacing(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                assetPath,
                width: ResponsiveHelper.spacing(22),
                height: ResponsiveHelper.spacing(22),
                color: iconColor,
                colorBlendMode: BlendMode.srcIn,
              ),
              SizedBox(height: ResponsiveHelper.spacing(4)),
              Text(
                label,
                style: TextStyle(
                  color: textColor,
                  fontSize: ResponsiveHelper.getResponsiveFontSize(11),
                  fontWeight: fontWeight,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      );
    });
  }
}
