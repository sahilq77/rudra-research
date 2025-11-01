// lib/app/modules/home/home_controller.dart
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rudra/app/data/network/exceptions.dart';
import 'package:rudra/app/data/network/networkcall.dart';
import 'package:rudra/app/data/urls.dart';
import 'package:rudra/app/widgets/app_snackbar_styles.dart'
    show AppSnackbarStyles;

import '../../../data/models/home/get_live_survey_response.dart';
import '../../../routes/app_routes.dart';
import '../../../utils/app_images.dart';
import '../../../utils/app_logger.dart';
import '../../../utils/app_utility.dart';

class HomeController extends GetxController {
  final RxInt currentIndex = 0.obs;
  final RxInt userRoleRx = 0.obs;
  var isLoading = true.obs;
  var liveSurveysList = <LiveSurveyData>[].obs;
  var errorMessage = ''.obs;
  RxInt offset = 0.obs;
  final int limit = 10;
  RxBool hasMoreData = true.obs;
  RxBool isLoadingMore = false.obs;
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

    fetchLiveSurveys(context: Get.context!);
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
      {
        'title': 'Number Of Surveys In Progress',
        'value': '1500',
        'color': const Color(0xFFD6EBFF), // Light Blue
        'imagePath': AppImages.surveyInProgress,
        'textColor': Colors.black,
      },
      {
        'title': 'Number Of Pending Surveys',
        'value': '500',
        'color': const Color(0xFFFFE9D5), // Light Orange
        'imagePath': AppImages.pendingSurvey,
        'textColor': Colors.black,
      },
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

  Future<void> fetchLiveSurveys({
    required BuildContext context,
    bool reset = false,
    bool isPagination = false,
    bool forceFetch = false,
  }) async {
    try {
      if (reset) {
        offset.value = 0;
        liveSurveysList.clear();
        hasMoreData.value = true;
      }
      if (!hasMoreData.value && !reset) {
        log('No more data to fetch');
        return;
      }

      if (isPagination) {
        isLoadingMore.value = true;
      } else {
        isLoading.value = true;
      }
      errorMessage.value = '';

      final jsonBody = {
        "team_id": AppUtility.teamId,
        // "role_id": AppUtility.roleId,
      };

      List<GetLiveSurveyListResponse>? response =
          (await Networkcall().postMethod(
                Networkutility.getLiveSurveyListApi,
                Networkutility.getLiveSurveyList,
                jsonEncode(jsonBody),
                context,
              ))
              as List<GetLiveSurveyListResponse>?;

      if (response != null && response.isNotEmpty) {
        if (response[0].status == "true") {
          final surveys = response[0].data;

          if (surveys.isEmpty || surveys.length < limit) {
            hasMoreData.value = false;
            log('No more data or fewer items received: ${surveys.length}');
          }
          for (var survey in surveys) {
            liveSurveysList.add(
              LiveSurveyData(
                surveyId: survey.surveyId,
                surveyTitle: survey.surveyTitle,
                districtName: survey.districtName,
                isLive: survey.isLive
              ),
            );
          }
          offset.value += limit;
          log('Offset updated to: ${offset.value}');
        } else {
          hasMoreData.value = false;
          errorMessage.value = 'No surveys found';
          log('API returned status false: No surveys found');
          AppSnackbarStyles.showError(
            title: 'Error',
            message: 'No surveys found',
          );
        }
      } else {
        hasMoreData.value = false;
        errorMessage.value = 'No response from server';
        log('No response from server');
        AppSnackbarStyles.showError(
          title: 'Error',
          message: 'No response from server',
        );
      }
    } on NoInternetException catch (e) {
      errorMessage.value = e.message;
      log('NoInternetException: ${e.message}');
      AppSnackbarStyles.showError(title: 'Error', message: e.message);
    } on TimeoutException catch (e) {
      errorMessage.value = e.message;
      log('TimeoutException: ${e.message}');
      AppSnackbarStyles.showError(title: 'Error', message: e.message);
    } on HttpException catch (e) {
      errorMessage.value = '${e.message} (Code: ${e.statusCode})';
      log('HttpException: ${e.message} (Code: ${e.statusCode})');
      AppSnackbarStyles.showError(
        title: 'Error',
        message: '${e.message} (Code: ${e.statusCode})',
      );
    } on ParseException catch (e) {
      errorMessage.value = e.message;
      log('ParseException: ${e.message}');
      AppSnackbarStyles.showError(title: 'Error', message: e.message);
    } catch (e) {
      errorMessage.value = 'Unexpected error: $e';
      log('Unexpected error: $e');
      AppSnackbarStyles.showError(
        title: 'Error',
        message: 'Unexpected error: $e',
      );
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  // Refresh data for pull-to-refresh
  Future<void> refresSurveyhData() async {
    await fetchLiveSurveys(context: Get.context!, reset: true);
  }

  String get userName {
    return 'Hi, ${AppUtility.fullName ?? ''}';
  }

  String get userRoleText {
    final roles = ['Manager', 'Executor', 'Validator'];
    return roles[userRole];
  }

  // Get bottom navigation items based on role
 
  // void changeTab(int index) {
  //   currentIndex.value = index;

  //   // Navigate based on tab selection
  //   if (isManager) {
  //     // Manager navigation (5 tabs)
  //     switch (index) {
  //       case 0:
  //         // Already on Home, do nothing
  //         AppLogger.d('Home tab selected', tag: 'HomeController');
  //         break;
  //       case 1:
  //         AppLogger.d('My Report tab selected', tag: 'HomeController');
  //         Get.toNamed(AppRoutes.myreport);
  //         // Get.snackbar(
  //         //   'Coming Soon',
  //         //   'My Report feature will be available soon',
  //         //   snackPosition: SnackPosition.TOP,
  //         //   duration: const Duration(seconds: 2),
  //         // );
  //         break;
  //       case 2:
  //         AppLogger.d('My Team tab selected', tag: 'HomeController');
  //         Get.toNamed(AppRoutes.myteam);
  //         // Get.snackbar(
  //         //   'Coming Soon',
  //         //   'My Team feature will be available soon',
  //         //   snackPosition: SnackPosition.TOP,
  //         //   duration: const Duration(seconds: 2),
  //         // );
  //         break;
  //       case 3:
  //         AppLogger.d('My Survey tab selected', tag: 'HomeController');
  //          Get.toNamed(AppRoutes.mySurvey);
  //         // Get.snackbar(
  //         //   'Coming Soon',
  //         //   'My Survey feature will be available soon',
  //         //   snackPosition: SnackPosition.TOP,
  //         //   duration: const Duration(seconds: 2),
  //         // );
  //         break;
  //       case 4:
  //         AppLogger.d('Profile tab selected', tag: 'HomeController');
  //         Get.toNamed(AppRoutes.profile);
  //         break;
  //     }
  //   } else {
  //     // Executive and Validator navigation (3 tabs)
  //     switch (index) {
  //       case 0:
  //         // Already on Home, do nothing
  //         AppLogger.d('Home tab selected', tag: 'HomeController');
  //         break;
  //       case 1:
  //         AppLogger.d('My Survey tab selected', tag: 'HomeController');
  //         Get.snackbar(
  //           'Coming Soon',
  //           'My Survey feature will be available soon',
  //           snackPosition: SnackPosition.TOP,
  //           duration: const Duration(seconds: 2),
  //         );
  //         break;
  //       case 2:
  //         AppLogger.d('Profile tab selected', tag: 'HomeController');
  //         Get.toNamed(AppRoutes.profile);
  //         break;
  //     }
  //   }
  // }

  void refreshData() {
    AppLogger.d('Refreshing home data', tag: 'HomeController');
    Get.snackbar(
      'Refresh',
      'Data refreshed successfully',
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 2),
    );
  }
}
