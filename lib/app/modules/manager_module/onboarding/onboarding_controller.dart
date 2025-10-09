// lib/app/modules/onboarding/onboarding_controller.dart
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../routes/app_routes.dart';
import '../../../utils/app_images.dart';
import '../../../utils/app_utility.dart'; // NEW: Import for setOnboardingSeen()

class OnboardingController extends GetxController {
  final RxInt currentPage = 0.obs;
  final pageTitles = [
    'Welcome To !',
    'Explore Features !',
    'Get Started !',
  ];
  final pageMainTitles = [
    'Rudra Research & Analytics',
    'Data Driven Decisions',
    'Unlock Potential',
  ];
  final pageSubtitles = [
    'Precision Leads. Prime Results. Get high-quality leads delivered to you daily.',
    'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam euismod eros non elit.',
    'Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip.',
  ];
  final onboardingImages = [
    AppImages.onboarding1,
    AppImages.onboarding2,
    AppImages.onboarding3,
  ];

  void nextPage(PageController pageController) {
    if (currentPage.value < 2) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      skip();
    }
  }

  void skip() {
    // NEW: Point 1 - Mark onboarding as seen before navigating (async, but fire-and-forget)
    AppUtility.setOnboardingSeen();
    Get.offNamed(AppRoutes.login);
  }
}
