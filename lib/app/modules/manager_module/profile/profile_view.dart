// lib/app/modules/profile/profile_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:rudra/app/utils/app_images.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/responsive_utils.dart';
import '../../../widgets/app_style.dart';
import 'profile_controller.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final ProfileController controller = Get.find();

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
                  _buildMenuList(),
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
        // Dark background container with proper positioning
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            // Dark background - starts from top
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
            // Profile picture overlapping the dark background
            Positioned(
              bottom: -ResponsiveHelper.spacing(50),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.white, width: 4),
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
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: ResponsiveHelper.spacing(60)),
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
      case 'assignment':
        iconData = AppImages.myTeamIcon;
        break;
      case 'assignment':
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
                style:
                    (item.isLogout
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
