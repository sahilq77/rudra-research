import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/super_admin/get_all_survey_response.dart';
import '../../../data/network/exceptions.dart';
import '../../../data/network/networkcall.dart';
import '../../../data/urls.dart';
import '../../../routes/app_routes.dart';
import '../../../utils/app_logger.dart';
import '../../../utils/app_utility.dart';
import '../../../widgets/app_snackbar_styles.dart';

class SuperAdminAllSurveysController extends GetxController {
  final RxList<AllSurveyData> allSurveysList = <AllSurveyData>[].obs;
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

  @override
  void onInit() {
    super.onInit();
    fetchAllSurveys(context: Get.context!);
  }

  @override
  void onClose() {
    _debounce?.cancel();
    searchController.dispose();
    super.onClose();
  }

  Future<void> fetchAllSurveys({
    required BuildContext context,
    bool reset = false,
    bool isPagination = false,
    bool isSearch = false,
  }) async {
    try {
      if (reset) {
        offset.value = 0;
        allSurveysList.clear();
        hasMoreData.value = true;
        hasPaginated.value = false;
      }
      if (!hasMoreData.value && !reset) {
        AppLogger.d('No more data to fetch',
            tag: 'SuperAdminAllSurveysController');
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
        "team_id": AppUtility.teamId ?? "",
        "user_id": AppUtility.userID ?? "",
        "limit": limit.toString(),
        "offset": offset.value.toString(),
        "search": searchQuery.value,
      };

      List<GetAllSurveyResponse>? response = (await Networkcall().postMethod(
        Networkutility.getAllSurveyApi,
        Networkutility.getAllSurvey,
        jsonEncode(jsonBody),
        context,
      )) as List<GetAllSurveyResponse>?;

      if (response != null && response.isNotEmpty) {
        if (response[0].status == "true") {
          final surveys = response[0].data;

          if (reset) {
            allSurveysList.assignAll(surveys);
          } else {
            allSurveysList.addAll(surveys);
          }

          if (surveys.length < limit) {
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
    await fetchAllSurveys(context: Get.context!, reset: true);
  }

  void searchSurveys(String query) {
    searchQuery.value = query;

    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      fetchAllSurveys(context: Get.context!, reset: true, isSearch: true);
    });
  }

  void clearSearch() {
    _debounce?.cancel();
    searchController.clear();
    searchQuery.value = '';
    fetchAllSurveys(context: Get.context!, reset: true);
  }

  void onViewDetailsTap(AllSurveyData survey) {
    AppLogger.d('Survey tapped: ${survey.surveyTitle}',
        tag: 'SuperAdminAllSurveysController');
    Get.toNamed(
      AppRoutes.superAdminSurveyTeamMembers,
      arguments: {
        'survey_id': survey.surveyId,
        'team_id': survey.teamId,
        'survey_title': survey.surveyTitle,
      },
    );
  }
}
