import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/notification/notification_model.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/responsive_utils.dart';
import '../../../widgets/app_style.dart';

class ValidatorNotificationDetailBottomSheet extends StatelessWidget {
  final NotificationModel notification;

  const ValidatorNotificationDetailBottomSheet({
    super.key,
    required this.notification,
  });

  @override
  Widget build(BuildContext context) {
    ResponsiveHelper.init(context);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(ResponsiveHelper.spacing(24)),
          topRight: Radius.circular(ResponsiveHelper.spacing(24)),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: ResponsiveHelper.spacing(12)),
          Container(
            width: ResponsiveHelper.spacing(40),
            height: ResponsiveHelper.spacing(4),
            decoration: BoxDecoration(
              color: AppColors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(ResponsiveHelper.spacing(2)),
            ),
          ),
          SizedBox(height: ResponsiveHelper.spacing(20)),
          Padding(
            padding: ResponsiveHelper.paddingSymmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        notification.title ?? 'Notification',
                        style:
                            AppStyle.heading1PoppinsBlack.responsive.copyWith(
                          fontSize: ResponsiveHelper.getResponsiveFontSize(16),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: Icon(
                        Icons.close,
                        color: AppColors.defaultBlack,
                        size: ResponsiveHelper.spacing(24),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: ResponsiveHelper.spacing(16)),
                Text(
                  notification.message,
                  style: AppStyle.bodyRegularPoppinsBlack.responsive.copyWith(
                    fontSize: ResponsiveHelper.getResponsiveFontSize(14),
                    height: 1.5,
                  ),
                ),
                if (notification.details != null) ...[
                  SizedBox(height: ResponsiveHelper.spacing(24)),
                  _buildDetailItem(
                    'Survey Name',
                    notification.details!.surveyName,
                  ),
                  SizedBox(height: ResponsiveHelper.spacing(16)),
                  _buildDetailItem(
                    'Executive Name',
                    notification.details!.executiveName,
                  ),
                  SizedBox(height: ResponsiveHelper.spacing(16)),
                  _buildDetailItem(
                    'Date & Time',
                    notification.details!.dateTime,
                  ),
                  SizedBox(height: ResponsiveHelper.spacing(16)),
                  _buildDetailItem(
                    'Target',
                    notification.details!.target,
                  ),
                ],
                SizedBox(height: ResponsiveHelper.spacing(24)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Column(
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
    );
  }
}
