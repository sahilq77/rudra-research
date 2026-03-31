import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/super_admin/get_all_survey_response.dart';
import '../../../data/network/exceptions.dart';
import '../../../data/network/networkcall.dart';
import '../../../data/urls.dart';
import '../../../utils/app_logger.dart';
import '../../../utils/app_utility.dart';
import '../../../widgets/app_snackbar_styles.dart';

class SuperAdminReportController extends GetxController {
  var isLoading = false.obs;
  var isSearching = false.obs;
  var isLoadingMore = false.obs;
  var allSurveys = <AllSurveyData>[].obs;
  var filteredSurveys = <AllSurveyData>[].obs;
  var searchQuery = ''.obs;
  var offset = 0.obs;
  var hasMoreData = true.obs;
  var hasPaginated = false.obs;
  final int limit = 10;
  Timer? _debounce;
  final TextEditingController searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchAllSurveys();
  }

  @override
  void onClose() {
    _debounce?.cancel();
    searchController.dispose();
    super.onClose();
  }

  Future<void> fetchAllSurveys({
    bool reset = false,
    bool isPagination = false,
    bool isSearch = false,
  }) async {
    try {
      if (reset) {
        offset.value = 0;
        allSurveys.clear();
        filteredSurveys.clear();
        hasMoreData.value = true;
        hasPaginated.value = false;
      }
      if (!hasMoreData.value && !reset) {
        AppLogger.d('No more data to fetch', tag: 'SuperAdminReportController');
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

      final jsonBody = {
        "user_id": AppUtility.userID,
        "limit": limit.toString(),
        "offset": offset.value.toString(),
        "search": searchQuery.value,
      };

      List<GetAllSurveyResponse>? response = (await Networkcall().postMethod(
        Networkutility.getAllSurveyApi,
        Networkutility.getAllSurvey,
        jsonEncode(jsonBody),
        Get.context!,
      )) as List<GetAllSurveyResponse>?;

      if (response != null && response.isNotEmpty) {
        if (response[0].status == "true") {
          final surveys = response[0].data;

          if (reset) {
            allSurveys.assignAll(surveys);
          } else {
            allSurveys.addAll(surveys);
          }

          filteredSurveys.assignAll(allSurveys);

          if (surveys.length < limit) {
            hasMoreData.value = false;
          }
          offset.value += limit;
        } else {
          hasMoreData.value = false;
          AppSnackbarStyles.showError(
            title: 'Error',
            message: 'No surveys found',
          );
        }
      } else {
        hasMoreData.value = false;
        AppSnackbarStyles.showError(
          title: 'Error',
          message: 'No response from server',
        );
      }
    } on NoInternetException catch (e) {
      AppSnackbarStyles.showError(title: 'Error', message: e.message);
    } on TimeoutException catch (e) {
      AppSnackbarStyles.showError(title: 'Error', message: e.message);
    } on HttpException catch (e) {
      AppSnackbarStyles.showError(
        title: 'Error',
        message: '${e.message} (Code: ${e.statusCode})',
      );
    } on ParseException catch (e) {
      AppSnackbarStyles.showError(title: 'Error', message: e.message);
    } catch (e) {
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

  void onSearchChanged(String query) {
    searchQuery.value = query;
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      fetchAllSurveys(reset: true, isSearch: true);
    });
  }

  Future<void> onRefresh() async {
    await Future.delayed(const Duration(seconds: 1));
    await fetchAllSurveys(reset: true);
  }

  void clearSearch() {
    _debounce?.cancel();
    searchController.clear();
    searchQuery.value = '';
    fetchAllSurveys(reset: true);
  }

  void onSurveyTap(AllSurveyData survey) {
    Get.toNamed(
      '/myreport-form',
      arguments: {
        'survey_id': survey.surveyId,
      },
    );
  }
}
