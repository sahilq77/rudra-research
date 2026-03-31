import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/notification/notification_model.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/responsive_utils.dart';
import '../../../widgets/app_style.dart';
import 'notification_controller.dart';

class NotificationView extends StatefulWidget {
  const NotificationView({super.key});

  @override
  State<NotificationView> createState() => _NotificationViewState();
}

class _NotificationViewState extends State<NotificationView> {
  final NotificationController controller = Get.find();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_loadMore);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadMore() {
    if (controller.hasMoreData.value &&
        !controller.isLoading.value &&
        !controller.isLoadingMore.value &&
        _scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent * 0.9) {
      controller.loadMoreNotifications(context: context);
    }
  }

  @override
  Widget build(BuildContext context) {
    ResponsiveHelper.init(context);
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: controller.onRefresh,
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (controller.notifications.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.separated(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: ResponsiveHelper.paddingSymmetric(
              horizontal: 16,
              vertical: 16,
            ),
            itemCount: controller.notifications.length +
                (controller.isLoadingMore.value ? 1 : 0),
            separatorBuilder: (context, index) =>
                SizedBox(height: ResponsiveHelper.spacing(12)),
            itemBuilder: (context, index) {
              if (index == controller.notifications.length) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                  ),
                );
              }
              final notification = controller.notifications[index];
              return _buildNotificationItem(notification);
            },
          );
        }),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: AppColors.defaultBlack,
          size: ResponsiveHelper.spacing(24),
        ),
        onPressed: () => Get.back(),
      ),
      title: Text(
        'Notification',
        style: AppStyle.heading1PoppinsBlack.responsive.copyWith(
          fontSize: ResponsiveHelper.getResponsiveFontSize(18),
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: false,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(0),
        child: Divider(
          color: AppColors.grey.withOpacity(0.5),
          // thickness: 2,
          height: 0,
        ),
      ),
    );
  }

  Widget _buildNotificationItem(NotificationModel notification) {
    return InkWell(
      onTap: () => controller.onNotificationTap(notification),
      borderRadius: BorderRadius.circular(ResponsiveHelper.spacing(12)),
      child: Container(
        padding: ResponsiveHelper.paddingSymmetric(
          horizontal: 16,
          vertical: 16,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(ResponsiveHelper.spacing(12)),
          border: Border.all(color: AppColors.grey.withOpacity(0.2), width: 1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bell Icon
            Container(
              width: ResponsiveHelper.spacing(40),
              height: ResponsiveHelper.spacing(40),
              decoration: BoxDecoration(
                color: AppColors.lightGrey.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_outlined,
                color: AppColors.defaultBlack,
                size: ResponsiveHelper.spacing(20),
              ),
            ),
            SizedBox(width: ResponsiveHelper.spacing(12)),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.message,
                    style: AppStyle.bodySmallPoppinsBlack.responsive.copyWith(
                      fontSize: ResponsiveHelper.getResponsiveFontSize(13),
                      fontWeight: FontWeight.w400,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            SizedBox(width: ResponsiveHelper.spacing(8)),
            // Time
            Text(
              notification.timeAgo,
              style: AppStyle.bodySmallPoppinsGrey.responsive.copyWith(
                fontSize: ResponsiveHelper.getResponsiveFontSize(11),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: ResponsiveHelper.spacing(80),
            color: AppColors.grey.withOpacity(0.5),
          ),
          SizedBox(height: ResponsiveHelper.spacing(16)),
          Text(
            'No Notifications',
            style: AppStyle.heading1PoppinsGrey.responsive.copyWith(
              fontSize: ResponsiveHelper.getResponsiveFontSize(18),
            ),
          ),
          SizedBox(height: ResponsiveHelper.spacing(8)),
          Text(
            'You don\'t have any notifications yet',
            style: AppStyle.bodySmallPoppinsGrey.responsive.copyWith(
              fontSize: ResponsiveHelper.getResponsiveFontSize(14),
            ),
          ),
        ],
      ),
    );
  }
}
