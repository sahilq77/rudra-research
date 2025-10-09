// lib/app/modules/home/home_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/app_routes.dart';
import '../../../utils/app_images.dart';
import '../../../utils/app_logger.dart';
import '../../../utils/app_utility.dart';

class ExecutiveHomeController extends GetxController {
  final RxInt currentIndex = 0.obs;
  final RxInt userRoleRx = 0.obs;

  int get userRole => userRoleRx.value;

  // Check if user is Manager
  bool get isManager => userRoleRx.value == 0;

  // Check if user is Executive
  bool get isExecutive => userRoleRx.value == 1;

  // Check if user is Validator
  bool get isValidator => userRoleRx.value == 2;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args != null && args['userRole'] != null) {
      userRoleRx.value = args['userRole'] as int;
    } else {
      userRoleRx.value = AppUtility.userRole ?? 0;
    }
  }

  // Get filtered dashboard stats based on role
  List<Map<String, dynamic>> get dashboardStats {
    final allStats = [
      {
        'title': 'Daily Assigned Target',
        'value': '1000',
        'color': const Color(0xFFFFF9C4), // Yellow
        'imagePath': AppImages.dailyTarget,
        'textColor': Colors.black,
      },
      {
        'title': 'Assigned Target Completed',
        'value': '800',
        'color': const Color(0xFFD7F5DC), // Light Green
        'imagePath': AppImages.targetCompleted,
        'textColor': Colors.black,
      },
      // {
      //   'title': 'Number Of Surveys In Progress',
      //   'value': '1500',
      //   'color': const Color(0xFFD6EBFF), // Light Blue
      //   'imagePath': AppImages.surveyInProgress,
      //   'textColor': Colors.black,
      // },
      // {
      //   'title': 'Number Of Pending Surveys',
      //   'value': '500',
      //   'color': const Color(0xFFFFE9D5), // Light Orange
      //   'imagePath': AppImages.pendingSurvey,
      //   'textColor': Colors.black,
      // },
    ];

    // Manager sees all 4 stats
    if (isManager) {
      return allStats;
    }

    // Executive sees only first 2 stats (Daily Assigned Target & Assigned Target Completed)
    if (isExecutive) {
      return allStats.sublist(0, 2);
    }

    // Validator sees no dashboard stats
    return [];
  }

  final List<Map<String, dynamic>> liveSurveys = [
    {
      'title': 'Maratha Question 13-09',
      'subtitle': 'Sambhaji Nagar',
      'isLive': true,
    },
    {
      'title': 'Maratha Question 13-09',
      'subtitle': 'Sambhaji Nagar',
      'isLive': true,
    },
  ];

  String get userName {
    return 'Hi, ${AppUtility.fullName ?? 'Abhay'}';
  }

  String get userRoleText {
    final roles = ['Manager', 'Executor', 'Validator'];
    return roles[userRole];
  }

  // Get bottom navigation items based on role
  List<Map<String, dynamic>> get bottomNavItems {
    // Manager has all 5 tabs
    if (isManager) {
      return [
        {'icon': Icons.home, 'label': 'Home'},
        {'icon': Icons.insert_chart_outlined, 'label': 'My Report'},
        {'icon': Icons.people_outline, 'label': 'My Team'},
        {'icon': Icons.description_outlined, 'label': 'My Survey'},
        {'icon': Icons.person_outline, 'label': 'Profile'},
      ];
    }

    // Executive and Validator have only 3 tabs: Home, My Survey, Profile
    return [
      {'icon': Icons.home, 'label': 'Home'},
      {'icon': Icons.description_outlined, 'label': 'My Survey'},
      {'icon': Icons.person_outline, 'label': 'Profile'},
    ];
  }

  void changeTab(int index) {
    currentIndex.value = index;

    // Navigate based on tab selection
    if (isManager) {
      // Manager navigation (5 tabs)
      switch (index) {
        case 0:
          // Already on Home, do nothing
          AppLogger.d('Home tab selected', tag: 'ExecutiveHomeController');
          break;
        case 1:
          AppLogger.d('My Report tab selected', tag: 'ExecutiveHomeController');
          Get.toNamed(AppRoutes.myreport);
          // Get.snackbar(
          //   'Coming Soon',
          //   'My Report feature will be available soon',
          //   snackPosition: SnackPosition.TOP,
          //   duration: const Duration(seconds: 2),
          // );
          break;
        case 2:
          AppLogger.d('My Team tab selected', tag: 'ExecutiveHomeController');
          Get.toNamed(AppRoutes.myteam);
          // Get.snackbar(
          //   'Coming Soon',
          //   'My Team feature will be available soon',
          //   snackPosition: SnackPosition.TOP,
          //   duration: const Duration(seconds: 2),
          // );
          break;
        case 3:
          AppLogger.d('My Survey tab selected', tag: 'ExecutiveHomeController');
          Get.toNamed(AppRoutes.mySurvey);
          // Get.snackbar(
          //   'Coming Soon',
          //   'My Survey feature will be available soon',
          //   snackPosition: SnackPosition.TOP,
          //   duration: const Duration(seconds: 2),
          // );
          break;
        case 4:
          AppLogger.d('Profile tab selected', tag: 'ExecutiveHomeController');
          Get.toNamed(AppRoutes.profile);
          break;
      }
    } else {
      // Executive and Validator navigation (3 tabs)
      switch (index) {
        case 0:
          // Already on Home, do nothing
          Get.toNamed(AppRoutes.executiveHome);
          AppLogger.d('Home tab selected', tag: 'ExecutiveHomeController');
          break;
        case 1:
          AppLogger.d('My Survey tab selected', tag: 'ExecutiveHomeController');
          Get.toNamed(AppRoutes.executiveMySurvey);

          Get.snackbar(
            'Coming Soon',
            'My Survey feature will be available soon',
            snackPosition: SnackPosition.TOP,
            duration: const Duration(seconds: 2),
          );
          break;
        case 2:
          AppLogger.d('Profile tab selected', tag: 'ExecutiveHomeController');
          Get.toNamed(AppRoutes.profile);
          break;
      }
    }
  }

  void refreshData() {
    AppLogger.d('Refreshing home data', tag: 'ExecutiveHomeController');
    Get.snackbar(
      'Refresh',
      'Data refreshed successfully',
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 2),
    );
  }
}
