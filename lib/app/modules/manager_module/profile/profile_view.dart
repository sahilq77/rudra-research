// lib/app/modules/profile/profile_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:rudra/app/utils/app_images.dart';
import 'package:rudra/bottom_navigation/bottom_navigation_view.dart';

import '../../../../bottom_navigation/bottom_navigation_controller.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/responsive_utils.dart';
import '../../../widgets/app_style.dart';
import '../../../widgets/profile_image_widget.dart';
import 'profile_controller.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final ProfileController controller = Get.find();
  final BottomNavigationController bottomController = Get.put(
    BottomNavigationController(),
  );

  @override
  Widget build(BuildContext context) {
    ResponsiveHelper.init(context);
    return Stack(
      children: [
        WillPopScope(
          onWillPop: () => bottomController.onWillPop(),
          child: Scaffold(
            backgroundColor: AppColors.white,
            appBar: _buildAppbar(),
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
                        _buildMenuList(),
                        SizedBox(height: ResponsiveHelper.spacing(24)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            bottomNavigationBar: const CustomBottomBar(),
          ),
        ),
      ],
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

  Widget _buildProfileHeader() {
    return Column(
      children: [
        // Dark background container with proper positioning
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
              // Profile picture overlapping the dark background
              Positioned(
                bottom: 0, // Changed from negative to 0
                child: ProfileImageWidget(
                  radius: ResponsiveHelper.spacing(50),
                  showEditIcon: false,
                  enableImageViewer: true,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: ResponsiveHelper.spacing(10)), // Reduced spacing
        Text(
          'Hi , ${controller.userName}',
          style: AppStyle.heading1PoppinsBlack.responsive.copyWith(
            fontSize: ResponsiveHelper.getResponsiveFontSize(18),
            fontWeight: FontWeight.w600,
          ),
        ),
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

  Widget _buildMenuList() {
    return Container(
      margin: ResponsiveHelper.paddingSymmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.lightGrey.withOpacity(0.15),
        borderRadius: BorderRadius.circular(ResponsiveHelper.spacing(16)),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: ResponsiveHelper.paddingSymmetric(vertical: 4),
        itemCount: controller.menuItems.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          thickness: 1,
          color: AppColors.grey.withOpacity(0.15),
          indent: ResponsiveHelper.spacing(56),
          endIndent: ResponsiveHelper.spacing(16),
        ),
        itemBuilder: (context, index) {
          final item = controller.menuItems[index];
          return _buildMenuItem(item);
        },
      ),
    );
  }

  Widget _buildMenuItem(item) {
    final String iconData;
    switch (item.icon) {
      case 'person':
        iconData = AppImages.userIcon;
        break;
      case 'notifications':
        iconData = AppImages.bellIcon;
        break;
      case 'My Team':
        iconData = AppImages.myTeamIcon;
        break;
      case 'My Survey':
        iconData = AppImages.mySurveyIcon;
        break;
      case 'logout':
        iconData = AppImages.logoutIcon;
        break;
      default:
        iconData = AppImages.logoutIcon;
    }

    return InkWell(
      onTap: () => controller.onMenuItemTap(item),
      borderRadius: BorderRadius.circular(ResponsiveHelper.spacing(16)),
      child: Container(
        padding: ResponsiveHelper.paddingSymmetric(
          horizontal: 16,
          vertical: 18,
        ),
        child: Row(
          children: [
            SvgPicture.asset(iconData),
            // Icon(
            //   iconData,
            //   color: item.isLogout ? AppColors.primary : AppColors.defaultBlack,
            //   size: ResponsiveHelper.spacing(24),
            // ),
            SizedBox(width: ResponsiveHelper.spacing(16)),
            Expanded(
              child: Text(
                item.title,
                style: (item.isLogout
                        ? AppStyle.bodyRegularPoppinsPrimary
                        : AppStyle.bodyRegularPoppinsBlack)
                    .responsive
                    .copyWith(
                      fontSize: ResponsiveHelper.getResponsiveFontSize(15),
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppColors.grey,
              size: ResponsiveHelper.spacing(24),
            ),
          ],
        ),
      ),
    );
  }
}
