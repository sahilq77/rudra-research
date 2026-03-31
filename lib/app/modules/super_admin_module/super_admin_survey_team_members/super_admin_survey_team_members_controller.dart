import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rudra/app/data/models/survey_target/get_assign_survey_target_list_response.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../data/models/survey_target/survey_target_model.dart';
import '../../../data/network/exceptions.dart';
import '../../../data/network/networkcall.dart';
import '../../../data/urls.dart';
import '../../../utils/app_logger.dart';
import '../../../utils/app_utility.dart';
import '../../../widgets/app_snackbar_styles.dart';

class SuperAdminSurveyTeamMembersController extends GetxController {
  final RxList<SurveyTargetModel> executorList = <SurveyTargetModel>[].obs;
  final RxList<SurveyTargetModel> filteredExecutorList =
      <SurveyTargetModel>[].obs;
  final TextEditingController searchController = TextEditingController();
  final RxString searchQuery = ''.obs;
  Timer? _debounce;
  var isLoading = true.obs;
  var isSearching = false.obs;
  var errorMessage = ''.obs;
  RxInt offset = 0.obs;
  final int limit = 10;
  RxBool hasMoreData = true.obs;
  RxBool isLoadingMore = false.obs;
  RxBool hasPaginated = false.obs;
  final RxInt surveyTarget = 0.obs;
  final RxInt surveyCompleted = 0.obs;

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
    bool isSearch = false,
    required String surveyId,
  }) async {
    try {
      if (reset) {
        offset.value = 0;
        executorList.clear();
        filteredExecutorList.clear();
        hasMoreData.value = true;
        hasPaginated.value = false;
      }
      if (!hasMoreData.value && !reset) {
        AppLogger.d('No more data to fetch',
            tag: 'SuperAdminSurveyTeamMembersController');
        return;
      }

      if (isPagination) {
        isLoadingMore.value = true;
        hasPaginated.value = true;
      } else if (isSearch) {
        isSearching.value = true;
      } else {
        isLoading.value = true;
      }
      errorMessage.value = '';

      final jsonBody = {
        "survey_id": surveyId,
        "user_id": AppUtility.userID ?? "",
        "limit": limit.toString(),
        "offset": offset.value.toString(),
        "search": searchQuery.value,
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
      isSearching.value = false;
    }
  }

  Future<void> refreshData() async {
    await Future.delayed(const Duration(seconds: 1));
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
      fetchAssignSurveyTarget(
        context: Get.context!,
        reset: true,
        isSearch: true,
        surveyId: surveyId,
      );
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
          tag: 'SuperAdminSurveyTeamMembersController');
    } catch (e) {
      AppLogger.e('Error making call: $e',
          tag: 'SuperAdminSurveyTeamMembersController');
      Get.snackbar(
        'Error',
        'Failed to make call: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
