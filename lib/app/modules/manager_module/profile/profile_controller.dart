// lib/app/modules/profile/profile_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/profile/profile_menu_item_model.dart';
import '../../../routes/app_routes.dart';
import '../../../utils/app_logger.dart';
import '../../../utils/app_utility.dart';
import 'logout_dialog.dart';

class ProfileController extends GetxController {
  final RxBool isLoading = false.obs;

  List<ProfileMenuItemModel> get menuItems => [
        ProfileMenuItemModel(
          title: 'Profile',
          icon: 'person',
          route: AppRoutes.profileDetails,
        ),
        ProfileMenuItemModel(
          title: 'Notification',
          icon: 'notifications',
          route: AppRoutes.notifications, // Changed from '/notifications'
        ),
        ProfileMenuItemModel(
          title: 'My Survey',
          icon: 'assignment',
          route: '/my-survey',
        ),
        ProfileMenuItemModel(
          title: 'Logout',
          icon: 'logout',
          route: '',
          isLogout: true,
        ),
      ];

  String get userName => AppUtility.fullName ?? 'User';

  String get greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  Future<void> onRefresh() async {
    await Future.delayed(const Duration(seconds: 1));
    AppLogger.d('Profile page refreshed', tag: 'ProfileController');
  }

  void onMenuItemTap(ProfileMenuItemModel item) {
    if (item.isLogout) {
      _showLogoutDialog();
    } else if (item.route == AppRoutes.profileDetails) {
      AppLogger.d('Navigate to: ${item.route}', tag: 'ProfileController');
      Get.toNamed(AppRoutes.profileDetails);
    } else if (item.route == AppRoutes.notifications) {
      // Added this condition
      AppLogger.d('Navigate to: ${item.route}', tag: 'ProfileController');
      Get.toNamed(AppRoutes.notifications);
    } else if (item.route.isNotEmpty) {
      // Changed from else to else if
      AppLogger.d('Navigate to: ${item.route}', tag: 'ProfileController');
      Get.snackbar(
        'Coming Soon',
        '${item.title} feature will be available soon',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );
    }
  }

  void _showLogoutDialog() {
    Get.dialog(
      LogoutDialog(
        onCancel: () => Get.back(),
        onConfirm: () async {
          Get.back();
          await _performLogout();
        },
      ),
      barrierDismissible: false,
    );
  }

  Future<void> _performLogout() async {
    try {
      isLoading.value = true;
      AppLogger.i('Clearing user data...', tag: 'ProfileController');

      // Clear all user info and shared preferences
      await AppUtility.clearUserInfo();

      AppLogger.i('User logged out successfully', tag: 'ProfileController');

      // Navigate to login and clear all previous routes
      Get.offAllNamed(AppRoutes.login);
    } catch (e, stackTrace) {
      AppLogger.e(
        'Logout failed',
        error: e,
        stackTrace: stackTrace,
        tag: 'ProfileController',
      );
      Get.snackbar(
        'Error',
        'Failed to logout. Please try again.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
