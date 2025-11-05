import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:rudra/app/data/models/my_survey/get_my_survey_submitted_response.dart';
import 'package:rudra/app/data/network/exceptions.dart';
import 'package:rudra/app/data/network/networkcall.dart';
import 'package:rudra/app/data/urls.dart';
import 'package:rudra/app/utils/app_logger.dart';
import 'package:rudra/app/utils/app_utility.dart';
import 'package:rudra/app/widgets/app_snackbar_styles.dart';

class MySurveyResponseController extends GetxController {
  // ---- API data (raw) ----------------------------------------------------
  final RxList<ResponseData> liveSurveysList = <ResponseData>[].obs;
  final RxString errorMessage = ''.obs;
  // Pagination
  final RxInt offset = 0.obs;
  final int limit = 10;
  final RxBool hasMoreData = true.obs;
  final RxBool isLoadingMore = false.obs;
  // ---- UI data -----------------------------------------------------------
  final RxList<MySurveyResponseModel> mySurveyList =
      <MySurveyResponseModel>[].obs;
  final RxList<MySurveyResponseModel> filteredSurveyList =
      <MySurveyResponseModel>[].obs;
  final TextEditingController searchController = TextEditingController();
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(() => searchSurveys(searchController.text));
    fetchMySurveyResponse(context: Get.context!, reset: true);
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  // -----------------------------------------------------------------------
  // 1. FETCH + PAGINATION
  // -----------------------------------------------------------------------
  Future<void> fetchMySurveyResponse({
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
    if (!hasMoreData.value && !reset && !forceFetch) return;
    if (isPagination) {
      isLoadingMore.value = true;
    } else {
      isLoading.value = true;
    }
    errorMessage.value = '';
    try {
      final jsonBody = {
        "survey_id": "1",
        "user_id": "3",
        "offset": offset.value.toString(),
        "limit": limit.toString(),
      };
      // API returns List<GetMySurveySubmittedResponse>
      final response =
          await Networkcall().postMethod(
                Networkutility.getMySurveySubmittedResponseListApi,
                Networkutility.getMySurveySubmittedResponseList,
                jsonEncode(jsonBody),
                context,
              )
              as List<GetMySurveySubmittedResponse>?;
      if (response == null || response.isEmpty) {
        _handleError('No response from server');
        return;
      }
      final List<MySurveyResponseModel> newUiModels = [];
      final List<ResponseData> newApiData = [];
      for (var apiResponse in response) {
        if (apiResponse.status != "true") {
          log('API returned status false: ${apiResponse.message}');
          continue; // Skip invalid entries
        }
        final data = apiResponse.data;
        if (data.surveyInfo.surveyId.isEmpty) continue;
        final uiModel = MySurveyResponseModel(
          id: data.surveyInfo.surveyId,
          surveyId: data.surveyInfo.surveyId,
          title: _getTitleFromResponseLists(data.responseLists),
          subtitle: data.surveySubmittedBy.name,
          submittedAt: _getLatestSubmittedAt(
            data.responseLists,
          ), // Fixed: Now shows actual date
        );
        newUiModels.add(uiModel);
        newApiData.add(data);
      }
      if (newUiModels.isEmpty) {
        _handleError('No valid survey data found');
        return;
      }
      // Update lists
      if (reset) {
        mySurveyList.assignAll(newUiModels);
        liveSurveysList.assignAll(newApiData);
      } else {
        mySurveyList.addAll(newUiModels);
        liveSurveysList.addAll(newApiData);
      }
      // Pagination logic
      hasMoreData.value = response.length >= limit;
      offset.value += limit;
      // Sync search
      searchSurveys(searchController.text);
    } on NoInternetException catch (e) {
      _handleError(e.message);
    } on TimeoutException catch (e) {
      _handleError(e.message);
    } on HttpException catch (e) {
      _handleError('${e.message} (Code: ${e.statusCode})');
    } on ParseException catch (e) {
      _handleError(e.message);
    } catch (e, stack) {
      _handleError('Unexpected error: $e');
      AppLogger.e('Stack trace: $stack', tag: 'MySurveyResponseController');
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  // Helper to extract title from responseLists
  String _getTitleFromResponseLists(List<List<ResponseList>> responseLists) {
    if (responseLists.isEmpty || responseLists.every((list) => list.isEmpty)) {
      return 'No Responses';
    }
    for (var list in responseLists) {
      if (list.isNotEmpty && list.first.name.isNotEmpty) {
        return list.first.name;
      }
    }
    return 'No Name';
  }

  // New Helper: Get the latest submitted_at from all responseLists
  String _getLatestSubmittedAt(List<List<ResponseList>> responseLists) {
    String latest = '';
    DateTime? latestDate;

    for (var list in responseLists) {
      for (var response in list) {
        if (response.submittedAt.isEmpty) continue;

        try {
          // Parse "2025-04-05 10:30:00" → make it ISO-like for DateTime.parse
          final cleaned = response.submittedAt.replaceAll(' ', 'T');
          final date = DateTime.parse(cleaned);
          if (latestDate == null || date.isAfter(latestDate)) {
            latestDate = date;
            latest = response.submittedAt;
          }
        } catch (e) {
          continue; // Skip invalid dates
        }
      }
    }

    if (latest.isEmpty) {
      final now = DateTime.now();
      return "${now.year}-${_twoDigits(now.month)}-${_twoDigits(now.day)} ${_twoDigits(now.hour)}:${_twoDigits(now.minute)}:00";
    }

    return latest;
  }

  // Helper for two-digit formatting
  String _twoDigits(int n) => n.toString().padLeft(2, '0');

  void _handleError(String msg) {
    hasMoreData.value = false;
    errorMessage.value = msg;
    AppSnackbarStyles.showError(title: 'Error', message: msg);
    log('MySurveyResponse Error: $msg');
  }

  // -----------------------------------------------------------------------
  // 2. PULL-TO-REFRESH
  // -----------------------------------------------------------------------
  Future<void> refreshData() async =>
      fetchMySurveyResponse(context: Get.context!, reset: true);

  // -----------------------------------------------------------------------
  // 3. SEARCH
  // -----------------------------------------------------------------------
  void searchSurveys(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      filteredSurveyList.assignAll(mySurveyList);
    } else {
      final lower = trimmed.toLowerCase();
      filteredSurveyList.assignAll(
        mySurveyList
            .where(
              (s) =>
                  s.title.toLowerCase().contains(lower) ||
                  s.subtitle.toLowerCase().contains(lower) ||
                  s.submittedAt.contains(lower),
            )
            .toList(),
      );
    }
    AppLogger.d(
      'Search query: "$query", Results: ${filteredSurveyList.length}',
      tag: 'MySurveyResponseController',
    );
  }

  // -----------------------------------------------------------------------
  // 4. LOAD MORE (infinite scroll)
  // -----------------------------------------------------------------------
  void loadMoreIfNeeded(int index) {
    if (isLoadingMore.value || !hasMoreData.value) return;
    if (index >= mySurveyList.length - 3) {
      fetchMySurveyResponse(context: Get.context!, isPagination: true);
    }
  }

  String formatDateTime(String dateTimeString) {
    try {
      // Parse the input string to DateTime
      DateTime dateTime = DateTime.parse(dateTimeString);

      // Define the desired format (e.g., "Sep 16, 2025 – 11:25 AM")
      final DateFormat formatter = DateFormat('MMM d, yyyy hh:mm');

      // Format the DateTime object
      return formatter.format(dateTime);
    } catch (e) {
      return 'Invalid date format';
    }
  }
}

// ---------------------------------------------------------------------------
// UI Model
// ---------------------------------------------------------------------------
class MySurveyResponseModel {
  final String id;
  final String title;
  final String subtitle;
  final String surveyId;
  final String submittedAt;

  MySurveyResponseModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.surveyId,
    required this.submittedAt,
  });

  MySurveyResponseModel copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? surveyId,
    String? responseCount,
  }) {
    return MySurveyResponseModel(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      surveyId: surveyId ?? this.surveyId,
      submittedAt: responseCount ?? this.submittedAt,
    );
  }

  @override
  String toString() {
    return 'MySurveyResponseModel(id: $id, title: $title, subtitle: $subtitle)';
  }
}
