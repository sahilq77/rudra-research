// lib/app/modules/home/home_controller.dart
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rudra/app/data/local/survey_local_repository.dart';
import 'package:rudra/app/data/models/dashboard/get_dashboard_counter_response.dart';
import 'package:rudra/app/data/models/home/get_live_survey_response.dart';
import 'package:rudra/app/data/network/exceptions.dart';
import 'package:rudra/app/data/network/networkcall.dart';
import 'package:rudra/app/data/service/survey_data_service.dart';
import 'package:rudra/app/data/service/sync_service.dart';
import 'package:rudra/app/data/urls.dart';
import 'package:rudra/app/widgets/app_snackbar_styles.dart';
import 'package:rudra/app/widgets/connctivityservice.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/app_images.dart';
import '../../../utils/app_logger.dart';
import '../../../utils/app_utility.dart';

class ExecutiveHomeController extends GetxController {
  final SurveyLocalRepository _localRepo = SurveyLocalRepository();
  final ConnectivityService _connectivityService =
      Get.find<ConnectivityService>();
  final SurveyDataService _surveyDataService = Get.find<SurveyDataService>();
  final RxInt currentIndex = 0.obs;
  final RxInt userRoleRx = 0.obs;
  var isLoading = true.obs;
  var liveSurveysList = <LiveSurveyData>[].obs;
  var errorMessage = ''.obs;
  RxInt offset = 0.obs;
  final int limit = 10;
  RxBool hasMoreData = true.obs;
  RxBool isLoadingMore = false.obs;
  RxBool hasPaginated = false.obs;
  int get userRole => userRoleRx.value;

  // Dashboard counters
  RxString dailyAssignTarget = '0'.obs;
  RxString targetCompleted = '0'.obs;
  final RxInt pendingSubmissionsCount = 0.obs;

  Future<void> fetchPendingSubmissionsCount() async {
    try {
      final count = await _localRepo.getPendingSubmissionsCount();
      pendingSubmissionsCount.value = count;
      log('Pending submissions count: $count');
    } catch (e) {
      log('Error fetching pending submissions count: $e');
    }
  }

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
  }

  Future<void> _initializeData() async {
    await AppUtility.fetchAndUpdateTeamIds(Get.context!);
    fetchDashboardCounters(context: Get.context!);
    fetchLiveSurveys(context: Get.context!);
    fetchPendingSubmissionsCount();
  }

  // Get filtered dashboard stats based on role
  List<Map<String, dynamic>> get dashboardStats {
    final allStats = [
      {
        'title': 'Daily Assigned Target',
        'value': dailyAssignTarget.value,
        'color': AppColors.dailyTargetBackground,
        'borderColor': AppColors.dailyTargetBorder,
        'imagePath': AppImages.dailyTarget,
        'textColor': const Color(0xFF4A4A4A),
      },
      {
        'title': 'Assigned Target Completed',
        'value': targetCompleted.value,
        'color': const Color(0xFFE9F9EF),
        'borderColor': const Color(0xFFA3EFC0),
        'imagePath': AppImages.targetCompleted,
        'textColor': const Color(0xFF4A4A4A),
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

  Future<void> fetchLiveSurveys({
    required BuildContext context,
    bool reset = false,
    bool isPagination = false,
    bool forceFetch = false,
  }) async {
    try {
      // Check internet connectivity first
      final isConnected = await _connectivityService.checkConnectivity();

      if (reset) {
        offset.value = 0;
        liveSurveysList.clear();
        hasMoreData.value = true;
        // Only clear local cache on reset if user is online
        if (isConnected) {
          await _localRepo.clearSurveys();
          log('Online: Cleared local cache on reset');
        } else {
          log('Offline: Skipped clearing local cache on reset');
        }
      }
      if (!hasMoreData.value && !reset) {
        log('No more data to fetch');
        return;
      }

      if (isPagination) {
        isLoadingMore.value = true;
        hasPaginated.value = true;
      } else {
        isLoading.value = true;
      }
      errorMessage.value = '';

      if (!isConnected) {
        // Load from local database (offline mode)
        log('No internet, loading from local DB');
        await _loadSurveysFromLocal();
        return;
      }

      // ONLINE MODE: Fetch from API

      final jsonBody = {
        "team_id": AppUtility.teamId,
        "user_id": AppUtility.userID ?? "",
        "limit": limit.toString(),
        "offset": offset.value.toString(),
      };

      List<GetLiveSurveyListResponse>? response =
          (await Networkcall().postMethod(
        Networkutility.getLiveSurveyListApi,
        Networkutility.getLiveSurveyList,
        jsonEncode(jsonBody),
        context,
      )) as List<GetLiveSurveyListResponse>?;

      if (response != null && response.isNotEmpty) {
        if (response[0].status == "true") {
          final surveys = response[0].data;

          if (surveys.isEmpty || surveys.length < limit) {
            hasMoreData.value = false;
            log('No more data or fewer items received: ${surveys.length}');
          }

          // Add surveys to UI list
          for (var survey in surveys) {
            liveSurveysList.add(
              LiveSurveyData(
                surveyId: survey.surveyId,
                surveyTitle: survey.surveyTitle,
                districtName: survey.districtName,
                isLive: survey.isLive,
              ),
            );
          }

          // Save to local database for offline access
          await _saveSurveysToLocal(surveys);

          // Fetch complete survey data in background
          _fetchSurveyDataInBackground(context, surveys);

          offset.value += limit;
          log('Online: Added ${surveys.length} surveys to list, offset: ${offset.value}');
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
      await _loadSurveysFromLocal();
    } on TimeoutException catch (e) {
      errorMessage.value = e.message;
      log('TimeoutException: ${e.message}');
      await _loadSurveysFromLocal();
    } on HttpException catch (e) {
      errorMessage.value = '${e.message} (Code: ${e.statusCode})';
      log('HttpException: ${e.message} (Code: ${e.statusCode})');
      await _loadSurveysFromLocal();
    } on ParseException catch (e) {
      errorMessage.value = e.message;
      log('ParseException: ${e.message}');
      AppSnackbarStyles.showError(title: 'Error', message: e.message);
    } catch (e) {
      errorMessage.value = 'Unexpected error: $e';
      log('Unexpected error: $e');
      await _loadSurveysFromLocal();
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  Future<void> _saveSurveysToLocal(List<LiveSurveyData> surveys) async {
    try {
      final surveyMaps = surveys
          .map((s) => {
                'survey_id': s.surveyId,
                'survey_title': s.surveyTitle,
                'district_name': s.districtName,
                'is_live': s.isLive,
              })
          .toList();

      await _localRepo.saveSurveys(surveyMaps);
      log('Saved ${surveys.length} surveys to local DB');
    } catch (e) {
      log('Error saving surveys to local: $e');
    }
  }

  Future<void> _loadSurveysFromLocal() async {
    try {
      final localSurveys = await _localRepo.getSurveys();

      if (localSurveys.isEmpty) {
        AppSnackbarStyles.showInfo(
          title: 'Offline Mode',
          message: 'No cached surveys available',
        );
        return;
      }

      // Convert local data to LiveSurveyData objects
      final surveys = localSurveys
          .map((survey) => LiveSurveyData(
                surveyId: survey['survey_id'],
                surveyTitle: survey['survey_title'],
                districtName: survey['district_name'] ?? '',
                isLive: survey['is_live'] ?? '0',
              ))
          .toList();

      // Replace entire list with cached surveys (no duplicates)
      liveSurveysList.assignAll(surveys);

      hasMoreData.value = false;
      AppSnackbarStyles.showInfo(
        title: 'Offline Mode',
        message: 'Showing ${localSurveys.length} cached surveys',
      );
      log('Offline: Loaded ${localSurveys.length} surveys from local DB');
    } catch (e) {
      log('Error loading surveys from local: $e');
    }
  }

  void _fetchSurveyDataInBackground(
    BuildContext context,
    List<LiveSurveyData> surveys,
  ) {
    AppLogger.i(
      '🔄 Starting background fetch for ${surveys.length} surveys',
      tag: 'ExecutiveHomeController',
    );

    final surveyIds = surveys.map((s) => s.surveyId).toList();

    Future.microtask(() async {
      try {
        await _surveyDataService.fetchMultipleSurveysInParallel(
          surveyIds: surveyIds,
          context: context,
        );

        AppLogger.i(
          '✅ Background fetch completed for ${surveyIds.length} surveys',
          tag: 'ExecutiveHomeController',
        );
      } catch (e, stackTrace) {
        AppLogger.e(
          '❌ Background fetch failed',
          error: e,
          stackTrace: stackTrace,
          tag: 'ExecutiveHomeController',
        );
      }
    });

    AppLogger.i(
      '📤 Background fetch initiated (non-blocking)',
      tag: 'ExecutiveHomeController',
    );
  }

  bool isSurveyDataLoading(String surveyId) {
    return _surveyDataService.isSurveyLoading(surveyId);
  }

  Future<bool> isSurveyDataReady(String surveyId) async {
    return await _surveyDataService.isSurveyDataAvailable(surveyId);
  }

  Future<void> fetchDashboardCounters({required BuildContext context}) async {
    try {
      final jsonBody = {
        "user_id": AppUtility.userID ?? "",
        "role_type": AppUtility.userRole.toString(),
      };

      final response = await Networkcall().postMethod(
        Networkutility.getDashboardCounterApi,
        Networkutility.getDashboardCounter,
        jsonEncode(jsonBody),
        context,
      ) as List<GetDashboardCounterResponse>?;

      if (response != null &&
          response.isNotEmpty &&
          response[0].status == "true") {
        final data = response[0].data;
        dailyAssignTarget.value = data.dailyAssignTarget ?? '0';
        targetCompleted.value = data.targetCompleted ?? '0';
      }
    } catch (e) {
      log('Error fetching dashboard counters: $e');
    }
  }

  // Refresh data for pull-to-refresh
  Future<void> refresSurveyhData() async {
    await AppUtility.fetchAndUpdateTeamIds(Get.context!);
    // Trigger sync of pending submissions
    if (Get.isRegistered<SyncService>()) {
      final syncService = Get.find<SyncService>();
      final syncStarted = await syncService.forceSyncNow();
      if (!syncStarted) {
        AppSnackbarStyles.showInfo(
          title: 'Sync In Progress',
          message: 'Survey upload is already running in background',
        );
      }
    }
    await fetchDashboardCounters(context: Get.context!);
    await fetchLiveSurveys(context: Get.context!, reset: true);
    fetchPendingSubmissionsCount();
  }

  String get userName {
    return 'Hi, ${AppUtility.fullName ?? ''}';
  }

  String get userRoleText {
    final roles = ['Manager', 'Executor', 'Validator'];
    return roles[userRole];
  }
}
