// lib/app/modules/splash/splash_controller.dart
import 'package:get/get.dart';

import '../../routes/app_routes.dart';
import '../../utils/app_utility.dart'; // Import for initialize() and checks

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    // NEW: Call initialize() to load flags from prefs
    AppUtility.initialize().then((_) {
      // Delay for splash animation, then navigate based on flags
      Future.delayed(const Duration(seconds: 3), () {
        // Point 1: If onboarding seen, skip it
        if (AppUtility.hasSeenOnboarding) {
          // Point 2: If logged in, go to home; else login
          if (AppUtility.isLoggedIn) {
            Get.offNamed(AppRoutes.home);
          } else {
            Get.offNamed(AppRoutes.login);
          }
        } else {
          // First time? Go to onboarding
          Get.offNamed(AppRoutes.onboarding);
        }
      });
    });
  }
}
