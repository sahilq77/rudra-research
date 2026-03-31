import 'dart:async';
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
  final RxString searchQuery = ''.obs;
  Timer? _debounce;
  final RxBool isLoading = false.obs;
  final RxBool isSearching = false.obs;
  final RxBool hasPaginated = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchMySurveys(context: Get.context!, reset: true);
  }

  @override
  void onClose() {
    _debounce?.cancel();
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
    bool isSearch = false,
    bool forceFetch = false,
  }) async {
    if (reset) {
      offset.value = 0;
      liveSurveysList.clear();
      mySurveyList.clear();
      hasMoreData.value = true;
      hasPaginated.value = false;
    }

    if (!hasMoreData.value && !reset) return;

    if (isPagination) {
      isLoadingMore.value = true;
      hasPaginated.value = true;
    } else if (isSearch) {
      isSearching.value = true;
    } else {
      isLoading.value = true;
    }
    errorMessage.value = '';

    try {
      final jsonBody = {
        "team_id": AppUtility.teamId,
        "user_id": AppUtility.userID ?? "",
        "limit": limit.toString(),
        "offset": offset.value.toString(),
        "search": searchQuery.value,
      };

      final response = await Networkcall().postMethod(
        Networkutility.getMySurveyListApi,
        Networkutility.getMySurveyList,
        jsonEncode(jsonBody),
        context,
      ) as List<GetMySurveyListResponse>?;

      if (response == null || response.isEmpty) {
        _handleError('No response from server');
        return;
      }

      final first = response.first;
      if (first.status != "true") {
        hasMoreData.value = false;
        errorMessage.value = first.message ?? 'No surveys found';
        if (!isPagination) {
          mySurveyList.clear();
          filteredSurveyList.clear();
        }
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
              responseCount: e.response.toString() ?? '0',
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

      // ----- Sync filtered list --------------------
      filteredSurveyList.assignAll(mySurveyList);
    } on NoInternetException catch (e) {
      _handleError(e.message, isPagination: isPagination);
    } on TimeoutException catch (e) {
      _handleError(e.message, isPagination: isPagination);
    } on HttpException catch (e) {
      _handleError('${e.message} (Code: ${e.statusCode})',
          isPagination: isPagination);
    } on ParseException catch (e) {
      _handleError(e.message, isPagination: isPagination);
    } catch (e) {
      _handleError('Unexpected error: $e', isPagination: isPagination);
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
      isSearching.value = false;
    }
  }

  void _handleError(String msg, {bool isPagination = false}) {
    hasMoreData.value = false;
    errorMessage.value = msg;
    if (!isPagination) {
      mySurveyList.clear();
      filteredSurveyList.clear();
    }
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
    searchQuery.value = query;

    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      fetchMySurveys(context: Get.context!, reset: true, isSearch: true);
    });
  }

  void clearSearch() {
    _debounce?.cancel();
    searchController.clear();
    searchQuery.value = '';
    fetchMySurveys(context: Get.context!, reset: true);
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
