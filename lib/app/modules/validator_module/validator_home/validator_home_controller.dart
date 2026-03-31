// lib/app/modules/home/home_controller.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/validator/validator_survey_list_response.dart';
import '../../../data/models/validator/validator_survey_model.dart';
import '../../../data/network/exceptions.dart';
import '../../../data/network/networkcall.dart';
import '../../../data/urls.dart';
import '../../../routes/app_routes.dart';
import '../../../utils/app_images.dart';
import '../../../utils/app_logger.dart';
import '../../../utils/app_utility.dart';
import '../../../widgets/app_snackbar_styles.dart';

class ValidatorHomeController extends GetxController {
  final RxInt currentIndex = 0.obs;
  final RxInt userRoleRx = 0.obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasPaginated = false.obs;
  final RxBool hasMoreData = true.obs;
  final RxInt offset = 0.obs;
  final RxList<ValidatorSurveyModel> liveSurveys = <ValidatorSurveyModel>[].obs;
  final RxString errorMessage = ''.obs;
  final int limit = 10;
  final ScrollController scrollController = ScrollController();

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
    _initializeData();
    scrollController.addListener(_onScroll);
  }

  Future<void> _initializeData() async {
    await AppUtility.fetchAndUpdateTeamIds(Get.context!);
    _fetchValidatorSurveys(context: Get.context!);
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  void _onScroll() {
    if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent * 0.8 &&
        !isLoadingMore.value &&
        hasMoreData.value &&
        !isLoading.value) {
      loadMoreSurveys(context: Get.context!);
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

  Future<void> _fetchValidatorSurveys({
    required BuildContext context,
    bool reset = false,
    bool isPagination = false,
  }) async {
    try {
      if (reset) {
        offset.value = 0;
        liveSurveys.clear();
        hasMoreData.value = true;
      }
      if (!hasMoreData.value && !reset) {
        return;
      }

      if (isPagination) {
        isLoadingMore.value = true;
        hasPaginated.value = true;
      } else {
        isLoading.value = true;
      }
      errorMessage.value = '';

      final jsonBody = {
        "validator_id": AppUtility.userID ?? "",
        "limit": limit.toString(),
        "offset": offset.value.toString(),
        "user_id": AppUtility.userID,
      };

      List<ValidatorSurveyListResponse>? response =
          (await Networkcall().postMethod(
        Networkutility.getValidatorSurveyListApi,
        Networkutility.getValidatorSurveyList,
        jsonEncode(jsonBody),
        context,
      )) as List<ValidatorSurveyListResponse>?;

      if (response != null && response.isNotEmpty) {
        if (response[0].status == "true") {
          final surveyData = response[0].data;
          if (surveyData.isEmpty || surveyData.length < limit) {
            hasMoreData.value = false;
          } else {
            hasMoreData.value = true;
          }

          for (var survey in surveyData) {
            if (!liveSurveys.any(
              (existing) =>
                  existing.surveyId == survey.surveyInfo.surveyId &&
                  existing.surveyDate == survey.surveyInfo.surveyDate,
            )) {
              liveSurveys.add(
                ValidatorSurveyModel(
                  surveyId: survey.surveyInfo.surveyId,
                  title: survey.surveyInfo.surveyTitle,
                  subtitle: survey.teamInfo.teamName,
                  dateRange: survey.surveyInfo.surveyDateRange,
                  surveyCount: survey.surveyInfo.surveyCount,
                  surveyDate: survey.surveyInfo.surveyDate,
                  teamName: survey.teamInfo.teamName,
                  target: survey.teamInfo.target,
                  managerName: survey.teamInfo.managerName,
                  isLive: true,
                ),
              );
            }
          }

          if (surveyData.isNotEmpty) {
            offset.value += surveyData.length;
          }
        } else {
          hasMoreData.value = false;
          errorMessage.value = response[0].message;
        }
      } else {
        hasMoreData.value = false;
        errorMessage.value = 'No response from server';
      }
    } on NoInternetException catch (e) {
      errorMessage.value = e.message;
      AppLogger.e('NoInternetException: ${e.message}',
          tag: 'ValidatorHomeController', error: e);
    } on TimeoutException catch (e) {
      errorMessage.value = e.message;
      AppLogger.e('TimeoutException: ${e.message}',
          tag: 'ValidatorHomeController', error: e);
    } on HttpException catch (e) {
      errorMessage.value = '${e.message} (Code: ${e.statusCode})';
      AppLogger.e('HttpException: ${e.message}',
          tag: 'ValidatorHomeController', error: e);
    } on ParseException catch (e) {
      errorMessage.value = e.message;
      AppLogger.e('ParseException: ${e.message}',
          tag: 'ValidatorHomeController', error: e);
    } catch (e, stackTrace) {
      errorMessage.value = 'Unexpected error: $e';
      AppLogger.e('Unexpected error: $e',
          tag: 'ValidatorHomeController', error: e, stackTrace: stackTrace);
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  Future<void> loadMoreSurveys({required BuildContext context}) async {
    if (!isLoadingMore.value && hasMoreData.value && !isLoading.value) {
      await _fetchValidatorSurveys(context: context, isPagination: true);
    }
  }

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

  Future<void> refreshData() async {
    AppLogger.d('Refreshing home data', tag: 'ValidatorHomeController');
    await AppUtility.fetchAndUpdateTeamIds(Get.context!);
    await _fetchValidatorSurveys(context: Get.context!, reset: true);
    if (errorMessage.value.isEmpty) {
      AppSnackbarStyles.showSuccess(
        title: 'Success',
        message: 'Data refreshed successfully',
      );
    }
  }
}
