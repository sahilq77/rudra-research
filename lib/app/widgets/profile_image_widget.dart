import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../utils/app_colors.dart';
import '../utils/app_logger.dart';
import '../utils/app_utility.dart';
import '../utils/responsive_utils.dart';
import 'profile_image_viewer.dart';

class ProfileImageWidget extends StatelessWidget {
  final double radius;
  final bool showEditIcon;
  final bool enableImageViewer;
  final VoidCallback? onEditTap;

  const ProfileImageWidget({
    super.key,
    required this.radius,
    this.showEditIcon = false,
    this.enableImageViewer = true,
    this.onEditTap,
  });

  @override
  Widget build(BuildContext context) {
    AppLogger.d(
        'ProfileImageWidget build, showEditIcon: $showEditIcon, onEditTap: ${onEditTap != null}',
        tag: 'ProfileImageWidget');

    return Obx(() {
      final imageUrl = AppUtility.userImage.value;
      return Stack(
        clipBehavior: Clip.none,
        children: [
          GestureDetector(
            onTap: () {
              if (onEditTap != null) {
                AppLogger.d('Profile image tapped for edit',
                    tag: 'ProfileImageWidget');
                onEditTap!();
              } else if (enableImageViewer && imageUrl.isNotEmpty) {
                AppLogger.d('Profile image tapped for viewing',
                    tag: 'ProfileImageWidget');
                _openImageViewer(imageUrl);
              }
            },
            child: Container(
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
              child: imageUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      imageBuilder: (context, imageProvider) => CircleAvatar(
                        radius: radius,
                        backgroundImage: imageProvider,
                      ),
                      placeholder: (context, url) => CircleAvatar(
                        radius: radius,
                        backgroundColor: AppColors.lightGrey,
                        child: const CircularProgressIndicator(
                          color: AppColors.primary,
                          strokeWidth: 2,
                        ),
                      ),
                      errorWidget: (context, url, error) => CircleAvatar(
                        radius: radius,
                        backgroundColor: AppColors.lightGrey,
                        child: Icon(
                          Icons.person,
                          size: radius * 1.1,
                          color: AppColors.grey,
                        ),
                      ),
                    )
                  : CircleAvatar(
                      radius: radius,
                      backgroundColor: AppColors.lightGrey,
                      child: Icon(
                        Icons.person,
                        size: radius * 1.1,
                        color: AppColors.grey,
                      ),
                    ),
            ),
          ),
          if (showEditIcon)
            Positioned(
              bottom: 0,
              right: 0,
              child: InkWell(
                onTap: () {
                  AppLogger.d('Edit icon tapped', tag: 'ProfileImageWidget');
                  if (onEditTap != null) {
                    AppLogger.d('Calling onEditTap', tag: 'ProfileImageWidget');
                    onEditTap!();
                  } else {
                    AppLogger.w('onEditTap is null', tag: 'ProfileImageWidget');
                  }
                },
                borderRadius:
                    BorderRadius.circular(ResponsiveHelper.spacing(20)),
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
      );
    });
  }

  void _openImageViewer(String imageUrl) {
    Get.to(
      () => ProfileImageViewer(
        imageUrl: imageUrl,
        userName: AppUtility.fullName ?? 'User',
      ),
      transition: Transition.fadeIn,
      duration: const Duration(milliseconds: 300),
    );
  }
}
