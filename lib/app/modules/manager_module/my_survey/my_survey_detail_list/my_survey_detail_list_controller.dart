// lib/app/modules/manager_module/my_survey/my_survey_detail_list/my_survey_detail_list_controller.dart
import 'dart:async';
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
import 'package:url_launcher/url_launcher.dart';

import '../../../../data/models/survey_target/survey_target_model.dart';
import '../../../../utils/app_utility.dart';

class MySurveyDetailListController extends GetxController {
  final RxList<SurveyTargetModel> executorList = <SurveyTargetModel>[].obs;
  final RxList<SurveyTargetModel> filteredExecutorList =
      <SurveyTargetModel>[].obs;
  final TextEditingController searchController = TextEditingController();
  final RxString searchQuery = ''.obs;
  Timer? _debounce;
  var isLoading = true.obs;
  var assignSurveyTargetList = <AssignSurveyData>[].obs;
  var errorMessage = ''.obs;
  RxInt offset = 0.obs;
  final int limit = 10;
  RxBool hasMoreData = true.obs;
  RxBool isLoadingMore = false.obs;
  RxBool isSearching = false.obs;
  RxBool hasPaginated = false.obs;
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
    _debounce?.cancel();
    searchController.dispose();
    super.onClose();
  }

  Future<void> fetchAssignSurveyTarget({
    required BuildContext context,
    bool reset = false,
    bool isPagination = false,
    bool forceFetch = false,
    required String surveyId,
    bool isSearch = false,
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
        hasPaginated.value = true;
      } else {
        isLoading.value = true;
      }
      errorMessage.value = '';

      final jsonBody = {
        "survey_id": surveyId,
        "limit": limit.toString(),
        "offset": offset.value.toString(),
        "search": searchQuery.value,
        "user_id": AppUtility.userID,
      };

      List<GetAssignSurveyTargetListResponse>? response =
          (await Networkcall().postMethod(
        Networkutility.getAssignSurveyTargetListApi,
        Networkutility.getAssignSurveyTargetList,
        jsonEncode(jsonBody),
        context,
      )) as List<GetAssignSurveyTargetListResponse>?;

      if (response != null && response.isNotEmpty) {
        if (response[0].status == "true") {
          final surveys = response[0].data;

          surveyTarget.value = int.tryParse(surveys.totalSurveys) ?? 0;
          surveyCompleted.value = int.tryParse(surveys.completedSurveys) ?? 0;

          final List<SurveyTargetModel> newExecutors =
              surveys.users.map((user) {
            return SurveyTargetModel(
              executorImage: user.file,
              id: user.userId,
              executorName: '${user.firstName} ${user.lastName}'.trim(),
              mobileNumber: user.mobileNo,
              totalAssignedTarget:
                  int.tryParse(user.totalAssignSurveyTarget) ?? 0,
              todayCompletedTarget:
                  int.tryParse(user.todayCompletedTarget) ?? 0,
              totalCompletedTarget:
                  int.tryParse(user.totalCompletedTarget) ?? 0,
              isAssigned: (int.tryParse(user.totalAssignSurveyTarget) ?? 0) > 0,
              currentCount: 0,
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
              remaningSurveys: surveys.remaningSurveys,
              users: surveys.users,
            ),
          );
        } else {
          hasMoreData.value = false;
          executorList.clear();
          filteredExecutorList.clear();
          errorMessage.value = 'No surveys found';
          AppSnackbarStyles.showError(
            title: 'Error',
            message: 'No surveys found',
          );
        }
      } else {
        hasMoreData.value = false;
        executorList.clear();
        filteredExecutorList.clear();
        errorMessage.value = 'No response from server';
        AppSnackbarStyles.showError(
          title: 'Error',
          message: 'No response from server',
        );
      }
    } on NoInternetException catch (e) {
      executorList.clear();
      filteredExecutorList.clear();
      errorMessage.value = e.message;
      AppSnackbarStyles.showError(title: 'Error', message: e.message);
    } on TimeoutException catch (e) {
      executorList.clear();
      filteredExecutorList.clear();
      errorMessage.value = e.message;
      AppSnackbarStyles.showError(title: 'Error', message: e.message);
    } on HttpException catch (e) {
      executorList.clear();
      filteredExecutorList.clear();
      errorMessage.value = '${e.message} (Code: ${e.statusCode})';
      AppSnackbarStyles.showError(
        title: 'Error',
        message: '${e.message} (Code: ${e.statusCode})',
      );
    } on ParseException catch (e) {
      executorList.clear();
      filteredExecutorList.clear();
      errorMessage.value = e.message;
      AppSnackbarStyles.showError(title: 'Error', message: e.message);
    } catch (e) {
      executorList.clear();
      filteredExecutorList.clear();
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

  Future<void> refreshData() async {
    await fetchAssignSurveyTarget(
      context: Get.context!,
      reset: true,
      surveyId: surveyId,
    );
  }

  void searchExecutors(String query) {
    searchQuery.value = query;

    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      isSearching.value = true;
      fetchAssignSurveyTarget(
        context: Get.context!,
        reset: true,
        surveyId: surveyId,
        isSearch: true,
      ).then((_) {
        isSearching.value = false;
      });
    });
  }

  void clearSearch() {
    _debounce?.cancel();
    searchController.clear();
    searchQuery.value = '';
    fetchAssignSurveyTarget(
      context: Get.context!,
      reset: true,
      surveyId: surveyId,
    );
  }

  Future<void> makeCall(String executorId) async {
    try {
      final executor = executorList.firstWhere((e) => e.id == executorId);
      final phoneNumber = executor.mobileNumber.trim();

      if (phoneNumber.isEmpty) {
        Get.snackbar(
          'Error',
          'Phone number not available',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);

      await launchUrl(
        phoneUri,
        mode: LaunchMode.externalApplication,
      );

      AppLogger.d('Making call to: $phoneNumber',
          tag: 'MySurveyDetailListController');
    } catch (e) {
      AppLogger.e('Error making call: $e', tag: 'MySurveyDetailListController');
      Get.snackbar(
        'Error',
        'Failed to make call: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Counter methods
}
