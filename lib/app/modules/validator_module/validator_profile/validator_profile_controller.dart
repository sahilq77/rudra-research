import 'dart:convert';

import 'package:get/get.dart';
import 'package:rudra/app/data/models/logout/logout_response.dart';
import 'package:rudra/app/data/models/profile/profile_menu_item_model.dart';
import 'package:rudra/app/data/network/networkcall.dart';
import 'package:rudra/app/data/urls.dart';
import 'package:rudra/app/utils/app_logger.dart';
import 'package:rudra/app/widgets/app_snackbar_styles.dart';

import '../../../routes/app_routes.dart';
import '../../../utils/app_utility.dart';
import '../../manager_module/profile/logout_dialog.dart';

class ValidatorProfileController extends GetxController {
  final RxBool isLoading = false.obs;

  List<ProfileMenuItemModel> get menuItems => [
        ProfileMenuItemModel(
          title: 'Profile',
          icon: 'person',
          route: AppRoutes
              .validatorProfileDetail, // Changed from '/profile-details'
        ),
        ProfileMenuItemModel(
          title: 'Notification',
          icon: 'notifications',
          route:
              AppRoutes.validatorNotification, // Changed from '/notifications'
        ),
        // ProfileMenuItemModel(
        //   title: 'My Survey',
        //   icon: 'assignment',
        //   route: AppRoutes.executiveMySurvey,
        // ),
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
    AppLogger.d('Profile page refreshed', tag: 'ExecutiveProfileController');
  }

  void onMenuItemTap(ProfileMenuItemModel item) {
    if (item.isLogout) {
      _showLogoutDialog();
    } else if (item.route == AppRoutes.validatorProfileDetail) {
      AppLogger.d(
        'Navigate to: ${item.route}',
        tag: 'ExecutiveProfileController',
      );
      Get.toNamed(AppRoutes.validatorProfileDetail);
    } else if (item.route == AppRoutes.validatorNotification) {
      // Added this condition
      AppLogger.d(
        'Navigate to: ${item.route}',
        tag: 'ExecutiveProfileController',
      );
      Get.toNamed(AppRoutes.validatorNotification);
    } else if (item.route.isNotEmpty) {
      // Changed from else to else if
      AppLogger.d(
        'Navigate to: ${item.route}',
        tag: 'ExecutiveProfileController',
      );
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
          await _performLogout();
        },
        isLoading: isLoading,
      ),
      barrierDismissible: false,
    );
  }

  Future<void> _performLogout() async {
    try {
      isLoading.value = true;
      AppLogger.i('Logging out...', tag: 'ValidatorProfileController');

      final jsonBody = {
        'user_id': AppUtility.userID ?? '',
        'device_id': AppUtility.deviceId ?? '',
      };

      final response = await Networkcall().postMethod(
        Networkutility.logoutApi,
        Networkutility.logout,
        jsonEncode(jsonBody),
        Get.context!,
      );

      if (response != null && response.isNotEmpty) {
        final logoutResponse = response[0] as LogoutResponse;

        if (logoutResponse.status == 'true') {
          await AppUtility.clearUserInfo();
          AppLogger.i('User logged out successfully',
              tag: 'ValidatorProfileController');
          Get.back(); // Close dialog
          Get.offAllNamed(AppRoutes.login);
          AppSnackbarStyles.showSuccess(
            title: 'Success',
            message: logoutResponse.message,
          );
        } else {
          Get.back(); // Close dialog
          AppSnackbarStyles.showError(
            title: 'Failed',
            message: logoutResponse.message,
          );
        }
      } else {
        Get.back(); // Close dialog
        AppSnackbarStyles.showError(
          title: 'Error',
          message: 'Failed to logout. Please try again.',
        );
      }
    } catch (e, stackTrace) {
      AppLogger.e(
        'Logout failed',
        error: e,
        stackTrace: stackTrace,
        tag: 'ValidatorProfileController',
      );
      Get.back(); // Close dialog
      AppSnackbarStyles.showError(
        title: 'Error',
        message: 'Failed to logout. Please try again.',
      );
    } finally {
      isLoading.value = false;
    }
  }
}
