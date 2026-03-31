import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../utils/app_colors.dart';
import '../utils/app_logger.dart';
import '../utils/responsive_utils.dart';
import 'app_style.dart';

class ImagePickerBottomSheet extends StatefulWidget {
  final VoidCallback onCamera;
  final VoidCallback onGallery;

  const ImagePickerBottomSheet({
    super.key,
    required this.onCamera,
    required this.onGallery,
  });

  @override
  State<ImagePickerBottomSheet> createState() => _ImagePickerBottomSheetState();
}

class _ImagePickerBottomSheetState extends State<ImagePickerBottomSheet> {
  @override
  Widget build(BuildContext context) {
    AppLogger.d('ImagePickerBottomSheet build', tag: 'ImagePickerBottomSheet');
    return Container(
      padding: ResponsiveHelper.paddingSymmetric(horizontal: 16, vertical: 20),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: ResponsiveHelper.spacing(40),
            height: ResponsiveHelper.spacing(4),
            decoration: BoxDecoration(
              color: AppColors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: ResponsiveHelper.spacing(20)),
          Text(
            'Select Image Source',
            style: AppStyle.heading1PoppinsBlack.responsive,
          ),
          SizedBox(height: ResponsiveHelper.spacing(20)),
          _buildOption(
            icon: Icons.camera_alt,
            title: 'Camera',
            onTap: () {
              AppLogger.d('Camera tapped', tag: 'ImagePickerBottomSheet');
              Get.back();
              widget.onCamera();
            },
          ),
          SizedBox(height: ResponsiveHelper.spacing(12)),
          _buildOption(
            icon: Icons.photo_library,
            title: 'Gallery',
            onTap: () {
              AppLogger.d('Gallery tapped', tag: 'ImagePickerBottomSheet');
              Get.back();
              widget.onGallery();
            },
          ),
          SizedBox(height: ResponsiveHelper.spacing(20)),
        ],
      ),
    );
  }

  Widget _buildOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(ResponsiveHelper.spacing(12)),
      child: Container(
        padding: ResponsiveHelper.paddingSymmetric(
          horizontal: 16,
          vertical: 16,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.grey.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(ResponsiveHelper.spacing(12)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(ResponsiveHelper.spacing(12)),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius:
                    BorderRadius.circular(ResponsiveHelper.spacing(10)),
              ),
              child: Icon(
                icon,
                color: AppColors.primary,
                size: ResponsiveHelper.spacing(24),
              ),
            ),
            SizedBox(width: ResponsiveHelper.spacing(16)),
            Text(
              title,
              style: AppStyle.bodyRegularPoppinsBlack.responsive,
            ),
          ],
        ),
      ),
    );
  }
}
