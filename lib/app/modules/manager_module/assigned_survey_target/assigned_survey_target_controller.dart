// lib/app/modules/assigned_survey_target/assigned_survey_target_controller.dart
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rudra/app/data/models/survey_target/get_assign_survey_target_list_response.dart';
import 'package:rudra/app/data/network/exceptions.dart';
import 'package:rudra/app/data/network/networkcall.dart';
import 'package:rudra/app/data/urls.dart';
import 'package:rudra/app/widgets/app_snackbar_styles.dart';

import '../../../data/models/survey_target/survey_target_model.dart';
import '../../../utils/app_logger.dart';

class AssignedSurveyTargetController extends GetxController {
  final RxList<SurveyTargetModel> executorList = <SurveyTargetModel>[].obs;
  final RxList<SurveyTargetModel> filteredExecutorList =
      <SurveyTargetModel>[].obs;
  final TextEditingController searchController = TextEditingController();
  var isLoading = true.obs;
  var assignSurveyTargetList = <AssignSurveyData>[].obs;
  var errorMessage = ''.obs;
  RxInt offset = 0.obs;
  final int limit = 10;
  RxBool hasMoreData = true.obs;
  RxBool isLoadingMore = false.obs;
  final RxInt surveyTarget = 200.obs;
  final RxInt surveyCompleted = 50.obs;

  @override
  void onInit() {
    super.onInit();

    fetchAssignSurveyTarget(context: Get.context!, surveyId: "2");
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> fetchAssignSurveyTarget({
    required BuildContext context,
    bool reset = false,
    bool isPagination = false,
    bool forceFetch = false,
    required String surveyId,
  }) async {
    try {
      if (reset) {
        offset.value = 0;
        assignSurveyTargetList.clear();
        executorList.clear();
        filteredExecutorList.clear();
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
        "survey_id": surveyId,
        "limit": limit.toString(),
        "offset": offset.value.toString(),
      };

      List<GetAssignSurveyTargetListResponse>? response =
          (await Networkcall().postMethod(
                Networkutility.getAssignSurveyTargetListApi,
                Networkutility.getAssignSurveyTargetList,
                jsonEncode(jsonBody),
                context,
              ))
              as List<GetAssignSurveyTargetListResponse>?;

      if (response != null && response.isNotEmpty) {
        if (response[0].status == "true") {
          final surveys = response[0].data;

          // Update summary
          surveyTarget.value = int.tryParse(surveys.totalSurveys) ?? 0;
          surveyCompleted.value = int.tryParse(surveys.completedSurveys) ?? 0;

          // Convert User -> SurveyTargetModel
          final List<SurveyTargetModel> newExecutors = surveys.users.map((
            user,
          ) {
            return SurveyTargetModel(
              executorImage: '',
              id: user.userId,
              executorName: '${user.firstName} ${user.lastName}'.trim(),
              totalAssignedTarget: int.tryParse(user.assignSurveyTarget) ?? 0,
              todayCompletedTarget:
                  int.tryParse(user.todayCompletedTarget) ?? 0,
              totalCompletedTarget:
                  int.tryParse(user.totalCompletedTarget) ?? 0,
              isAssigned: (int.tryParse(user.assignSurveyTarget) ?? 0) > 0,
              currentCount: 0, // New target to assign
            );
          }).toList();

          // Add to main list (for pagination)
          executorList.addAll(newExecutors);
          filteredExecutorList.assignAll(
            executorList,
          ); // Initial filter = full list

          // Update pagination
          if (newExecutors.length < limit) {
            hasMoreData.value = false;
          }
          offset.value += limit;

          // Store raw data (if needed elsewhere)
          assignSurveyTargetList.add(
            AssignSurveyData(
              surveyId: surveys.surveyId,
              surveyTitle: surveys.surveyTitle,
              totalSurveys: surveys.totalSurveys,
              completedSurveys: surveys.completedSurveys,
              users: surveys.users,
            ),
          );
        } else {
          hasMoreData.value = false;
          errorMessage.value = 'No surveys found';
          AppSnackbarStyles.showError(
            title: 'Error',
            message: 'No surveys found',
          );
        }
      } else {
        hasMoreData.value = false;
        errorMessage.value = 'No response from server';
        AppSnackbarStyles.showError(
          title: 'Error',
          message: 'No response from server',
        );
      }
    } on NoInternetException catch (e) {
      errorMessage.value = e.message;
      AppSnackbarStyles.showError(title: 'Error', message: e.message);
    } on TimeoutException catch (e) {
      errorMessage.value = e.message;
      AppSnackbarStyles.showError(title: 'Error', message: e.message);
    } on HttpException catch (e) {
      errorMessage.value = '${e.message} (Code: ${e.statusCode})';
      AppSnackbarStyles.showError(
        title: 'Error',
        message: '${e.message} (Code: ${e.statusCode})',
      );
    } on ParseException catch (e) {
      errorMessage.value = e.message;
      AppSnackbarStyles.showError(title: 'Error', message: e.message);
    } catch (e) {
      errorMessage.value = 'Unexpected error: $e';
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
  Future<void> refreshData() async {
    await fetchAssignSurveyTarget(
      context: Get.context!,
      reset: true,
      surveyId: "2",
    );
  }

  void searchExecutors(String query) {
    if (query.isEmpty) {
      filteredExecutorList.value = executorList;
    } else {
      filteredExecutorList.value = executorList
          .where(
            (executor) => executor.executorName.toLowerCase().contains(
              query.toLowerCase(),
            ),
          )
          .toList();
    }
    AppLogger.d(
      'Search query: $query, Results: ${filteredExecutorList.length}',
      tag: 'AssignedSurveyTargetController',
    );
  }

  void incrementCount(int index) {
    final executor = filteredExecutorList[index];
    executor.currentCount++;
    filteredExecutorList[index] = executor.copyWith(
      currentCount: executor.currentCount,
    );
    filteredExecutorList.refresh();
    AppLogger.d(
      'Incremented count for ${executor.executorName}: ${executor.currentCount}',
      tag: 'AssignedSurveyTargetController',
    );
  }

  void decrementCount(int index) {
    final executor = filteredExecutorList[index];
    if (executor.currentCount > 0) {
      executor.currentCount--;
      filteredExecutorList[index] = executor.copyWith(
        currentCount: executor.currentCount,
      );
      filteredExecutorList.refresh();
      AppLogger.d(
        'Decremented count for ${executor.executorName}: ${executor.currentCount}',
        tag: 'AssignedSurveyTargetController',
      );
    }
  }

  void updateCount(int index, int count) {
    if (count >= 0) {
      final executor = filteredExecutorList[index];
      executor.currentCount = count;
      filteredExecutorList[index] = executor.copyWith(currentCount: count);
      filteredExecutorList.refresh();
      AppLogger.d(
        'Updated count for ${executor.executorName}: $count',
        tag: 'AssignedSurveyTargetController',
      );
    }
  }

  Future<void> assignTarget() async {
    try {
      isLoading.value = true;

      // Filter executors with count > 0
      final executorsToAssign = filteredExecutorList
          .where((executor) => executor.currentCount > 0)
          .toList();

      if (executorsToAssign.isEmpty) {
        Get.snackbar(
          'No Assignment',
          'Please set target count for at least one executor',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        isLoading.value = false;
        return;
      }

      // TODO: Make API call to assign targets
      await Future.delayed(const Duration(seconds: 1));

      AppLogger.i(
        'Targets assigned successfully',
        tag: 'AssignedSurveyTargetController',
      );

      Get.snackbar(
        'Success',
        'Targets assigned successfully',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Refresh the list
      await refreshData();

      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      AppLogger.e(
        'Error assigning targets',
        error: e,
        tag: 'AssignedSurveyTargetController',
      );
      Get.snackbar(
        'Error',
        'Failed to assign targets',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void makeCall(String executorId) {
    AppLogger.d(
      'Making call to executor: $executorId',
      tag: 'AssignedSurveyTargetController',
    );
    Get.snackbar(
      'Call',
      'Calling executor...',
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 2),
    );
  }
}
