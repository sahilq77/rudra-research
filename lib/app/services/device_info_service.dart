import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

import '../data/models/device_info/device_info_response.dart';
import '../data/network/networkcall.dart';
import '../data/urls.dart';
import '../utils/app_logger.dart';

class DeviceInfoService {
  static Future<void> sendDeviceInfo({
    required String userId,
    required String userType,
    required String username,
    required String name,
    required String mobileNo,
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      final packageInfo = await PackageInfo.fromPlatform();

      String deviceOsVersion = '';
      String deviceId = '';
      String deviceManufacture = '';
      String deviceModal = '';
      String targetSdk = '';
      String deviceOs = '';

      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        deviceOsVersion = androidInfo.version.release;
        deviceId = androidInfo.id;
        deviceManufacture = androidInfo.manufacturer;
        deviceModal = androidInfo.model;
        targetSdk = androidInfo.version.sdkInt.toString();
        deviceOs = 'Android';
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        deviceOsVersion = iosInfo.systemVersion;
        deviceId = iosInfo.identifierForVendor ?? '';
        deviceManufacture = 'Apple';
        deviceModal = iosInfo.model;
        targetSdk = iosInfo.systemVersion;
        deviceOs = 'iOS';
      }

      final locationStatus = await Permission.location.status;
      final cameraStatus = await Permission.camera.status;
      final locationAlwaysStatus = await Permission.locationAlways.status;
      final notificationStatus = await Permission.notification.status;

      final jsonBody = {
        "project": "Rudra",
        "user_id": userId,
        "user_type": userType,
        "username": username,
        "name": name,
        "mobile_no": mobileNo,
        "email": email,
        "password": password,
        "device_details": {
          "device_os_version": deviceOsVersion,
          "device_id": deviceId,
          "device_manufacture": deviceManufacture,
          "device_modal": deviceModal,
          "taget_sdk": targetSdk,
          "app_current_version": packageInfo.version,
          "device_os": deviceOs,
        },
        "permission_details": [
          {
            "permission": "Location",
            "is_required": "Yes",
            "status": _getPermissionStatus(locationStatus),
          },
          {
            "permission": "Camera",
            "is_required": "Yes",
            "status": _getPermissionStatus(cameraStatus),
          },
          {
            "permission": "Location_Always",
            "is_required": "Yes",
            "status": _getPermissionStatus(locationAlwaysStatus),
          },
          {
            "permission": "Notification",
            "is_required": "Yes",
            "status": _getPermissionStatus(notificationStatus),
          },
        ],
      };

      AppLogger.i('Device Info request: $jsonBody');

      final response = await Networkcall().postMethod(
        Networkutility.deviceCompleteInfoApi,
        Networkutility.deviceCompleteInfo,
        jsonEncode(jsonBody),
        context,
      );

      if (response != null && response.isNotEmpty) {
        final deviceInfoResponse = response as List<DeviceInfoResponse>;
        if (deviceInfoResponse[0].status == "true") {
          AppLogger.i('Device info sent: ${deviceInfoResponse[0].message}');
        } else {
          AppLogger.w('Device info failed: ${deviceInfoResponse[0].message}');
        }
      }
    } catch (e) {
      AppLogger.e('Error sending device info', error: e);
    }
  }

  static String _getPermissionStatus(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.granted:
        return 'Granted';
      case PermissionStatus.denied:
        return 'Denied';
      case PermissionStatus.permanentlyDenied:
        return 'Permanently Denied';
      case PermissionStatus.restricted:
        return 'Restricted';
      case PermissionStatus.limited:
        return 'Limited';
      default:
        return 'Pending';
    }
  }
}
