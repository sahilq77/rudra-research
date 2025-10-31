// lib/app/modules/splash/splash_controller.dart
import 'dart:io' show Platform;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../routes/app_routes.dart';
import '../../../utils/app_utility.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();

    // 1. Load saved flags first
    AppUtility.initialize().then((_) async {
      // 2. Request permissions *before* any navigation
      final granted = await _requestAllPermissions();
      if (!granted) {
        // If any permission is permanently denied, show dialog and stop
        _showPermissionDeniedDialog();
        return;
      }

      // 3. Splash animation (3 seconds) → then navigate
      Future.delayed(const Duration(seconds: 3), _navigateBasedOnFlags);
    });
  }

  // ──────────────────────────────────────────────────────────────
  // 1. Request every permission you declared in the manifest
  // ──────────────────────────────────────────────────────────────
  Future<bool> _requestAllPermissions() async {
    // Map of permission → whether it needs to be requested
    Map<Permission, bool> permissions = {};

    // ---------- CAMERA ----------
    permissions[Permission.camera] = true;

    // ---------- STORAGE ----------
    if (Platform.isAndroid) {
      // Android 13+ (API 33) → granular media permissions
      if (await _isAndroid13OrHigher()) {
        permissions[Permission.photos] = true;      // READ_MEDIA_IMAGES
        permissions[Permission.videos] = true;      // READ_MEDIA_VIDEO
        permissions[Permission.audio] = true;       // READ_MEDIA_AUDIO
      } else {
        // Android < 13 → legacy storage
        permissions[Permission.storage] = true;
      }
    }

    // ---------- MICROPHONE ----------
    permissions[Permission.microphone] = true;

    // ---------- NOTIFICATIONS ----------
    permissions[Permission.notification] = true;

    // Request all at once
    final statuses = await Future.wait(
      permissions.keys.map((p) => p.request()),
    );

    // Check if *any* is denied permanently
    for (var i = 0; i < permissions.keys.length; i++) {
      final perm = permissions.keys.elementAt(i);
      final status = statuses[i];

      if (status.isDenied || status.isPermanentlyDenied) {
        // If permanently denied → open app settings
        if (status.isPermanentlyDenied) {
          await openAppSettings();
        }
        return false;
      }
    }
    return true;
  }

  // Helper: detect Android 13+
  Future<bool> _isAndroid13OrHigher() async {
    if (!Platform.isAndroid) return false;
    final deviceInfo = await _getAndroidVersion();
    return deviceInfo >= 33;
  }

  Future<int> _getAndroidVersion() async {
    try {
      final androidInfo = await  DeviceInfoPlugin().androidInfo;
      return androidInfo.version.sdkInt;
    } catch (_) {
      return 0;
    }
  }

  // ──────────────────────────────────────────────────────────────
  // 2. Show a dialog when permission is permanently denied
  // ──────────────────────────────────────────────────────────────
  void _showPermissionDeniedDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Permissions Required'),
        content: const Text(
          'This app needs camera, storage, microphone and notification '
          'permissions to work correctly. Please grant them in Settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              await openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
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
        }
      } else {
        Get.offNamed(AppRoutes.login);
      }
    } else {
      Get.offNamed(AppRoutes.onboarding);
    }
  }
}