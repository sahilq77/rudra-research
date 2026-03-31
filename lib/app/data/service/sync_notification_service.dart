import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:rudra/app/data/service/sync_service.dart';
import 'package:rudra/app/utils/app_logger.dart';

class SyncNotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'survey_sync_channel';
  static const String _channelName = 'Survey Sync';
  static const int _notificationId = 1001;

  static Future<void> initialize() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    if (Platform.isAndroid) {
      await _notifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(
            const AndroidNotificationChannel(
              _channelId,
              _channelName,
              description: 'Shows survey upload progress',
              importance: Importance.high,
              enableVibration: false,
              playSound: false,
            ),
          );
    }

    AppLogger.i('SyncNotificationService initialized', tag: 'SyncNotification');
  }

  static void _onNotificationTap(NotificationResponse response) {
    if (response.actionId == 'upload_now') {
      AppLogger.i('Upload Now button tapped', tag: 'SyncNotification');
      if (Get.isRegistered<SyncService>()) {
        Get.find<SyncService>().forceSyncNow();
      }
    }
  }

  static Future<void> showPendingSurveysNotification(int count) async {
    if (count == 0) {
      await cancelNotification();
      return;
    }

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: 'Shows survey upload progress',
      importance: Importance.high,
      priority: Priority.high,
      ongoing: true,
      autoCancel: false,
      showProgress: false,
      icon: '@mipmap/ic_launcher',
      actions: [
        AndroidNotificationAction(
          'upload_now',
          'Upload Now',
          showsUserInterface: true,
        ),
      ],
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: false,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      _notificationId,
      'Pending Surveys',
      '$count survey${count > 1 ? 's' : ''} waiting to upload',
      details,
    );

    AppLogger.i('Notification shown: $count pending surveys',
        tag: 'SyncNotification');
  }

  static Future<void> showUploadProgress(int current, int total) async {
    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: 'Shows survey upload progress',
      importance: Importance.high,
      priority: Priority.high,
      ongoing: true,
      autoCancel: false,
      showProgress: true,
      maxProgress: total,
      progress: current,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: false,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      _notificationId,
      'Uploading Surveys',
      'Uploading $current of $total...',
      details,
    );
  }

  static Future<void> showUploadComplete(int count) async {
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: 'Shows survey upload progress',
      importance: Importance.high,
      priority: Priority.high,
      ongoing: false,
      autoCancel: true,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      _notificationId,
      'Upload Complete',
      '$count survey${count > 1 ? 's' : ''} uploaded successfully',
      details,
    );

    await Future.delayed(const Duration(seconds: 3));
    await cancelNotification();
  }

  static Future<void> showUploadFailed(int failed, int total) async {
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: 'Shows survey upload progress',
      importance: Importance.high,
      priority: Priority.high,
      ongoing: false,
      autoCancel: true,
      icon: '@mipmap/ic_launcher',
      actions: [
        AndroidNotificationAction(
          'upload_now',
          'Retry',
          showsUserInterface: true,
        ),
      ],
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      _notificationId,
      'Upload Failed',
      '$failed of $total survey${total > 1 ? 's' : ''} failed to upload',
      details,
    );
  }

  static Future<void> cancelNotification() async {
    await _notifications.cancel(_notificationId);
  }
}
