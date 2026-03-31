import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rudra/app/data/models/my_survey/get_my_survey_submitted_response.dart';
import 'package:rudra/app/data/network/exceptions.dart';
import 'package:rudra/app/data/network/networkcall.dart';
import 'package:rudra/app/data/urls.dart';
import 'package:rudra/app/utils/app_logger.dart';
import 'package:rudra/app/widgets/app_snackbar_styles.dart';

import '../../../../../utils/app_utility.dart';

class MySurveyResponseController extends GetxController {
  final RxList<ResponseData> liveSurveysList = <ResponseData>[].obs;
  final RxString errorMessage = ''.obs;
  final RxInt offset = 0.obs;
  final int limit = 10;
  final RxBool hasMoreData = true.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool isSearching = false.obs;
  final RxBool hasPaginated = false.obs;
  final RxList<MySurveyResponseModel> mySurveyList =
      <MySurveyResponseModel>[].obs;
  final RxList<MySurveyResponseModel> filteredSurveyList =
      <MySurveyResponseModel>[].obs;
  final TextEditingController searchController = TextEditingController();
  final RxString searchQuery = ''.obs;
  Timer? _debounce;
  final RxBool isLoading = false.obs;
  late final String surveyId;
  late final String userId;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    surveyId = args['surveyId']?.toString() ?? '';
    userId = args['userId']?.toString() ?? '';
    fetchMySurveyResponse(context: Get.context!, reset: true);
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
  Future<void> fetchMySurveyResponse({
    required BuildContext context,
    bool reset = false,
    bool isPagination = false,
    bool forceFetch = false,
    bool isSearch = false,
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
      hasPaginated.value = true;
    } else {
      isLoading.value = true;
    }
    errorMessage.value = '';
    try {
      final jsonBody = {
        "survey_id": surveyId,
        "user_id": userId,
        "offset": offset.value.toString(),
        "limit": (limit + offset.value ~/ limit).toString(),
        "search": searchQuery.value,
        "logged_in_user_id": AppUtility.userID,
      };
      // API returns List<GetMySurveySubmittedResponse>
      final response = await Networkcall().postMethod(
        Networkutility.getMySurveySubmittedResponseListApi,
        Networkutility.getMySurveySubmittedResponseList,
        jsonEncode(jsonBody),
        context,
      ) as List<GetMySurveySubmittedResponse>?;
      if (response == null || response.isEmpty) {
        _handleError('No response from server');
        return;
      }
      final List<MySurveyResponseModel> newUiModels = [];
      final List<ResponseData> newApiData = [];
      for (var apiResponse in response) {
        if (apiResponse.status != "true") {
          log('API returned status false: ${apiResponse.message}');
          continue;
        }
        final data = apiResponse.data;
        if (data.surveyInfo.surveyId.isEmpty) continue;

        // Flatten all response lists to show each person as a separate card
        for (var person in data.responseLists) {
          final uiModel = MySurveyResponseModel(
            id: person.peopleDetailsId,
            surveyId: data.surveyInfo.surveyId,
            peopleDetailsId: person.peopleDetailsId,
            title: person.name.isEmpty ? 'No Name' : person.name,
            subtitle: data.surveySubmittedBy.name,
            submittedAt: person.submittedAt,
          );
          newUiModels.add(uiModel);
        }
        newApiData.add(data);
      }
      if (newUiModels.isEmpty) {
        if (!isPagination) {
          mySurveyList.clear();
          filteredSurveyList.clear();
          _handleError('No valid survey data found');
        } else {
          hasMoreData.value = false;
        }
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
      hasMoreData.value = newUiModels.length >= limit;
      offset.value += limit;
      // Sync filtered list
      filteredSurveyList.assignAll(mySurveyList);
    } on NoInternetException catch (e) {
      if (!isPagination) {
        mySurveyList.clear();
        filteredSurveyList.clear();
      }
      _handleError(e.message);
    } on TimeoutException catch (e) {
      if (!isPagination) {
        mySurveyList.clear();
        filteredSurveyList.clear();
      }
      _handleError(e.message);
    } on HttpException catch (e) {
      if (!isPagination) {
        mySurveyList.clear();
        filteredSurveyList.clear();
      }
      _handleError('${e.message} (Code: ${e.statusCode})');
    } on ParseException catch (e) {
      if (!isPagination) {
        mySurveyList.clear();
        filteredSurveyList.clear();
      }
      _handleError(e.message);
    } catch (e, stack) {
      if (!isPagination) {
        mySurveyList.clear();
        filteredSurveyList.clear();
      }
      _handleError('Unexpected error: $e');
      AppLogger.e('Stack trace: $stack', tag: 'MySurveyResponseController');
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

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
    searchQuery.value = query;

    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      isSearching.value = true;
      fetchMySurveyResponse(context: Get.context!, reset: true, isSearch: true)
          .then((_) {
        isSearching.value = false;
      });
    });
  }

  void clearSearch() {
    _debounce?.cancel();
    searchController.clear();
    searchQuery.value = '';
    fetchMySurveyResponse(context: Get.context!, reset: true);
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
    return dateTimeString;
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
  final String peopleDetailsId;

  MySurveyResponseModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.surveyId,
    required this.submittedAt,
    required this.peopleDetailsId,
  });

  MySurveyResponseModel copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? surveyId,
    String? responseCount,
    String? peopleDetailsId,
  }) {
    return MySurveyResponseModel(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      surveyId: surveyId ?? this.surveyId,
      submittedAt: responseCount ?? submittedAt,
      peopleDetailsId: peopleDetailsId ?? this.peopleDetailsId,
    );
  }

  @override
  String toString() {
    return 'MySurveyResponseModel(id: $id, title: $title, subtitle: $subtitle)';
  }
}
