import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data/models/permission_model.dart';
import '../utils/app_colors.dart';
import '../utils/responsive_utils.dart';
import 'app_style.dart';

class PermissionsDialog extends StatefulWidget {
  final VoidCallback onAccept;
  final VoidCallback onLater;

  const PermissionsDialog({
    super.key,
    required this.onAccept,
    required this.onLater,
  });

  @override
  State<PermissionsDialog> createState() => _PermissionsDialogState();
}

class _PermissionsDialogState extends State<PermissionsDialog> {
  bool isRequesting = false;

  @override
  Widget build(BuildContext context) {
    ResponsiveHelper.init(context);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        padding: ResponsiveHelper.padding(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.security,
              size: ResponsiveHelper.spacing(48),
              color: AppColors.primary,
            ),
            SizedBox(height: ResponsiveHelper.spacing(16)),
            ResponsiveHelper.safeText(
              'App Permissions Required',
              style: AppStyle.heading2PoppinsBlack.responsive,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: ResponsiveHelper.spacing(12)),
            ResponsiveHelper.safeText(
              'This app requires the following permissions to function properly:',
              style: AppStyle.bodyRegularPoppinsGrey.responsive,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: ResponsiveHelper.spacing(16)),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    ...PermissionModel.getRequiredPermissions().map(
                      (permission) => _buildPermissionItem(
                        permission.icon,
                        permission.title,
                        permission.description,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: ResponsiveHelper.spacing(16)),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Get.back();
                      widget.onLater();
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.grey,
                      side: const BorderSide(color: AppColors.grey, width: 1),
                      minimumSize:
                          Size(double.infinity, ResponsiveHelper.spacing(44)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: ResponsiveHelper.safeText(
                      'Later',
                      style: AppStyle.buttonTextSmallPoppinsGrey.responsive,
                    ),
                  ),
                ),
                SizedBox(width: ResponsiveHelper.spacing(12)),
                Expanded(
                  child: ElevatedButton(
                    onPressed: isRequesting
                        ? null
                        : () {
                            setState(() {
                              isRequesting = true;
                            });
                            Get.back();
                            widget.onAccept();
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      elevation: 0,
                      minimumSize:
                          Size(double.infinity, ResponsiveHelper.spacing(44)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: isRequesting
                        ? SizedBox(
                            height: ResponsiveHelper.spacing(16),
                            width: ResponsiveHelper.spacing(16),
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.white),
                            ),
                          )
                        : ResponsiveHelper.safeText(
                            'Allow',
                            style:
                                AppStyle.buttonTextSmallPoppinsWhite.responsive,
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionItem(IconData icon, String title, String description) {
    return Container(
      margin: EdgeInsets.only(bottom: ResponsiveHelper.spacing(8)),
      padding: ResponsiveHelper.padding(8),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: ResponsiveHelper.spacing(16),
            color: AppColors.primary,
          ),
          SizedBox(width: ResponsiveHelper.spacing(8)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppStyle.labelPrimaryPoppinsBlack.responsive,
                ),
                SizedBox(height: ResponsiveHelper.spacing(2)),
                Text(
                  description,
                  style: AppStyle.bodySmallPoppinsGrey.responsive,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
