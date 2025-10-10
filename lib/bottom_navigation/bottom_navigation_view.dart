import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:rudra/app/utils/app_colors.dart';
import 'package:rudra/app/utils/app_images.dart';
import 'package:rudra/app/utils/app_utility.dart';
import 'package:rudra/bottom_navigation/bottom_navigation_controller.dart';

class CustomBottomBar extends StatefulWidget {
  const CustomBottomBar({super.key});

  @override
  State<CustomBottomBar> createState() => _CustomBottomBarState();
}

class _CustomBottomBarState extends State<CustomBottomBar> {
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(BottomNavigationController());
    return Container(
      height: 70.0,
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
      child: Obx(
        () => AppUtility.userRole == 0
            ? _indivisualUser(controller)
            : _officer(controller),
      ),
    );
  }

  Row _indivisualUser(BottomNavigationController controller) {
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

  Row _officer(BottomNavigationController controller) {
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

  Widget _buildNavItem({
    required int index,
    required String assetPath,
    required String label,
    required BottomNavigationController controller,
  }) {
    final isSelected = controller.selectedIndex.value == index;
    final iconColor = isSelected ? AppColors.defaultBlack : Colors.grey;
    final textColor = isSelected ? AppColors.defaultBlack : Colors.grey;
    final fontWeight = isSelected ? FontWeight.w600 : FontWeight.normal;

    return GestureDetector(
      onTap: () => controller.changeTab(index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              assetPath,
              width: 25.0,
              height: 25.0,
              color: iconColor,
              colorBlendMode: BlendMode.srcIn,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.error, size: 20.0, color: Colors.red),
            ),
            // Image.asset(
            //   assetPath,
            //   width: 20.0,
            //   height: 20.0,
            //   color: iconColor,
            //   colorBlendMode: BlendMode.srcIn,
            //   errorBuilder: (context, error, stackTrace) => const Icon(
            //     Icons.error,
            //     size: 20.0,
            //     color: Colors.red,
            //   ),
            // ),
            const SizedBox(height: 4.0),
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontSize: 12.0,
                fontWeight: fontWeight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
