import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:rudra/app/data/network/exceptions.dart';
import 'package:rudra/app/data/network/networkcall.dart';
import 'package:rudra/app/data/urls.dart';
import 'package:rudra/app/widgets/app_snackbar_styles.dart';

import '../../../data/models/notification/get_notification_response.dart';
import '../../../data/models/notification/notification_model.dart';
import '../../../utils/app_logger.dart';
import '../../../utils/app_utility.dart';
import 'validator_notification_detail_bottom_sheet.dart';

class ValidatorNotificationController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMoreData = true.obs;
  final RxInt offset = 0.obs;
  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  final RxInt unreadCount = 0.obs;
  final RxString errorMessage = ''.obs;
  final int limit = 10;

  @override
  void onInit() {
    super.onInit();
    _fetchNotifications(context: Get.context!);
  }

  Future<void> onRefresh() async {
    AppLogger.d('Notification page refreshed',
        tag: 'ValidatorNotificationController');
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
        AppLogger.d('No more notifications to fetch',
            tag: 'ValidatorNotificationController');
        return;
      }

      if (isPagination) {
        isLoadingMore.value = true;
      } else {
        isLoading.value = true;
      }
      errorMessage.value = '';

      final jsonBody = {
        "user_id": AppUtility.userID ?? "",
        "limit": limit.toString(),
        "offset": offset.value.toString(),
      };

      List<GetNotificationResponse>? response = (await Networkcall().postMethod(
        Networkutility.notificationsApi,
        Networkutility.notifications,
        jsonEncode(jsonBody),
        context,
      )) as List<GetNotificationResponse>?;

      if (response != null && response.isNotEmpty) {
        if (response[0].status == "true") {
          final notificationData = response[0].data;
          if (notificationData.isEmpty || notificationData.length < limit) {
            hasMoreData.value = false;
            AppLogger.d(
                'No more notifications or fewer items received: ${notificationData.length}',
                tag: 'ValidatorNotificationController');
          } else {
            hasMoreData.value = true;
          }

          for (var notification in notificationData) {
            if (!notifications
                .any((existing) => existing.id == notification.id)) {
              notifications.add(
                NotificationModel(
                  id: notification.id,
                  title: notification.title,
                  message: notification.body,
                  timeAgo: _calculateTimeAgo(notification.createdOn),
                  dateTime: notification.createdOn,
                  isRead: notification.responseStatus == 'read',
                  details: _mapToNotificationDetails(notification),
                ),
              );
            }
          }

          if (notificationData.isNotEmpty) {
            offset.value += notificationData.length;
            AppLogger.d('Offset updated to: ${offset.value}',
                tag: 'ValidatorNotificationController');
          }

          _updateUnreadCount();
          AppLogger.d('Notifications loaded successfully',
              tag: 'ValidatorNotificationController');
        } else {
          hasMoreData.value = false;
          errorMessage.value = response[0].message ?? 'No notifications found';
          AppLogger.d('API returned status false: ${errorMessage.value}',
              tag: 'ValidatorNotificationController');
        }
      } else {
        hasMoreData.value = false;
        errorMessage.value = 'No response from server';
        AppLogger.d('No response from server',
            tag: 'ValidatorNotificationController');
      }
    } on NoInternetException catch (e) {
      errorMessage.value = e.message;
      AppLogger.e('NoInternetException: ${e.message}',
          tag: 'ValidatorNotificationController', error: e);
    } on TimeoutException catch (e) {
      errorMessage.value = e.message;
      AppLogger.e('TimeoutException: ${e.message}',
          tag: 'ValidatorNotificationController', error: e);
    } on HttpException catch (e) {
      errorMessage.value = '${e.message} (Code: ${e.statusCode})';
      AppLogger.e('HttpException: ${e.message} (Code: ${e.statusCode})',
          tag: 'ValidatorNotificationController', error: e);
    } on ParseException catch (e) {
      errorMessage.value = e.message;
      AppLogger.e('ParseException: ${e.message}',
          tag: 'ValidatorNotificationController', error: e);
    } catch (e, stackTrace) {
      errorMessage.value = 'Unexpected error: $e';
      AppLogger.e('Unexpected error: $e',
          tag: 'ValidatorNotificationController',
          error: e,
          stackTrace: stackTrace);
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  Future<void> loadMoreNotifications({required BuildContext context}) async {
    if (!isLoadingMore.value && hasMoreData.value && !isLoading.value) {
      AppLogger.d('Loading more notifications with offset: ${offset.value}',
          tag: 'ValidatorNotificationController');
      await _fetchNotifications(context: context, isPagination: true);
    }
  }

  Future<void> refreshNotifications(
      {required BuildContext context, bool showLoading = true}) async {
    try {
      notifications.clear();
      errorMessage.value = '';
      offset.value = 0;
      hasMoreData.value = true;

      if (showLoading) {
        isLoading.value = true;
      }

      await _fetchNotifications(context: context, reset: true);

      if (errorMessage.value.isEmpty) {
        AppSnackbarStyles.showSuccess(
            title: 'Success', message: 'Notifications refreshed successfully');
      }
    } catch (e, stackTrace) {
      errorMessage.value = 'Failed to refresh notifications: $e';
      AppLogger.e('Failed to refresh notifications',
          tag: 'ValidatorNotificationController',
          error: e,
          stackTrace: stackTrace);
      AppSnackbarStyles.showError(title: 'Error', message: errorMessage.value);
    } finally {
      if (showLoading) {
        isLoading.value = false;
      }
    }
  }

  void onNotificationTap(NotificationModel notification) {
    AppLogger.d('Notification tapped: ${notification.id}',
        tag: 'ValidatorNotificationController');

    if (!notification.isRead) {
      markAsRead(notification.id);
    }

    showNotificationDetails(notification);
  }

  void showNotificationDetails(NotificationModel notification) {
    Get.bottomSheet(
      ValidatorNotificationDetailBottomSheet(notification: notification),
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
          tag: 'ValidatorNotificationController');
    }
  }

  String formatDateTime(String dateTimeString) {
    try {
      DateTime dateTime = DateTime.parse(dateTimeString);
      final DateFormat formatter = DateFormat('MMM d, yyyy – h:mm a');
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
    AppLogger.d('All notifications marked as read',
        tag: 'ValidatorNotificationController');
  }

  void deleteNotification(String notificationId) {
    notifications.removeWhere((n) => n.id == notificationId);
    _updateUnreadCount();
    AppLogger.d('Notification deleted: $notificationId',
        tag: 'ValidatorNotificationController');
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
      NotificationData notification) {
    try {
      if (notification.response != null && notification.response!.isNotEmpty) {
        final responseJson = jsonDecode(notification.response!);
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
      AppLogger.e('Failed to parse notification details: $e',
          tag: 'ValidatorNotificationController');
      return null;
    }
  }
}
