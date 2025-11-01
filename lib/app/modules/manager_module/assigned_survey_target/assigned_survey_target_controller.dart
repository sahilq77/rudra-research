// lib/app/modules/assigned_survey_target/assigned_survey_target_controller.dart
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rudra/app/data/models/survey_target/get_assign_survey_target_list_response.dart';
import 'package:rudra/app/data/models/survey_target/set_assign_survey_target_response.dart';
import 'package:rudra/app/data/network/exceptions.dart';
import 'package:rudra/app/data/network/networkcall.dart';
import 'package:rudra/app/data/urls.dart';
import 'package:rudra/app/utils/app_utility.dart';
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
  final RxInt surveyTarget = 0.obs;
  final RxInt surveyCompleted = 0.obs;

  var isLoadings = false.obs;
  var errorMessages = ''.obs;
  String surveyId = "";

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    surveyId = args?['survey_id']?.toString() ?? "";

    fetchAssignSurveyTarget(context: Get.context!, surveyId: surveyId);
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
      surveyId: surveyId,
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

  // Helper – current sum of all currentCount fields
  int _totalAssigned() {
    return filteredExecutorList
        .fold(0, (sum, e) => sum + e.currentCount);
  }

  // Apply count with clamping to remaining target
  void _applyCount(int index, int newCount) {
    final currentOfThis = filteredExecutorList[index].currentCount;
    final remaining = surveyTarget.value - (_totalAssigned() - currentOfThis);
    final clamped = newCount.clamp(0, remaining);

    final executor = filteredExecutorList[index];
    executor.currentCount = clamped;
    filteredExecutorList[index] = executor.copyWith(currentCount: clamped);
    filteredExecutorList.refresh();

    if (clamped != newCount) {
      Get.snackbar(
        'Limit reached',
        'Cannot assign more than remaining target: $remaining',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    }

    AppLogger.d(
      'Applied count for ${executor.executorName}: $clamped (requested: $newCount)',
      tag: 'AssignedSurveyTargetController',
    );
  }

  void incrementCount(int index) {
    final executor = filteredExecutorList[index];
    _applyCount(index, executor.currentCount + 1);
  }

  void decrementCount(int index) {
    final executor = filteredExecutorList[index];
    if (executor.currentCount > 0) {
      _applyCount(index, executor.currentCount - 1);
    }
  }

  void updateCount(int index, int count) {
    _applyCount(index, count);
  }

  // ==================== NEW: Distribute Target Equally ====================
  void distributeTargetEqually() {
    final total = surveyTarget.value;
    final executors = filteredExecutorList;
    if (total == 0 || executors.isEmpty) return;

    final perExecutor = total ~/ executors.length;
    final remainder = total % executors.length;

    int sum = 0;
    for (int i = 0; i < executors.length; i++) {
      final extra = i < remainder ? 1 : 0;
      final newCount = perExecutor + extra;
      sum += newCount;

      final exec = executors[i];
      exec.currentCount = newCount;
      filteredExecutorList[i] = exec.copyWith(currentCount: newCount);
    }

    // Defensive: shave excess if math overflowed (should never happen)
    if (sum > total) {
      int excess = sum - total;
      for (int i = executors.length - 1; excess > 0 && i >= 0; i--) {
        final exec = filteredExecutorList[i];
        final shave = excess.clamp(0, exec.currentCount);
        exec.currentCount -= shave;
        filteredExecutorList[i] = exec.copyWith(currentCount: exec.currentCount);
        excess -= shave;
      }
    }

    filteredExecutorList.refresh();
    AppLogger.d(
      'Distributed $total targets → $perExecutor each + $remainder extra',
      tag: 'AssignedSurveyTargetController',
    );
  }

  // ==================== INTEGRATED assignTarget() ====================
  Future<void> assignTarget() async {
    try {
      isLoading.value = true;

      final executorsToAssign = filteredExecutorList
          .where((executor) => executor.currentCount > 0)
          .map((e) => {
                "user_id": e.id,
                "assign_target": e.currentCount.toString(),
              })
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

      final success = await setTarget(assignUsers: executorsToAssign);

      if (success != null) {
        Get.snackbar(
          'Success',
          'Targets assigned successfully',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        await refreshData();
      }
    } catch (e) {
        Get.snackbar(
          'Error',
          'Failed to assign targets',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      } finally {
        isLoading.value = false;
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

    // ==================== FIXED setTarget() ====================
    Future<String?> setTarget({
      required List<Map<String, dynamic>> assignUsers,
    }) async {
      try {
        isLoadings.value = true;
        errorMessages.value = '';

        final jsonBody = {
          "survey_id": surveyId,
          "assigned_by": AppUtility.userID,
          "team_id": AppUtility.teamId,
          "assign_users": assignUsers,
        };

        final response = await Networkcall().postMethod(
              Networkutility.setAssignSurveyTargetApi,
              Networkutility.setAssignSurveyTarget,
              jsonEncode(jsonBody),
              Get.context!,
            ) as List<SeAssignSurveyTargetResponse>?;

        if (response != null &&
            response.isNotEmpty &&
            response[0].status == "true") {
          AppSnackbarStyles.showSuccess(
            title: 'Success',
            message: "Targets assigned successfully",
          );
          return response[0].data?.surveyId ?? '';
        } else {
          final msg = response?[0].message ?? "Assign target failed";
          errorMessages.value = msg;
          AppSnackbarStyles.showError(title: 'Failed', message: msg);
          return null;
        }
      } on NoInternetException catch (e) {
        errorMessages.value = e.message;
        AppSnackbarStyles.showError(title: 'Error', message: e.message);
      } on TimeoutException catch (e) {
        errorMessages.value = e.message;
        AppSnackbarStyles.showError(title: 'Error', message: e.message);
      } on HttpException catch (e) {
        errorMessages.value = '${e.message} (Code: ${e.statusCode})';
        AppSnackbarStyles.showError(
          title: 'Error',
          message: '${e.message} (Code: ${e.statusCode})',
        );
      } on ParseException catch (e) {
        errorMessages.value = e.message;
        AppSnackbarStyles.showError(title: 'Error', message: e.message);
      } catch (e, s) {
        errorMessages.value = 'Unexpected error: $e';
        log('setTarget error: $e', stackTrace: s);
        AppSnackbarStyles.showError(title: 'Error', message: errorMessages.value);
      } finally {
        isLoadings.value = false;
      }
      return null;
    }
  }