import 'dart:convert';

import 'package:get/get.dart';

import '../../../data/models/logout/logout_response.dart';
import '../../../data/models/profile/profile_menu_item_model.dart';
import '../../../data/network/networkcall.dart';
import '../../../data/urls.dart';
import '../../../routes/app_routes.dart';
import '../../../utils/app_logger.dart';
import '../../../utils/app_utility.dart';
import '../../../widgets/app_snackbar_styles.dart';
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
          route: AppRoutes.notifications,
        ),
        ProfileMenuItemModel(
          title: 'My Team',
          icon: 'My Team',
          route: AppRoutes.myteam,
        ),
        ProfileMenuItemModel(
          title: 'My Survey',
          icon: 'My Survey',
          route: AppRoutes.mySurvey,
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
      AppLogger.d('Navigate to: ${item.route}', tag: 'ProfileController');
      Get.toNamed(AppRoutes.notifications);
    } else if (item.route == AppRoutes.myteam) {
      AppLogger.d('Navigate to: ${item.route}', tag: 'ProfileController');
      Get.toNamed(AppRoutes.myteam);
    } else if (item.route == AppRoutes.mySurvey) {
      AppLogger.d('Navigate to: ${item.route}', tag: 'ProfileController');
      Get.toNamed(AppRoutes.mySurvey);
    }
  }

  void _showLogoutDialog() {
    Get.closeAllSnackbars();
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
      AppLogger.i('Logging out...', tag: 'ProfileController');

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
          AppLogger.i('User logged out successfully', tag: 'ProfileController');
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
        tag: 'ProfileController',
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
