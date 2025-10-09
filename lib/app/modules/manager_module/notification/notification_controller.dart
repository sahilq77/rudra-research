import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/notification/notification_model.dart';
import '../../../utils/app_logger.dart';
import 'notification_detail_bottom_sheet.dart';

class NotificationController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  final RxInt unreadCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _loadNotifications();
  }

  Future<void> onRefresh() async {
    await Future.delayed(const Duration(seconds: 1));
    _loadNotifications();
    AppLogger.d('Notification page refreshed', tag: 'NotificationController');
  }

  void _loadNotifications() {
    try {
      isLoading.value = true;

      // Mock data - Replace with actual API call
      notifications.value = [
        NotificationModel(
          id: '1',
          title: 'Abhay Sinare Submitted A Test OBC Question 13-09 Nanded',
          message:
              'Lorem ipsum is simply dummy text of the printing and typesetting industry.',
          timeAgo: '3 min ago',
          dateTime: DateTime.now().subtract(const Duration(minutes: 3)),
          isRead: false,
          details: NotificationDetails(
            surveyName: 'OBC Question 13-09 Nanded',
            executiveName: 'Abhay Sinare',
            dateTime: 'Sep 16, 2025 - 11:25 AM',
            target: '1 / 375',
          ),
        ),
        NotificationModel(
          id: '2',
          title: 'New Survey Assigned',
          message:
              'Lorem ipsum is simply dummy text of the printing and typesetting industry.',
          timeAgo: '3 min ago',
          dateTime: DateTime.now().subtract(const Duration(minutes: 3)),
          isRead: false,
        ),
        NotificationModel(
          id: '3',
          title: 'Survey Completed',
          message:
              'Lorem ipsum is simply dummy text of the printing and typesetting industry.',
          timeAgo: '3 min ago',
          dateTime: DateTime.now().subtract(const Duration(minutes: 3)),
          isRead: true,
        ),
        NotificationModel(
          id: '4',
          title: 'Target Achieved',
          message:
              'Lorem ipsum is simply dummy text of the printing and typesetting industry.',
          timeAgo: '3 min ago',
          dateTime: DateTime.now().subtract(const Duration(minutes: 3)),
          isRead: false,
        ),
        NotificationModel(
          id: '5',
          title: 'Monthly Report Available',
          message:
              'Lorem ipsum is simply dummy text of the printing and typesetting industry.',
          timeAgo: '3 min ago',
          dateTime: DateTime.now().subtract(const Duration(minutes: 3)),
          isRead: true,
        ),
        NotificationModel(
          id: '6',
          title: 'New Message from Admin',
          message:
              'Lorem ipsum is simply dummy text of the printing and typesetting industry.',
          timeAgo: '3 min ago',
          dateTime: DateTime.now().subtract(const Duration(minutes: 3)),
          isRead: false,
        ),
        NotificationModel(
          id: '7',
          title: 'System Maintenance Notice',
          message:
              'Lorem ipsum is simply dummy text of the printing and typesetting industry.',
          timeAgo: '3 min ago',
          dateTime: DateTime.now().subtract(const Duration(minutes: 3)),
          isRead: true,
        ),
        NotificationModel(
          id: '8',
          title: 'Weekly Performance Update',
          message:
              'Lorem ipsum is simply dummy text of the printing and typesetting industry.',
          timeAgo: '3 min ago',
          dateTime: DateTime.now().subtract(const Duration(minutes: 3)),
          isRead: false,
        ),
        NotificationModel(
          id: '9',
          title: 'New Team Member Added',
          message:
              'Lorem ipsum is simply dummy text of the printing and typesetting industry.',
          timeAgo: '3 min ago',
          dateTime: DateTime.now().subtract(const Duration(minutes: 3)),
          isRead: true,
        ),
        NotificationModel(
          id: '10',
          title: 'Survey Deadline Reminder',
          message:
              'Lorem ipsum is simply dummy text of the printing and typesetting industry.',
          timeAgo: '3 min ago',
          dateTime: DateTime.now().subtract(const Duration(minutes: 3)),
          isRead: false,
        ),
      ];

      _updateUnreadCount();
      AppLogger.d('Notifications loaded successfully',
          tag: 'NotificationController');
    } catch (e, stackTrace) {
      AppLogger.e(
        'Failed to load notifications',
        error: e,
        stackTrace: stackTrace,
        tag: 'NotificationController',
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _updateUnreadCount() {
    unreadCount.value = notifications.where((n) => !n.isRead).length;
  }

  void onNotificationTap(NotificationModel notification) {
    AppLogger.d('Notification tapped: ${notification.id}',
        tag: 'NotificationController');

    // Mark as read if not already read
    if (!notification.isRead) {
      markAsRead(notification.id);
    }

    // Show bottom sheet with details
    if (notification.details != null) {
      showNotificationDetails(notification);
    } else {
      Get.snackbar(
        'Notification',
        notification.message,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );
    }
  }

  void showNotificationDetails(NotificationModel notification) {
    Get.bottomSheet(
      NotificationDetailBottomSheet(notification: notification),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
    );
  }

  void markAsRead(String notificationId) {
    final index = notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      notifications[index] = notifications[index].copyWith(isRead: true);
      _updateUnreadCount();
      AppLogger.d('Notification marked as read: $notificationId',
          tag: 'NotificationController');
    }
  }

  void markAllAsRead() {
    for (int i = 0; i < notifications.length; i++) {
      if (!notifications[i].isRead) {
        notifications[i] = notifications[i].copyWith(isRead: true);
      }
    }
    _updateUnreadCount();
    AppLogger.d('All notifications marked as read',
        tag: 'NotificationController');
  }

  void deleteNotification(String notificationId) {
    notifications.removeWhere((n) => n.id == notificationId);
    _updateUnreadCount();
    AppLogger.d('Notification deleted: $notificationId',
        tag: 'NotificationController');
  }
}
