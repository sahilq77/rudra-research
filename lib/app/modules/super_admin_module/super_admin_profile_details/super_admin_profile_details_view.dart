import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/app_images.dart';
import '../../../utils/responsive_utils.dart';
import '../../../widgets/app_style.dart';
import '../../../widgets/profile_image_widget.dart';
import 'super_admin_profile_details_controller.dart';

class SuperAdminProfileDetailsView extends StatefulWidget {
  const SuperAdminProfileDetailsView({super.key});

  @override
  State<SuperAdminProfileDetailsView> createState() =>
      _SuperAdminProfileDetailsViewState();
}

class _SuperAdminProfileDetailsViewState
    extends State<SuperAdminProfileDetailsView> {
  final SuperAdminProfileDetailsController controller = Get.find();

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
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (controller.errorMessage.isNotEmpty) {
                  return Center(
                    child: Text(
                      controller.errorMessage.value,
                      style: AppStyle.bodySmallPoppinsGrey.responsive.copyWith(
                        fontSize: ResponsiveHelper.getResponsiveFontSize(14),
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),
            ),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  SizedBox(height: ResponsiveHelper.spacing(24)),
                  _buildProfileHeader(),
                  SizedBox(height: ResponsiveHelper.spacing(24)),
                  _buildProfileInfoCard(),
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
    return Obx(() => Column(
          children: [
            SizedBox(
              height:
                  ResponsiveHelper.spacing(140) + ResponsiveHelper.spacing(50),
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
                    bottom: 0,
                    child: ProfileImageWidget(
                      radius: ResponsiveHelper.spacing(50),
                      showEditIcon: true,
                      onEditTap: controller.onEditProfile,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: ResponsiveHelper.spacing(10)),
            Text(
              'Hi, ${controller.userName}',
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
        ));
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
              _formatDateTime(profile.joiningDate),
            ),
            _buildDivider(),
            _buildInfoItem('DOB', _formatDateTime(profile.dob)),
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

  String _formatDateTime(String dateTimeString) {
    try {
      DateTime dateTime = DateTime.parse(dateTimeString);
      final DateFormat formatter = DateFormat('MMM d, yyyy');
      return formatter.format(dateTime);
    } catch (e) {
      return 'N/A';
    }
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
}
