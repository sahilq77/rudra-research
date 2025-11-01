// lib/app/modules/manager_module/my_survey/my_survey_detail_list/my_survey_detail_list_controller.dart
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rudra/app/data/models/survey_target/get_assign_survey_target_list_response.dart';
import 'package:rudra/app/data/network/exceptions.dart';
import 'package:rudra/app/data/network/networkcall.dart';
import 'package:rudra/app/data/urls.dart';
import 'package:rudra/app/utils/app_logger.dart';
import 'package:rudra/app/widgets/app_snackbar_styles.dart';

import '../../../../data/models/survey_target/survey_target_model.dart';

class MySurveyDetailListController extends GetxController {
  final RxList<SurveyTargetModel> executorList = <SurveyTargetModel>[].obs;
  final RxList<SurveyTargetModel> filteredExecutorList = <SurveyTargetModel>[].obs;
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

  // Scroll controller for pagination
  final ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    surveyId = args?['survey_id']?.toString() ?? "";

    fetchAssignSurveyTarget(context: Get.context!, surveyId: surveyId);

    // Listen for scroll
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent * 0.9) {
        if (hasMoreData.value && !isLoadingMore.value) {
          loadMore(surveyId);
        }
      }
    });
  }

  @override
  void onClose() {
    searchController.dispose();
    scrollController.dispose();
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

          surveyTarget.value = int.tryParse(surveys.totalSurveys) ?? 0;
          surveyCompleted.value = int.tryParse(surveys.completedSurveys) ?? 0;

          final List<SurveyTargetModel> newExecutors = surveys.users.map((user) {
            return SurveyTargetModel(
              executorImage: '',
              id: user.userId,
              executorName: '${user.firstName} ${user.lastName}'.trim(),
              totalAssignedTarget: int.tryParse(user.assignSurveyTarget) ?? 0,
              todayCompletedTarget: int.tryParse(user.todayCompletedTarget) ?? 0,
              totalCompletedTarget: int.tryParse(user.totalCompletedTarget) ?? 0,
              isAssigned: (int.tryParse(user.assignSurveyTarget) ?? 0) > 0,
              currentCount: 0, // Make reactive
            );
          }).toList();

          executorList.addAll(newExecutors);
          filteredExecutorList.assignAll(executorList);

          if (newExecutors.length < limit) {
            hasMoreData.value = false;
          }
          offset.value += limit;

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

  void loadMore(String surveyId) {
    fetchAssignSurveyTarget(
      context: Get.context!,
      isPagination: true,
      surveyId: surveyId,
    );
  }

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
          .where((executor) =>
              executor.executorName.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
  }

  void makeCall(String executorId) {
    AppLogger.d('Making call to executor: $executorId',
        tag: 'MySurveyDetailListController');
    Get.snackbar(
      'Call',
      'Calling executor...',
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 2),
    );
  }

  // Counter methods
  
}