import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:rudra/app/data/models/notification/get_notification_response.dart';
import 'package:rudra/app/data/network/exceptions.dart';
import 'package:rudra/app/data/network/networkcall.dart';
import 'package:rudra/app/data/urls.dart';
import 'package:rudra/app/modules/executive_module/executive_notification/executive_notification_detail_bottom_sheet.dart';
import 'package:rudra/app/modules/manager_module/notification/notification_detail_bottom_sheet.dart';
import 'package:rudra/app/utils/app_utility.dart';
import 'package:rudra/app/widgets/app_snackbar_styles.dart';

import '../../../data/models/notification/notification_model.dart';
import '../../../utils/app_logger.dart';

class ExecutiveNotificationController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs; // For pagination loading
  final RxBool hasMoreData = true.obs; // To track if more data is available
  final RxInt offset = 0.obs; // Pagination offset
  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  final RxInt unreadCount = 0.obs;
  final RxString errorMessage = ''.obs;
  final int limit = 10; // Number of items per page

  @override
  void onInit() {
    super.onInit();
    _fetchNotifications(context: Get.context!);
  }

  Future<void> onRefresh() async {
    AppLogger.d('Notification page refreshed', tag: 'NotificationController');
    await refreshNotifications(context: Get.context!);
  }

  Future<void> _fetchNotifications({
    required BuildContext context,
    bool reset = false,
    bool isPagination = false,
  }) async {
    try {
      if (reset) {
        offset.value = 0;
        notifications.clear();
        hasMoreData.value = true;
      }
      if (!hasMoreData.value && !reset) {
        AppLogger.d(
          'No more notifications to fetch',
          tag: 'NotificationController',
        );
        return; // Exit if no more data is available
      }

      if (isPagination) {
        isLoadingMore.value = true;
      } else {
        isLoading.value = true;
      }
      errorMessage.value = '';

      final jsonBody = {
        "user_id": AppUtility.userID,
        "limit": limit.toString(),
        "offset": offset.value.toString(),
      };

      List<GetNotificationResponse>? response =
          (await Networkcall().postMethod(
                Networkutility.notificationsApi,
                Networkutility.notifications,
                jsonEncode(jsonBody),
                context,
              ))
              as List<GetNotificationResponse>?;

      if (response != null && response.isNotEmpty) {
        if (response[0].status == "true") {
          final notificationData = response[0].data;
          if (notificationData.isEmpty || notificationData.length < limit) {
            hasMoreData.value =
                false; // No more data if fewer notifications than limit
            AppLogger.d(
              'No more notifications or fewer items received: ${notificationData.length}',
              tag: 'NotificationController',
            );
          } else {
            hasMoreData.value = true; // More data might be available
          }

          // Map API response to NotificationModel and add only new notifications
          for (var notification in notificationData) {
            if (!notifications.any(
              (existing) => existing.id == notification.id,
            )) {
              notifications.add(
                NotificationModel(
                  id: notification.id,
                  title: notification.title,
                  message: notification.body,
                  timeAgo: _calculateTimeAgo(notification.createdOn),
                  dateTime: notification.createdOn,
                  isRead:
                      notification.responseStatus ==
                      'read', // Adjust based on your API's read status logic
                  details: _mapToNotificationDetails(
                    notification,
                  ), // Map details if applicable
                ),
              );
            }
          }

          // Increment offset only if new data was added
          if (notificationData.isNotEmpty) {
            offset.value += notificationData.length;
            AppLogger.d(
              'Offset updated to: ${offset.value}',
              tag: 'NotificationController',
            );
          }

          _updateUnreadCount();
          AppLogger.d(
            'Notifications loaded successfully',
            tag: 'NotificationController',
          );
        } else {
          hasMoreData.value = false;
          errorMessage.value = response[0].message ?? 'No notifications found';
          AppLogger.d(
            'API returned status false: ${errorMessage.value}',
            tag: 'NotificationController',
          );
        }
      } else {
        hasMoreData.value = false;
        errorMessage.value = 'No response from server';
        AppLogger.d('No response from server', tag: 'NotificationController');
      }
    } on NoInternetException catch (e) {
      errorMessage.value = e.message;
      AppLogger.e(
        'NoInternetException: ${e.message}',
        tag: 'NotificationController',
        error: e,
      );
    } on TimeoutException catch (e) {
      errorMessage.value = e.message;
      AppLogger.e(
        'TimeoutException: ${e.message}',
        tag: 'NotificationController',
        error: e,
      );
    } on HttpException catch (e) {
      errorMessage.value = '${e.message} (Code: ${e.statusCode})';
      AppLogger.e(
        'HttpException: ${e.message} (Code: ${e.statusCode})',
        tag: 'NotificationController',
        error: e,
      );
    } on ParseException catch (e) {
      errorMessage.value = e.message;
      AppLogger.e(
        'ParseException: ${e.message}',
        tag: 'NotificationController',
        error: e,
      );
    } catch (e, stackTrace) {
      errorMessage.value = 'Unexpected error: $e';
      AppLogger.e(
        'Unexpected error: $e',
        tag: 'NotificationController',
        error: e,
        stackTrace: stackTrace,
      );
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  Future<void> loadMoreNotifications({required BuildContext context}) async {
    if (!isLoadingMore.value && hasMoreData.value && !isLoading.value) {
      AppLogger.d(
        'Loading more notifications with offset: ${offset.value}',
        tag: 'NotificationController',
      );
      await _fetchNotifications(context: context, isPagination: true);
    }
  }

  Future<void> refreshNotifications({
    required BuildContext context,
    bool showLoading = true,
  }) async {
    try {
      // Reset the notification list
      notifications.clear();
      errorMessage.value = '';
      offset.value = 0;
      hasMoreData.value = true;

      // Set loading state
      if (showLoading) {
        isLoading.value = true;
      }

      // Fetch the notification list
      await _fetchNotifications(context: context, reset: true);

      // Show success message if no errors
      if (errorMessage.value.isEmpty) {
        AppSnackbarStyles.showSuccess(
          title: 'Success',
          message: 'Notifications refreshed successfully',
        );
      }
    } catch (e, stackTrace) {
      errorMessage.value = 'Failed to refresh notifications: $e';
      AppLogger.e(
        'Failed to refresh notifications',
        tag: 'NotificationController',
        error: e,
        stackTrace: stackTrace,
      );
      AppSnackbarStyles.showError(title: 'Error', message: errorMessage.value);
    } finally {
      if (showLoading) {
        isLoading.value = false;
      }
    }
  }

  void onNotificationTap(NotificationModel notification) {
    AppLogger.d(
      'Notification tapped: ${notification.id}',
      tag: 'NotificationController',
    );

    // Mark as read if not already read
    if (!notification.isRead) {
      markAsRead(notification.id);
    }

    // Show bottom sheet with details
    if (notification.title != null) {
      showNotificationDetails(notification);
    } else {
      AppSnackbarStyles.showInfo(
        title: 'Notification',
        message: notification.message,
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
      AppLogger.d(
        'Notification marked as read: $notificationId',
        tag: 'NotificationController',
      );
      // Optionally, make an API call to update the read status on the server
      // _updateNotificationStatusOnServer(notificationId, 'read');
    }
  }

  String formatDateTime(String dateTimeString) {
    try {
      // Parse the input string to DateTime
      DateTime dateTime = DateTime.parse(dateTimeString);

      // Define the desired format (e.g., "Sep 16, 2025 – 11:25 AM")
      final DateFormat formatter = DateFormat('MMM d, yyyy – h:mm a');

      // Format the DateTime object
      return formatter.format(dateTime);
    } catch (e) {
      return 'Invalid date format';
    }
  }

  void markAllAsRead() {
    for (int i = 0; i < notifications.length; i++) {
      if (!notifications[i].isRead) {
        notifications[i] = notifications[i].copyWith(isRead: true);
      }
    }
    _updateUnreadCount();
    AppLogger.d(
      'All notifications marked as read',
      tag: 'NotificationController',
    );
    // Optionally, make an API call to update all notifications as read on the server
    // _updateAllNotificationsStatusOnServer('read');
  }

  void deleteNotification(String notificationId) {
    notifications.removeWhere((n) => n.id == notificationId);
    _updateUnreadCount();
    AppLogger.d(
      'Notification deleted: $notificationId',
      tag: 'NotificationController',
    );
    // Optionally, make an API call to delete the notification on the server
    // _deleteNotificationOnServer(notificationId);
  }

  void _updateUnreadCount() {
    unreadCount.value = notifications.where((n) => !n.isRead).length;
  }

  String _calculateTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} min${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  NotificationDetails? _mapToNotificationDetails(
    NotificationData notification,
  ) {
    // Adjust this mapping based on your API response and NotificationDetails structure
    // Example: Parse notification.response if it contains structured data
    try {
      if (notification.response.isNotEmpty) {
        final responseJson = jsonDecode(notification.response);
        return NotificationDetails(
          surveyName: responseJson['survey_name'] ?? notification.title,
          executiveName: responseJson['executive_name'] ?? '',
          dateTime:
              responseJson['date_time'] ?? notification.createdOn.toString(),
          target: responseJson['target'] ?? '',
        );
      }
      return null;
    } catch (e) {
      AppLogger.e(
        'Failed to parse notification details: $e',
        tag: 'NotificationController',
      );
      return null;
    }
  }
}
