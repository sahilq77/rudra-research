import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rudra/app/data/models/my_survey/get_my_survey_list_response.dart';
import 'package:rudra/app/data/models/my_survey/my_surevy_model.dart'
    show MySurveyModel;
import 'package:rudra/app/data/network/exceptions.dart';
import 'package:rudra/app/data/network/networkcall.dart';
import 'package:rudra/app/data/urls.dart';
import 'package:rudra/app/utils/app_utility.dart';
import 'package:rudra/app/widgets/app_snackbar_styles.dart';

import '../../../utils/app_logger.dart';

class MySurveyController extends GetxController {
  // ---- API data (raw) ----------------------------------------------------
  final RxList<MySurveyData> liveSurveysList = <MySurveyData>[].obs;
  final RxString errorMessage = ''.obs;
  final RxInt offset = 0.obs;
  final int limit = 10;
  final RxBool hasMoreData = true.obs;
  final RxBool isLoadingMore = false.obs;

  // ---- UI data -----------------------------------------------------------
  final RxList<MySurveyModel> mySurveyList = <MySurveyModel>[].obs;
  final RxList<MySurveyModel> filteredSurveyList = <MySurveyModel>[].obs;
  final TextEditingController searchController = TextEditingController();
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(() => searchSurveys(searchController.text));
    fetchMySurveys(context: Get.context!, reset: true); // initial load
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  // -----------------------------------------------------------------------
  // 1. FETCH + PAGINATION
  // -----------------------------------------------------------------------
  Future<void> fetchMySurveys({
    required BuildContext context,
    bool reset = false,
    bool isPagination = false,
    bool forceFetch = false,
  }) async {
    if (reset) {
      offset.value = 0;
      liveSurveysList.clear();
      mySurveyList.clear();
      hasMoreData.value = true;
    }

    if (!hasMoreData.value && !reset) return;

    if (isPagination) {
      isLoadingMore.value = true;
    } else {
      isLoading.value = true;
    }
    errorMessage.value = '';

    try {
      final jsonBody = {"team_id": AppUtility.teamId};

      final response =
          await Networkcall().postMethod(
                Networkutility.getMySurveyListApi,
                Networkutility.getMySurveyList,
                jsonEncode(jsonBody),
                context,
              )
              as List<GetMySurveyListResponse>?;

      if (response == null || response.isEmpty) {
        _handleError('No response from server');
        return;
      }

      final first = response.first;
      if (first.status != "true") {
        _handleError(first.message ?? 'No surveys found');
        return;
      }

      final List<MySurveyData> surveys = first.data;

      // ----- Convert API → UI model ---------------------------------------
      final List<MySurveyModel> uiModels = surveys
          .map(
            (e) => MySurveyModel(
              id: e.surveyId,
              surveyId: e.surveyId ?? '',
              title: e.surveyTitle ?? '',
              subtitle: e.districtName ?? '',
              responseCount: e.response?.toString() ?? '0',
              // add any extra fields you need here
            ),
          )
          .toList();

      if (reset) {
        mySurveyList.assignAll(uiModels);
      } else {
        mySurveyList.addAll(uiModels);
      }

      // ----- Pagination logic ---------------------------------------------
      if (surveys.length < limit) hasMoreData.value = false;
      offset.value += limit;

      // ----- Sync filtered list (keep current search) --------------------
      searchSurveys(searchController.text);
    } on NoInternetException catch (e) {
      _handleError(e.message);
    } on TimeoutException catch (e) {
      _handleError(e.message);
    } on HttpException catch (e) {
      _handleError('${e.message} (Code: ${e.statusCode})');
    } on ParseException catch (e) {
      _handleError(e.message);
    } catch (e) {
      _handleError('Unexpected error: $e');
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  void _handleError(String msg) {
    hasMoreData.value = false;
    errorMessage.value = msg;
    AppSnackbarStyles.showError(title: 'Error', message: msg);
    log(msg);
  }

  // -----------------------------------------------------------------------
  // 2. PULL-TO-REFRESH
  // -----------------------------------------------------------------------
  Future<void> refreshData() async =>
      fetchMySurveys(context: Get.context!, reset: true);

  // -----------------------------------------------------------------------
  // 3. SEARCH
  // -----------------------------------------------------------------------
  void searchSurveys(String query) {
    if (query.trim().isEmpty) {
      filteredSurveyList.assignAll(mySurveyList);
    } else {
      final lower = query.toLowerCase();
      filteredSurveyList.assignAll(
        mySurveyList
            .where(
              (s) =>
                  s.title.toLowerCase().contains(lower) ||
                  s.subtitle.toLowerCase().contains(lower),
            )
            .toList(),
      );
    }
    AppLogger.d(
      'Search query: $query, Results: ${filteredSurveyList.length}',
      tag: 'MySurveyController',
    );
  }

  // -----------------------------------------------------------------------
  // 4. LOAD MORE (infinite scroll)
  // -----------------------------------------------------------------------
  void loadMoreIfNeeded(int index) {
    if (isLoadingMore.value || !hasMoreData.value) return;
    if (index >= mySurveyList.length - 3) {
      fetchMySurveys(context: Get.context!, isPagination: true);
    }
  }
}
