// lib/app/modules/assigned_survey_target/assigned_survey_target_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/survey_target/survey_target_model.dart';
import '../../utils/app_logger.dart';

class AssignedSurveyTargetController extends GetxController {
  final RxList<SurveyTargetModel> executorList = <SurveyTargetModel>[].obs;
  final RxList<SurveyTargetModel> filteredExecutorList =
      <SurveyTargetModel>[].obs;
  final TextEditingController searchController = TextEditingController();
  final RxBool isLoading = false.obs;
  final RxInt surveyTarget = 200.obs;
  final RxInt surveyCompleted = 50.obs;

  @override
  void onInit() {
    super.onInit();
    loadExecutors();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> loadExecutors() async {
    try {
      isLoading.value = true;
      await Future.delayed(const Duration(seconds: 1));

      // Mock data - Replace with actual API call
      executorList.value = [
        SurveyTargetModel(
          id: '1',
          executorName: 'Mallikarjun Pote',
          executorImage: '',
          isAssigned: false,
          todayCompletedTarget: 0,
          totalAssignedTarget: 0,
          totalCompletedTarget: 0,
          currentCount: 1,
        ),
        SurveyTargetModel(
          id: '2',
          executorName: 'Mallikarjun Pote',
          executorImage: '',
          isAssigned: false,
          todayCompletedTarget: 0,
          totalAssignedTarget: 0,
          totalCompletedTarget: 0,
          currentCount: 1,
        ),
        SurveyTargetModel(
          id: '3',
          executorName: 'Mallikarjun Pote',
          executorImage: '',
          isAssigned: false,
          todayCompletedTarget: 0,
          totalAssignedTarget: 0,
          totalCompletedTarget: 0,
          currentCount: 1,
        ),
      ];

      filteredExecutorList.value = executorList;
      isLoading.value = false;
      AppLogger.i('Executors loaded successfully',
          tag: 'AssignedSurveyTargetController');
    } catch (e) {
      isLoading.value = false;
      AppLogger.e('Error loading executors',
          error: e, tag: 'AssignedSurveyTargetController');
    }
  }

  void searchExecutors(String query) {
    if (query.isEmpty) {
      filteredExecutorList.value = executorList;
    } else {
      filteredExecutorList.value = executorList
          .where((executor) =>
              executor.executorName.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    AppLogger.d('Search query: $query, Results: ${filteredExecutorList.length}',
        tag: 'AssignedSurveyTargetController');
  }

  void incrementCount(int index) {
    final executor = filteredExecutorList[index];
    executor.currentCount++;
    filteredExecutorList[index] =
        executor.copyWith(currentCount: executor.currentCount);
    filteredExecutorList.refresh();
    AppLogger.d(
        'Incremented count for ${executor.executorName}: ${executor.currentCount}',
        tag: 'AssignedSurveyTargetController');
  }

  void decrementCount(int index) {
    final executor = filteredExecutorList[index];
    if (executor.currentCount > 0) {
      executor.currentCount--;
      filteredExecutorList[index] =
          executor.copyWith(currentCount: executor.currentCount);
      filteredExecutorList.refresh();
      AppLogger.d(
          'Decremented count for ${executor.executorName}: ${executor.currentCount}',
          tag: 'AssignedSurveyTargetController');
    }
  }

  void updateCount(int index, int count) {
    if (count >= 0) {
      final executor = filteredExecutorList[index];
      executor.currentCount = count;
      filteredExecutorList[index] = executor.copyWith(currentCount: count);
      filteredExecutorList.refresh();
      AppLogger.d('Updated count for ${executor.executorName}: $count',
          tag: 'AssignedSurveyTargetController');
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

      AppLogger.i('Targets assigned successfully',
          tag: 'AssignedSurveyTargetController');

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
      AppLogger.e('Error assigning targets',
          error: e, tag: 'AssignedSurveyTargetController');
      Get.snackbar(
        'Error',
        'Failed to assign targets',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> refreshData() async {
    await loadExecutors();
  }

  void makeCall(String executorId) {
    AppLogger.d('Making call to executor: $executorId',
        tag: 'AssignedSurveyTargetController');
    Get.snackbar(
      'Call',
      'Calling executor...',
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 2),
    );
  }
}
