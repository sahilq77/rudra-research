import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rudra/app/data/models/executive/executive_model.dart';
import 'package:rudra/app/data/models/executive/get_executive_list.dart';
import 'package:rudra/app/data/models/executive/set_executive_response.dart';
import 'package:rudra/app/data/models/survey_target/survey_target_model.dart';
import 'package:rudra/app/data/network/exceptions.dart';
import 'package:rudra/app/data/network/networkcall.dart';
import 'package:rudra/app/data/urls.dart';
import 'package:rudra/app/utils/app_utility.dart';
import 'package:rudra/app/widgets/app_snackbar_styles.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/app_logger.dart';

class AssignExecutiveController extends GetxController {
  // -----  UI lists  -----
  final RxList<ExecutiveModel> executives = <ExecutiveModel>[].obs;
  final RxList<ExecutiveModel> filteredExecutives = <ExecutiveModel>[].obs;

  // -----  Pagination / raw data  -----
  final TextEditingController searchController = TextEditingController();
  var isLoading = true.obs;
  var executiveList = <ExecutiveData>[].obs;
  var errorMessage = ''.obs;
  RxInt offset = 0.obs;
  final int limit = 10;
  RxBool hasMoreData = true.obs;
  RxBool isLoadingMore = false.obs;

  // -----  Helper lists for pagination  -----
  final RxList<SurveyTargetModel> executorList = <SurveyTargetModel>[].obs;
  final RxList<SurveyTargetModel> filteredExecutorList =
      <SurveyTargetModel>[].obs;

  String surveyId = "";
  var isLoadings = false.obs;
  var errorMessages = ''.obs;
  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    surveyId = args?['survey_id']?.toString() ?? "";
    fetchAssignSurveyTarget(context: Get.context!, surveyId: surveyId);
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
        executiveList.clear();
        executorList.clear();
        filteredExecutorList.clear();
        hasMoreData.value = true;
      }
      if (!hasMoreData.value && !reset) {
        AppLogger.d('No more data to fetch');
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
        "survey_id": surveyId,
        "limit": limit.toString(),
        "offset": offset.value.toString(),
      };

      final response =
          await Networkcall().postMethod(
                Networkutility.getAllExecutiveApi,
                Networkutility.getAllExecutive,
                jsonEncode(jsonBody),
                context,
              )
              as List<GetExecutiveListResponse>?;

      if (response != null && response.isNotEmpty) {
        if (response[0].status == "true") {
          final surveys = response[0].data;

          // ----- Convert API model → SurveyTargetModel -----
          final List<SurveyTargetModel> newExecutors = surveys.executives.map((
            user,
          ) {
            return SurveyTargetModel(
              executorImage: '',
              id: user.userId,
              executorName: '${user.firstName} ${user.lastName}'.trim(),
              totalAssignedTarget: int.tryParse('0') ?? 0,
              todayCompletedTarget: int.tryParse('0') ?? 0,
              totalCompletedTarget: int.tryParse('0') ?? 0,
              isAssigned: false,
              currentCount: 0,
            );
          }).toList();

          // ----- Pagination handling -----
          executorList.addAll(newExecutors);
          filteredExecutorList.assignAll(executorList);

          if (newExecutors.length < limit) hasMoreData.value = false;
          offset.value += limit;

          // ----- Build UI model (ExecutiveModel) -----
          final List<ExecutiveModel> uiModels = surveys.executives.map((e) {
            return ExecutiveModel(
              id: e.userId,
              name: '${e.firstName} ${e.lastName}'.trim(),
              mobile: e.mobileNo,
              designation: e.role,
              isSelected: false,
            );
          }).toList();

          if (reset) {
            executives.assignAll(uiModels);
            filteredExecutives.assignAll(uiModels);
          } else {
            executives.addAll(uiModels);
            filteredExecutives.addAll(uiModels);
          }

          // Store raw data
          executiveList.add(
            ExecutiveData(
              surveyId: surveys.surveyId,
              teamId: surveys.teamId,
              executives: surveys.executives,
            ),
          );
        } else {
          hasMoreData.value = false;
          errorMessage.value = 'No data found';
          AppSnackbarStyles.showError(title: 'Error', message: 'No data found');
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

  // ---------- SEARCH ----------
  void searchExecutives(String query) {
    if (query.isEmpty) {
      filteredExecutives.assignAll(executives);
    } else {
      final lower = query.toLowerCase();
      filteredExecutives.assignAll(
        executives
            .where(
              (e) =>
                  e.name.toLowerCase().contains(lower) ||
                  e.mobile.contains(query) ||
                  e.designation.toLowerCase().contains(lower),
            )
            .toList(),
      );
    }
    AppLogger.d('Search: $query → ${filteredExecutives.length}');
  }

  // ---------- SELECTION ----------
  void toggleSelect(String id) {
    final idx = filteredExecutives.indexWhere((e) => e.id == id);
    if (idx != -1) {
      final exec = filteredExecutives[idx];
      filteredExecutives[idx] = exec.copyWith(isSelected: !exec.isSelected);
      filteredExecutives.refresh();
    }
  }

  // ---------- ASSIGN ----------
  // ---------- ASSIGN ----------
  Future<void> assignExecutives() async {
    try {
      isLoading.value = true;

      final selected = filteredExecutives.where((e) => e.isSelected).toList();
      if (selected.isEmpty) {
        Get.snackbar(
          'No Selection',
          'Please select at least one executive',
          backgroundColor: AppColors.primary,
          colorText: AppColors.white,
        );
        return;
      }

      // ---- Build payload for setExecutive API ----
      final List<Map<String, dynamic>> assignUsers = selected.map((exec) {
        return {
          "user_id": exec.id,
          // add any extra fields required by the API here
        };
      }).toList();

      // ---- Call the real API (setExecutive) ----
      final result = await setExecutive(userIds: assignUsers);

      if (result != null) {
        Get.snackbar(
          'Success',
          'Executives assigned successfully',
          backgroundColor: AppColors.greenColor,
          colorText: AppColors.white,
        );

        await refreshData(); // reload the list to reflect updated state
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to assign executives',
        backgroundColor: AppColors.primary,
        colorText: AppColors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshData() async {
    await fetchAssignSurveyTarget(
      context: Get.context!,
      surveyId: surveyId,
      reset: true,
    );
  }

  Future<String?> setExecutive({
    required List<Map<String, dynamic>> userIds,
  }) async {
    try {
      isLoadings.value = true;
      errorMessages.value = '';

      // ---- Build payload with team_id and array of user_ids ----
      final List<String> userIdList = userIds
          .map((user) => user['user_id'] as String)
          .toList();
      final jsonBody = {"team_id": AppUtility.teamId, "user_id": userIdList};

      final response =
          await Networkcall().postMethod(
                Networkutility.setExecutiveApi,
                Networkutility.setExecutive,
                jsonEncode(jsonBody),
                Get.context!,
              )
              as List<SetExecutiveResponse>?;

      if (response != null &&
          response.isNotEmpty &&
          response[0].status == "true") {
        AppSnackbarStyles.showSuccess(
          title: 'Success',
          message: "Targets assigned successfully",
        );
        return response[0].data?.teamId ?? '';
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
