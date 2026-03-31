// lib/app/modules/splash/splash_controller.dart
import 'dart:io' show Platform;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../routes/app_routes.dart';
import '../../../services/device_info_service.dart';
import '../../../utils/app_utility.dart';
import '../../../widgets/permissions_dialog.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();

    // 1. Load saved flags first
    AppUtility.initialize().then((_) async {
      // Send device info if user is logged in
      if (AppUtility.isLoggedIn && AppUtility.userID != null) {
        DeviceInfoService.sendDeviceInfo(
          userId: AppUtility.userID!,
          userType: AppUtility.userRole.toString(),
          username: AppUtility.fullName?.split(' ').first ?? '',
          name: AppUtility.fullName ?? '',
          mobileNo: AppUtility.mobileNumber ?? '',
          email: AppUtility.email ?? '',
          password: '123',
          context: Get.context!,
        );
      }
      // 2. Check if permissions are needed after 2 seconds
      Future.delayed(const Duration(seconds: 2), _checkAndRequestPermissions);
    });
  }

  Future<void> _checkAndRequestPermissions() async {
    final needsPermissions = await _checkIfPermissionsNeeded();

    if (needsPermissions) {
      _showPermissionsDialog();
    } else {
      _navigateBasedOnFlags();
    }
  }

  void _showPermissionsDialog() {
    Get.dialog(
      PermissionsDialog(
        onAccept: () {
          _requestAllPermissions().then((_) {
            Future.delayed(
                const Duration(milliseconds: 500), _navigateBasedOnFlags);
          });
        },
        onLater: () {
          _navigateBasedOnFlags();
        },
      ),
      barrierDismissible: false,
    );
  }

  Future<bool> _checkIfPermissionsNeeded() async {
    try {
      List<Permission> permissionsToCheck = [];

      // Camera
      permissionsToCheck.add(Permission.camera);

      // Storage/Media
      if (Platform.isAndroid) {
        if (await _isAndroid13OrHigher()) {
          permissionsToCheck.addAll([
            Permission.photos,
            Permission.videos,
            Permission.audio,
          ]);
        } else {
          permissionsToCheck.add(Permission.storage);
        }
      }

      // Microphone
      permissionsToCheck.add(Permission.microphone);

      // Notifications
      permissionsToCheck.add(Permission.notification);

      // Location
      permissionsToCheck.add(Permission.location);

      // Check if any permission is not granted
      for (var permission in permissionsToCheck) {
        final status = await permission.status;
        if (!status.isGranted) {
          return true; // At least one permission is needed
        }
      }

      return false; // All permissions are granted
    } catch (e) {
      return true; // Show dialog on error to be safe
    }
  }

  // ──────────────────────────────────────────────────────────────
  // Request permissions after user accepts
  // ──────────────────────────────────────────────────────────────
  Future<void> _requestAllPermissions() async {
    try {
      // List of permissions to request
      List<Permission> permissionsToRequest = [];

      // ---------- CAMERA ----------
      permissionsToRequest.add(Permission.camera);

      // ---------- STORAGE ----------
      if (Platform.isAndroid) {
        // Android 13+ (API 33) → granular media permissions
        if (await _isAndroid13OrHigher()) {
          permissionsToRequest.add(Permission.photos);
          permissionsToRequest.add(Permission.videos);
          permissionsToRequest.add(Permission.audio);
        } else {
          permissionsToRequest.add(Permission.storage);
        }
      }

      // ---------- MICROPHONE ----------
      permissionsToRequest.add(Permission.microphone);

      // ---------- NOTIFICATIONS ----------
      permissionsToRequest.add(Permission.notification);

      // Location
      permissionsToRequest.add(Permission.location);

      // Request permissions ONE BY ONE
      for (var permission in permissionsToRequest) {
        final status = await permission.status;
        if (!status.isGranted) {
          await permission.request();
        }
      }

      // Request battery optimization exemption (doesn't block)
      if (Platform.isAndroid) {
        final batteryStatus =
            await Permission.ignoreBatteryOptimizations.status;
        if (!batteryStatus.isGranted) {
          await Permission.ignoreBatteryOptimizations.request();
        }
      }
    } catch (e) {
      // Silently fail - don't block navigation
    }
  }

  // Helper: detect Android 13+
  Future<bool> _isAndroid13OrHigher() async {
    if (!Platform.isAndroid) return false;
    final deviceInfo = await _getAndroidVersion();
    return deviceInfo >= 33;
  }

  Future<int> _getAndroidVersion() async {
    try {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      return androidInfo.version.sdkInt;
    } catch (_) {
      return 0;
    }
  }

  // ──────────────────────────────────────────────────────────────
  // 3. Navigation logic (unchanged, just extracted)
  // ──────────────────────────────────────────────────────────────
  void _navigateBasedOnFlags() {
    if (AppUtility.hasSeenOnboarding) {
      if (AppUtility.isLoggedIn) {
        if (AppUtility.userRole == 0) {
          Get.offNamed(AppRoutes.home);
        } else if (AppUtility.userRole == 1) {
          Get.offNamed(AppRoutes.executiveHome);
        } else if (AppUtility.userRole == 2) {
          Get.offNamed(AppRoutes.validatorHome);
        } else if (AppUtility.userRole == 3) {
          Get.offNamed(AppRoutes.superAdminHome);
        } else {
          Get.offNamed(AppRoutes.login);
        }
      } else {
        Get.offNamed(AppRoutes.login);
      }
    } else {
      Get.offNamed(AppRoutes.onboarding);
    }
  }
}
